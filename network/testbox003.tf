module "testbox003" {
  source	 	= "./testbox003"
  host_name		= "testbox003"
}

output "testbox003_public_ip" {
  value			= module.testbox003[*].this[*].public_ip
}

output "testbox003_private_ip" {
  value			= module.testbox003[*].this[*].private_ip
}

