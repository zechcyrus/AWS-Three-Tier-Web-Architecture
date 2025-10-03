//VPC
resource "aws_vpc" "myVPC" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "myVPC"
  }
}

//6 Subnets (2 public + 4 private)
resource "aws_subnet" "public_subnet1" {
  vpc_id = aws_vpc.myVPC.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "Public-Sub-AZ1"
  }
}

resource "aws_subnet" "public_subnet2" {
  vpc_id = aws_vpc.myVPC.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "Public-Sub-AZ2"
  }
}

resource "aws_subnet" "app_private_subnet1" {
  vpc_id = aws_vpc.myVPC.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "Private-App-Sub-AZ1"
  }
}

resource "aws_subnet" "app_private_subnet2" {
  vpc_id = aws_vpc.myVPC.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "Private-App-Sub-AZ2"
  }
}

resource "aws_subnet" "DB_private_subnet1" {
  vpc_id = aws_vpc.myVPC.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "Private-DB-Sub-AZ1"
  }
}

resource "aws_subnet" "DB_private_subnet2" {
  vpc_id = aws_vpc.myVPC.id
  cidr_block = "10.0.5.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "Private-DB-Sub-AZ2"
  }
}

//Internet Gateway
resource "aws_internet_gateway" "myIGW" {
  vpc_id = aws_vpc.myVPC.id
  tags = {
    Name = "myIGW"
  }
}

//2 NAT Gateways
resource "aws_nat_gateway" "NAT_AZ1" {
  allocation_id = aws_eip.eip1.id
  subnet_id = aws_subnet.public_subnet1.id
  tags = {
    Name = "NGW-AZ1"
  }
}

resource "aws_nat_gateway" "NAT_AZ2" {
  allocation_id = aws_eip.eip2.id
  subnet_id = aws_subnet.public_subnet2.id
  tags = {
    Name = "NGW-AZ2"
  }
}

//2 Elastic IPs for Both NAT-GWs
resource "aws_eip" "eip1" {
  domain = "vpc"
}

resource "aws_eip" "eip2" {
  domain = "vpc"
}

//Route Tables
