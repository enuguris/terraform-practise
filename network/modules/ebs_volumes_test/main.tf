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
  source = "./modules/ebs_vols/"

  disks = [
    {
      availability_zone = "us-east-1"
      size              = 1
      type              = "gp2"
      kms_key_id        = "arn:aws:kms:us-east-1:689464524016:key/f3440599-bacc-4eca-8312-6d5c146a3d19"
      tags              = "datadisk001"
    },
    {
      availability_zone = "us-east-1"
      size              = 2
      type              = "gp2"
      kms_key_id        = "arn:aws:kms:us-east-1:689464524016:key/f3440599-bacc-4eca-8312-6d5c146a3d19"
      tags              = "datadisk002"
    }
  ]

  
  
}

    for_each = local.disks
    content {
      availability_zone = ebs_vols.value.availability_zone
      size              = ebs_vols.value.size
      type              = ebs_vols.value.type
      encyrpted         = true
      kms_key_id        = ebs_vols.value.kms_key_id
      tags              = ebs_vols.value.tags
    }
  }
}
