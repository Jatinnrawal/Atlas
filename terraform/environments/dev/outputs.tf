output "vpc_id" {
  description = "ATLAS VPC ID"
  value       = aws_vpc.atlas.id
}

output "private_subnet_id" {
  description = "ATLAS private subnet ID"
  value       = aws_subnet.private.id
}

output "instance_id" {
  description = "ATLAS EC2 instance ID"
  value       = aws_instance.atlas.id
}

output "private_ip" {
  description = "ATLAS EC2 private IP"
  value       = aws_instance.atlas.private_ip
}

output "instance_profile" {
  description = "ATLAS EC2 instance profile"
  value       = aws_iam_instance_profile.atlas_ec2.name
}
