variable "host_name" {
  type 		= string
  description	= "Ec2 instance host name"
}

variable "aws_ami" {
  type 		= string
  description 	= "Amazon Machine Image Id"
  default    	= "ami-065db1a25541c1a83"
}

variable "instance_type" {
  type		= string
  description 	= "EC2 instance type"
  default	= "t2.micro"
}

variable "enable_monitoring" {
  type 		= bool
  description	= "Pass boolean as true/false to enable monitoring. Default is true."
  default	= "true"
}

variable "vpc_sg_ids" {
  type		= list(string)
  description	= "List of Security Group Ids"
  default	= ["sg-01356cdf51b894cd8"]
}

variable "subnet_id" {
  type 		= string
  description	= "Subnet Id in which to launch the ec2 instance"
  default	= "subnet-0ee684dbc2a7fa8de"
} 

variable "private_key_file" {
  type		= string
  description   = "Path to the ssh private key file."
  default 	= "/home/vmimport/.ssh/id_rsa"
}
