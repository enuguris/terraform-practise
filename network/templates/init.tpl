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
    key                  = "aws/${host_name}/instance.state"
  }

}

provider "aws" {
  region = "us-east-1"
}

provider "azurerm" {
  features {}
}

#variables
variable "host_name" {
  type          = string
  description   = "Ec2 instance host name"
}

variable "aws_ami" {
  type          = string
  description   = "Amazon Machine Image Id"
  default       = "ami-065db1a25541c1a83"
}

variable "instance_type" {
  type          = string
  description   = "EC2 instance type"
  default       = "t2.micro"
}

variable "enable_monitoring" {
  type          = bool
  description   = "Pass boolean as true/false to enable monitoring. Default is true."
  default       = "true"
}

variable "vpc_sg_ids" {
  type          = list(string)
  description   = "List of Security Group Ids"
  default       = ["sg-01356cdf51b894cd8"]
}

variable "subnet_id" {
  type          = string
  description   = "Subnet Id in which to launch the ec2 instance"
  default       = "subnet-0ee684dbc2a7fa8de"
}

variable "private_key_file" {
  type          = string
  description   = "Path to the ssh private key file."
  default       = "/home/vmimport/.ssh/id_rsa"
}


#Local variables
locals {
  deploy_instance = "true"
}

module "this_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "2.17.0"
  # insert the 10 required variables here

  count                  = local.deploy_instance == "true" ? 1 : 0

  name                   = var.host_name
  instance_count         = 1

  ami                    = var.aws_ami
  instance_type          = var.instance_type
  monitoring             = var.enable_monitoring
  vpc_security_group_ids = var.vpc_sg_ids
  subnet_id              = var.subnet_id

  tags = {
    Name = var.host_name
  }

}

#Creating null_resource to run the provisioner
resource "null_resource" "this_instance" {

  count                  = local.deploy_instance == "true" ? 1 : 0

  # Changes to the instance will cause the null_resource to be re-executed
  triggers = {
    instance_ids = element(module.this_instance[count.index].id, 0) 
  }

  # Running the remote provisioner like this ensures that ssh is up and running
  # before running the local provisioner

  provisioner "remote-exec" {
    inline = ["sudo hostnamectl set-hostname ${var.host_name}"]
  }

  connection {
    type        = "ssh"
    user        = "vmimport"
    private_key = file(var.private_key_file)
    host        = element(module.this_instance[count.index].public_ip, 0)
  }

}

#outputs
output "public_ip" {
  value		= module.this_instance[0].public_ip
}

