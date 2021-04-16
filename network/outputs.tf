output "vpc-id" {
  value = module.vpc.vpc_id
}

output "ebs-kms-key" {
  value		= aws_kms_key.kms_key.key_id
}
