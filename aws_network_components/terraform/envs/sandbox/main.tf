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

locals {
  # TGW attaches app-vpc, and the VPN attaches to the TGW, so each implies
  # the one below it. Deriving this here keeps the dayNN.tfvars files honest.
  tgw_enabled     = var.enable_tgw || var.enable_vpn
  app_vpc_enabled = var.enable_app_vpc || local.tgw_enabled
}

check "vpn_requires_tgw" {
  assert {
    condition     = !var.enable_vpn || local.tgw_enabled
    error_message = "enable_vpn requires enable_tgw."
  }
}

# Day 1 - VPC Anatomy. Unconditional: every day needs it.
module "shared_services_vpc" {
  source = "../../modules/vpc"

  name                  = "shared-services"
  cidr_block            = "10.0.0.0/16"
  azs                   = ["${var.region}a", "${var.region}b"]
  public_subnet_cidrs   = ["10.0.0.0/24", "10.0.1.0/24"]
  private_subnet_cidrs  = ["10.0.2.0/24", "10.0.3.0/24"]
  isolated_subnet_cidrs = ["10.0.4.0/24", "10.0.5.0/24"]
}

# Day 2 - Security Layer
module "shared_services_security" {
  count  = var.enable_security ? 1 : 0
  source = "../../modules/security"

  name               = "shared-services"
  vpc_id             = module.shared_services_vpc.vpc_id
  vpc_cidr           = "10.0.0.0/16"
  private_subnet_ids = module.shared_services_vpc.private_subnet_ids
}

# Test harness - SSM-managed instances, one per private subnet.
module "ec2_test_shared_services" {
  count  = var.enable_ec2_test ? 1 : 0
  source = "../../modules/ec2_test"

  name         = "shared-services"
  vpc_id       = module.shared_services_vpc.vpc_id
  subnet_ids   = module.shared_services_vpc.private_subnet_ids
  allowed_cidr = "10.0.0.0/8"
}

# Day 3 - DNS
module "shared_services_dns" {
  count  = var.enable_dns ? 1 : 0
  source = "../../modules/dns"

  name               = "shared-services"
  vpc_id             = module.shared_services_vpc.vpc_id
  private_subnet_ids = module.shared_services_vpc.private_subnet_ids
  resolver_sg_id     = one(module.shared_services_security[*].resolver_sg_id)
}

# Day 4 adds module "app_vpc" and module "ec2_test_app" (see plan Step H3).
