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
