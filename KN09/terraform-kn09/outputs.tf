output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.db_server.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.db_server.public_ip
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.db_sg.id
}

output "connection_test_command" {
  description = "Command to test database connectivity"
  value       = "telnet ${aws_instance.db_server.public_ip} 3306"
}
