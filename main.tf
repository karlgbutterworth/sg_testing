provider "aws" {
  region = "eu-west-2" 
}

# VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Subnets
resource "aws_subnet" "subnet_a" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-west-2a"
}

resource "aws_subnet" "subnet_b" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-west-2b"
}

resource "aws_subnet" "subnet_c" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "eu-west-2c"
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id
}

# Route Tables
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Associate Route Tables with Subnets
resource "aws_route_table_association" "subnet_a_association" {
  subnet_id      = aws_subnet.subnet_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "subnet_b_association" {
  subnet_id      = aws_subnet.subnet_b.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "subnet_c_association" {
  subnet_id      = aws_subnet.subnet_c.id
  route_table_id = aws_route_table.public_rt.id
}

# Transit Gateway
resource "aws_ec2_transit_gateway" "tgw" {}

# Transit Gateway Attachments
resource "aws_ec2_transit_gateway_vpc_attachment" "vpc_attachment" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = aws_vpc.main_vpc.id
  subnet_ids         = [
    aws_subnet.subnet_a.id,
    aws_subnet.subnet_b.id,
    aws_subnet.subnet_c.id,
  ]
}

# Security Group
resource "aws_security_group" "allow_ping" {
  vpc_id = aws_vpc.main_vpc.id
  name = "SG allow ICMP"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # Internal CIDR for ping
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["10.0.0.0/16"] # Internal CIDR for ping
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instances
resource "aws_instance" "instance_a" {
  ami           = "ami-07d1e0a32156d0d21"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.subnet_a.id
  security_groups = [aws_security_group.allow_ping.id]
  key_name        = "Zenbook"
  associate_public_ip_address = true
  lifecycle {                         
    ignore_changes = [security_groups]
  }                                   
}

resource "aws_instance" "instance_b" {
  ami           = "ami-07d1e0a32156d0d21" 
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.subnet_b.id
  security_groups = [aws_security_group.allow_ping.id]
  associate_public_ip_address = true
  key_name        = "Zenbook"
  lifecycle {                         
    ignore_changes = [security_groups]
  }                                   
}

resource "aws_instance" "instance_c" {
  ami           = "ami-07d1e0a32156d0d21" 
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.subnet_c.id
  security_groups = [aws_security_group.allow_ping.id]
  associate_public_ip_address = true
  key_name        = "Zenbook"
  lifecycle {                         
    ignore_changes = [security_groups]
  }                                   
}

output "public_ip_instance_a" {
  description = "The public IPs of the EC2 instance: instance_a"
  value       = aws_instance.instance_a.public_ip
}
output "public_ip_instance_b" {
  description = "The public IPs of the EC2 instance: instance_b"
  value       = aws_instance.instance_b.public_ip
}
output "public_ip_instance_c" {
  description = "The public IPs of the EC2 instance: instance_c"
  value       = aws_instance.instance_c.public_ip
}

