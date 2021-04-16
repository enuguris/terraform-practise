module "general-securitygroup" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "3.18.0"
  # insert the 2 required variables here

  name = "SSH"
  description = "Allow SSH access"
  vpc_id = "vpc-0926212a7fae4b2ff"

  ingress_cidr_blocks = ["10.0.0.0/16", "0.0.0.0/0"]
  ingress_rules       = ["ssh-tcp", "all-icmp"]
  egress_rules        = ["all-all"]
}

output "general-securitygroup" {
  value = module.general-securitygroup.this_security_group_id
}
