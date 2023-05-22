provider "aws" {
  region = "ap-southeast-1"
}
//vpc
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name        = "${var.project_name}"
    Description = "VPC main"
  }
}
//public + private subnet
resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.public_subnet_cidr
  tags = {
    Name        = "${var.project_name}-public_subnet"
    Description = "Public subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.private_subnet_cidr
  tags = {
    Name        = "${var.project_name}-private_subnet"
    Description = "Private subnet"
  }
}
//main gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = "${var.project_name}-main_gateway"
    Description = "Gateway vpc"
  }
}
//elastic ip for nat gateway
resource "aws_eip" "elastic_nat_gw" {

}
//nat gateway
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.elastic_nat_gw.id
  subnet_id     = aws_subnet.private_subnet.id

  tags = {
    Name        = "${var.project_name}-nat_gw"
    Description = "Nat gateway"
  }

  depends_on = [aws_internet_gateway.gw]
}
//public + private route table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = var.all_ip
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name        = "${var.project_name}-public_route_table"
    Description = "Public route table"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = var.all_ip
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name        = "${var.project_name}-private_route_table"
    Description = "Private route table"
  }
}

//connect route table to subnet
resource "aws_route_table_association" "route_public_subnet" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "route_private_subnet" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}

//data source
data "aws_ami" "linux" {
  most_recent = true

  filter {
    name   = "image-id"
    values = ["ami-052f483c20fa1351a"]
  }
}



//ec2 instance
resource "aws_instance" "public_instance" {
  ami                         = data.aws_ami.linux.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_subnet.id
  associate_public_ip_address = true
  
  tags = {
    Name        = "${var.project_name}-public_instance"
    Description = "ec2 instance in public subnet"
  }
}

resource "aws_instance" "private_instance" {
  ami           = data.aws_ami.linux.id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.private_subnet.id

  tags = {
    Name        = "${var.project_name}-private_instance"
    Description = "ec2 instance in private subnet"
  }
}

resource "aws_eip" "eip_vcp" {
  vpc = true
}

resource "aws_eip_association" "eip_association_public_instance" {
    instance_id = aws_instance.public_instance.id
    allocation_id = aws_eip.eip_vcp.id
}
