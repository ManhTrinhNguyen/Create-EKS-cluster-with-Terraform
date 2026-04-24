output "vpc-obj" {
  value = aws_vpc.my-vpc
}

output "pl-subnet-1-ojb" {
  value = aws_subnet.my-public-subnet-1
}

output "pl-subnet-2-obj" {
  value = aws_subnet.my-public-subnet-2
}

output "pv-subnet-1-obj" {
  value = aws_subnet.my-private-subnet-1
}

output "pv-subnet-2-obj" {
  value = aws_subnet.my-private-subnet-2.id
}