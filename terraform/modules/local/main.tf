resource "null_resource" "local" {
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

  provisioner "local-exec" {
    command = "scp -i ${self.triggers.key} -r ${self.triggers.user}@${self.triggers.host}:/tmp/.server .."
  }
}
