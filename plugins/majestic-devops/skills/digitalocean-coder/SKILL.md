---
name: digitalocean-coder
description: This skill guides writing DigitalOcean infrastructure with OpenTofu/Terraform. Use when provisioning Droplets, VPCs, Managed Databases, Firewalls, or other DO resources.
allowed-tools: Read, Write, Edit, Grep, Glob, Bash
---

# DigitalOcean Coder

## Overview

DigitalOcean provides simple, developer-friendly cloud infrastructure. This skill covers OpenTofu/Terraform patterns for DO resources.

## Provider Setup

```hcl
terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {
  # Token from environment: DIGITALOCEAN_TOKEN
}
```

## VPC (Virtual Private Cloud)

```hcl
resource "digitalocean_vpc" "main" {
  name     = "${var.project}-${var.environment}-vpc"
  region   = var.region
  ip_range = "10.10.0.0/16"

  description = "VPC for ${var.project} ${var.environment}"
}
```

## Droplets (Compute)

### Basic Droplet

```hcl
resource "digitalocean_droplet" "app" {
  name     = "${var.project}-${var.environment}-app"
  region   = var.region
  size     = var.droplet_size  # s-1vcpu-1gb, s-2vcpu-4gb, etc.
  image    = "ubuntu-22-04-x64"
  vpc_uuid = digitalocean_vpc.main.id

  ssh_keys   = var.ssh_key_ids
  monitoring = true
  ipv6       = false

  tags = [var.project, var.environment]
}
```

### Droplet with Cloud-Init

```hcl
resource "digitalocean_droplet" "app" {
  name     = "${var.project}-app"
  region   = var.region
  size     = "s-1vcpu-2gb"
  image    = "ubuntu-22-04-x64"
  vpc_uuid = digitalocean_vpc.main.id

  ssh_keys   = var.ssh_key_ids
  monitoring = true

  user_data = <<-EOT
    #cloud-config
    package_update: true
    packages:
      - docker.io
      - docker-compose-plugin
    users:
      - name: deploy
        groups: docker
        sudo: ALL=(ALL) NOPASSWD:ALL
        shell: /bin/bash
        ssh_authorized_keys:
          - ${var.deploy_ssh_key}
    runcmd:
      - systemctl enable --now docker
      - sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
      - systemctl restart sshd
  EOT

  tags = [var.project]
}
```

### Common Droplet Sizes

| Size | vCPUs | Memory | Use Case |
|------|-------|--------|----------|
| `s-1vcpu-1gb` | 1 | 1 GB | Testing, small apps |
| `s-1vcpu-2gb` | 1 | 2 GB | Small production |
| `s-2vcpu-4gb` | 2 | 4 GB | Medium apps |
| `s-4vcpu-8gb` | 4 | 8 GB | Production workloads |
| `c-2` | 2 | 4 GB | CPU-intensive |
| `m-2vcpu-16gb` | 2 | 16 GB | Memory-intensive |

## Reserved IP (Static IP)

```hcl
resource "digitalocean_reserved_ip" "app" {
  region = var.region
}

resource "digitalocean_reserved_ip_assignment" "app" {
  ip_address = digitalocean_reserved_ip.app.ip_address
  droplet_id = digitalocean_droplet.app.id
}

output "app_ip" {
  value = digitalocean_reserved_ip.app.ip_address
}
```

## Firewall

### Basic Web Server Firewall

```hcl
resource "digitalocean_firewall" "web" {
  name = "${var.project}-web-firewall"

  droplet_ids = [digitalocean_droplet.app.id]

  # Inbound rules
  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = var.ssh_allowed_ips  # Restrict SSH access
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

  # Outbound rules
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

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}
```

### Dynamic IP Whitelist

```hcl
variable "db_allowed_ips" {
  type        = list(string)
  default     = []
  description = "IPs allowed to access database directly"
}

resource "digitalocean_database_firewall" "postgres" {
  cluster_id = digitalocean_database_cluster.postgres.id

  # Always allow app droplet
  rule {
    type  = "droplet"
    value = digitalocean_droplet.app.id
  }

  # Dynamic IP whitelist for developers
  dynamic "rule" {
    for_each = var.db_allowed_ips
    content {
      type  = "ip_addr"
      value = rule.value
    }
  }
}
```

