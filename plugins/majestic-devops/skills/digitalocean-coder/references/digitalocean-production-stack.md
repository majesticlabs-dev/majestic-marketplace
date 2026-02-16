# DigitalOcean Complete Production Stack

```hcl
locals {
  name_prefix = "${var.project}-${var.environment}"
}

# VPC
resource "digitalocean_vpc" "main" {
  name     = "${local.name_prefix}-vpc"
  region   = var.region
  ip_range = "10.10.0.0/16"
}

# App Server
resource "digitalocean_droplet" "app" {
  name     = "${local.name_prefix}-app"
  region   = var.region
  size     = var.droplet_size
  image    = "ubuntu-22-04-x64"
  vpc_uuid = digitalocean_vpc.main.id

  ssh_keys   = [data.digitalocean_ssh_key.deploy.id]
  monitoring = true

  user_data = file("${path.module}/cloud-init.yaml")
  tags      = [var.project, var.environment]
}

# Static IP
resource "digitalocean_reserved_ip" "app" {
  region = var.region
}

resource "digitalocean_reserved_ip_assignment" "app" {
  ip_address = digitalocean_reserved_ip.app.ip_address
  droplet_id = digitalocean_droplet.app.id
}

# Firewall
resource "digitalocean_firewall" "app" {
  name        = "${local.name_prefix}-firewall"
  droplet_ids = [digitalocean_droplet.app.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = var.ssh_allowed_ips
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
    port_range            = "all"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "all"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

# Database
resource "digitalocean_database_cluster" "postgres" {
  name                 = "${local.name_prefix}-pg"
  engine               = "pg"
  version              = "16"
  size                 = var.db_size
  region               = var.region
  node_count           = 1
  private_network_uuid = digitalocean_vpc.main.id
  tags                 = [var.project]
}

resource "digitalocean_database_firewall" "postgres" {
  cluster_id = digitalocean_database_cluster.postgres.id

  rule {
    type  = "droplet"
    value = digitalocean_droplet.app.id
  }
}

# Outputs
output "app_ip" {
  value = digitalocean_reserved_ip.app.ip_address
}

output "database_uri" {
  value     = digitalocean_database_cluster.postgres.private_uri
  sensitive = true
}
```
