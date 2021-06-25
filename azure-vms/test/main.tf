terraform {
  required_version = "= 0.14.7"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.64.0"
    }
  }
}

provider "azurerm" {
  features {}
}

variable "cluster" {
  default = {
    azvm001 = {
      host_name                  = "azvm001"
      private_ip_addr_allocation = "Static"
      private_ipaddress          = "10.0.1.10"
    },
    azvm002 = {
      host_name                  = "azvm002"
      private_ip_addr_allocation = "Static"
      private_ipaddress          = "10.0.1.11"
    }
  }
}

variable "frontend_ip" {
  default = "10.0.1.20"
}

locals {
  vms_subnet_id = distinct(flatten([for s in var.cluster : module.vms_subnet_id[s.host_name].subnetid]))
  lb_subnet_id = module.lb_subnetid.subnetid != [] ? module.lb_subnetid.subnetid : [""]
 
  concat_subnet_ids = distinct(concat(local.vms_subnet_id, local.lb_subnet_id))

  subnet_id = length(local.concat_subnet_ids) == 1 ? local.concat_subnet_ids : []
}

module "vms_subnet_id" {
  source     = "../modules/azurerm-get-subnetid"
  for_each   = var.cluster
  private_ip = each.value.private_ipaddress
}

module "lb_subnetid" {
  source     = "../modules/azurerm-get-subnetid"
  private_ip = var.frontend_ip
}

output "lb_subnet_id" {
 value = local.lb_subnet_id[0]
}

output "subnetid" {
  value = local.subnet_id[0]
}

