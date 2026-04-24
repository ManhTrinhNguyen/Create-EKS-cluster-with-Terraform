resource "aws_security_group" "my-ec2-SG" {
  name = "my-ec2-SG"
  vpc_id = module.my-vpc.vpc-obj.id

  tags = {
    Name = "my-ec2-SG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "my-ec2-SG-ingress-rule-22" {
  security_group_id = aws_security_group.my-ec2-SG.id 
  cidr_ipv4 = "0.0.0.0/0"
  from_port = 22
  ip_protocol = "tcp"
  to_port = 22
}

resource "aws_vpc_security_group_ingress_rule" "my-ec2-SG-ingress-rule-80" {
  security_group_id = aws_security_group.my-ec2-SG.id
  cidr_ipv4 = "0.0.0.0/0"
  from_port = 80
  ip_protocol = "tcp"
  to_port = 80
}

resource "aws_vpc_security_group_ingress_rule" "my-ec2-SG-ingress-rule-443" {
  security_group_id = aws_security_group.my-ec2-SG.id
  cidr_ipv4 = "0.0.0.0/0"
  from_port = 443
  ip_protocol = "tcp"
  to_port = 443
}

resource "aws_vpc_security_group_egress_rule" "my-ec2-SG-egress-all" {
  security_group_id = aws_security_group.my-ec2-SG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_instance" "my-ec2" {
    associate_public_ip_address = true
    instance_type = "t2.micro"
    ami = "ami-02671e999eec7752f"
    key_name = "redhat"
    subnet_id = module.my-vpc.pl-subnet-1-ojb.id
    vpc_security_group_ids = [aws_security_group.my-ec2-SG.id]
    
    tags = {
      Name = "my-instance"
    }
}