variable "vpc_id" { default = "vpc-0926212a7fae4b2ff" }
variable "ami_id" { default = "ami-065db1a25541c1a83" }
variable "instance_type" { default = "t2.micro" }
variable "host_name" { type = string }
variable "private_ip" { type = string }
variable "environment" { type = string }
variable "region" { type = string }
variable "billing" { type = string }
variable "subnet_name" { type = string }
variable "sg_names" { type = list(string) }
variable "init_cfg_vers" { type = string }
variable "vpc_name" { type = string }
variable "root_volume_size" {
  type    = string
  default = 10
}
variable "ebs_block_devices" {
  type = list(object({
    size        = string
    type        = string
    disk_name   = string
    device_name = string
    additional_tags = map(string)
  }))
  default = []
}
