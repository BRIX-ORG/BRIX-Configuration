provider "aws" {
  region = var.aws_region
}

resource "aws_security_group" "brix_k3s_sg" {
  name        = "brix-k3s-sg"
  description = "Security group for BRIX K3s Cluster setup by Terraform"
  vpc_id      = var.vpc_id

  ingress {
    description      = "SSH from anywhere for Ansible"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "HTTP for Traefik Ingress"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "HTTPS for Traefik Ingress"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Kubernetes API"
    from_port        = 6443
    to_port          = 6443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    description      = "Allow all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "brix-k3s-sg"
    Project = "BRIX"
  }
}

resource "aws_instance" "brix_k3s" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  # Network
  vpc_security_group_ids = [aws_security_group.brix_k3s_sg.id]
  associate_public_ip_address = true

  # Storage
  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  tags = {
    Name = "brix-k3s-master"
    Project = "BRIX"
  }
}
