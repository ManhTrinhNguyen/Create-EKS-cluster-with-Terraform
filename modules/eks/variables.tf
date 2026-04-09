variable "eks-role" {}

variable "eks-managed-node-group-role" {}

variable "cluster-autoscaler-role" {}

variable "eks-cluster-name" {
  default = "eks-cluster"
}

variable "eks-cluster-version" {
  default = "1.35"
}

variable "eks-managed-node-group-name" {
  default = "eks-managed-node-group"
}

variable "principal-arn" {
  default = "arn:aws:iam::660753258283:user/trinhnguyen"
}

variable "region" {
  default = "us-west-1" 
}

variable "policy-arn" {}

variable "private-subnet-1-id" {
  
}

variable "private-subnet-2-id" {
  
}