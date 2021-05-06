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

variable "ebs_block_devices" {
  type = list(object({
    availability_zone = string,
    size = string,
    type = string,
    kms_key_id = string,
    disk_name = string
 }))
}


resource "aws_ebs_volume" "this" {
  
      for_each = {for d in var.ebs_block_devices: d.disk_name => d}

      availability_zone = each.value.availability_zone
      size              = each.value.size
      type              = each.value.type
      kms_key_id        = each.value.kms_key_id
      tags = {
        Name = each.key
      }
      encrypted = true
}

/*
data "aws_ebs_volumes" "all" {
  tags = {
    Name = var.ebs_block_devices[disk_name]
  }
}

*/

