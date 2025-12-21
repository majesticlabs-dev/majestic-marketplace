---
name: hetzner-coder
description: This skill guides provisioning Hetzner Cloud infrastructure with OpenTofu/Terraform. Use when creating servers, networks, firewalls, load balancers, or volumes on Hetzner Cloud.
allowed-tools: Read, Write, Edit, Grep, Glob, Bash
---

# Hetzner Coder

## Overview

Hetzner Cloud offers high-performance, cost-effective cloud infrastructure with European data centers. This skill covers OpenTofu/Terraform patterns for Hetzner resources.

## Provider Setup

```hcl
terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.50"
    }
  }
}

provider "hcloud" {
  # Token from environment: HCLOUD_TOKEN
  # Or explicitly (not recommended):
  # token = var.hcloud_token
}
```

### Authentication

```bash
# Set token via environment variable
export HCLOUD_TOKEN="your-api-token"

# Or with 1Password
HCLOUD_TOKEN=op://Infrastructure/Hetzner/api_token
```

**Token Permissions:**
- **Read** - GET requests only (monitoring, auditing)
- **Read & Write** - Full access (required for Terraform)

## Locations and Datacenters

| Location | Code | Region | Network Zone |
|----------|------|--------|--------------|
| Falkenstein | `fsn1` | Germany | `eu-central` |
| Nuremberg | `nbg1` | Germany | `eu-central` |
| Helsinki | `hel1` | Finland | `eu-central` |
| Ashburn | `ash` | US East | `us-east` |
| Hillsboro | `hil` | US West | `us-west` |

## Server Types

### Shared CPU (Best for general workloads)

| Type | vCPUs | RAM | Storage | Best For |
|------|-------|-----|---------|----------|
| `cx22` | 2 | 4 GB | 40 GB | Small apps |
| `cx32` | 4 | 8 GB | 80 GB | Medium apps |
| `cx42` | 8 | 16 GB | 160 GB | Production |
| `cx52` | 16 | 32 GB | 320 GB | High traffic |

### AMD EPYC (CPX - Better single-thread)

| Type | vCPUs | RAM | Storage |
|------|-------|-----|---------|
| `cpx11` | 2 | 2 GB | 40 GB |
| `cpx21` | 3 | 4 GB | 80 GB |
| `cpx31` | 4 | 8 GB | 160 GB |
| `cpx41` | 8 | 16 GB | 240 GB |
| `cpx51` | 16 | 32 GB | 360 GB |

### ARM64 (CAX - Best price/performance)

| Type | vCPUs | RAM | Storage |
|------|-------|-----|---------|
| `cax11` | 2 | 4 GB | 40 GB |
| `cax21` | 4 | 8 GB | 80 GB |
| `cax31` | 8 | 16 GB | 160 GB |
| `cax41` | 16 | 32 GB | 320 GB |

### Dedicated vCPU (CCX - Guaranteed resources)

| Type | vCPUs | RAM | Storage |
|------|-------|-----|---------|
| `ccx13` | 2 | 8 GB | 80 GB |
| `ccx23` | 4 | 16 GB | 160 GB |
| `ccx33` | 8 | 32 GB | 240 GB |
| `ccx43` | 16 | 64 GB | 360 GB |

## Servers (Compute)

### Basic Server

```hcl
resource "hcloud_server" "app" {
  name        = "${var.project}-${var.environment}-app"
  server_type = "cx22"
  image       = "ubuntu-24.04"
  location    = "fsn1"

  ssh_keys = [hcloud_ssh_key.deploy.id]

  labels = {
    environment = var.environment
    project     = var.project
    role        = "app"
  }

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }
}
```

### Server with Cloud-Init

```hcl
resource "hcloud_server" "app" {
  name        = "${var.project}-app"
  server_type = "cx22"
  image       = "ubuntu-24.04"
  location    = "fsn1"

  ssh_keys = [hcloud_ssh_key.deploy.id]

  user_data = <<-EOT
    #cloud-config
    package_update: true
    packages:
      - docker.io
      - docker-compose-plugin

    users:
      - name: deploy
        groups: docker, sudo
        sudo: ALL=(ALL) NOPASSWD:ALL
        shell: /bin/bash
        ssh_authorized_keys:
          - ${var.deploy_ssh_key}

    runcmd:
      - systemctl enable --now docker
      - sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
      - sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
      - systemctl restart sshd
  EOT

  labels = {
    environment = var.environment
    role        = "app"
  }
}
```

