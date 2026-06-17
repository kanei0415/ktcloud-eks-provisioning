# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo does

Provisions an AWS EKS cluster (hybrid: Fargate + managed nodegroup) with **Terraform**, then configures it with **Ansible** to install ArgoCD and apply a single root Application. That root Application pulls everything else from a separate manifest repo: <https://github.com/kanei0415/ktcloud-argocd-eks-manifest> (path `bootstrap/`, recursive). That repo follows the **app-of-apps** layout: `bootstrap/` fans out `projects/` (the `platform` + `market` AppProjects, sync-wave -10), a `platform/*` ApplicationSet (Istio, kube-prometheus-stack, EFK, Kafka/Strimzi, KEDA, Gatekeeper, Falco, Chaos Mesh, cluster-autoscaler, external-secrets, Traefik, …), and an `applications/` ApplicationSet (the 5 KTCloudMarket microservices + frontend, multi-source from the `ktcloud-msa-chart` + `ktcloud-msa-values` repos). The EBS CSI driver + `ebs-sc` StorageClass are supplied by Terraform here (not by the manifest repo).

Cluster identity: account `208876571165`, region `ap-northeast-2`, cluster name `ktcloud-eks`.

## The hybrid-compute split (load-bearing decision)

Fargate cannot run DaemonSets and cannot use the EBS CSI driver. The downstream manifest deploys StatefulSets that need EBS-backed PVCs (Postgres, Kafka, Redis), so a pure-Fargate cluster is not viable here.

Resolution: Fargate profiles select the `kube-system` and `argocd` namespaces only (see `var.fargate_namespaces` in `terraform/variables.tf`). Every other namespace lands on the managed nodegroup (`workloads`, 2x t3.medium). CoreDNS is patched via `cluster_addons.coredns.configuration_values.computeType = "Fargate"` so it can run on the kube-system Fargate profile without a nodegroup dependency.

When adding a new workload, decide compute target by namespace, not by labels. To run something on Fargate, add the namespace to `var.fargate_namespaces` and re-apply — don't try to relabel pods.

## Commands

End-to-end (provisioning + configuration):
```bash
make up                  # tf-init → tf-apply → ansible-deps → ansible-all
```

Terraform (run from repo root; the Makefile cd's into `terraform/`):
```bash
make tf-init             # one-time per checkout
make tf-plan             # writes tfplan
make tf-apply            # applies tfplan if present, else fresh apply
make tf-validate
make tf-fmt              # recursive
make tf-output
make tf-destroy
```

Ansible:
```bash
make ansible-deps        # installs collections (kubernetes.core, community.general, amazon.aws)
make ansible-bootstrap   # kubeconfig + helm v3 download + cluster reachability
make ansible-argocd      # helm install argo-cd + apply root Application
make ansible-all         # site.yml = bootstrap + argocd
```

Day-to-day:
```bash
make kubeconfig                            # aws eks update-kubeconfig
make argocd-password                       # initial admin password
make argocd-ui                             # port-forward https://localhost:8080
kubectl -n argocd get applications,applicationsets
```

Targeted Ansible reruns (skip `make`):
```bash
cd ansible && ansible-playbook playbooks/argocd.yml --tags <tag>      # if you add tags
ansible-playbook --syntax-check site.yml                              # quick lint
ansible-playbook -e helm_version=3.17.3 playbooks/bootstrap.yml       # override helm pin
```

## Architectural quirks worth knowing before editing

**Terraform state lives in S3 with native locking, not DynamoDB.** Backend config in `terraform/versions.tf` uses `use_lockfile = true` (Terraform ≥ 1.10). Do not add `dynamodb_table` — the choice is deliberate. Bucket: `ktcloud-terraform-208876571165-ap-northeast-2-an`, key `provisioning/terraform.tfstate`. The bucket is not managed by this repo and must already exist.

**`terraform/storage.tf` creates a default `gp3` StorageClass and demotes `gp2`.** The EBS CSI addon ships a default `gp2` StorageClass; we override it so PVCs land on cheaper/faster gp3. The `kubernetes_annotations` resource forces the demotion with `force = true` because the annotation is field-managed by the addon.

**Helm version pin (Ansible side).** `kubernetes.core` rejects Helm ≥ 4.0.0. To avoid forcing users to downgrade their global helm, `ansible/playbooks/bootstrap.yml` downloads Helm v3 (default 3.16.4, override with `-e helm_version=...`) into `ansible/bin/helm` and every `kubernetes.core.helm*` task passes `binary_path: "{{ helm_binary_path }}"`. The download uses `tar -xzf` directly, not `ansible.builtin.unarchive`, because the unarchive module rejects macOS's BSD tar.

**ArgoCD values gotcha.** Never leave a top-level key (e.g. `global:`) with no value in `ansible/files/argocd-values.yaml` — YAML parses it as `null`, which clobbers the chart's defaults under that key and breaks templating (specifically `.Values.global.image.tag` becomes a nil-pointer eval). If you need to override something under `global`, add real keys; otherwise omit the stanza entirely.

**ArgoCD runs in `server.insecure: "true"` mode.** The intent is that a future Traefik IngressRoute (deployed by the `Charts/Traefik` ApplicationSet from the manifest repo) terminates TLS in front of it. Do not expose argocd-server to the internet without an ingress + TLS in front.

**The root Application uses `directory.recurse: true` on path `Setup`.** Anything added under `Setup/` in the manifest repo will be auto-applied. This is `ansible/templates/root-app.yaml.j2` — change carefully.

## File layout cheat sheet

- `terraform/versions.tf` — provider pins + S3 backend (S3-native lock)
- `terraform/eks.tf` — EKS module, Fargate profiles, managed nodegroup (CA auto-discovery tags), addons (vpc-cni with `enableNetworkPolicy`), and IRSA roles: EBS CSI, cluster-autoscaler (`ktcloud-eks-cluster-autoscaler`), external-secrets (`ktcloud-eks-external-secrets`)
- `terraform/storage.tf` — gp3 default StorageClass + gp2 demotion
- `terraform/variables.tf` — every knob (region, project, cluster_version, sizing, `fargate_namespaces`)
- `ansible/group_vars/all.yml` — single source of truth for cluster name, region, helm pin, ArgoCD chart version, manifest repo URL
- `ansible/playbooks/bootstrap.yml` — kubeconfig + project-local Helm v3 pin
- `ansible/playbooks/argocd.yml` — Helm install + apply root Application
- `ansible/files/argocd-values.yaml` — chart values (Fargate-sized, no HA, no dex/notifications)
- `ansible/templates/root-app.yaml.j2` — the single Application resource that bootstraps everything

## Things this repo intentionally does NOT do

- **No AWS Load Balancer Controller, no Traefik install via Terraform/Ansible.** Traefik is expected to come from the downstream manifest repo via the `Charts/Traefik` ApplicationSet. If that chart needs an LB controller, install it as a separate step (likely a new playbook or a `helm_release` in Terraform).
- **No HA/dex/notifications on ArgoCD.** Disabled in `argocd-values.yaml` to keep the Fargate footprint small.
- **No state-bucket bootstrap.** The S3 bucket for Terraform state is assumed to exist; if not, create it out-of-band before `make tf-init`.
- **No CI.** All apply/plan flows are manual via `make`.
