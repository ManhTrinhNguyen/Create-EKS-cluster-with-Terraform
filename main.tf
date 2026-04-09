resource "aws_vpc" "eks-vpc" {
    cidr_block = var.eks-vpc-cidr
    tags = {
        Name = var.eks-vpc-name
    } 
}

module "eks-vpc" {
  source = "./modules/vpc"
  eks-vpc-id = aws_vpc.eks-vpc.id
  eks-vpc-name = var.eks-vpc-name
  eks-public-subnets-1 = var.eks-public-subnets-1
  eks-public-subnets-2 = var.eks-public-subnets-2
  eks-private-subnets-1 = var.eks-private-subnets-1
  eks-private-subnets-2 = var.eks-private-subnets-2
}

module "eks-cluster" {
  source = "./modules/eks"
  eks-role = var.eks-role
  eks-managed-node-group-role = var.eks-managed-node-group-role
  cluster-autoscaler-role = var.cluster-autoscaler-role
  eks-cluster-name = var.eks-cluster-name
  eks-cluster-version  = var.eks-cluster-version
  eks-managed-node-group-name = var.eks-managed-node-group-name
  principal-arn = var.principal-arn
  region = var.region
  policy-arn = var.policy-arn
  private-subnet-1-id = module.eks-vpc.private-subnet-1.id 
  private-subnet-2-id = module.eks-vpc.private-subnet-2.id
}