resource "null_resource" "main" {
  triggers = {
    user = var.nodes.server.user
    host = var.nodes.server.host
    key  = var.nodes.server.key
    run  = timestamp()
  }

  connection {
    type        = "ssh"
    user        = self.triggers.user
    host        = self.triggers.host
    private_key = file(self.triggers.key)
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /tmp/.server",
      "sudo chmod 777 /tmp/.server",
      "sudo ip -4 route get 1.1.1.1 | grep -oP 'src \\K\\S+' > /tmp/.server/address",
      "sudo apt-get upgrade -y",
      "sudo apt-get update -y",
      "sudo apt-get install -y docker.io",
      "sudo docker network create ollama-net",
      "sudo docker run -d --network=ollama-net -v ollama:/root/.ollama --name ollama ollama/ollama",
      "sudo docker run -d --network=ollama-net -v open-webui:/app/backend/data --name open-webui -p 0.0.0.0:3000:8080 -e OLLAMA_BASE_URL=http://ollama:11434 --restart always ghcr.io/open-webui/open-webui:main",
    ]
  }

  provisioner "local-exec" {
    command = "scp -i ${self.triggers.key} -r ${self.triggers.user}@${self.triggers.host}:/tmp/.server .."
  }

  provisioner "remote-exec" {
    when = destroy
    inline = [
      "sudo docker ps -q | xargs -r sudo docker stop",
      "sudo docker system prune --all --volumes --force",
      "sudo apt-get remove -y docker.io",
      "sudo apt-get autoremove -y",
      "sudo apt-get autoclean -y",
      "sudo rm -rf /tmp/.server",
    ]
  }
}
