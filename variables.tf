variable "eks-vpc-cidr" {
  type = string
  default = "10.0.0.0/16"
}
variable "eks-role" {}
variable "eks-managed-node-group-role" {}
variable "cluster-autoscaler-role" {}
variable "eks-cluster-name" {}
variable "eks-cluster-version" {}
variable "eks-managed-node-group-name" {}
variable "principal-arn" {}
variable "region" {}
variable "policy-arn" {}    
variable "eks-vpc-name" {}
variable "eks-public-subnets-1" {}
variable "eks-public-subnets-2" {}
variable "eks-private-subnets-1" {}
variable "eks-private-subnets-2" {}