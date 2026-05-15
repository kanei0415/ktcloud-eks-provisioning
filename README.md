# ktcloud-eks-provisioning

Provision an AWS EKS cluster (hybrid: Fargate + managed nodegroup) with Terraform,
then bootstrap ArgoCD with Ansible and apply a root Application that pulls every
downstream workload from the manifest repo
[`kanei0415/ktcloud-k8s-argocd-manifest`](https://github.com/kanei0415/ktcloud-k8s-argocd-manifest).

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│  Terraform (terraform/)                                                 │
│    VPC (3 AZ, public + private + NAT)                                   │
│    EKS cluster `ktcloud-eks` (Kubernetes 1.31)                          │
│      ├─ Fargate profiles: kube-system, argocd                           │
│      ├─ Managed nodegroup: 2x t3.medium (stateful + DaemonSets)         │
│      └─ Addons: CoreDNS (Fargate-patched), kube-proxy, VPC CNI, EBS CSI │
│    IRSA role for EBS CSI driver                                         │
│    gp3 StorageClass (default)                                           │
└────────────────────────────────────┬────────────────────────────────────┘
                                     │ kubeconfig
┌────────────────────────────────────▼────────────────────────────────────┐
│  Ansible (ansible/)                                                     │
│    bootstrap.yml  →  refresh kubeconfig, verify cluster                 │
│    argocd.yml     →  Helm-install ArgoCD, apply root Application        │
└────────────────────────────────────┬────────────────────────────────────┘
                                     │ root-app
┌────────────────────────────────────▼────────────────────────────────────┐
│  ArgoCD (in cluster)                                                    │
│    root-app  →  Setup/  →  3 ApplicationSets                            │
│        Addons-app   →  Postgres, Redis, Kafka                           │
│        Apps-app     →  KTCloudMarket                                    │
│        Charts-app   →  Traefik                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

**Why hybrid compute?** Fargate cannot run DaemonSets and cannot use the EBS CSI
driver. The downstream manifest deploys Postgres/Kafka/Redis (need EBS-backed
PVCs) and Traefik. ArgoCD itself + `kube-system` run on Fargate; everything
heavier lands on the nodegroup. See `terraform/eks.tf`.

## Prerequisites

- AWS CLI configured with credentials for account `208876571165`
- `terraform >= 1.10` (S3-native locking needs ≥1.10)
- `kubectl`
- `helm` (only required if you want to run helm CLI manually; Ansible uses the
  `kubernetes.core.helm` module which calls helm internally)
- `ansible-core >= 2.16` with Python 3.10+
- The S3 state bucket `ktcloud-terraform-208876571165-ap-northeast-2-an` must
  already exist (the backend won't create it)

## One-shot end-to-end

```bash
make up
```

That runs: `tf-init` → `tf-apply` → `ansible-deps` → `ansible-all`.

## Step-by-step

```bash
# 1. Provision infrastructure
make tf-init
make tf-plan
make tf-apply

# 2. Configure cluster (kubeconfig + ArgoCD + root-app)
make ansible-deps
make ansible-all

# 3. Inspect
make argocd-password
make argocd-ui        # then open https://localhost:8080 (user: admin)
kubectl get applications -n argocd
kubectl get applicationsets -n argocd
```

## Project layout

```
terraform/
  versions.tf         provider + S3 backend pins
  variables.tf        region, project, cluster_version, sizing knobs
  locals.tf           subnet CIDR math, cluster_name
  providers.tf        aws / kubernetes / helm providers
  vpc.tf              terraform-aws-modules/vpc/aws
  eks.tf              terraform-aws-modules/eks/aws (Fargate + nodegroup + addons)
  storage.tf          gp3 default StorageClass, demote gp2
  outputs.tf          cluster endpoint, OIDC URL, kubeconfig command
  terraform.tfvars.example

ansible/
  ansible.cfg
  inventory.yml       localhost only (everything runs locally against the K8s API)
  requirements.yml    kubernetes.core, community.general, amazon.aws
  group_vars/all.yml  cluster name, region, ArgoCD chart version, manifest repo URL
  files/
    argocd-values.yaml  Helm values for ArgoCD (Fargate-friendly, no HA, no dex)
  templates/
    root-app.yaml.j2    The App-of-Apps root Application
  playbooks/
    bootstrap.yml      kubeconfig + sanity check
    argocd.yml         Helm install + apply root-app
  site.yml             both playbooks
```

## Configuration

Edit `terraform/variables.tf` defaults (or supply `terraform.tfvars`) to change
region, cluster name, sizing, etc.

Edit `ansible/group_vars/all.yml` to change ArgoCD chart version, manifest repo
URL, or the path the root Application targets within the manifest repo.

## Notes & caveats

- The Helm values file disables ArgoCD HA, dex (SSO), and notifications to keep
  the Fargate footprint small. Enable them per environment as needed.
- The ArgoCD server runs in insecure mode (HTTP) so a future Traefik IngressRoute
  can terminate TLS. Don't expose it publicly without an ingress in front.
- The root Application targets `path=Setup` with `directory.recurse=true`, so any
  new `*.yaml` added under `Setup/` in the manifest repo will be auto-applied.
- Stateful addons (Kafka/Postgres/Redis) land on the managed nodegroup via
  their charts' default `nodeSelector`/`tolerations` (none set) — Fargate
  profiles only select `kube-system` and `argocd` namespaces.

## Cleanup

```bash
make tf-destroy
```

ArgoCD-managed workloads in the cluster will be torn down along with the EKS
cluster. The S3 state bucket is **not** managed here and remains.
