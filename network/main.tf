
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.78.0"
  # insert the 52 required variables here

  name = "test-vpc"

  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.3.0/24"]

  vpc_tags = {
    Name = "test-vpc"
  }
}

resource "aws_kms_key" "kms_key" {
  description         = "KMS key to encrypt/encrypt ec2 instance root volumes"
  enable_key_rotation = "true"

  tags = {
    Name = "ebs-kms-key"
  }
}

