module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = "eks-cluster"
  kubernetes_version = "1.33"

  # Optional
  endpoint_public_access = true

  # Optional: Adds the current caller identity as an administrator via cluster access entry
  enable_cluster_creator_admin_permissions = true

  addons = {
    coredns                = {}
    eks-pod-identity-agent = {
      before_compute = true
    }
    kube-proxy             = {}
    vpc-cni                = {
      before_compute = true
    }
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    example = {
      instance_types = ["t3.medium"]

      min_size     = 1
      max_size     = 10
      desired_size = 1
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

### Fetch Auto Scaler Role ARN

data "aws_iam_role" "cluster-autoscaler-role" {
    name = "Pod-Identity-Cluster-Auto-Scaler"
}

### Create Pod Identity Association

resource "aws_eks_pod_identity_association" "cluster-autoscaler-pod-identity-association" {
    cluster_name = module.eks.cluster_name
    namespace = "kube-system"
    service_account = "cluster-autoscaler"
    role_arn = data.aws_iam_role.cluster-autoscaler-role.arn
}