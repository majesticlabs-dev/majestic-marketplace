---
name: onepassword-cli-coder
description: This skill guides integrating 1Password CLI (op) for secret management in development workflows. Use when loading secrets for infrastructure, deployments, or local development.
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# 1Password CLI Coder

## Overview

The 1Password CLI (`op`) provides secure secret injection into development workflows without exposing credentials in code, environment files, or shell history.

## Core Patterns

### Secret Reference Format

```
op://<vault>/<item>/<field>
```

Examples:
```
op://Development/AWS/access_key_id
op://Production/Database/password
op://Shared/Stripe/secret_key
```

### Environment File (.op.env)

Create `.op.env` in project root:

```bash
# AWS credentials
AWS_ACCESS_KEY_ID=op://Infrastructure/AWS/access_key_id
AWS_SECRET_ACCESS_KEY=op://Infrastructure/AWS/secret_access_key
AWS_REGION=op://Infrastructure/AWS/region

# DigitalOcean
DIGITALOCEAN_TOKEN=op://Infrastructure/DigitalOcean/api_token

# Database
DATABASE_URL=op://Production/PostgreSQL/connection_string

# API Keys
STRIPE_SECRET_KEY=op://Production/Stripe/secret_key
OPENAI_API_KEY=op://Development/OpenAI/api_key
```

**Critical:** Add to `.gitignore`:
```gitignore
# 1Password - NEVER commit
.op.env
*.op.env
```

### Running Commands with Secrets

```bash
# Single command
op run --env-file=.op.env -- terraform plan

# With environment variable prefix
op run --env-file=.op.env -- rails server

# Inline secret reference
op run -- printenv DATABASE_URL
```

## Integration Patterns

### Makefile Integration

```makefile
OP ?= op
OP_ENV_FILE ?= .op.env

# Prefix for all commands needing secrets
CMD = $(OP) run --env-file=$(OP_ENV_FILE) --

deploy:
	$(CMD) kamal deploy

console:
	$(CMD) rails console

migrate:
	$(CMD) rails db:migrate
```

### Docker Compose

```yaml
# docker-compose.yml
services:
  app:
    build: .
    environment:
      - DATABASE_URL=${DATABASE_URL}
      - REDIS_URL=${REDIS_URL}
```

```bash
# Run with secrets injected
op run --env-file=.op.env -- docker compose up
```

### Kamal Deployment

```yaml
# config/deploy.yml
env:
  secret:
    - RAILS_MASTER_KEY
    - DATABASE_URL
    - REDIS_URL
```

```bash
# .kamal/secrets (loaded by Kamal)
RAILS_MASTER_KEY=$(op read "op://Production/Rails/master_key")
DATABASE_URL=$(op read "op://Production/PostgreSQL/url")
REDIS_URL=$(op read "op://Production/Redis/url")
```

### CI/CD (GitHub Actions)

```yaml
# .github/workflows/deploy.yml
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: 1password/load-secrets-action@v2
        with:
          export-env: true
        env:
          OP_SERVICE_ACCOUNT_TOKEN: ${{ secrets.OP_SERVICE_ACCOUNT_TOKEN }}
          AWS_ACCESS_KEY_ID: op://CI/AWS/access_key_id
          AWS_SECRET_ACCESS_KEY: op://CI/AWS/secret_access_key

      - run: terraform apply -auto-approve
```

## CLI Commands

### Reading Secrets

```bash
# Read single field
op read "op://Vault/Item/field"

# Read with output format
op read "op://Vault/Item/field" --format json

# Read to file (for certificates, keys)
op read "op://Vault/TLS/private_key" > /tmp/key.pem
chmod 600 /tmp/key.pem
```

### Injecting into Commands

```bash
# Single secret inline
DATABASE_URL=$(op read "op://Production/DB/url") rails db:migrate

# Multiple secrets via env file
op run --env-file=.op.env -- ./deploy.sh

# With account specification
op run --account my-team --env-file=.op.env -- terraform apply
```

### Managing Items

```bash
# List vaults
op vault list

# List items in vault
op item list --vault Infrastructure

# Get item details
op item get "AWS" --vault Infrastructure

# Create item
op item create \
  --category login \
  --vault Infrastructure \
  --title "New Service" \
  --field username=admin \
  --field password=secret123
```

## Project Setup

### Initial Configuration

```bash
# Sign in (creates session)
op signin

# Verify access
op vault list

# Create project env file
cat > .op.env << 'EOF'
# Infrastructure secrets
AWS_ACCESS_KEY_ID=op://Infrastructure/AWS/access_key_id
AWS_SECRET_ACCESS_KEY=op://Infrastructure/AWS/secret_access_key

# Application secrets
DATABASE_URL=op://Production/Database/url
REDIS_URL=op://Production/Redis/url
EOF

# Test secret loading
op run --env-file=.op.env -- env | grep -E '^(AWS|DATABASE|REDIS)'
```

### Vault Organization

Recommended vault structure:

| Vault | Purpose | Access |
|-------|---------|--------|
| `Infrastructure` | Cloud provider credentials | DevOps team |
| `Production` | Production app secrets | Deploy systems |
| `Staging` | Staging environment | Dev team |
| `Development` | Local dev secrets | Individual devs |
| `Shared` | Cross-team API keys | All teams |

