---
name: kamal-coder
description: This skill guides deploying Rails applications with Kamal 2. Use when configuring deploy.yml, setting up kamal-proxy, managing secrets, accessories, or preparing servers for container deployment.
allowed-tools: Read Write Edit Grep Glob Bash
---

# Kamal 2 Coder

Servers need Docker, SSH access, and ports 22/80/443 open. Provision with Ansible or cloud-init.

## Configuration: config/deploy.yml

### Minimal Setup

```yaml
service: myapp
image: myapp

servers:
  web:
    - 203.0.113.10

proxy:
  ssl: true
  host: myapp.com

registry:
  username: username
  password:
    - KAMAL_REGISTRY_PASSWORD

env:
  clear:
    RAILS_ENV: production
    RAILS_LOG_TO_STDOUT: "true"
  secret:
    - RAILS_MASTER_KEY
```

### Multi-Role Setup (Web + Job Worker)

```yaml
service: myapp
image: myapp

servers:
  web:
    - 203.0.113.10
  job:
    hosts:
      - 203.0.113.10
    cmd: bin/jobs start

proxy:
  ssl: true
  host: myapp.com

registry:
  username: username
  password:
    - KAMAL_REGISTRY_PASSWORD

env:
  clear:
    RAILS_ENV: production
    SOLID_QUEUE_IN_PUMA: false
  secret:
    - RAILS_MASTER_KEY
```

**Job worker notes:**
- `cmd: bin/jobs start` runs Solid Queue in a separate container
- Set `SOLID_QUEUE_IN_PUMA: false` to disable in-process queue
- Job role has no proxy — only web role serves HTTP traffic

### With Local Registry

Eliminates Docker Hub dependency, rate limits, and external costs:

```yaml
registry:
  server: localhost:5555
  username: ignored
  password:
    - KAMAL_REGISTRY_PASSWORD
```

Deploy the registry as an accessory:

```yaml
accessories:
  registry:
    image: registry:2
    host: 203.0.113.10
    port: "5555:5000"
    volumes:
      - registry_data:/var/lib/registry
```

### With Accessories

```yaml
accessories:
  db:
    image: postgres:16
    host: 203.0.113.10
    port: 5432
    env:
      clear:
        POSTGRES_DB: myapp_production
      secret:
        - POSTGRES_PASSWORD
    directories:
      - data:/var/lib/postgresql/data
    options:
      shm-size: 256m

  redis:
    image: redis:7-alpine
    host: 203.0.113.10
    port: 6379
    directories:
      - data:/data
    cmd: redis-server --appendonly yes
```

### Docker Volumes for Persistence

For SQLite + ActiveStorage apps, mount a named volume:

```yaml
servers:
  web:
    hosts:
      - 203.0.113.10
    volumes:
      - myapp_storage:/rails/storage
    labels:
      docker-volume-backup.stop-during-backup: "true"
  job:
    hosts:
      - 203.0.113.10
    cmd: bin/jobs start
    volumes:
      - myapp_storage:/rails/storage
```

Both web and job containers share the same volume for database access.

## Proxy Configuration (kamal-proxy)

Kamal 2 uses kamal-proxy (not Traefik). It handles SSL termination, routing, and zero-downtime deploys.

### Basic SSL

```yaml
proxy:
  ssl: true
  host: myapp.com
```

Automatic Let's Encrypt certificate provisioning — no manual cert management.

### Custom Port

```yaml
proxy:
  ssl: true
  host: myapp.com
  app_port: 3000
```

### Multiple Hosts

```yaml
proxy:
  ssl: true
  hosts:
    - myapp.com
    - www.myapp.com
```

### Health Check

```yaml
proxy:
  ssl: true
  host: myapp.com
  healthcheck:
    path: /up
    interval: 3
    timeout: 3
```

### Response Timeout

```yaml
proxy:
  ssl: true
  host: myapp.com
  response_timeout: 30
```

## Secrets: .kamal/secrets

Kamal reads secrets from `.kamal/secrets` (git-ignored).

### With 1Password CLI

```bash
KAMAL_REGISTRY_PASSWORD=$(op read "op://Infrastructure/DockerHub/password")
RAILS_MASTER_KEY=$(op read "op://MyApp/production/master_key")
DATABASE_URL=$(op read "op://MyApp/production/database_url")
```

### With Environment Variables

```bash
KAMAL_REGISTRY_PASSWORD=$DOCKERHUB_TOKEN
RAILS_MASTER_KEY=$RAILS_MASTER_KEY
DATABASE_URL=$DATABASE_URL
```

### Multi-Environment

```yaml
# config/deploy.yml — base config
service: myapp

# config/deploy.staging.yml — overrides
service: myapp-staging
servers:
  web:
    - 203.0.113.20
proxy:
  host: staging.myapp.com
```

