terraform {
  required_version = ">= 1.5.0"
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.36"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

variable "do_token" { type = string }
variable "region"   { type = string  default = "fra1" }
variable "size"     { type = string  default = "s-1vcpu-1gb" }
variable "image"    { type = string  default = "ubuntu-22-04-x64" }
variable "ssh_key_fingerprint" { type = string }
variable "domain" { type = string }
variable "subdomain" { type = string  default = "krainet" }

resource "digitalocean_droplet" "app" {
  name   = "${var.subdomain}.${var.domain}"
  region = var.region
  size   = var.size
  image  = var.image

  ssh_keys = [var.ssh_key_fingerprint]

  monitoring = true

  lifecycle { create_before_destroy = true }
}

resource "digitalocean_firewall" "app_fw" {
  name = "${var.subdomain}-fw"

  droplet_ids = [digitalocean_droplet.app.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

# Read existing DNS zone instead of creating it
data "digitalocean_domain" "root" {
  name = var.domain
}

resource "digitalocean_record" "app_a" {
  domain = data.digitalocean_domain.root.name
  type   = "A"
  name   = var.subdomain
  value  = digitalocean_droplet.app.ipv4_address
  ttl    = 60
}

output "droplet_ip" {
  value = digitalocean_droplet.app.ipv4_address
}

