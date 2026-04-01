variable "aws_region" {
  default = "us-east-1"
}

variable "worker_count" {
  description = "Number of K3s worker nodes to create"
  type        = number
  default     = 0
}

variable "instance_type" {
  description = "EC2 instance type for worker nodes"
  default     = "t3.medium"
}

variable "ami_id" {
  description = "Ubuntu 24.04 LTS AMI (same as master)"
  default     = "ami-0ec10929233384c7f"
}

variable "key_name" {
  description = "AWS Key Pair name for SSH access"
  default     = "BRIX"
}
