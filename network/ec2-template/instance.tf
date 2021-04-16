module "instance" {
  source	 	= "./instance"
  host_name		= "instance"
}

output "instance_public_ip" {
  value			= module.instance[*].this[*].public_ip
}

output "instance_private_ip" {
  value			= module.instance[*].this[*].private_ip
}

