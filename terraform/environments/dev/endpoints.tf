resource "aws_security_group" "vpce" {
  name        = "atlas-dev-vpce-sg"
  description = "Security group for ATLAS VPC endpoints"
  vpc_id      = aws_vpc.atlas.id

  ingress {
    description     = "HTTPS from ATLAS workloads"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.workload.id]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "atlas-dev-vpce-sg"
    Environment = "dev"
    Project     = "atlas"
  }
}


resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = aws_vpc.atlas.id
  service_name        = "com.amazonaws.ap-south-1.ssm"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids = [
    aws_subnet.private.id
  ]

  security_group_ids = [
    aws_security_group.vpce.id
  ]

  tags = {
    Name        = "atlas-dev-ssm-endpoint"
    Environment = "dev"
    Project     = "atlas"
  }
}


resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id              = aws_vpc.atlas.id
  service_name        = "com.amazonaws.ap-south-1.ssmmessages"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids = [
    aws_subnet.private.id
  ]

  security_group_ids = [
    aws_security_group.vpce.id
  ]

  tags = {
    Name        = "atlas-dev-ssmmessages-endpoint"
    Environment = "dev"
    Project     = "atlas"
  }
}


resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id              = aws_vpc.atlas.id
  service_name        = "com.amazonaws.ap-south-1.ec2messages"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids = [
    aws_subnet.private.id
  ]

  security_group_ids = [
    aws_security_group.vpce.id
  ]

  tags = {
    Name        = "atlas-dev-ec2messages-endpoint"
    Environment = "dev"
    Project     = "atlas"
  }
}



# ECR API endpoint
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id            = aws_vpc.atlas.id
  service_name      = "com.amazonaws.ap-south-1.ecr.api"
  vpc_endpoint_type = "Interface"

  subnet_ids = [
    aws_subnet.private.id
  ]

  security_group_ids = [
    aws_security_group.vpce.id
  ]

  private_dns_enabled = true

  tags = {
    Name        = "atlas-dev-ecr-api-endpoint"
    Environment = "dev"
    Project     = "atlas"
  }
}

# ECR Docker registry endpoint
resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id            = aws_vpc.atlas.id
  service_name      = "com.amazonaws.ap-south-1.ecr.dkr"
  vpc_endpoint_type = "Interface"

  subnet_ids = [
    aws_subnet.private.id
  ]

  security_group_ids = [
    aws_security_group.vpce.id
  ]

  private_dns_enabled = true

  tags = {
    Name        = "atlas-dev-ecr-dkr-endpoint"
    Environment = "dev"
    Project     = "atlas"
  }
}
