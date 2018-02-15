resource "digitalocean_droplet" "consumer" {
  depends_on = [
    "digitalocean_droplet.gateway",
    "digitalocean_droplet.webserver"
  ]
  image = "${var.droplet_image}"
  private_networking = false
  ipv6 = false
  name = "perf-tyk-${lookup(var.droplet_names, "consumer")}"
  region = "${var.droplet_region}"
  size = "${lookup(var.droplet_sizes, "consumer")}"
  ssh_keys = [
    "${var.ssh_key}"
  ]
  provisioner "local-exec" {
    command = "echo ${self.ipv4_address} ${lookup(var.droplet_names, "consumer")} > hosts/${lookup(var.droplet_names, "consumer")}.ipv4_address.host"
  }
  provisioner "remote-exec" {
    connection {
      user = "core"
    }
    inline = [
      "sudo systemctl enable docker",

      "echo '${digitalocean_droplet.webserver.ipv4_address} webserver' | sudo tee --append /etc/hosts",
      "echo '${digitalocean_droplet.gateway.ipv4_address} gateway' | sudo tee --append /etc/hosts",

      "docker pull rcmorano/docker-hey"
    ]
  }
}
