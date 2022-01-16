provider "aws" {
    region = lookup(var.awslocation, "region")
}

# create a vpc

resource "aws_vpc" "prod-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
      Name = lookup(var.awsprojectcontent, "vpc-name")
  }
}

# create internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.prod-vpc.id
}

# create a custom route table

resource "aws_route_table" "prod-route-table" {
  vpc_id = aws_vpc.prod-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "prod"
  }
}
  # create a subnet

  resource "aws_subnet" "subnet-1" {
  vpc_id     = aws_vpc.prod-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = lookup(var.awslocation, "az")

  tags = {
    Name = lookup(var.awsprojectcontent, "subnet-name")
  }
}

#create a subnet with route table

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.prod-route-table.id
}

# create a security group to allow port 22, 80 and 443

resource "aws_security_group" "allow_traffic" {
  name        = "allow_traffic"
  description = "Allow web traffic"
  vpc_id      = aws_vpc.prod-vpc.id

  ingress {
    description = "HTTPS"
    from_port   = lookup(var.openPortNum, "HTTPS")
    to_port     = lookup(var.openPortNum, "HTTPS")
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

ingress {
    description = "HTTP"
    from_port   = lookup(var.openPortNum, "HTTP")
    to_port     = lookup(var.openPortNum, "HTTP")
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "jenkins"
    from_port   = lookup(var.openPortNum, "JENKINS")
    to_port     = lookup(var.openPortNum, "JENKINS")
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = lookup(var.openPortNum, "SSH")
    to_port     = lookup(var.openPortNum, "SSH")
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = lookup(var.awsprojectcontent, "sgrp-name")
  }
}

# create a network interface 

resource "aws_network_interface" "web-server-nic" {
  subnet_id       = aws_subnet.subnet-1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_traffic.id]
}

#Assign an elastic ip to the network interface

resource "aws_eip" "two" {
  vpc                       = true
  network_interface         = aws_network_interface.web-server-nic.id
  associate_with_private_ip = "10.0.1.50"
  depends_on                = [aws_internet_gateway.gw]
}

# create Ubuntu server and install/enable apche2

resource "aws_instance" "test-server" {
  ami           =  lookup(var.awsprojectcontent, "image-name")
  instance_type = lookup(var.awsprojectcontent, "instance-type")
  availability_zone= lookup(var.awslocation, "az")
  key_name = lookup(var.awsprojectcontent, "key-name")
  

  network_interface  {
      device_index = 0
      network_interface_id = aws_network_interface.web-server-nic.id

  }

  tags = {
    Name        = lookup(var.awsprojectcontent, "server-name1")
  }
}

