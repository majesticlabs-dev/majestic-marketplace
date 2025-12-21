# Firewall & WAF

## IP Access Rules

```hcl
# Block specific IP
resource "cloudflare_access_rule" "block_bad_actor" {
  zone_id = data.cloudflare_zone.main.id
  mode    = "block"
  notes   = "Blocked for abuse"

  configuration {
    target = "ip"
    value  = "1.2.3.4"
  }
}

# Allow office IP range
resource "cloudflare_access_rule" "allow_office" {
  zone_id = data.cloudflare_zone.main.id
  mode    = "whitelist"
  notes   = "Office network"

  configuration {
    target = "ip_range"
    value  = "203.0.113.0/24"
  }
}

# Block country
resource "cloudflare_access_rule" "block_country" {
  zone_id = data.cloudflare_zone.main.id
  mode    = "block"
  notes   = "High-risk country"

  configuration {
    target = "country"
    value  = "XX"
  }
}
```

## WAF Custom Rules (Rulesets)

```hcl
resource "cloudflare_ruleset" "waf_custom" {
  zone_id     = data.cloudflare_zone.main.id
  name        = "Custom WAF Rules"
  description = "Application-specific WAF rules"
  kind        = "zone"
  phase       = "http_request_firewall_custom"

  # Block requests to admin without auth header
  rules {
    action      = "block"
    expression  = "(starts_with(http.request.uri.path, \"/admin\") and not http.request.headers[\"x-admin-key\"][0] eq \"${var.admin_key}\")"
    description = "Block unauthorized admin access"
    enabled     = true
  }

  # Challenge suspicious login attempts
  rules {
    action      = "managed_challenge"
    expression  = "(http.request.uri.path eq \"/login\" and http.request.method eq \"POST\" and ip.geoip.country ne \"US\")"
    description = "Challenge non-US login attempts"
    enabled     = true
  }

  # Rate limit API
  rules {
    action = "block"
    ratelimit {
      characteristics     = ["ip.src"]
      period              = 60
      requests_per_period = 100
      mitigation_timeout  = 600
    }
    expression  = "(starts_with(http.request.uri.path, \"/api/\"))"
    description = "Rate limit API to 100 req/min per IP"
    enabled     = true
  }
}
```

## Managed WAF Rulesets

```hcl
resource "cloudflare_ruleset" "waf_managed" {
  zone_id     = data.cloudflare_zone.main.id
  name        = "Managed WAF"
  description = "Deploy Cloudflare managed rulesets"
  kind        = "zone"
  phase       = "http_request_firewall_managed"

  # Cloudflare Managed Ruleset
  rules {
    action = "execute"
    action_parameters {
      id = "efb7b8c949ac4650a09736fc376e9aee"  # Cloudflare Managed Ruleset
    }
    expression  = "true"
    description = "Execute Cloudflare Managed Ruleset"
    enabled     = true
  }

  # OWASP Core Ruleset
  rules {
    action = "execute"
    action_parameters {
      id = "4814384a9e5d4991b9815dcfc25d2f1f"  # OWASP Core Ruleset
    }
    expression  = "true"
    description = "Execute OWASP Core Ruleset"
    enabled     = true
  }
}
```
