terraform {
  backend "s3" {
    bucket         = "brix-terraform-state-317447425524-us-east-1-an"
    key            = "k3s-terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "brix-terraform-lock"
    encrypt        = true
  }
}
