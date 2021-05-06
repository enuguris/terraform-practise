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


/*
resource "aws_ebs_volume" "ebs_data_disk_001" {
  availability_zone = module.this.az
  size              = 2
  type              = "gp2"
  encrypted         = true
  kms_key_id        = module.this.kms_key_arn

  tags = merge({
    Name = "${module.this.host_name}_ebs_data_disk_001"
  }, module.this.tags)

}

resource "aws_volume_attachment" "this_data_disk_001" {
  device_name   = "/dev/sdd"
  volume_id     = aws_ebs_volume.ebs_data_disk_001.id
  instance_id   = module.this.instance_id
}

*/
