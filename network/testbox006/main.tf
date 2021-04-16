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

  backend "azurerm" {
    resource_group_name  = "rg-test"
    storage_account_name = "stacestustrfmstate"
    container_name       = "tfstate-0-21"
    key                  = "aws/testbox001/instance.tfstate"
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
}

variable instance_name {
  type = string
  description = "Name of the ec2 instance to provision"
}


module "this_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "2.17.0"
  # insert the 10 required variables here

  count                  = local.deploy_instance == "true" ? 1 : 0

  name                   = var.instance_name
  instance_count         = 1

  ami                    = "ami-065db1a25541c1a83"
  instance_type          = "t2.micro"
  monitoring             = true
  vpc_security_group_ids = ["sg-01356cdf51b894cd8"]
  subnet_id              = "subnet-0ee684dbc2a7fa8de"

  tags = {
    Name = var.instance_name
  }

}


resource "null_resource" "this_instance" {

  count                  = local.deploy_instance == "true" ? 1 : 0

  # Changes to the instance will cause the null_resource to be re-executed
  triggers = {
    instance_ids = element(module.this_instance[count.index].id, 0) 
  }

  # Running the remote provisioner like this ensures that ssh is up and running
  # before running the local provisioner

  provisioner "remote-exec" {
    inline = ["sudo hostnamectl set-hostname ${var.instance_name}"]
  }

  connection {
    type        = "ssh"
    user        = "vmimport"
    private_key = file("/home/vmimport/.ssh/id_rsa")
    host        = element(module.this_instance[count.index].public_ip, 0)
  }

}
