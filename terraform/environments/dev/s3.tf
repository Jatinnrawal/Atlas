resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.atlas.id
  service_name      = "com.amazonaws.ap-south-1.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [
    aws_route_table.private.id
  ]

  tags = {
    Name        = "atlas-dev-s3-endpoint"
    Environment = "dev"
    Project     = "atlas"
  }
}

resource "aws_s3_bucket" "ansible_ssm" {
  bucket_prefix = "atlas-dev-ansible-ssm-"

  tags = {
    Name        = "atlas-dev-ansible-ssm"
    Environment = "dev"
    Project     = "atlas"
    Purpose     = "Ansible SSM file transfer"
  }
}

resource "aws_s3_bucket_public_access_block" "ansible_ssm" {
  bucket = aws_s3_bucket.ansible_ssm.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "ansible_ssm" {
  bucket = aws_s3_bucket.ansible_ssm.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

output "ansible_ssm_bucket" {
  description = "S3 bucket used by Ansible SSM connection"
  value       = aws_s3_bucket.ansible_ssm.bucket
}
