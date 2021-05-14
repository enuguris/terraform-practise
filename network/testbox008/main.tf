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
  source = "../modules/aws_instance"

  ami           = "ami-0f85893b3253ed13d"
  host_name     = "testbox008"
  private_ip    = "172.31.64.10"
  region        = "us-east-1"
  sg_names      = ["mytestsg"]
  volume_size   = 10
  instance_type = "t2.micro"
  Billing       = "PAYGUR"
  Environment   = "development"
  Maintainer    = "terraform"
  tags          = { erequestnumber = "ER#12345" }

  ebs_block_devices = [
    {
      size             = "1"
      type             = "gp2"
      disk_name_suffix = "www_data_01"
      device_name      = "/dev/sdd"
      additional_tags  = { eReq = "1234", Maintainer = "terraform" }
    },
    {
      size             = "1"
      type             = "gp2"
      disk_name_suffix = "www_log_02"
      device_name      = "/dev/sdf"
      additional_tags  = { eReq = "1234", Maintainer = "terraform" }
    },
  ]
}

output "private_ip" {
  value = module.ec2.private_ip
}
