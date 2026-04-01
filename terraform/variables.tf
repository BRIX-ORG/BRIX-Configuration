variable "aws_region" {
  default = "us-east-1"
}

variable "instance_type" {
  default = "t3.large"
}

variable "ami_id" {
  default = "ami-0ec10929233384c7f" # Ubuntu 24.04 LTS
}

variable "vpc_id" {
  default = "vpc-0dbcd29dc00b02d81"
}

variable "key_name" {
  description = "The name of the AWS Key Pair to use for SSH access"
  default     = "BRIX" # Your actual key name in AWS
}
