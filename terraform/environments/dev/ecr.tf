resource "aws_ecr_repository" "atlas" {
  name                 = "atlas"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Project     = "atlas"
    Environment = "dev"
    Name        = "atlas-ecr"
  }
}
