# Creating a VPC with 2 public and 2 private subnets
resource "aws_vpc" "ecs-vpc" {
  cidr_block = var.VPC_CIDR
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "ecs-vpc"
  }
}
resource "aws_subnet" "ecs-publicsubnet1" {
  vpc_id            = aws_vpc.ecs-vpc.id
  cidr_block        = var.PUB1_CIDR
  availability_zone = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "ecs-publicsubnet1"
  }
}
resource "aws_subnet" "ecs-publicsubnet2" {
  vpc_id                  = aws_vpc.ecs-vpc.id
  cidr_block              = var.PUB2_CIDR
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true
  tags = {
    Name = "ecs-publicsubnet2"
  }
}
 
resource "aws_subnet" "ecs-privatesubnet1" {
  vpc_id            = aws_vpc.ecs-vpc.id
  cidr_block        = var.PVT1_CIDR
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "ecs-privatesubnet1"
  }
}
resource "aws_subnet" "ecs-privatesubnet2" {
  vpc_id                  = aws_vpc.ecs-vpc.id
  cidr_block              = var.PVT2_CIDR
  availability_zone       = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "ecs-privatesubnet2"
  }
}

# Grant the VPC public subnet access to internet in route table.
resource "aws_route_table" "rt-public" {
  vpc_id = aws_vpc.ecs-vpc.id
  
  tags = {
    Name = "rt-public"
  }
}
resource "aws_route_table" "rt-private" {
  vpc_id = aws_vpc.ecs-vpc.id
  
  tags = {
    Name = "rt-private"
  }
}


resource "aws_route_table_association" "rt-assoc-pub1" {
  subnet_id = aws_subnet.ecs-publicsubnet1.id
  route_table_id = aws_route_table.rt-public.id
}
resource "aws_route_table_association" "rt-assoc-pvt1" {
  subnet_id = aws_subnet.ecs-privatesubnet1.id
  route_table_id = aws_route_table.rt-private.id
}
resource "aws_route_table_association" "rt-assoc-pub2" {
  subnet_id = aws_subnet.ecs-publicsubnet2.id
  route_table_id = aws_route_table.rt-public.id
}
resource "aws_route_table_association" "rt-assoc-pvt2" {
  subnet_id = aws_subnet.ecs-privatesubnet2.id
  route_table_id = aws_route_table.rt-private.id
}

# create an internet gateway to give our vpc public subnets access to internet
resource "aws_internet_gateway" "ecs-vpc-igw" {
  vpc_id = aws_vpc.ecs-vpc.id
  tags = {
    Name = "ecs-vpc-igw"
  }
}
resource "aws_route" "ecs-vpc-public-route" {
  route_table_id         = aws_route_table.rt-public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ecs-vpc-igw.id
}

# create NAT gateway for private subets to talk to internet
resource "aws_eip" "ecs-vpc-eip" {
  vpc = true
}
resource "aws_nat_gateway" "ecs-vpc-nat-gw" {
  allocation_id = aws_eip.ecs-vpc-eip.id
  subnet_id     = aws_subnet.ecs-publicsubnet1.id
  tags = {
    Name = "ecs-vpc-nat-gw"
  }
  # To ensure proper ordering, it is recommended to add an explicit dependency on the Internet Gateway for the VPC.
  depends_on  = [aws_internet_gateway.ecs-vpc-igw]
}
resource "aws_route" "ecs-vpc-pvt-route" {
  route_table_id         = aws_route_table.rt-private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.ecs-vpc-nat-gw.id
}