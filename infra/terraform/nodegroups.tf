#################################################
# Terraform-managed SSH key for EKS nodes
#################################################

resource "tls_private_key" "eks_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "eks_key" {
  key_name   = "llm-eks-key"
  public_key = tls_private_key.eks_key.public_key_openssh
}

output "eks_private_key_pem" {
  value     = tls_private_key.eks_key.private_key_pem
  sensitive = true
}

#################################################
# system Node Group (ON_DEMAND)
#################################################

module "system_node" {
  source  = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"
  version = "21.0.2" 

  cluster_name = module.eks.cluster_name
  name         = "system_node"
  cluster_service_cidr = var.cluster_service_cidr


  subnet_ids     = module.vpc.private_subnets
  instance_types = ["t3.small"]
  capacity_type  = "ON_DEMAND"
  ami_type = "AL2023_x86_64_STANDARD"
  kubernetes_version  = var.cluster_version

  min_size     = 1
  max_size     = 1
  desired_size = 1
  disk_size    = 15

  labels = {
    node-role = "system_node"
    pool      = "system"
  }

  iam_role_additional_policies = {
    WorkerNodePolicy = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    ECRReadOnly      = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    CNI              = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    SSM              = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  tags = {
    Name = "system_node"
  }
}

#################################################
# Warm Node Group (ON_DEMAND)
#################################################

module "warm_node_group" {
  source  = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"
  version = "21.0.2" 

  cluster_name = module.eks.cluster_name
  name         = "cpu-warm"
  cluster_service_cidr = var.cluster_service_cidr


  subnet_ids     = module.vpc.private_subnets
  instance_types = ["m7i-flex.large"]
  capacity_type  = "ON_DEMAND"
  ami_type = "AL2023_x86_64_STANDARD"
  kubernetes_version  = var.cluster_version

  min_size     = 1
  max_size     = 1
  desired_size = 1
  disk_size    = 100

  labels = {
    node-role = "cpu"
    pool      = "warm"
  }

  taints = {
    spot = {
      key    = "warm-pool"
      value  = "true"
      effect = "NO_SCHEDULE"
    }
  }

  iam_role_additional_policies = {
    WorkerNodePolicy = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    ECRReadOnly      = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    CNI              = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    SSM              = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  tags = {
    Name = "cpu-warm-workers"
  }
}

#################################################
# Spot Node Group (SPOT)
#################################################

module "spot_node_group" {
  source  = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"
  version = "21.0.2" 

  cluster_name = module.eks.cluster_name
  name         = "cpu-spot"
  cluster_service_cidr = var.cluster_service_cidr


  subnet_ids     = module.vpc.private_subnets
  instance_types = ["m7i-flex.large"]
  capacity_type  = "SPOT"
  ami_type = "AL2023_x86_64_STANDARD"
  kubernetes_version  = var.cluster_version 



  min_size     = 0
  max_size     = 3
  desired_size = 0
  disk_size    = 100

  labels = {
    node-role = "cpu"
    pool      = "spot"
  }

  taints = {
    spot = {
      key    = "spot"
      value  = "true"
      effect = "PREFER_NO_SCHEDULE"
    }
  }



  iam_role_additional_policies = {
    WorkerNodePolicy = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    ECRReadOnly      = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    CNI              = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    SSM              = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  tags = {
    Name = "cpu-spot-workers"
  }
}