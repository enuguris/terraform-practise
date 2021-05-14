module "testbox002" {
  source    = "./testbox002"
  host_name = "testbox002"
}

output "testbox002_public_ip" {
  value = module.testbox002[*].this[*].public_ip
}

output "testbox002_private_ip" {
  value = module.testbox002[*].this[*].private_ip
}

