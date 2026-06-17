module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"

  cluster_name    = local.cluster_name
  cluster_version = var.cluster_version

  cluster_endpoint_public_access = true

  enable_cluster_creator_admin_permissions = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_addons = {
    coredns = {
      most_recent = true
      configuration_values = jsonencode({
        computeType = "Fargate"
        resources = {
          limits   = { cpu = "0.25", memory = "256M" }
          requests = { cpu = "0.25", memory = "256M" }
        }
      })
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
      # Enable in-cluster NetworkPolicy enforcement. The MSA chart emits per-service
      # NetworkPolicies and the manifest repo ships a default-deny baseline; the VPC
      # CNI network-policy agent is what actually enforces them on EKS.
      configuration_values = jsonencode({
        enableNetworkPolicy = "true"
      })
    }
    aws-ebs-csi-driver = {
      most_recent              = true
      service_account_role_arn = module.ebs_csi_irsa.iam_role_arn
    }
  }

  fargate_profiles = {
    for ns in var.fargate_namespaces : ns => {
      name = "fp-${ns}"
      selectors = [
        { namespace = ns }
      ]
      subnet_ids = module.vpc.private_subnets
    }
  }

  eks_managed_node_groups = {
    workloads = {
      ami_type       = "AL2_x86_64"
      instance_types = var.nodegroup_instance_types
      capacity_type  = "ON_DEMAND"

      min_size     = var.nodegroup_min_size
      max_size     = var.nodegroup_max_size
      desired_size = var.nodegroup_desired_size

      labels = {
        role = "workloads"
      }

      # Cluster Autoscaler auto-discovery (platform/20-cluster-autoscaler).
      tags = {
        "k8s.io/cluster-autoscaler/enabled"               = "true"
        "k8s.io/cluster-autoscaler/${local.cluster_name}" = "owned"
      }
    }
  }
}

module "ebs_csi_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.48"

  role_name             = "${var.project}-ebs-csi-irsa"
  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
}

# IRSA for the Cluster Autoscaler addon (platform/20-cluster-autoscaler).
# The Helm values annotate the `kube-system:cluster-autoscaler` SA with this
# role's ARN (arn:aws:iam::<acct>:role/ktcloud-eks-cluster-autoscaler).
module "cluster_autoscaler_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.48"

  role_name                        = "${var.project}-cluster-autoscaler"
  attach_cluster_autoscaler_policy = true
  cluster_autoscaler_cluster_names = [local.cluster_name]

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:cluster-autoscaler"]
    }
  }
}

# IRSA for External Secrets Operator (platform/40-external-secrets).
# The Helm values annotate the `external-secrets:external-secrets` SA with this
# role's ARN (arn:aws:iam::<acct>:role/ktcloud-eks-external-secrets); the
# ClusterSecretStore `aws-secrets` then reads AWS Secrets Manager via JWT auth.
module "external_secrets_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.48"

  role_name                      = "${var.project}-external-secrets"
  attach_external_secrets_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["external-secrets:external-secrets"]
    }
  }
}
