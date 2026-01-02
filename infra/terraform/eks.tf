module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.0.2"

  name                = var.cluster_name
  kubernetes_version  = var.cluster_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  enable_irsa = true

  endpoint_public_access = true
  enable_cluster_creator_admin_permissions = true


  addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  tags = {
    Environment = "prod"
    Terraform   = "true"
  }
}
