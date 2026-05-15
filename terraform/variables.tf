variable "region" {
  description = "AWS region for all resources."
  type        = string
  default     = "ap-northeast-2"
}

variable "project" {
  description = "Short project identifier used as a resource name prefix."
  type        = string
  default     = "ktcloud-eks"
}

variable "cluster_version" {
  description = "EKS Kubernetes minor version."
  type        = string
  default     = "1.31"
}

variable "vpc_cidr" {
  description = "CIDR block for the project VPC."
  type        = string
  default     = "10.40.0.0/16"
}

variable "azs" {
  description = "Availability zones to spread subnets across. Three AZs are required by EKS Fargate."
  type        = list(string)
  default     = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]
}

variable "fargate_namespaces" {
  description = "Namespaces whose pods schedule on Fargate."
  type        = list(string)
  default     = ["kube-system", "argocd"]
}

variable "nodegroup_instance_types" {
  description = "Instance types for the managed nodegroup that runs stateful workloads and DaemonSets."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "nodegroup_min_size" {
  type    = number
  default = 2
}

variable "nodegroup_max_size" {
  type    = number
  default = 4
}

variable "nodegroup_desired_size" {
  type    = number
  default = 2
}

variable "tags" {
  description = "Tags applied to every resource."
  type        = map(string)
  default = {
    Project   = "ktcloud-eks"
    ManagedBy = "terraform"
  }
}
