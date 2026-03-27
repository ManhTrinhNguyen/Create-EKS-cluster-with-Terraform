variable "eks-role" {
  default = "EKS-Role"
}

variable "eks-managed-node-group-role" {
  default = "EKS-Managed-Node-Group"
}

variable "cluster-autoscaler-role" {
  default = "Pod-Identity-Cluster-Auto-Scaler"
}

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
variable "policy-arn" {
  default = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
}