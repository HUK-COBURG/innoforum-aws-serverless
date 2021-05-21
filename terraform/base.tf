terraform {
  required_providers { # <1>
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    archive = {
      source = "hashicorp/archive"
      version = "~> 2.2"
    }
  }
}

# Configure the AWS Provider
provider "aws" { # <2>
  region = "eu-central-1"
}