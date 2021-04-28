terraform {

  required_version = "= 0.14.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 3.0"
    }

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 2.46.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

provider "azurerm" {
  features {}
}

locals {
  vpc_id = "vpc-0926212a7fae4b2ff"

  tags = {
    maintained_by = "terraform"
    source_region = "us-east-2"
  }
}

module "general-securitygroup" {
  source  = "git::https://github.com/terraform-aws-modules/terraform-aws-security-group?ref=v3.18.0"

  name = "sg_general"
  description = "Allow SSH access"
  vpc_id = local.vpc_id

  ingress_cidr_blocks = ["10.0.0.0/16", "0.0.0.0/0"]
  ingress_rules       = ["ssh-tcp", "all-icmp"]
  egress_rules        = ["all-all"]

  ingress_with_cidr_blocks = [
    {
      rule        = "nfs-tcp"
      cidr_blocks = "10.100.1.10/32"
    },
    {
      rule        = "postgresql-tcp"
      cidr_blocks = "30.30.30.30/32"
    },
    {
      from_port   = 10
      to_port     = 20
      protocol    = 6
      description = "Service name"
      cidr_blocks = "10.10.0.0/20"
    },
    {
      from_port   = 0
      to_port     = 65355
      protocol    = 6
      description = "nfs-test-tcp"
      cidr_blocks = "10.100.1.10/32"
    },
    {
      from_port   = 0
      to_port     = 65335
      protocol    = 17
      description = "nfs-test-udp"
      cidr_blocks = "10.100.1.10/32"
    },
  ]

  tags = merge({
    Name = "general-securitygroup001"
    Env  = "Prod"
  }, local.tags)

}

output "general-securitygroup" {
  value = module.general-securitygroup.this_security_group_id
}
