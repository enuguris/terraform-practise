terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

locals {
  kms_key_map = {
    "us-east-1" = "f3440599-bacc-4eca-8312-6d5c146a3d19"
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

data "template_file" "config" {
  template = file("${path.module}/init.tpl")

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

resource "aws_instance" "this" {
  ami                    = var.ami
  ebs_optimized          = var.ebs_optimized
  instance_type          = var.instance_type
  monitoring             = var.monitoring
  private_ip             = var.private_ip
  subnet_id              = tolist(data.aws_subnet_ids.subnet_name.ids)[0]
  vpc_security_group_ids = data.aws_security_groups.sg.ids
  user_data_base64       = data.template_cloudinit_config.config.rendered

  metadata_options {
    http_endpoint               = var.http_endpoint
    http_put_response_hop_limit = var.http_put_response_hop_limit
    http_tokens                 = var.http_tokens
  }

  root_block_device {
    delete_on_termination = true
    encrypted             = true
    kms_key_id            = data.aws_kms_key.key.arn
    volume_size           = var.volume_size
    volume_type           = var.volume_type

    tags = merge({
      Name = "${var.host_name}_root_volume"
    }, var.tags)
  }

  tags = merge({
    Name = var.host_name
  }, var.tags)

  credit_specification {
    cpu_credits = "standard"
  }

  lifecycle {
    ignore_changes = [user_data_base64]
  }
}

resource "aws_ebs_volume" "ebs" {
  for_each          = { for d in var.ebs_block_devices: d.disk_name => d }
  availability_zone = aws_instance.this.availability_zone
  size              = each.value.size
  type              = each.value.type
  kms_key_id        = data.aws_kms_key.key.arn
  encrypted         = true

  tags = merge({
    Name = "${var.host_name}_${each.key}"
  }, each.value.additional_tags)
}

resource "aws_volume_attachment" "ebs_att" {
  for_each    = { for t in var.ebs_block_devices: t.device_name => t }
  device_name = each.key
  volume_id   = aws_ebs_volume.ebs[each.value.disk_name].id
  instance_id = aws_instance.this.id
}
