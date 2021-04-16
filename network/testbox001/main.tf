
locals {
  deploy_instance = "false"
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
