module "my-vpc" {
  source = "./modules/vpc"
  
  vpc-cidr = var.vpc-cidr
  vpc-name = var.vpc-name
  public-subnets = var.public-subnets
  private-subnets = var.private-subnets
}

output "vpc-obj" {
  value = module.my-vpc.vpc-obj
}