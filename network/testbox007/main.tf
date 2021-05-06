terraform {
  required_version = "= 0.14.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 3.37.0"
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

module "this" {
  source = "../modules/ec2"

  vpc_name         = "test-vpc"
  ami_id           = "ami-0f85893b3253ed13d"
  host_name        = "testbox007"
  private_ip       = "10.0.3.7"
  environment      = "development"
  region           = "us-east-1"
  billing          = "free tier"
  sg_names         = ["general-securitygroup001"]
  subnet_name      = "test-vpc-public-us-east-1a"
  init_cfg_vers    = "v1.3"
  root_volume_size = 20

  ebs_block_devices = [
    {
      size              = "1"
      type              = "gp2"
      disk_name         = "datadisk001"
      device_name       = "/dev/sdd"
      extra_tags        = { eRequest = "1234" }
    },
  ]
}
