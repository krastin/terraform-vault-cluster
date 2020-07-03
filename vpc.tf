resource "aws_vpc" "vpc" {
  cidr_block = var.cidr_block
  enable_dns_hostnames = true

  tags = {
    Owner = var.owner
    # Keep  = ""
    Name = "${var.aws_prefix}-${var.datacenter}-vpc"
    Datacenter = var.datacenter
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Owner = var.owner
    # Keep  = ""
    Name = "${var.aws_prefix}-${var.datacenter}-igw"
    Datacenter = var.datacenter
  }
}

resource "aws_route" "route-default" {
  route_table_id         = aws_vpc.vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_security_group" "secgrp-permit" {
  name = "secgrp-permit"
  description = "allow all inbound and outbound traffic"

  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Owner = var.owner
    # Keep  = ""
    Name = "${var.aws_prefix}-${var.datacenter}-secgrp-permit"
    Datacenter = var.datacenter
  }
}

resource "aws_subnet" "subnet-vaultcluster" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.cidr_block
  map_public_ip_on_launch = true

  tags = {
    Owner = var.owner
    # Keep  = ""
    Name = "${var.aws_prefix}-${var.datacenter}-subnet-vaultcluster"
    Datacenter = var.datacenter
  }
}

output "vpc_id" {
  value = aws_vpc.vpc.id
  description = "VPC-ID"
  sensitive = false
}
