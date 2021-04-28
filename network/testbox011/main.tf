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
  deploy_instance = "true"
  vpc_id = "vpc-0926212a7fae4b2ff"

  user_data = <<EOF
#!/bin/bash
hostnamectl set-hostname ${var.host_name}
EOF

}


data "aws_kms_key" "key" {
  key_id = "f3440599-bacc-4eca-8312-6d5c146a3d19"
}


data "aws_subnet_ids" "test-vpc-public-us-east-1a" {

  vpc_id = local.vpc_id

  filter {
    name   = "tag:Name"
    values = ["test-vpc-public-us-east-1a"] 
  }
}

data "aws_security_groups" "general" {
  filter {
    name   = "tag:Name"
    values = ["general-securitygroup"]
  }

  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }
}


module "this" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "2.17.0"

  count                  = local.deploy_instance == "true" ? 1 : 0

  name                   = var.host_name
  instance_count         = 1

  ami                    = var.aws_ami
  instance_type          = var.instance_type
  monitoring             = var.enable_monitoring
  vpc_security_group_ids = data.aws_security_groups.general.ids
  subnet_id              = tolist(data.aws_subnet_ids.test-vpc-public-us-east-1a.ids)[0]
  private_ip		 = var.private_ip
 
  user_data_base64 	 = base64encode(local.user_data)

  root_block_device = [
    {
      volume_type = "gp2"
      encrypted   = true
      kms_key_id  = data.aws_kms_key.key.arn
    }
  ]

/*
  ebs_block_device = [
    {
      device_name = "/dev/sdb"
      volume_type = "gp2"
      volume_size = 5
      encrypted   = true
      kms_key_id  = data.aws_kms_key.key.arn
    },
  ]
    {
      device_name = "/dev/sdc"
      volume_type = "gp2"
      volume_size = 1
      encrypted   = true
      kms_key_id  = data.aws_kms_key.key.arn
    }
  ]
*/
  
  tags = {
    Name = var.host_name
  }

}

/*
resource "null_resource" "this" {

  count                  = local.deploy_instance == "true" ? 1 : 0

  triggers = {
    instance_ids = element(module.this[count.index].id, 0) 
  }

  provisioner "remote-exec" {
    inline = ["sudo hostnamectl set-hostname ${var.host_name}"]
  }

  connection {
    type        = "ssh"
    user        = "vmimport"
    private_key = file(var.private_key_file)
    host        = element(module.this[count.index].public_ip, 0)
  }

}


resource "aws_ebs_volume" "ebs_vol_001" {
  count                  = local.deploy_instance == "true" ? 1 : 0
  availability_zone = element(module.this[count.index].availability_zone, 0)
  size              = 4
  type		    = "gp2"
  encrypted	    = true
  kms_key_id	    = data.aws_kms_key.key.arn 

  tags = {
    Name = var.host_name
  }
}

resource "aws_volume_attachment" "this_va" {
  count                  = local.deploy_instance == "true" ? 1 : 0
  device_name 	= "/dev/sdd"
  volume_id   	= aws_ebs_volume.ebs_vol_001[count.index].id
  instance_id 	= element(module.this[count.index].id, 0)
}

*/
