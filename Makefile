.DEFAULT_GOAL := help

REGION       ?= ap-northeast-2
CLUSTER_NAME ?= ktcloud-eks
TF_DIR       := terraform
ANSIBLE_DIR  := ansible

.PHONY: help
help:
	@awk 'BEGIN {FS = ":.*##"} /^[a-zA-Z_-]+:.*##/ {printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.PHONY: tf-init
tf-init:
	cd $(TF_DIR) && terraform init

.PHONY: tf-fmt
tf-fmt:
	cd $(TF_DIR) && terraform fmt -recursive

.PHONY: tf-validate
tf-validate:
	cd $(TF_DIR) && terraform validate

.PHONY: tf-plan
tf-plan:
	cd $(TF_DIR) && terraform plan -out tfplan

.PHONY: tf-apply
tf-apply:
	cd $(TF_DIR) && (test -f tfplan && terraform apply tfplan || terraform apply)

.PHONY: tf-destroy
tf-destroy:
	cd $(TF_DIR) && terraform destroy

.PHONY: tf-output
tf-output:
	cd $(TF_DIR) && terraform output

.PHONY: kubeconfig
kubeconfig:
	aws eks update-kubeconfig --name $(CLUSTER_NAME) --region $(REGION)

.PHONY: ansible-deps
ansible-deps:
	cd $(ANSIBLE_DIR) && ansible-galaxy collection install -r requirements.yml

.PHONY: ansible-bootstrap
ansible-bootstrap:
	cd $(ANSIBLE_DIR) && ansible-playbook playbooks/bootstrap.yml

.PHONY: ansible-argocd
ansible-argocd:
	cd $(ANSIBLE_DIR) && ansible-playbook playbooks/argocd.yml

.PHONY: ansible-all
ansible-all:
	cd $(ANSIBLE_DIR) && ansible-playbook site.yml

.PHONY: up
up: tf-init tf-apply ansible-deps ansible-all ## Provision and configure end-to-end

.PHONY: argocd-password
argocd-password:
	kubectl -n argocd get secret argocd-initial-admin-secret \
		-o jsonpath='{.data.password}' | base64 -d ; echo

.PHONY: argocd-ui
argocd-ui:
	kubectl -n argocd port-forward svc/argocd-server 8080:443
