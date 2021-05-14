variable "ami" { default = "ami-065db1a25541c1a83" }
variable "instance_type" { default = "t2.micro" }
variable "host_name" { type = string }
variable "private_ip" { type = string }
variable "region" { type = string }
#variable "subnet_name" { type = string }
variable "sg_names" { type = list(string) }
#variable "vpc_name" { type = string }
variable "volume_size" {
  type        = number
  description = "Volume Size"
  default     = 10
}

variable "volume_type" {
  type        = string
  description = "Volume Type"
  default     = "gp2"
}
variable "ebs_block_devices" {
  type = list(object({
    size             = string
    type             = string
    disk_name_suffix = string
    device_name      = string
    additional_tags  = map(string)
  }))
  default = []
}

variable "ebs_optimized" {
  type        = bool
  description = "If true, launched ec2 instance will be ebs optimized. Default is false"
  default     = false
}

variable "monitoring" {
  type        = bool
  description = "Set monitoring to true/false, default is true"
  default     = true
}

variable "http_endpoint" {
  type        = string
  description = "HTTP endpoint, default is enabled"
  default     = "enabled"
}

variable "http_put_response_hop_limit" {
  type        = number
  description = "Hop limit, valid values are between 1 and 64"
  default     = 1
}

variable "http_tokens" {
  type        = string
  description = "Valid values include optional or required. Defaults to optional."
  default     = "optional"
}

variable "Environment" {}
variable "Maintainer" {}
variable "Billing" {}

variable "tags" {
  type        = map(any)
  description = "Tags"
  default     = {}
}
