terraform {
  required_version = ">= 1.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region  = var.region
  profile = var.aws_profile
}

module "shared_services_vpc" {
  source = "../../modules/vpc"

  name                  = "shared-services"
  cidr_block            = "10.0.0.0/16"
  azs                   = ["${var.region}a", "${var.region}b"]
  public_subnet_cidrs   = ["10.0.0.0/24", "10.0.1.0/24"]
  private_subnet_cidrs  = ["10.0.2.0/24", "10.0.3.0/24"]
  isolated_subnet_cidrs = ["10.0.4.0/24", "10.0.5.0/24"]
}