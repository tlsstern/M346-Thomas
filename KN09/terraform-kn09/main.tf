2terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Variables
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "db_name" {
  description = "Name tag for the database instance"
  type        = string
  default     = "DB-Server-KN09-Terraform"
}

# Cloud-init configuration for database server
locals {
  db_cloud_init = <<-EOF
    #cloud-config
    packages:
      - mariadb-server

    runcmd:
      - sudo systemctl start mariadb
      - sudo systemctl enable mariadb
      - sudo mysql -sfu root -e "GRANT ALL ON *.* TO 'admin'@'%' IDENTIFIED BY 'password' WITH GRANT OPTION;"
      - sudo sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mysql/mariadb.conf.d/50-server.cnf
      - sudo systemctl restart mariadb
  EOF
}

# Get default VPC
data "aws_vpc" "default" {
  default = true
}

# Get latest Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
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

# EC2 Instance for Database Server
resource "aws_instance" "db_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = "thomas1"
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  
  user_data = local.db_cloud_init

  tags = {
    Name = var.db_name
  }

  # Ensure user_data runs on every instance replacement
  user_data_replace_on_change = true
}

# Outputs
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
