output "vpc_id" {
  description = "Project VPC ID"
  value       = aws_vpc.main.id
}

output "web_public_ip" {
  description = "Public IP of the Flask server"
  value       = aws_instance.web.public_ip
}

output "web_private_ip" {
  description = "Private IP of the Flask server"
  value       = aws_instance.web.private_ip
}

output "db_private_ip" {
  description = "Private IP of the MySQL server"
  value       = aws_instance.db.private_ip
}

output "nat_gateway_public_ip" {
  description = "Elastic IP assigned to NAT Gateway"
  value       = aws_eip.nat.public_ip
}
