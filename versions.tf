terraform {
  required_version = ">= 1.10"

  required_providers {
    hostinger = {
      source  = "hostinger/hostinger"
      version = "~> 0.1"
    }
  }
}

provider "hostinger" {
  # API token should be set via HOSTINGER_API_TOKEN environment variable
  # or passed via terraform.tfvars
}
