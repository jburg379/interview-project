#sets AWS as the provider in which the infrastructure will be deployed
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.85"  # This uses aws provider 5.15.x through 5.99.x to stay within the limits of Coalfire's module requirements
    }

    tls = {
      source = "hashicorp/tls"
      version = "~> 4.0"
    }

    local = {
      source = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}