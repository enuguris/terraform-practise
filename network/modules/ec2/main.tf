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

locals {
  kms_key_map = {
    "us-east-1" = "f3440599-bacc-4eca-8312-6d5c146a3d19"
  }
  tags = {
    Environment = var.environment
    Region      = var.region
    Billing     = var.billing
  }
}

data "aws_vpcs" "selected" {
  tags = {
    Name = var.vpc_name
  }
}

data "aws_subnet_ids" "subnet_name" {
  vpc_id = tolist(data.aws_vpcs.selected.ids)[0]

  filter {
    name   = "tag:Name"
    values = [var.subnet_name]
  }
}

data "aws_security_groups" "sg" {
  filter {
    name   = "tag:Name"
    values = var.sg_names
  }

  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

data "aws_kms_key" "key" {
  key_id = local.kms_key_map[var.region]
}

data "http" "cloud_init_config" {
  url = "https://raw.githubusercontent.com/enuguris/cloud-init/${var.init_cfg_vers}/init.tpl"
}

data "template_file" "config" {
  template = data.http.cloud_init_config.body

  vars = {
    host_name  = var.host_name
    private_ip = var.private_ip
  }
}

data "template_cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "terraform.tpl"
    content_type = "text/cloud-config"
    content      = data.template_file.config.rendered
  }
}

module "ec2-instance" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-ec2-instance?ref=v2.17.0"

  name                        = var.host_name
  instance_count              = 1
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = tolist(data.aws_subnet_ids.subnet_name.ids)[0]
  vpc_security_group_ids      = data.aws_security_groups.sg.ids
  associate_public_ip_address = true
  private_ip                  = var.private_ip
  user_data_base64            = data.template_cloudinit_config.config.rendered

  root_block_device = [
    {
      volume_type = "gp2"
      volume_size = var.root_volume_size
      encrypted   = true
      kms_key_id  = data.aws_kms_key.key.arn
    }
  ]

  tags = merge({
    Name = var.host_name
  }, local.tags)

  #volume_tags = merge({ Name = "${var.host_name}_root_volume" }, local.tags)
}

resource "aws_ebs_volume" "ebs" {
  for_each          = { for d in var.ebs_block_devices : d.disk_name => d }
  availability_zone = element(module.ec2-instance.availability_zone, 0)
  size              = each.value.size
  type              = each.value.type
  kms_key_id        = data.aws_kms_key.key.arn
  encrypted         = true

  tags = {
    Name = "${var.host_name}_${each.key}"
  }
}

resource "aws_volume_attachment" "ebs_att" {
  for_each    = { for t in var.ebs_block_devices : t.device_name => t }
  device_name = each.key
  volume_id   = aws_ebs_volume.ebs[each.value.disk_name].id
  instance_id = element(module.ec2-instance.id, 0)
}
