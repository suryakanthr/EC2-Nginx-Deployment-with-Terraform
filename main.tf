terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Get a default subnet in the first availability zone of the region
data "aws_subnet" "default" {
  default_for_az   = true
  availability_zone = "${var.aws_region}a"
}

# Get the latest Ubuntu 20.04 LTS AMI from Canonical
data "aws_ami" "ubuntu_focal" {
  most_recent = true
  owners      = ["099720109477"] # Canonical official account

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

# Security group for HTTP + SSH
resource "aws_security_group" "nginx_sg" {
  name        = "terraform-nginx-sg"
  description = "Allow HTTP and SSH"
  vpc_id      = data.aws_subnet.default.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "terraform-nginx-sg"
    CreatedBy   = "Terraform"
    Environment = var.environment
  }
}

# EC2 instance
resource "aws_instance" "web" {
  ami                         = data.aws_ami.ubuntu_focal.id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnet.default.id
  vpc_security_group_ids      = [aws_security_group.nginx_sg.id]
  associate_public_ip_address = true

  # Optional SSH key
  key_name = var.key_name

  tags = {
    Name        = "terraform-nginx-ubuntu"
    Environment = var.environment
    CreatedBy   = "Terraform"
  }

  # Install Nginx and custom HTML page
  user_data = <<-EOF
    #!/bin/bash
    set -e
    apt-get update -y
    DEBIAN_FRONTEND=noninteractive apt-get install -y nginx
    cat > /var/www/html/index.html <<'HTML'
    <!doctype html>
    <html>
      <head><meta charset="utf-8"><title>Terraform Nginx</title></head>
      <body>
        <h1>Welcome to the Terraform-managed Nginx Server on Ubuntu</h1>
      </body>
    </html>
    HTML
    systemctl enable nginx
    systemctl restart nginx
  EOF
}