## Security Best Practices

### DO

- Use `.op.env` files for project-specific secret mapping
- Add all `.op.env` variants to `.gitignore`
- Use service accounts for CI/CD (not personal accounts)
- Scope vault access by team/environment
- Rotate secrets regularly via 1Password

### DON'T

- Never commit `.op.env` files
- Never use `op read` output in logs or echo statements
- Never store session tokens in scripts
- Avoid hardcoding vault/item names - use variables

### Audit Logging

```bash
# Check recent access events
op events-api

# Specific vault events
op audit-events list --vault Production
```

## Troubleshooting

### Session Expired

```bash
# Re-authenticate
op signin

# Check current session
op whoami
```

### Item Not Found

```bash
# Verify vault access
op vault list

# Search for item
op item list --vault Infrastructure | grep -i aws

# Check exact field names
op item get "AWS" --vault Infrastructure --format json | jq '.fields[].label'
```

### Permission Denied

```bash
# Check account permissions
op vault list

# Verify specific vault access
op vault get Infrastructure
```

## Multiple Accounts

Many users have separate personal and work 1Password accounts. The CLI supports switching between them.

### List Configured Accounts

```bash
op account list
```

Output:
```
USER ID                          URL
-----------------------------    --------------------------
A3BCDEFGHIJKLMNOPQRSTUVWX       my.1password.com
B4CDEFGHIJKLMNOPQRSTUVWXY       acme.1password.com
```

### Specify Account per Command

Use `--account` with either the sign-in address or account ID:

```bash
# Using sign-in address
op vault list --account my.1password.com
op item get "AWS" --account acme.1password.com

# Using account ID
op vault list --account A3BCDEFGHIJKLMNOPQRSTUVWX
```

### Set Default Account (Environment Variable)

Set `OP_ACCOUNT` to choose default for all commands in that shell:

```bash
export OP_ACCOUNT=acme.1password.com
op vault list            # Uses acme.1password.com
op item get "API Key"    # Uses acme.1password.com
```

`--account` flag **overrides** `OP_ACCOUNT` for a single command.

### Multiple Accounts with op run

```bash
# Specify account explicitly
op run --account acme.1password.com --env-file=.op.env.work -- ./deploy.sh

# Or set environment variable first
export OP_ACCOUNT=my.1password.com
op run --env-file=.op.env.personal -- ./start-local-dev.sh
```

### Cross-Account Workflows

When scripts need secrets from different accounts:

```bash
# Script using work account
export OP_ACCOUNT=acme.1password.com
WORK_DB=$(op read "op://Production/Database/url")

# Switch to personal for specific command
PERSONAL_KEY=$(op read "op://Personal/GitHub/token" --account my.1password.com)
```

### Makefile with Account Selection

```makefile
# Default to work account
OP_ACCOUNT ?= acme.1password.com
OP ?= op
OP_ENV_FILE ?= .op.env

CMD = OP_ACCOUNT=$(OP_ACCOUNT) $(OP) run --env-file=$(OP_ENV_FILE) --

deploy:
	$(CMD) kamal deploy

# Personal account for local dev
dev:
	OP_ACCOUNT=my.1password.com $(OP) run --env-file=.op.env.personal -- rails server

# Usage:
# make deploy                           # Uses work account
# make deploy OP_ACCOUNT=my.1password.com  # Override account
# make dev                              # Uses personal account
```

### Best Practices for Multiple Accounts

**DO:**
- Always use `--account` or `OP_ACCOUNT` in scripts (don't rely on "last signed in")
- Use work accounts for CI/CD, personal for local dev
- Create separate `.op.env` files per account context

**DON'T:**
- Rely on "last signed in" account in automation (brittle)
- Mix account contexts in single env file

### Account-Specific Env Files

```bash
# .op.env.work (uses work account vaults)
AWS_ACCESS_KEY_ID=op://Work-Infrastructure/AWS/access_key_id
DATABASE_URL=op://Work-Production/Database/url

# .op.env.personal (uses personal account vaults)
GITHUB_TOKEN=op://Personal/GitHub/token
OPENAI_API_KEY=op://Personal/OpenAI/api_key
```

```makefile
# Makefile with account + env file pairing
work-deploy:
	op run --account acme.1password.com --env-file=.op.env.work -- ./deploy.sh

personal-dev:
	op run --account my.1password.com --env-file=.op.env.personal -- ./dev.sh
```

## Multi-Environment Pattern

```bash
# .op.env.production
DATABASE_URL=op://Production/Database/url
REDIS_URL=op://Production/Redis/url

# .op.env.staging
DATABASE_URL=op://Staging/Database/url
REDIS_URL=op://Staging/Redis/url

# .op.env.development
DATABASE_URL=op://Development/Database/url
REDIS_URL=op://Development/Redis/url
```

```makefile
ENV ?= development
OP_ENV_FILE = .op.env.$(ENV)

deploy:
	op run --env-file=$(OP_ENV_FILE) -- kamal deploy

# Usage: make deploy ENV=production
```