### ARM64 Server (Cost-Effective)

```hcl
resource "hcloud_server" "worker" {
  name        = "${var.project}-worker"
  server_type = "cax21"  # ARM64 - great price/performance
  image       = "ubuntu-24.04"
  location    = "fsn1"

  ssh_keys = [hcloud_ssh_key.deploy.id]

  labels = {
    role = "worker"
    arch = "arm64"
  }
}
```

## Private Networks

### Network with Subnet

```hcl
resource "hcloud_network" "private" {
  name     = "${var.project}-network"
  ip_range = "10.0.0.0/16"

  labels = {
    project = var.project
  }
}

resource "hcloud_network_subnet" "private" {
  network_id   = hcloud_network.private.id
  type         = "cloud"
  network_zone = "eu-central"  # Must match server location zone
  ip_range     = "10.0.1.0/24"
}
```

### Server in Private Network

```hcl
resource "hcloud_server" "db" {
  name        = "${var.project}-db"
  server_type = "cpx31"
  image       = "ubuntu-24.04"
  location    = "fsn1"

  ssh_keys = [hcloud_ssh_key.deploy.id]

  # Attach to private network
  network {
    network_id = hcloud_network.private.id
    ip         = "10.0.1.10"  # Optional: specific IP
  }

  # Optionally disable public IP for security
  public_net {
    ipv4_enabled = false
    ipv6_enabled = false
  }

  labels = {
    role = "database"
  }

  depends_on = [hcloud_network_subnet.private]
}
```

## Firewalls

### Web Server Firewall

```hcl
resource "hcloud_firewall" "web" {
  name = "${var.project}-web-firewall"

  # SSH from specific IPs only
  rule {
    description = "SSH"
    direction   = "in"
    protocol    = "tcp"
    port        = "22"
    source_ips  = var.ssh_allowed_ips
  }

  # HTTP/HTTPS from anywhere
  rule {
    description = "HTTP"
    direction   = "in"
    protocol    = "tcp"
    port        = "80"
    source_ips  = ["0.0.0.0/0", "::/0"]
  }

  rule {
    description = "HTTPS"
    direction   = "in"
    protocol    = "tcp"
    port        = "443"
    source_ips  = ["0.0.0.0/0", "::/0"]
  }

  # Apply to servers with label
  apply_to {
    label_selector = "role=web"
  }
}
```

### Database Firewall (Private Only)

```hcl
resource "hcloud_firewall" "db" {
  name = "${var.project}-db-firewall"

  # PostgreSQL from private network only
  rule {
    description = "PostgreSQL"
    direction   = "in"
    protocol    = "tcp"
    port        = "5432"
    source_ips  = ["10.0.0.0/16"]  # Private network range
  }

  # SSH from bastion only
  rule {
    description = "SSH from bastion"
    direction   = "in"
    protocol    = "tcp"
    port        = "22"
    source_ips  = ["10.0.1.1/32"]  # Bastion IP
  }

  apply_to {
    label_selector = "role=database"
  }
}
```

## Floating IPs (High Availability)

```hcl
resource "hcloud_floating_ip" "app" {
  type          = "ipv4"
  name          = "${var.project}-vip"
  home_location = "fsn1"

  labels = {
    project = var.project
    purpose = "failover"
  }
}

resource "hcloud_floating_ip_assignment" "app" {
  floating_ip_id = hcloud_floating_ip.app.id
  server_id      = hcloud_server.app.id
}

output "floating_ip" {
  value = hcloud_floating_ip.app.ip_address
}
```

## Load Balancers

### HTTP Load Balancer

```hcl
resource "hcloud_load_balancer" "web" {
  name               = "${var.project}-lb"
  load_balancer_type = "lb11"
  location           = "fsn1"

  labels = {
    project = var.project
  }
}

resource "hcloud_load_balancer_network" "web" {
  load_balancer_id = hcloud_load_balancer.web.id
  network_id       = hcloud_network.private.id
  ip               = "10.0.1.100"
}

resource "hcloud_load_balancer_service" "http" {
  load_balancer_id = hcloud_load_balancer.web.id
  protocol         = "http"
  listen_port      = 80
  destination_port = 8080

  health_check {
    protocol = "http"
    port     = 8080
    interval = 10
    timeout  = 5
    retries  = 3

    http {
      path         = "/health"
      status_codes = ["200"]
    }
  }
}

resource "hcloud_load_balancer_target" "web" {
  load_balancer_id = hcloud_load_balancer.web.id
  type             = "server"
  server_id        = hcloud_server.app.id
  use_private_ip   = true

  depends_on = [hcloud_load_balancer_network.web]
}
```

