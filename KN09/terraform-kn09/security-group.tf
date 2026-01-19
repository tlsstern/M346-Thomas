# Get default VPC
data "aws_vpc" "default" {
  default = true
}

# Security group for database server
resource "aws_security_group" "db_sg" {
  name        = "db-sg-kn09-terraform"
  description = "Security group for KN09 database server - Terraform managed"
  vpc_id      = data.aws_vpc.default.id

  # SSH access
  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Note: MySQL port 3306 not exposed to internet for security
  # You can add it manually later if needed for your specific use case

  # Outbound rules
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "db-sg-kn09-terraform"
  }
}
