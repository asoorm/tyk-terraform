# Tyk Production Deployments

Deploys a consistent Tyk installation, every time!

Pre-Requisites

* DigitalOcean account
* Terraform

Deploys

* 1 x Tyk Gateway Node
* 1 x Redis Node
* 1 x GWan web server to mimic an internal webservice
* Installs api definitions from `./apps` to `/opt/tyk-gateway/apps` in gateway container

## Setup

Create a `terraform.tfvars` file in the root directory with the following content.
 
```bash
api_key = "YOUR API KEY"
ssh_key = "YOUR SSH KEY FINGERPRINT FROM DO ACCOUNT SETTINGS"
```

### Usage

```bash
$ terraform plan
$ terraform apply
```

### Take Down

```bash
$ terraform destroy -force
# -force no need for prompt
```

### Perf Test

```bash
// direct webserver test
"docker run --rm rcmorano/docker-hey -n 100000 -c 100 http://webserver:6060/index.json",

// gateway proxy test
"docker run --rm rcmorano/docker-hey -n 100000 -c 100 http://gateway:8080/gwan/index.json",
```