### HTTPS Load Balancer with Certificate

```hcl
resource "hcloud_managed_certificate" "web" {
  name         = "${var.project}-cert"
  domain_names = [var.domain, "www.${var.domain}"]

  labels = {
    project = var.project
  }
}

resource "hcloud_load_balancer_service" "https" {
  load_balancer_id = hcloud_load_balancer.web.id
  protocol         = "https"
  listen_port      = 443
  destination_port = 8080

  http {
    certificates = [hcloud_managed_certificate.web.id]
    redirect_http = true
  }

  health_check {
    protocol = "http"
    port     = 8080
    interval = 10
    timeout  = 5
  }
}
```

## Volumes (Persistent Storage)

```hcl
resource "hcloud_volume" "data" {
  name      = "${var.project}-data"
  size      = 100  # GB
  location  = "fsn1"
  format    = "ext4"

  labels = {
    project = var.project
    purpose = "database"
  }
}

resource "hcloud_volume_attachment" "data" {
  volume_id = hcloud_volume.data.id
  server_id = hcloud_server.db.id
  automount = true
}
```

## SSH Keys

```hcl
resource "hcloud_ssh_key" "deploy" {
  name       = "${var.project}-deploy"
  public_key = file(var.ssh_public_key_path)

  labels = {
    project = var.project
    purpose = "deployment"
  }
}
```

## Placement Groups (High Availability)

```hcl
resource "hcloud_placement_group" "spread" {
  name = "${var.project}-spread"
  type = "spread"  # Distribute across physical hosts

  labels = {
    project = var.project
  }
}

resource "hcloud_server" "app" {
  count = 3

  name              = "${var.project}-app-${count.index}"
  server_type       = "cx22"
  image             = "ubuntu-24.04"
  location          = "fsn1"
  placement_group_id = hcloud_placement_group.spread.id

  ssh_keys = [hcloud_ssh_key.deploy.id]

  labels = {
    project = var.project
    role    = "app"
    index   = count.index
  }
}
```

## Snapshots and Backups

### Enable Automatic Backups

```hcl
resource "hcloud_server" "app" {
  name        = "${var.project}-app"
  server_type = "cx22"
  image       = "ubuntu-24.04"
  location    = "fsn1"

  backups = true  # Enable automatic backups (20% surcharge)

  ssh_keys = [hcloud_ssh_key.deploy.id]
}
```

### Manual Snapshot

```hcl
resource "hcloud_snapshot" "before_upgrade" {
  server_id   = hcloud_server.app.id
  description = "Snapshot before major upgrade"

  labels = {
    project = var.project
    purpose = "pre-upgrade"
  }
}
```

## Labels Best Practices

Use consistent labels for organization and filtering:

```hcl
locals {
  common_labels = {
    project     = var.project
    environment = var.environment
    managed_by  = "opentofu"
  }
}

resource "hcloud_server" "app" {
  # ...
  labels = merge(local.common_labels, {
    role      = "app"
    component = "api"
  })
}

resource "hcloud_network" "private" {
  # ...
  labels = local.common_labels
}
```

**Recommended label schema:**

| Key | Values | Purpose |
|-----|--------|---------|
| `environment` | `prod`, `staging`, `dev` | Environment separation |
| `project` | Your project name | Project grouping |
| `role` | `web`, `api`, `db`, `worker` | Server role |
| `team` | Team name | Cost allocation |
| `managed_by` | `opentofu`, `terraform` | IaC tracking |

## Complete Production Stack

See [resources/production-stack.md](resources/production-stack.md) for a complete production setup with app servers, database, load balancer, firewalls, volumes, and networking.

## Cost Optimization Tips

- **Use ARM64 (cax)** - Best price/performance for compatible workloads
- **Private networks are free** - No cost for internal traffic
- **Volumes over local storage** - More flexible, persistent across server changes
- **Right-size servers** - Start small, scale up as needed
- **Use labels** - Track costs by project/team
- **Delete unused resources** - Snapshots, volumes, floating IPs still cost money
- **Consider location** - German DCs often cheaper than US
