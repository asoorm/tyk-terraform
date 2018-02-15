resource "digitalocean_droplet" "webserver" {
  image = "${var.droplet_image}"
  private_networking = true
  ipv6 = false
  name = "perf-tyk-${lookup(var.droplet_names, "webserver")}"
  region = "${var.droplet_region}"
  size = "${lookup(var.droplet_sizes, "webserver")}"
  ssh_keys = [
    "${var.ssh_key}"
  ]

  provisioner "local-exec" {
    command = "echo ${self.ipv4_address} ${lookup(var.droplet_names, "webserver")} > hosts/${lookup(var.droplet_names, "webserver")}.host"
  }

  provisioner "remote-exec" {
    connection {
      host = "${self.ipv4_address}"
      user = "core"
    }
    inline = [
      "sudo systemctl enable docker",
      "mkdir /tmp/webserver",
    ]
  }

  provisioner "file" {
    connection {
      host = "${self.ipv4_address}"
      user = "core"
    }
    source = "webserver"
    destination = "/tmp"
  }

  provisioner "remote-exec" {
    connection {
      host = "${self.ipv4_address}"
      user = "core"
    }
    inline = [
      "cd /tmp/webserver && sudo chown -R 33:33 . && cd ~",
      "docker run -itd --rm --name gwan -v /tmp/webserver:/opt/www -p 6060:80 retailify/docker-gwan"
    ]
  }
}