## Managed Database

### PostgreSQL Cluster

```hcl
resource "digitalocean_database_cluster" "postgres" {
  name       = "${var.project}-${var.environment}-pg"
  engine     = "pg"
  version    = "16"
  size       = var.db_size  # db-s-1vcpu-1gb, db-s-2vcpu-4gb
  region     = var.region
  node_count = 1  # Increase for HA

  # CRITICAL: Use private network
  private_network_uuid = digitalocean_vpc.main.id

  tags = [var.project, var.environment]
}

# Database firewall - restrict access
resource "digitalocean_database_firewall" "postgres" {
  cluster_id = digitalocean_database_cluster.postgres.id

  rule {
    type  = "droplet"
    value = digitalocean_droplet.app.id
  }
}

output "database_uri" {
  value     = digitalocean_database_cluster.postgres.uri
  sensitive = true
}

output "database_private_uri" {
  value     = digitalocean_database_cluster.postgres.private_uri
  sensitive = true
}
```

### Database Sizes

| Size | vCPUs | Memory | Storage | Use Case |
|------|-------|--------|---------|----------|
| `db-s-1vcpu-1gb` | 1 | 1 GB | 10 GB | Development |
| `db-s-1vcpu-2gb` | 1 | 2 GB | 25 GB | Small production |
| `db-s-2vcpu-4gb` | 2 | 4 GB | 38 GB | Production |
| `db-s-4vcpu-8gb` | 4 | 8 GB | 115 GB | High traffic |

### Redis Cluster

```hcl
resource "digitalocean_database_cluster" "redis" {
  name       = "${var.project}-${var.environment}-redis"
  engine     = "redis"
  version    = "7"
  size       = "db-s-1vcpu-1gb"
  region     = var.region
  node_count = 1

  private_network_uuid = digitalocean_vpc.main.id
  tags                 = [var.project]
}
```

## Spaces (Object Storage)

```hcl
resource "digitalocean_spaces_bucket" "assets" {
  name   = "${var.project}-assets"
  region = var.spaces_region  # nyc3, sfo3, ams3, sgp1, fra1

  acl = "private"  # or "public-read"
}

resource "digitalocean_spaces_bucket_cors_configuration" "assets" {
  bucket = digitalocean_spaces_bucket.assets.id
  region = var.spaces_region

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST"]
    allowed_origins = ["https://${var.domain}"]
    max_age_seconds = 3600
  }
}

output "spaces_endpoint" {
  value = digitalocean_spaces_bucket.assets.bucket_domain_name
}
```

## DNS Records

```hcl
resource "digitalocean_domain" "main" {
  name = var.domain
}

resource "digitalocean_record" "app" {
  domain = digitalocean_domain.main.id
  type   = "A"
  name   = "@"
  value  = digitalocean_reserved_ip.app.ip_address
  ttl    = 300
}

resource "digitalocean_record" "www" {
  domain = digitalocean_domain.main.id
  type   = "CNAME"
  name   = "www"
  value  = "@"
  ttl    = 300
}
```

## SSH Keys

```hcl
# Reference existing key
data "digitalocean_ssh_key" "deploy" {
  name = "deploy-key"
}

# Or create new key
resource "digitalocean_ssh_key" "deploy" {
  name       = "${var.project}-deploy"
  public_key = file("~/.ssh/deploy.pub")
}
```

## Complete Production Stack

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

## Best Practices

### Security
- Always use VPC for private networking
- Restrict database to droplet access only
- Use reserved IPs for consistent addressing
- Limit SSH to specific IPs via firewall
- Use cloud-init to disable root login

### Cost Optimization
- Use appropriate droplet sizes
- Single-node databases for non-critical workloads
- Reserved IPs are free when assigned
- Monitor with built-in metrics

### Networking
- Use `private_uri` for database connections
- Place all resources in same VPC
- Use firewall rules, not iptables
- Enable monitoring on droplets
