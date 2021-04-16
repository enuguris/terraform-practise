
resource "null_resource" "this_instance" {


  # Changes to the instance will cause the null_resource to be re-executed
  triggers = {
    instance_ids = element(module.this_instance[0].id, 0) 
  }

  # Running the remote provisioner like this ensures that ssh is up and running
  # before running the local provisioner

  provisioner "remote-exec" {
    inline = ["sudo hostnamectl set-hostname ${each.value.hostname}"]
  }

  connection {
    type        = "ssh"
    user        = "vmimport"
    private_key = file("/home/vmimport/.ssh/id_rsa")
    host        = element(module.this_instance[0].public_ip, 0)
  }

}
