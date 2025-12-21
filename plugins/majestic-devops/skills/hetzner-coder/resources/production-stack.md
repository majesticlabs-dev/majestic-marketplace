# Complete Production Stack

A complete Hetzner Cloud production setup with app servers, database, load balancer, firewalls, and networking.

```hcl
locals {
  name_prefix = "${var.project}-${var.environment}"
  common_labels = {
    project     = var.project
    environment = var.environment
    managed_by  = "opentofu"
  }
}

# SSH Key
resource "hcloud_ssh_key" "deploy" {
  name       = "${local.name_prefix}-deploy"
  public_key = file(var.ssh_public_key_path)
  labels     = local.common_labels
}

# Private Network
resource "hcloud_network" "private" {
  name     = "${local.name_prefix}-network"
  ip_range = "10.0.0.0/16"
  labels   = local.common_labels
}

resource "hcloud_network_subnet" "private" {
  network_id   = hcloud_network.private.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = "10.0.1.0/24"
}

# Placement Group for HA
resource "hcloud_placement_group" "app" {
  name   = "${local.name_prefix}-spread"
  type   = "spread"
  labels = local.common_labels
}

# App Servers
resource "hcloud_server" "app" {
  count = var.app_count

  name               = "${local.name_prefix}-app-${count.index}"
  server_type        = var.app_server_type
  image              = "ubuntu-24.04"
  location           = var.location
  placement_group_id = hcloud_placement_group.app.id
  ssh_keys           = [hcloud_ssh_key.deploy.id]
  backups            = var.environment == "prod"

  network {
    network_id = hcloud_network.private.id
  }

  user_data = file("${path.module}/cloud-init.yaml")

  labels = merge(local.common_labels, {
    role  = "app"
    index = count.index
  })

  depends_on = [hcloud_network_subnet.private]
}

# Database Server
resource "hcloud_server" "db" {
  name        = "${local.name_prefix}-db"
  server_type = var.db_server_type
  image       = "ubuntu-24.04"
  location    = var.location
  ssh_keys    = [hcloud_ssh_key.deploy.id]
  backups     = true

  network {
    network_id = hcloud_network.private.id
    ip         = "10.0.1.10"
  }

  # No public IP for database
  public_net {
    ipv4_enabled = false
    ipv6_enabled = false
  }

  labels = merge(local.common_labels, {
    role = "database"
  })

  depends_on = [hcloud_network_subnet.private]
}

# Database Volume
resource "hcloud_volume" "db_data" {
  name     = "${local.name_prefix}-db-data"
  size     = var.db_volume_size
  location = var.location
  format   = "ext4"
  labels   = local.common_labels
}

resource "hcloud_volume_attachment" "db_data" {
  volume_id = hcloud_volume.db_data.id
  server_id = hcloud_server.db.id
  automount = true
}

# Firewalls
resource "hcloud_firewall" "app" {
  name = "${local.name_prefix}-app-fw"

  rule {
    description = "SSH"
    direction   = "in"
    protocol    = "tcp"
    port        = "22"
    source_ips  = var.ssh_allowed_ips
  }

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

  apply_to {
    label_selector = "role=app"
  }
}

resource "hcloud_firewall" "db" {
  name = "${local.name_prefix}-db-fw"

  rule {
    description = "PostgreSQL from private network"
    direction   = "in"
    protocol    = "tcp"
    port        = "5432"
    source_ips  = ["10.0.0.0/16"]
  }

  apply_to {
    label_selector = "role=database"
  }
}

# Load Balancer
resource "hcloud_load_balancer" "app" {
  name               = "${local.name_prefix}-lb"
  load_balancer_type = "lb11"
  location           = var.location
  labels             = local.common_labels
}

resource "hcloud_load_balancer_network" "app" {
  load_balancer_id = hcloud_load_balancer.app.id
  network_id       = hcloud_network.private.id
}

resource "hcloud_load_balancer_service" "http" {
  load_balancer_id = hcloud_load_balancer.app.id
  protocol         = "http"
  listen_port      = 80
  destination_port = 3000

  health_check {
    protocol = "http"
    port     = 3000
    interval = 10
    timeout  = 5
  }
}

resource "hcloud_load_balancer_target" "app" {
  count = var.app_count

  load_balancer_id = hcloud_load_balancer.app.id
  type             = "server"
  server_id        = hcloud_server.app[count.index].id
  use_private_ip   = true

  depends_on = [hcloud_load_balancer_network.app]
}

# Outputs
output "load_balancer_ip" {
  value = hcloud_load_balancer.app.ipv4
}

output "app_ips" {
  value = hcloud_server.app[*].ipv4_address
}

output "db_private_ip" {
  value = one(hcloud_server.db.network[*].ip)
}
```
