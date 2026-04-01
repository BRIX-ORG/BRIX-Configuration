output "worker_count" {
  description = "Current number of worker nodes"
  value       = var.worker_count
}

output "worker_public_ips" {
  description = "Public IPs of all worker nodes"
  value       = aws_instance.worker[*].public_ip
}

output "worker_private_ips" {
  description = "Private IPs of all worker nodes"
  value       = aws_instance.worker[*].private_ip
}

output "worker_instance_ids" {
  description = "Instance IDs of all worker nodes"
  value       = aws_instance.worker[*].id
}

output "master_private_ip" {
  description = "Private IP of the master node (for K3s join)"
  value       = data.aws_instance.master.private_ip
}

output "master_public_ip" {
  description = "Public IP of the master node (for Ansible SSH)"
  value       = data.aws_instance.master.public_ip
}
