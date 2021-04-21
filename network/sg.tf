locals {
  tags = {
    maintained_by = "terraform"
    source_region = "us-east-2"
  }
}

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

  ingress_with_cidr_blocks = [
    {
      rule        = "nfs-tcp"
      cidr_blocks = "10.100.1.10/32"
    },
    {
      rule        = "postgresql-tcp"
      cidr_blocks = "30.30.30.30/32"
    },
    {
      from_port   = 10
      to_port     = 20
      protocol    = 6
      description = "Service name"
      cidr_blocks = "10.10.0.0/20"
    },
  ]

  tags = merge({
    Name = "general-securitygroup"
    Env  = "Prod"
  }, local.tags)

}

output "general-securitygroup" {
  value = module.general-securitygroup.this_security_group_id
}
