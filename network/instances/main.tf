module "this_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "2.17.0"
  
  for_each 		 = var.hosts
  name                   = each.value.hostname
  ami                    = each.value.ami
  instance_type          = each.value.instance_type
  monitoring             = each.value.monitoring
  vpc_security_group_ids = each.value.vpc_security_group_ids
  subnet_id              = each.value.subnet_id

  tags = {
    Name = each.value.hostname
  }
}

