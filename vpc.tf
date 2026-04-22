variable "vpc-cidr" {}
variable "vpc-name" {}
variable "public-subnets" {
  type = list()
}

variable "private-subnets" {
  type = list()
}


resource "aws_vpc" "my-vpc" {
    cidr_block = var.vpc-cidr
    tags = {
        Name = var.vpc-name
    } 
}

resource "aws_subnet" "my-public-subnet-1" {
    vpc_id = aws_vpc.my-vpc.id 
    cidr_block = var.public-subnets[0]
    availability_zone = "us-west-1a"
    tags = {
      Name = "${var.vpc-name}-public-subnet-1" 
     }
}

resource "aws_subnet" "my-public-subnet-2" {
    vpc_id = aws_vpc.my-vpc.id 
    cidr_block = var.public-subnets[1]
    availability_zone = "us-west-1b"
    tags = {
      Name = "${var.vpc-name}-public-subnet-2" 
     }
}

resource "aws_subnet" "my-private-subnet-1"{
    vpc_id = aws_vpc.my-vpc.id
    cidr_block = var.private-subnets[0]
    availability_zone = "us-west-1a"
    tags = {
        Name = "${var.vpc-name}-private-subnet-1"
    }
}

resource "aws_subnet" "my-private-subnet-2" {
    vpc_id = aws_vpc.my-vpc.id 
    cidr_block = var.private-subnets[1]
    availability_zone = "us-west-1b"
    tags = {
        Name = "${var.vpc-name}-private-subnet-2"
    }
}

resource "aws_internet_gateway" "my-igw" {
  vpc_id = aws_vpc.my-vpc.id

  tags = {
    Name = "${var.vpc-name}-IGW"
  }
}

resource "aws_route_table" "my-public-rtb-1" {
    vpc_id = aws_vpc.my-vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.my-igw
    }

    route {
        cidr_block = var.vpc-cidr
        gateway_id = "local"
    }
}

resource "aws_route_table_association" "my-public-rtb-association-1" {
    subnet_id = aws_subnet.my-public-subnet-1.id
    route_table_id = aws_route_table.my-public-rtb-1.id
}