resource "aws_iam_role" "atlas_ec2" {
  name = "atlas-dev-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "atlas-dev-ec2-role"
    Environment = "dev"
    Project     = "atlas"
  }
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.atlas_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ecr" {
  role       = aws_iam_role.atlas_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.atlas_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "atlas_ec2" {
  name = "atlas-dev-ec2-profile"
  role = aws_iam_role.atlas_ec2.name

  tags = {
    Name        = "atlas-dev-ec2-profile"
    Environment = "dev"
    Project     = "atlas"
  }
}

