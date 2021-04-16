locals {
#  deploy_instance = "true"
  deploy_instance = "false"
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
  vpc_security_group_ids = var.vpc_sg_ids
  subnet_id              = var.subnet_id

  tags = {
    Name = var.host_name
  }

}

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
