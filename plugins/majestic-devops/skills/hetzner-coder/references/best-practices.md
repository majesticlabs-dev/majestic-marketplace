# Hetzner Cloud Best Practices

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

## Cost Optimization Tips

- **Use ARM64 (cax)** - Best price/performance for compatible workloads
- **Private networks are free** - No cost for internal traffic
- **Volumes over local storage** - More flexible, persistent across server changes
- **Right-size servers** - Start small, scale up as needed
- **Use labels** - Track costs by project/team
- **Delete unused resources** - Snapshots, volumes, floating IPs still cost money
- **Consider location** - German DCs often cheaper than US

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
