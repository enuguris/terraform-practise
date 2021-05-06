terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.37"
    }

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.46"
    }
  }
}

resource "aws_ebs_volume" "this" {
  availability_zone = var.availability_zone
  size              = var.size
  type	= var.type
  encrypted = true
  kms_key_id = var.kms_key_id
  tags = var.tags
}
