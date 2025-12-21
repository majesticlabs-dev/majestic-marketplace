# Complete Production Zone Example

A complete Terraform configuration for a production-ready Cloudflare zone with DNS, SSL/TLS, WAF, caching, and redirects.

```hcl
locals {
  domain = var.domain
}

# Zone data
data "cloudflare_zone" "main" {
  name = local.domain
}

# DNS Records
resource "cloudflare_record" "root" {
  zone_id = data.cloudflare_zone.main.id
  name    = "@"
  type    = "A"
  content = var.server_ip
  ttl     = 1
  proxied = true
}

resource "cloudflare_record" "www" {
  zone_id = data.cloudflare_zone.main.id
  name    = "www"
  type    = "CNAME"
  content = "@"
  ttl     = 1
  proxied = true
}

# SSL/TLS - Strict mode
resource "cloudflare_zone_settings_override" "ssl" {
  zone_id = data.cloudflare_zone.main.id

  settings {
    ssl                      = "strict"
    min_tls_version          = "1.2"
    tls_1_3                  = "on"
    always_use_https         = "on"
    automatic_https_rewrites = "on"

    security_header {
      enabled            = true
      max_age            = 31536000
      include_subdomains = true
      preload            = true
      nosniff            = true
    }
  }
}

# Performance settings
resource "cloudflare_zone_settings_override" "performance" {
  zone_id = data.cloudflare_zone.main.id

  settings {
    brotli       = "on"
    early_hints  = "on"
    http2        = "on"
    http3        = "on"
    zero_rtt     = "on"

    minify {
      css  = "on"
      html = "on"
      js   = "on"
    }
  }
}

# Security settings
resource "cloudflare_zone_settings_override" "security" {
  zone_id = data.cloudflare_zone.main.id

  settings {
    security_level      = "medium"
    challenge_ttl       = 1800
    browser_check       = "on"
    email_obfuscation   = "on"
    hotlink_protection  = "on"
  }
}

# WAF - Managed rulesets
resource "cloudflare_ruleset" "waf" {
  zone_id     = data.cloudflare_zone.main.id
  name        = "Managed WAF"
  description = "Cloudflare managed security rules"
  kind        = "zone"
  phase       = "http_request_firewall_managed"

  rules {
    action = "execute"
    action_parameters {
      id = "efb7b8c949ac4650a09736fc376e9aee"
    }
    expression  = "true"
    description = "Cloudflare Managed Ruleset"
    enabled     = true
  }
}

# Cache rules
resource "cloudflare_ruleset" "cache" {
  zone_id     = data.cloudflare_zone.main.id
  name        = "Cache Configuration"
  description = "Caching rules"
  kind        = "zone"
  phase       = "http_request_cache_settings"

  rules {
    action = "set_cache_settings"
    action_parameters {
      cache = true
      edge_ttl {
        mode    = "override_origin"
        default = 2592000
      }
    }
    expression  = "(http.request.uri.path.extension in {\"css\" \"js\" \"jpg\" \"jpeg\" \"png\" \"gif\" \"svg\" \"woff\" \"woff2\" \"ico\"})"
    description = "Cache static assets"
    enabled     = true
  }

  rules {
    action = "set_cache_settings"
    action_parameters {
      cache = false
    }
    expression  = "(starts_with(http.request.uri.path, \"/api/\") or starts_with(http.request.uri.path, \"/admin\"))"
    description = "Bypass cache for dynamic paths"
    enabled     = true
  }
}

# Redirect www to apex
resource "cloudflare_ruleset" "redirects" {
  zone_id     = data.cloudflare_zone.main.id
  name        = "Redirects"
  description = "URL redirects"
  kind        = "zone"
  phase       = "http_request_dynamic_redirect"

  rules {
    action = "redirect"
    action_parameters {
      from_value {
        status_code = 301
        target_url {
          expression = "concat(\"https://${local.domain}\", http.request.uri.path)"
        }
        preserve_query_string = true
      }
    }
    expression  = "(http.host eq \"www.${local.domain}\")"
    description = "Redirect www to apex"
    enabled     = true
  }
}

# Outputs
output "zone_id" {
  value = data.cloudflare_zone.main.id
}

output "nameservers" {
  value = data.cloudflare_zone.main.name_servers
}
```

## Variables Template

```hcl
variable "cloudflare_account_id" {
  description = "Cloudflare account ID"
  type        = string
}

variable "domain" {
  description = "Domain name"
  type        = string
}

variable "server_ip" {
  description = "Origin server IP"
  type        = string
}

variable "environment" {
  description = "Environment (prod, staging, dev)"
  type        = string
  default     = "prod"
}

variable "ssh_allowed_ips" {
  description = "IPs allowed for SSH access"
  type        = list(string)
  default     = []
}
```
