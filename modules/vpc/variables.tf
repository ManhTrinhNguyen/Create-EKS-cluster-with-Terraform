variable "eks-vpc-cidr" {
  type = string
  default = "10.0.0.0/16"
}

variable "eks-vpc-name" {
  default = "eks-vpc"
}

variable "eks-public-subnets-1" {
  default = "10.0.0.0/18"
}

variable "eks-public-subnets-2" {
  default = "10.0.64.0/18"
}

variable "eks-private-subnets-1" {
  default = "10.0.128.0/18"
}

variable "eks-private-subnets-2" {
  default = "10.0.192.0/18"
}