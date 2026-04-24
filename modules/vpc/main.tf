
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

resource "aws_eip" "nat-ip" {
    domain = "vpc"

    tags = {
      Name = "${var.vpc-name}-eip"
    }
} 

resource "aws_nat_gateway" "my-nat" {
    allocation_id = aws_eip.nat-ip.id
    subnet_id = aws_subnet.my-public-subnet-1.id

    tags = {
      Name = "${var.vpc-name}-NAT-PL1"
    }
}

resource "aws_route_table" "my-public-rtb" {
    vpc_id = aws_vpc.my-vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.my-igw.id
    }


    tags = {
      Name = "${var.vpc-name}-my-public-rtb"
    }
}

resource "aws_route_table_association" "my-public-rtb-association-1" {
    subnet_id = aws_subnet.my-public-subnet-1.id
    route_table_id = aws_route_table.my-public-rtb.id
}

resource "aws_route_table_association" "my-public-rtb-association-2" {
    subnet_id = aws_subnet.my-public-subnet-2.id
    route_table_id = aws_route_table.my-public-rtb.id
}

resource "aws_route_table" "my-private-rtb" {
    vpc_id = aws_vpc.my-vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_nat_gateway.my-nat.id
    }

    tags = {
      Name = "${var.vpc-name}-my-private-rtb"
    }
}

resource "aws_route_table_association" "my-private-rtb-association-1" {
  subnet_id = aws_subnet.my-private-subnet-1.id
  route_table_id = aws_route_table.my-private-rtb.id
}

resource "aws_route_table_association" "my-private-rtb-association-2" {
  subnet_id = aws_subnet.my-private-subnet-2.id
  route_table_id = aws_route_table.my-private-rtb.id
}