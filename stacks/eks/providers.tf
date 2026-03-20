terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = local.configs.global_variables.region

  default_tags {
    tags = {
      Environment = local.configs.global_variables.environment
      ManagedBy   = "terraform"
      Project     = "devsecops-ge"
    }
  }
}
