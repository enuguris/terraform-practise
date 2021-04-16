variable "hosts" {
  type = map(object({
    hostname = string
    ami      = string
    instance_type = string
    monitoring    = bool
    vpc_security_group_ids = list(string)
    subnet_id  = string
    }))
}

