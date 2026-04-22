variable "vpc-cidr" {}
variable "private-subnets" {
  type = list(string)  
}
variable "public-subnets" {
  type = list(string)
}

### Automatically get AZs in the region

data "aws_availability_zones" "available" {
  state = "available"
}

### Create VPC and Subnets

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "eks-vpc"
  cidr = var.vpc-cidr

  azs             = data.aws_availability_zones.available.names
  private_subnets = var.private-subnets
  public_subnets  = var.public-subnets

  enable_nat_gateway = true
  single_nat_gateway = true
  enable_dns_hostnames = true


  tags = {
    "kubernetes.io/cluster/eks-cluster" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }
}