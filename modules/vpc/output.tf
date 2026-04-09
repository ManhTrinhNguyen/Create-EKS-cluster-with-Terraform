output "private-subnet-1" {
  value = aws_subnet.eks-private-subnet-1
}

output "private-subnet-2" {
  value = aws_subnet.eks-private-subnet-2
}

output "public-subnet-1" {
  value = aws_subnet.eks-public-subnet-1
}

output "public-subnet-2" {
  value = aws_subnet.eks-public-subnet-2
}