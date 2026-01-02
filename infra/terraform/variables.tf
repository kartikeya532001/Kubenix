# -----------------------------
# AWS provider variables
# -----------------------------
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

# -----------------------------
# EKS cluster variables
# -----------------------------
variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "llm-cluster"
}

variable "cluster_version" {
  description = "Kubernetes version for EKS"
  type        = string
  default     = "1.29"
}

variable "cluster_service_cidr" {
  description = "Cluster service CIDR block (required for node groups)"
  type        = string
  default     = "172.20.0.0/16"
}

# -----------------------------
# VPC variables
# -----------------------------
variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "10.0.0.0/16"
}

# -----------------------------
# Node group / autoscaler variables
# -----------------------------
variable "cluster_autoscaler_cluster_ids" {
  description = "List of EKS cluster IDs for autoscaler"
  type        = list(string)
  default     = null
}

variable "cluster_autoscaler_cluster_names" {
  description = "List of EKS cluster names for autoscaler"
  type        = list(string)
  default     = ["llm-cluster"]
}

variable "create_node_groups" {
  description = "Whether to create node groups"
  type        = bool
  default     = true
}
