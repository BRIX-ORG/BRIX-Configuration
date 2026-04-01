output "public_ip" {
  description = "Public IP of K3s Master"
  value       = aws_instance.brix_k3s.public_ip
}

output "instance_id" {
  description = "Instance ID of the K3s node"
  value       = aws_instance.brix_k3s.id
}

output "master_private_ip" {
  description = "Private IP of K3s Master (for worker join)"
  value       = aws_instance.brix_k3s.private_ip
}
