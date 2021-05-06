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

provider "aws" {
  region = "us-east-1"
}

module "vols" {
  source = "../modules/ebs_volumes"

  ebs_block_devices = [
    {
      availability_zone = "us-east-1a"
      size              = "1"
      type              = "gp2"
      kms_key_id        = "arn:aws:kms:us-east-1:689464524016:key/f3440599-bacc-4eca-8312-6d5c146a3d19"
      disk_name         = "datadisk001"
    },
    {
      availability_zone = "us-east-1a"
      size              = "1"
      type              = "gp2"
      kms_key_id        = "arn:aws:kms:us-east-1:689464524016:key/f3440599-bacc-4eca-8312-6d5c146a3d19"
      disk_name         = "datadisk002"
    }
  ]
}


