resource "aws_security_group" "bastion" {
  name        = "atlas-dev-bastion-sg"
  description = "Security group for ATLAS administrative access"
  vpc_id      = aws_vpc.atlas.id

  ingress {
    description = "SSH administrative access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["163.53.179.51/32"]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "atlas-dev-bastion-sg"
    Environment = "dev"
    Project     = "atlas"
  }
}

resource "aws_security_group" "workload" {
  name        = "atlas-dev-workload-sg"
  description = "Security group for ATLAS workloads"
  vpc_id      = aws_vpc.atlas.id

  ingress {
    description     = "SSH from bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "atlas-dev-workload-sg"
    Environment = "dev"
    Project     = "atlas"
  }
}
