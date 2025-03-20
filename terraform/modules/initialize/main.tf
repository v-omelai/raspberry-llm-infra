resource "null_resource" "initialize" {
  triggers = {
    user = var.server.user
    host = var.server.host
    key  = var.server.key
    run = timestamp()
  }

  connection {
    type = "ssh"
    user = self.triggers.user
    host = self.triggers.host
    private_key = file(self.triggers.key)
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /tmp/.server",
      "sudo chmod 777 /tmp/.server",
      "sudo ip -4 route get 1.1.1.1 | grep -oP 'src \\K\\S+' > /tmp/.server/address",
    ]
  }

  provisioner "remote-exec" {
    when = destroy
    inline = [
      "sudo rm -rf /tmp/.server",
    ]
  }
}