```bash
# .kamal/secrets.staging
RAILS_MASTER_KEY=$(op read "op://MyApp/staging/master_key")
```

Deploy with: `kamal deploy -d staging`

## Common Commands

### First Deployment

```bash
# One-time: installs kamal-proxy, pushes image, deploys
kamal setup

# Subsequent: builds, pushes, rolling restart
kamal deploy
```

### Regular Operations

```bash
kamal deploy                    # Deploy latest
kamal deploy --version=abc123   # Deploy specific version
kamal deploy -d staging         # Deploy to staging
kamal redeploy                  # Redeploy without building
```

### Rollback

```bash
kamal app containers            # List available versions
kamal rollback <version>        # Rollback to specific version
```

### Debugging

```bash
kamal app exec --interactive bash              # Shell into container
kamal app logs -f                              # Tail logs
kamal app exec --interactive "bin/rails console"  # Rails console
kamal app exec "bin/rails db:migrate"          # Run migrations
```

### Accessories

```bash
kamal accessory boot all        # Start all accessories
kamal accessory reboot db       # Restart specific accessory
kamal accessory exec db --interactive "psql -U postgres"
kamal accessory logs litestream  # View accessory logs
```

## Builder Configuration

### Native Builds

```yaml
builder:
  arch: amd64
```

### Multi-Architecture

```yaml
builder:
  multiarch: true
```

### Remote Builder

```yaml
builder:
  remote:
    arch: amd64
    host: ssh://builder@build-server
```

### Build Arguments

```yaml
builder:
  args:
    RUBY_VERSION: "3.3.0"
```

## Hooks

### Pre-Deploy

```bash
# .kamal/hooks/pre-deploy
#!/bin/sh
echo "Running pre-deploy checks..."
```

### Post-Deploy

```bash
# .kamal/hooks/post-deploy
#!/bin/sh
echo "Deploy complete: $(date)"
curl -s https://notify.example.com/deploy
```

## Provisioning Workflow

### Ansible + Kamal Pipeline

```bash
# 1. Ansible: Configure server
ansible-playbook -i hosts.ini playbook.yml

# 2. Kamal: Bootstrap and deploy
kamal setup
```

### What Ansible Should Configure

Based on [kamal-ansible-manager](https://github.com/guillaumebriday/kamal-ansible-manager):

| Task | Purpose |
|------|---------|
| Install Docker | Container runtime |
| Configure fail2ban | SSH intrusion prevention |
| Setup UFW | Firewall (22, 80, 443) |
| Enable NTP | Time synchronization |
| Create swap | Memory overflow protection |
| Harden SSH | Disable password auth, root login |
| Unattended upgrades | Automatic security patches |

## Litestream Backup Accessory

For SQLite apps, add Litestream as an accessory (see `litestream-coder` for full config):

```yaml
accessories:
  litestream:
    image: litestream/litestream:0.3
    host: 203.0.113.10
    cmd: replicate
    volumes:
      - myapp_storage:/rails/storage:ro
    files:
      - config/litestream.yml:/etc/litestream.yml
    env:
      secret:
        - LITESTREAM_ACCESS_KEY_ID
        - LITESTREAM_SECRET_ACCESS_KEY
```

Mount storage as read-only (`:ro`) — Litestream only reads WAL files.

## Directory Structure

```
myapp/
├── config/
│   ├── deploy.yml           # Main Kamal config
│   └── deploy.staging.yml   # Staging overrides
├── .kamal/
│   ├── secrets              # Production secrets (git-ignored)
│   ├── secrets.staging      # Staging secrets (git-ignored)
│   └── hooks/
│       ├── pre-deploy
│       └── post-deploy
├── Dockerfile               # Application container
└── docker-entrypoint.sh     # Entrypoint script
```

## Troubleshooting

| Issue | Cause | Fix |
|-------|-------|-----|
| Connection refused | Docker not running | `kamal setup` or check Docker service |
| Permission denied | SSH key not authorized | Check server's `authorized_keys` |
| Health check failing | App not starting | Check `kamal app logs` |
| Registry auth failed | Wrong credentials | Verify `.kamal/secrets` |
| 502 Bad Gateway | Container not healthy | Increase healthcheck timeout |
| SSL cert not issued | DNS not pointing to server | Verify DNS A record |
| Asset 404 after deploy | Volume not mounted | Check `volumes:` in deploy.yml |

## References

- [references/request-flow.md](references/request-flow.md) — Request architecture and Cloudflare integration
- [references/docker-patterns.md](references/docker-patterns.md) — Production Dockerfile, entrypoint, and volume patterns
