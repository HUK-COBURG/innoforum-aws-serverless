terraform {
  required_providers { # <1>
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.67"
    }
    archive = {
      source = "hashicorp/archive"
      version = "~> 2.3"
    }
  }
}

# Configure the AWS Provider
provider "aws" { # <2>
  region = "eu-central-1"
}