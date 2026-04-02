variable "aws_region" {
  default = "us-east-1"
}

variable "worker_instance_types" {
  description = "List of instance types for each worker node (e.g. [\"t3.large\", \"t3.medium\", \"t3.large\"])"
  type        = list(string)
  default     = []
}

variable "ami_id" {
  description = "Ubuntu 24.04 LTS AMI (same as master)"
  default     = "ami-0ec10929233384c7f"
}

variable "key_name" {
  description = "AWS Key Pair name for SSH access"
  default     = "BRIX"
}
