terraform {
  required_version = "= 0.14.7"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "ec2" {
  source        = "../modules/aws_instance"

  vpc_name      = "test-vpc"
  ami           = "ami-0f85893b3253ed13d"
  host_name     = "testbox008"
  private_ip    = "10.0.3.7"
  environment   = "development"
  region        = "us-east-1"
  billing       = "free tier"
  sg_names      = ["general-securitygroup001"]
  subnet_name   = "test-vpc-public-us-east-1a"
  volume_size   = 10
  instance_type = "t2.micro"
  tags          = { Environment = "development", Maintainer = "terraform", Billing = "Free Tier" }

  ebs_block_devices = [
    {
      size            = "1"
      type            = "gp2"
      disk_name       = "datadisk001"
      device_name     = "/dev/sdd"
      additional_tags = { eReq = "1234", Maintainer = "terraform" }
    },
    {
      size            = "1"
      type            = "gp2"
      disk_name       = "datadisk002"
      device_name     = "/dev/sdb"
      additional_tags = { eReq = "1234", Maintainer = "terraform" }
    },
  ]
}
