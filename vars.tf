variable "api_key" {
  type = "string"
  description = "DigitalOcean API key"
  default = ""
}

variable "ssh_key" {
  description = "SSH Key for provisioning"
  default = ""
}

variable "droplet_region" {
  type = "string"
  default = "lon1"
}

# Get a list of usable image slugs from DO API.
# curl https://api.digitalocean.com/v2/images -H 'Authorization: Bearer DO_API_KEY'
variable "droplet_image" {
  default = "coreos-stable"
}

variable "droplet_sizes" {
  type = "map"
  default = {
    "swarm-manager" = "512mb"
    "swarm-worker" = "4gb"
    "gateway" = "2gb"
    "redis" = "2gb"
    "webserver" = "2gb"
    "consumer" = "2gb"
  }
}

variable "droplet_names" {
  type = "map"
  default = {
    "gateway" = "gateway"
    "redis" = "redis"
    "webserver" = "webserver"
    "consumer" = "consumer"
  }
}
