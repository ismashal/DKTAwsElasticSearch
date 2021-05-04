
#VPC resources
resource "aws_vpc" "devops-vpc" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    {
      Name        = "devops-vpc",
      Project     = var.project,
      Environment = var.environment
    },
    var.tags
  )
}

#Internet gateway
resource "aws_internet_gateway" "devops-ig" {
  vpc_id = aws_vpc.devops-vpc.id

  tags = merge(
    {
      Name        = "devops-ig",
      Project     = var.project,
      Environment = var.environment
    },
    var.tags
  )
}

# Private route table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.devops-vpc.id
  tags = merge(
    {
      Name        = "PrivateRouteTable",
      Project     = var.project,
      Environment = var.environment
    },
    var.tags
  )
}

resource "aws_route" "private" {
  route_table_id          = aws_route_table.private.id
  destination_cidr_block  = var.public_cidr_address
  nat_gateway_id          = aws_nat_gateway.devops-ng.id
}

# Public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.devops-vpc.id

  tags = merge(
    {
      Name        = "PublicRouteTable",
      Project     = var.project,
      Environment = var.environment
    },
    var.tags
  )
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = var.public_cidr_address
  gateway_id             = aws_internet_gateway.devops-ig.id
}

# public subnets
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidr_blocks)
  vpc_id            = aws_vpc.devops-vpc.id
  cidr_block        = var.private_subnet_cidr_blocks[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    {
      Name        = "PrivateSubnet",
      Project     = var.project,
      Environment = var.environment
    },
    var.tags
  )
}

#public subnets
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidr_blocks)
  vpc_id                  = aws_vpc.devops-vpc.id
  cidr_block              = var.public_subnet_cidr_blocks[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    {
      Name        = "PublicSubnet",
      Project     = var.project,
      Environment = var.environment
    },
    var.tags
  )
}

# Route table association
resource "aws_route_table_association" "private" {
  count           = length(var.private_subnet_cidr_blocks)
  subnet_id       = aws_subnet.private[count.index].id
  route_table_id  = aws_route_table.private.id
}

resource "aws_route_table_association" "public" {
  count           = length(var.public_subnet_cidr_blocks)
  subnet_id       = aws_subnet.public[count.index].id
  route_table_id  = aws_route_table.public.id
}

#Elastic ip address
resource "aws_eip" "eip" {
  vpc = true
}

#NAT resources
resource "aws_nat_gateway" "devops-ng" {
  depends_on    = [aws_internet_gateway.devops-ig]
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(
    {
      Name        = "devops-nat",
      Project     = var.project,
      Environment = var.environment
    },
    var.tags
  )
}

#Role to create the elasticsearch
resource "aws_iam_service_linked_role" "devops_elastic_search_role" {
    aws_service_name = "es.amazonaws.com"
    description      = "Allows Amazon ES to manage AWS resources for a domain on your behalf."
}


# Creating elasticsearch with 3 master and 3 worker nodes
resource "aws_elasticsearch_domain" "devops_elastic_search" {

  domain_name           = "devops-es"
  elasticsearch_version = "7.10"

  cluster_config {
    instance_type  = "t3.small.elasticsearch" 
    instance_count = "3"

    dedicated_master_type    = "m5.small.elasticsearch"
    dedicated_master_count   = "3"
  }

  ebs_options {
    ebs_enabled = true
    volume_size = "10"
  }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"

  }

  vpc_options {
    subnet_ids         = [aws_subnet.private[0].id]
    security_group_ids = [aws_security_group.devops-es-sg.id]
  }

  tags = merge(
    {
      Name        = "devops_es",
      Project     = var.project,
      Environment = var.environment
    },
    var.tags
  )

}

#Elasticsearch Security group 
resource "aws_security_group" "devops-es-sg" {
  name        = "devops-es-sg"
  description = "Security group for ATS ES"
  vpc_id      = aws_vpc.devops-vpc.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Elasticsearch Security group rule
resource "aws_security_group_rule" "devops-cidr-block" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.devops-es-sg.id
}





