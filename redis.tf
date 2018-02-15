resource "digitalocean_droplet" "redis" {
  image = "${var.droplet_image}"
  private_networking = true
  ipv6 = false
  name = "perf-tyk-${lookup(var.droplet_names, "redis")}"
  region = "${var.droplet_region}"
  size = "${lookup(var.droplet_sizes, "redis")}"
  ssh_keys = [
    "${var.ssh_key}"
  ]
  provisioner "local-exec" {
    command = "echo ${self.ipv4_address} ${lookup(var.droplet_names, "redis")} > hosts/${lookup(var.droplet_names, "redis")}.ipv4_address.host"
  }
  provisioner "local-exec" {
    command = "echo ${self.ipv4_address_private} ${lookup(var.droplet_names, "redis")} > hosts/${lookup(var.droplet_names, "redis")}.ipv4_address_private.host"
  }
  provisioner "remote-exec" {
    connection {
      user = "core"
    }
    inline = [
      "sudo systemctl enable docker",
      "docker run -itd --rm --name redis -p ${self.ipv4_address_private}:6379:6379 redis:4.0-alpine",
    ]
  }
}
