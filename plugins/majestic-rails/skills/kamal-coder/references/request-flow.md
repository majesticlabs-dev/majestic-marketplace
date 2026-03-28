# Request Flow Architecture

## Default Chain

```
Client → kamal-proxy (SSL/routing) → Puma → Rails
```

kamal-proxy handles:
- SSL termination via Let's Encrypt
- Zero-downtime deploy routing (old → new container)
- Health check gating (only routes to healthy containers)
- Multi-app routing on single server

## With Thruster (Optional)

If using [Thruster](https://github.com/basecamp/thruster) as HTTP/2 proxy:

```
Client → kamal-proxy (SSL/routing) → Thruster (compression/caching/HTTP2) → Puma → Rails
```

Thruster adds:
- HTTP/2 support
- Gzip/Brotli compression
- Static asset caching
- X-Sendfile support

Add to Gemfile: `gem "thruster"`. Start with `thrust bin/rails server` in Dockerfile CMD.

## With Cloudflare CDN

```
Client → Cloudflare (CDN/WAF) → kamal-proxy (SSL/routing) → Puma → Rails
```

### Cloudflare Configuration

| Setting | Value | Why |
|---------|-------|-----|
| SSL/TLS mode | **Full** | Cloudflare → server uses Let's Encrypt cert. Not "Flexible" (no encryption to origin). Not "Strict" (Let's Encrypt CA may not be in Cloudflare's trust store) |
| DNS record | Proxied (orange cloud) | Routes through Cloudflare CDN |
| Always Use HTTPS | On | Redirects HTTP → HTTPS at edge |

### ActiveStorage with Cloudflare

Use proxy mode for CDN-cacheable asset URLs:

```ruby
# config/environments/production.rb
config.active_storage.resolve_model_to_route = :rails_storage_proxy
```

This serves assets through Rails (cacheable by Cloudflare) instead of redirect URLs (not cacheable).

## Port Configuration

| Component | Default Port | Configure Via |
|-----------|-------------|---------------|
| kamal-proxy | 80/443 (host) | Automatic |
| Puma | 3000 (container) | `proxy: app_port:` in deploy.yml |
| Thruster | 3000 → upstream | `THRUSTER_PORT` env var |

## Multi-App on Single Server

kamal-proxy routes by hostname — multiple apps share ports 80/443:

```yaml
# App 1: config/deploy.yml
service: app1
proxy:
  host: app1.example.com

# App 2: config/deploy.yml
service: app2
proxy:
  host: app2.example.com
```

Both deploy to the same server. kamal-proxy routes based on `Host` header.
