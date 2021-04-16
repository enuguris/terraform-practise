module "testbox011" {
  source	 	= "./testbox011"
  host_name		= "testbox011"
  private_ip		= "10.0.3.11"
}

output "testbox011_public_ip" {
  value			= module.testbox011[*].this[*].public_ip
}

output "testbox011_private_ip" {
  value			= module.testbox011[*].this[*].private_ip
}

