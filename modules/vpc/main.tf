resource "aws_vpc" "eks-vpc" {
    cidr_block = variable.eks-vpc-cidr
    tags = {
        Name = var.eks-vpc-name
    } 
}

resource "aws_subnet" "eks-public-subnet-1" {
    vpc_id = aws_vpc.eks-vpc.id
    cidr_block = var.eks-public-subnets-1
    availability_zone = "us-west-1a"

    tags = {
        Name = "eks-public-subnet-1"
    }
}

resource "aws_subnet" "eks-public-subnet-2" {
    vpc_id = aws_vpc.eks-vpc.id
    cidr_block = var.eks-public-subnets-2
    availability_zone = "us-west-1b"
    tags = {
        Name = "eks-public-subnet-2"
    }
}

resource "aws_subnet" "eks-private-subnet-1" {
    vpc_id = aws_vpc.eks-vpc.id
    cidr_block = var.eks-private-subnets-1
    availability_zone = "us-west-1a"
    tags = {
        Name = "eks-private-subnet-1"
    }
}

resource "aws_subnet" "eks-private-subnet-2" {
    vpc_id = aws_vpc.eks-vpc.id
    cidr_block = var.eks-private-subnets-2
    availability_zone = "us-west-1b"
    tags = {
        Name = "eks-private-subnet-2"
    }
}

### Create Internet Gateway 

resource "aws_internet_gateway" "eks-igw" {
    vpc_id = aws_vpc.eks-vpc.id
    tags = {
        Name = "eks-igw"
    }
}


### Create Elastic IP for NAT Gateway

resource "aws_eip" "nat-eip-1" {
  domain = "vpc"
}

resource "aws_eip" "nat-eip-2" {
  domain = "vpc"
}

### Create NAT Gateway

resource "aws_nat_gateway" "eks-nat-gateway-1" {
  allocation_id = aws_eip.nat-eip-1.id
  subnet_id     = aws_subnet.eks-public-subnet-1.id 
  tags = {
    Name = "gw NAT public subnet 1"
  }
}

resource "aws_nat_gateway" "eks-nat-gateway-2" {
  allocation_id = aws_eip.nat-eip-2.id
  subnet_id     = aws_subnet.eks-public-subnet-2.id

  tags = {
    Name = "gw NAT public subnet 2"
  }
}

### Create Route Table for Public Subnets

resource "aws_route_table" "eks-rtb-public" {
  vpc_id = aws_vpc.eks-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks-igw.id
  }

  tags = {
    Name = "rtb public"
  }
}

### Associate Route Table with Public Subnets

resource "aws_route_table_association" "eks-rtb-public-association-1" {
  subnet_id = aws_subnet.eks-public-subnet-1.id
  route_table_id = aws_route_table.eks-rtb-public.id
}   

resource "aws_route_table_association" "eks-rtb-public-association-2" {
  subnet_id = aws_subnet.eks-public-subnet-2.id
  route_table_id = aws_route_table.eks-rtb-public.id
}

### Create Route Table for Private Subnets

resource "aws_route_table" "eks-rtb-private-1" {
  vpc_id = aws_vpc.eks-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.eks-nat-gateway-1.id
  }

  tags = {
    Name = "rtb private 1"
  }
}

resource "aws_route_table" "eks-rtb-private-2" {
  vpc_id = aws_vpc.eks-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.eks-nat-gateway-2.id
  }

  tags = {
    Name = "rtb private 2"
  }
}

### Associate Route Table with Private Subnets

resource "aws_route_table_association" "eks-rtb-private-association-1" {
  subnet_id = aws_subnet.eks-private-subnet-1.id
  route_table_id = aws_route_table.eks-rtb-private-1.id
}

resource "aws_route_table_association" "eks-rtb-private-association-2" {
  subnet_id = aws_subnet.eks-private-subnet-2.id
  route_table_id = aws_route_table.eks-rtb-private-2.id
}

