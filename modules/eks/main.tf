### Fetch created IAM roles for EKS cluster and node group

data "aws_iam_role" "eks-role" {
    name = var.eks-role
}

data "aws_iam_role" "eks-managed-node-group-role" {
    name = var.eks-managed-node-group-role
}

data "aws_iam_role" "cluster-autoscaler-role" {
    name = var.cluster-autoscaler-role
}

### Create EKS Cluster

resource "aws_eks_cluster" "eks-cluster" {
    name = var.cluster-autoscaler-role
    role_arn = data.aws_iam_role.eks-role.arn
    version = var.eks-cluster-version

    vpc_config {
        endpoint_private_access = true
        endpoint_public_access  = true

        subnet_ids = [
            aws_subnet.eks-private-subnet-1.id,
            aws_subnet.eks-private-subnet-2.id
        ]
    }

    access_config {
      authentication_mode = "API"
    }



    tags = {
        Name = "eks-cluster"
    }
}

### Create EKS Managed Node Group
resource "aws_eks_node_group" "eks-managed-node-group" {
    cluster_name = aws_eks_cluster.eks-cluster.name
    node_group_name = var.eks.managed-node-group-name

    node_role_arn = data.aws_iam_role.eks-managed-node-group-role.arn
    
    subnet_ids = [
        aws_subnet.eks-private-subnet-1.id,
        aws_subnet.eks-private-subnet-2.id
    ]

    scaling_config {
        desired_size = 2
        max_size = 3
        min_size = 1
    }

    update_config {
      max_unavailable = 1
    }
}

### Create Addon 

resource "aws_eks_addon" "vpc-cni" {
  cluster_name = aws_eks_cluster.eks-cluster.name
  addon_name   = "vpc-cni"  
}

resource "aws_eks_addon" "core-dns" {
  cluster_name = aws_eks_cluster.eks-cluster.name
  addon_name   = "coredns"
}

resource "aws_eks_addon" "kube-proxy" {
  cluster_name = aws_eks_cluster.eks-cluster.name
  addon_name   = "kube-proxy"
}

resource "aws_eks_addon" "metrics-server" {
  cluster_name = aws_eks_cluster.eks-cluster.name
  addon_name   = "metrics-server"
}

resource "aws_eks_addon" "pod-identity-agent" {
  cluster_name = aws_eks_cluster.eks-cluster.name
  addon_name   = "eks-pod-identity-agent"
}

### Create Access Entry 
resource "aws_eks_access_entry" "eks-access-entry" {
    cluster_name = aws_eks_cluster.eks-cluster.name 
    principal_arn = var.principal-arn
    region = var.region
}

### Create Access Policy Association 

resource "aws_eks_access_policy_association" "eks-access-policy-association" {
    cluster_name = aws_eks_cluster.eks-cluster.name
    principal_arn = var.principal-arn
    policy_arn    = var.policy-arn

    access_scope {
        type = "cluster"
    }
}

### Create Pod Identity Association
resource "aws_eks_pod_identity_association" "cluster-autoscaler-pod-identity-association" {
    cluster_name = aws_eks_cluster.eks-cluster.name
    namespace = "kube-system"
    service_account = "cluster-autoscaler"
    role_arn = data.aws_iam_role.cluster-autoscaler-role.arn
}