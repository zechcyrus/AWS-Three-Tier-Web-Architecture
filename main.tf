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

//Route Tables for Public Subnets
resource "aws_route_table" "RT_Public" {
  vpc_id = aws_vpc.myVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myIGW.id
  }
}

resource "aws_route_table_association" "RT_PublicSub1" {
  subnet_id = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.RT_Public.id
}

resource "aws_route_table_association" "RT_PublicSub2" {
  subnet_id = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.RT_Public.id
}

//Routes Tables for Private Subnets
resource "aws_route_table" "RT_Private1" {
  vpc_id = aws_vpc.myVPC.id

  route = {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.NAT_AZ1.id
  }

  tags = {
    Name = "PrivateRT-AZ1"
  }
}

resource "aws_route_table_association" "RT_PrivateSub1" {
  subnet_id = aws_subnet.app_private_subnet1.id
  route_table_id = aws_route_table.RT_Private1.id
}

resource "aws_route_table" "RT_Private2" {
  vpc_id = aws_vpc.myVPC.id

  route = {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.NAT_AZ2.id
  }

  tags = {
    Name = "PrivateRT-AZ2"
  }
}

resource "aws_route_table_association" "RT_PrivateSub2" {
  subnet_id = aws_subnet.app_private_subnet2.id
  route_table_id = aws_route_table.RT_Private2.id
}

//Security Groups
resource "aws_security_group" "internet-lb" {
  name = "Internet-lb-sg"
  description = "Internet Facing Load Balancer Security Group"
  vpc_id = aws_vpc.myVPC.id

  tags = {
    Name = "Internet-lb"
  }
}

resource "aws_vpc_security_group_ingress_rule" "HTTP" {
  security_group_id = aws_security_group.internet-lb.id
  cidr_ipv4 = "0.0.0.0/0"
  from_port = 80
  ip_protocol = "tcp"
  to_port = 80
}

resource "aws_vpc_security_group_egress_rule" "All_Traffic" {
  security_group_id = aws_security_group.internet-lb.id
  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol = "-1"
}
  


