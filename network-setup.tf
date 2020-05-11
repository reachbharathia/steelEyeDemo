locals {
  vpc_id       = join("", aws_vpc.this.*.id)
  app_node_ips = join("", aws_instance.application_nodes.*.private_ip)
  policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "AllowPublicRead",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
                
            },
            "Action": "s3:*",
            "Resource": [ 
			     "arn:aws:s3:::${var.bucket_name}/*",
                 "arn:aws:s3:::${var.bucket_name}"
            ]
	    }
    ]
}
EOF
}

resource "aws_vpc" "this" {
  count = var.create_networking_resources ? 1 : 0

  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
}


# Internet Gateway 
resource "aws_internet_gateway" "this" {
  count = var.create_networking_resources ? 1 : 0

  vpc_id = local.vpc_id

}

# Public Subnets 
resource "aws_subnet" "public" {
  count = var.create_networking_resources ? length(var.public_subnet_cidr_blocks) : 0

  vpc_id                  = local.vpc_id
  cidr_block              = var.public_subnet_cidr_blocks[count.index]
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = true
}

# Publiс Route Table 
resource "aws_route_table" "public" {
  count  = var.create_networking_resources ? 1 : 0
  vpc_id = local.vpc_id
}

# Publiс Route
resource "aws_route" "public_internet_gateway" {
  count = var.create_networking_resources ? 1 : 0

  route_table_id         = join("", aws_route_table.public.*.id)
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = join("", aws_internet_gateway.this.*.id)
}

# Publiс Subnets Route Table Association 
resource "aws_route_table_association" "public" {
  count          = var.create_networking_resources ? length(var.public_subnet_cidr_blocks) : 0
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = join("", aws_route_table.public.*.id)
}





# Private Subnets 
resource "aws_subnet" "private" {
  count          = var.create_networking_resources ? length(var.private_subnet_cidr_blocks) : 0

  vpc_id            = local.vpc_id
  cidr_block        = var.private_subnet_cidr_blocks[count.index]
  availability_zone = element(var.azs, count.index)
}


# Private Route Tables 
resource "aws_route_table" "private" {
  count          = var.create_networking_resources ? length(var.private_subnet_cidr_blocks) : 0
  vpc_id = local.vpc_id
}


# Private Subnets Route Tables Association 
resource "aws_route_table_association" "private" {
  count          = var.create_networking_resources ? length(var.private_subnet_cidr_blocks) : 0

  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}


# EIPs for NAT Gateways 
resource "aws_eip" "nat" {
 count          = var.create_networking_resources ? length(var.private_subnet_cidr_blocks) : 0
  vpc = true
}

# NAT Gateways 
resource "aws_nat_gateway" "this" {
  count          = var.create_networking_resources ? length(var.private_subnet_cidr_blocks) : 0

  allocation_id = element(aws_eip.nat.*.id, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)


  depends_on = [aws_internet_gateway.this]
}


# Private Routes #
resource "aws_route" "private_nat_gateway" {
  count          = var.create_networking_resources ? length(var.private_subnet_cidr_blocks) : 0

  route_table_id         = element(aws_route_table.private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.this.*.id, count.index)
}