resource "digitalocean_droplet" "gateway" {
  depends_on = [
    "digitalocean_droplet.webserver",
    "digitalocean_droplet.redis"
  ]
  image = "${var.droplet_image}"
  private_networking = true
  ipv6 = false
  name = "perf-tyk-${lookup(var.droplet_names, "gateway")}"
  region = "${var.droplet_region}"
  size = "${lookup(var.droplet_sizes, "gateway")}"
  ssh_keys = [
    "${var.ssh_key}"
  ]
  provisioner "local-exec" {
    command = "echo ${self.ipv4_address} ${lookup(var.droplet_names, "gateway")} > hosts/${lookup(var.droplet_names, "gateway")}.ipv4_address.host"
  }
  provisioner "local-exec" {
    command = "echo ${self.ipv4_address_private} ${lookup(var.droplet_names, "gateway")} > hosts/${lookup(var.droplet_names, "gateway")}.ipv4_address_private.host"
  }
  provisioner "remote-exec" {
    connection {
      user = "core"
    }
    inline = [
      "sudo systemctl enable docker",
      "mkdir /tmp/apps",
      "echo '${digitalocean_droplet.webserver.ipv4_address_private} webserver' | sudo tee --append /etc/hosts",
      "echo '${digitalocean_droplet.redis.ipv4_address_private} redis' | sudo tee --append /etc/hosts"
    ]
  }
  provisioner "file" {
    connection {
      host = "${self.ipv4_address}"
      user = "core"
    }
    source = "apps"
    destination = "/tmp"
  }

  provisioner "remote-exec" {
    connection {
      user = "core"
    }
    inline = [
      "docker run -itd --rm --name tyk-gateway --add-host webserver:${digitalocean_droplet.webserver.ipv4_address_private} -v /tmp/apps:/opt/tyk-gateway/apps -e TYK_GW_COPROCESSOPTIONS_ENABLECOPROCESS=false -e TYK_GW_CLOSECONNECTIONS=false -e TYK_GW_STORAGE_HOST=${digitalocean_droplet.redis.ipv4_address_private} -p 8080:8080 tykio/tyk-gateway:v2.5.1",
    ]
  }
}
