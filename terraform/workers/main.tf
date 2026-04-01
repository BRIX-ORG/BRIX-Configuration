provider "aws" {
  region = var.aws_region
}

# ============================================
# Discover existing infrastructure by tags
# ============================================

data "aws_instance" "master" {
  filter {
    name   = "tag:Name"
    values = ["brix-k3s-master"]
  }
  filter {
    name   = "instance-state-name"
    values = ["running", "stopped", "pending"]
  }
}

data "aws_security_group" "k3s_sg" {
  filter {
    name   = "tag:Name"
    values = ["brix-k3s-sg"]
  }
}

# ============================================
# Worker EC2 Instances
# ============================================

resource "aws_instance" "worker" {
  count         = var.worker_count
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  # Use same network config as master
  vpc_security_group_ids      = [data.aws_security_group.k3s_sg.id]
  subnet_id                   = data.aws_instance.master.subnet_id
  associate_public_ip_address = true

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name    = "brix-k3s-worker-${count.index + 1}"
    Project = "BRIX"
    Role    = "worker"
  }
}
