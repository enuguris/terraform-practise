
hosts = {
  "testbox003" = {
    hostname               = "testbox003"
    ami                    = "ami-065db1a25541c1a83"
    instance_type          = "t2.micro"
    monitoring             = true
    vpc_security_group_ids = ["sg-01356cdf51b894cd8"]
    subnet_id              = "subnet-0ee684dbc2a7fa8de"
  },
  "testbox005" = {
    hostname               = "testbox005"
    ami                    = "ami-065db1a25541c1a83"
    instance_type          = "t2.micro"
    monitoring             = true
    vpc_security_group_ids = ["sg-01356cdf51b894cd8"]
    subnet_id              = "subnet-0ee684dbc2a7fa8de"
  }
}


#hosts = {}
