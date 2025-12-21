# Argo & Load Balancing

## Argo Smart Routing

```hcl
resource "cloudflare_argo" "main" {
  zone_id        = data.cloudflare_zone.main.id
  tiered_caching = "on"
  smart_routing  = "on"
}
```

## Load Balancer

```hcl
# Origin pools
resource "cloudflare_load_balancer_pool" "primary" {
  account_id = var.cloudflare_account_id
  name       = "primary-pool"

  origins {
    name    = "primary-origin"
    address = var.primary_server_ip
    enabled = true
    weight  = 1
  }

  minimum_origins = 1
  monitor         = cloudflare_load_balancer_monitor.http.id

  origin_steering {
    policy = "random"
  }
}

resource "cloudflare_load_balancer_pool" "fallback" {
  account_id = var.cloudflare_account_id
  name       = "fallback-pool"

  origins {
    name    = "fallback-origin"
    address = var.fallback_server_ip
    enabled = true
  }

  minimum_origins = 1
  monitor         = cloudflare_load_balancer_monitor.http.id
}

# Health check monitor
resource "cloudflare_load_balancer_monitor" "http" {
  account_id     = var.cloudflare_account_id
  type           = "http"
  expected_codes = "200"
  method         = "GET"
  path           = "/health"
  interval       = 60
  retries        = 2
  timeout        = 5
  description    = "HTTP health check"
}

# Load balancer
resource "cloudflare_load_balancer" "main" {
  zone_id          = data.cloudflare_zone.main.id
  name             = "lb.example.com"
  default_pool_ids = [cloudflare_load_balancer_pool.primary.id]
  fallback_pool_id = cloudflare_load_balancer_pool.fallback.id
  proxied          = true

  session_affinity = "cookie"
  session_affinity_ttl = 1800

  adaptive_routing {
    failover_across_pools = true
  }
}
```
