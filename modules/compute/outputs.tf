# Outputs for the compute module

output "instance_ids" {
  description = "The IDs of the EC2 instances"
  value       = aws_instance.app_server[*].id
}

output "instance_public_ips" {
  description = "The public IP addresses of the EC2 instances"
  value       = aws_instance.app_server[*].public_ip
}
