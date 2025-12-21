# Majestic DevOps

Infrastructure-as-Code and DevOps workflows for Claude Code.

## Overview

This plugin provides AI-powered assistance for:
- Infrastructure provisioning with OpenTofu/Terraform
- Cloud provider configuration (AWS, Backblaze B2, Cloudflare, DigitalOcean, Hetzner, GCP)
- Cloudflare Workers, Pages, D1, R2, and KV with Wrangler
- Backblaze B2 Cloud Storage with B2 CLI and S3-compatible API
- Secret management with 1Password CLI
- VM provisioning with cloud-init
- Infrastructure security review

## Getting Started

### Prerequisites

1. **OpenTofu or Terraform installed**
   ```bash
   # macOS
   brew install opentofu

   # Linux (Debian/Ubuntu)
   curl -fsSL https://get.opentofu.org/install-opentofu.sh | sh

   # Or Terraform (macOS)
   brew install terraform

   # Or Terraform (Linux)
   # See https://developer.hashicorp.com/terraform/install
   ```

2. **Cloud provider credentials configured**
   ```bash
   # AWS
   export AWS_ACCESS_KEY_ID="your-key"
   export AWS_SECRET_ACCESS_KEY="your-secret"

   # Backblaze B2
   export B2_APPLICATION_KEY_ID="your-key-id"
   export B2_APPLICATION_KEY="your-application-key"

   # Cloudflare
   export CLOUDFLARE_API_TOKEN="your-api-token"

   # DigitalOcean
   export DIGITALOCEAN_TOKEN="your-token"

   # Hetzner
   export HCLOUD_TOKEN="your-token"
   ```

3. **Wrangler CLI (for Cloudflare Workers/Pages)**
   ```bash
   npm install -g wrangler
   wrangler login
   ```

4. **B2 CLI (for Backblaze B2 Cloud Storage)**
   ```bash
   # macOS
   brew install b2-tools

   # Linux (Debian/Ubuntu)
   sudo apt install backblaze-b2

   # Linux (via pip)
   pip install b2

   # Authorize
   b2 authorize-account <keyId> <applicationKey>
   ```

5. **1Password CLI (optional but recommended)**
   ```bash
   brew install 1password-cli
   op signin
   ```

   **Multiple accounts?** Use `--account` or `OP_ACCOUNT` to select:
   ```bash
   op account list                              # List configured accounts
   op run --account acme.1password.com -- ...  # Use specific account
   export OP_ACCOUNT=acme.1password.com        # Set default for session
   ```

### Quick Start: Create Infrastructure

1. **Initialize a new IaC project:**
   ```
   Help me set up infrastructure for my Rails app on DigitalOcean
   ```

2. **Claude will create:**
   - `providers.tf` - Provider configuration
   - `main.tf` - Core infrastructure resources
   - `variables.tf` - Input variables
   - `outputs.tf` - Output values
   - `Makefile` - Automation commands

3. **Deploy your infrastructure:**
   ```bash
   make plan production/core
   make apply production/core
   ```

### Project Structure Pattern

The plugin follows a workspace/stack directory pattern:

```
infrastructure/
├── Makefile                    # Automation commands
├── .op.env                     # 1Password secret references
├── providers.tf                # Shared provider config
├── shared_variables.tf         # Shared variable validation
├── shared/
│   └── backend/                # State backend (S3 + DynamoDB)
│       ├── main.tf
│       └── backend.tf
├── production/
│   └── core/                   # Production infrastructure
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── staging/
    └── core/                   # Staging infrastructure
        └── ...
```

### Common Workflows

**Create a new environment:**
```
Set up a staging environment matching production but with smaller instances
```

**Add a database:**
```
Add a managed PostgreSQL database to my production stack with private networking
```

**Security review:**
```
Review my infrastructure code for security issues
```

**Set up secrets:**
```
Help me configure 1Password CLI for loading deployment credentials
```

## Skills

### opentofu-coder

Write Infrastructure-as-Code using OpenTofu (open-source Terraform fork).

**Triggers on:**
- Creating `.tf` files
- Managing cloud infrastructure
- Configuring providers
- Designing reusable modules

**Includes:**
- HCL syntax patterns
- State management with encryption
- Module design best practices
- Provider configuration examples
- Makefile automation workflows

### 1password-cli-coder

Integrate 1Password CLI (`op`) for secret management.

**Triggers on:**
- Loading secrets for infrastructure
- Setting up deployment credentials
- Configuring local development environments

**Includes:**
- `.op.env` file patterns
- Makefile integration
- Docker Compose secret injection
- Kamal deployment secrets
- CI/CD integration (GitHub Actions)

### cloud-init-coder

Write cloud-init configurations for VM provisioning.

**Triggers on:**
- Creating `user_data` blocks
- Writing cloud-init YAML
- Setting up new instances

**Includes:**
- User and SSH key management
- Package installation
- SSH hardening
- Docker setup
- Firewall configuration
- Systemd service creation

### digitalocean-coder

Provision DigitalOcean infrastructure.

**Triggers on:**
- Creating DO resources
- Configuring Droplets, VPCs, Databases
- Setting up firewalls

**Includes:**
- VPC networking patterns
- Droplet provisioning with cloud-init
- Reserved IP management
- Database cluster configuration
- Firewall rules
- Complete production stack examples

### hetzner-coder

Provision Hetzner Cloud infrastructure.

**Triggers on:**
- Creating Hetzner resources
- Configuring servers, networks, load balancers
- Setting up firewalls and volumes

**Includes:**
- Server types: shared (cx), AMD EPYC (cpx), ARM64 (cax), dedicated (ccx)
- Private networks with subnet configuration
- Firewalls with label selectors
- Load balancers with health checks and TLS
- Volumes, snapshots, and backups
- Placement groups for high availability
- Complete production stack examples

### cloudflare-coder

Provision Cloudflare infrastructure with OpenTofu/Terraform.

**Triggers on:**
- Managing DNS records
- Configuring SSL/TLS settings
- Setting up WAF and firewall rules
- Creating cache rules and Page Rules
- Configuring load balancers

**Includes:**
- Zone and DNS management
- SSL/TLS strict mode configuration
- WAF custom rules and managed rulesets
- Cache rules (modern rulesets)
- Redirect rules
- Load balancer configuration
- Origin certificates
- Complete production zone examples

### wrangler-coder

Develop Cloudflare Workers and Pages with Wrangler CLI.

**Triggers on:**
- Creating Workers or Pages projects
- Configuring wrangler.toml
- Setting up D1, R2, KV, or Queues
- Deploying to Cloudflare

**Includes:**
- wrangler.toml configuration patterns
- Multi-environment setup (staging/production)
- KV namespace management
- D1 database and migrations
- R2 object storage
- Queues and Durable Objects
- Workers AI integration
- Secrets management
- Local development workflows
- Deployment and rollback patterns

### backblaze-coder

Manage Backblaze B2 Cloud Storage with B2 CLI and Terraform.

**Triggers on:**
- Creating B2 buckets
- Configuring lifecycle rules
- Setting up application keys
- Syncing files to/from B2
- Using S3-compatible API

**Includes:**
- B2 CLI operations (sync, upload, download)
- Terraform provider configuration
- Bucket management with encryption
- Lifecycle rules for cost optimization
- Application key management
- S3-compatible API with AWS CLI and rclone
- CORS configuration for web assets
- File lock for compliance
- Complete production setup examples

## Agents

### infra-security-review

Review IaC for security vulnerabilities and misconfigurations.

**Checks for:**
- State backend security (encryption, locking, public access)
- Secret exposure (hardcoded credentials)
- Network security (SSH exposure, database access)
- Compute hardening (root login, password auth)
- Storage security (public buckets, encryption)

**Usage:**
```
Review my infrastructure code for security issues
```

## Installation

Add to your Claude Code settings:

```json
{
  "plugins": [
    "majestic-devops@majestic-marketplace"
  ]
}
```

## Usage Examples

### Create Infrastructure on DigitalOcean

```
Set up a production stack on DigitalOcean with:
- VPC for network isolation
- Droplet with Docker
- Managed PostgreSQL
- Firewall rules
```

### Create Infrastructure on Hetzner

```
Set up a cost-effective production stack on Hetzner with:
- ARM64 servers for best price/performance
- Private network
- Load balancer with health checks
- Placement group for high availability
```

### Review Security

```
Review my Terraform code for security issues
```

### Set Up Secrets

```
Help me configure 1Password CLI for my infrastructure deployments
```

### Configure Cloudflare Zone

```
Set up my domain on Cloudflare with:
- Strict SSL/TLS mode
- WAF with managed rulesets
- Cache rules for static assets
- Redirect www to apex
```

### Create Cloudflare Worker

```
Create a Cloudflare Worker API with:
- D1 database for users
- KV for caching
- Multi-environment config (staging/production)
```

### Deploy to Cloudflare Pages

```
Set up Cloudflare Pages deployment for my React app with:
- API functions in /api/*
- D1 database binding
- Environment-specific secrets
```

### Set Up Backblaze B2 Storage

```
Set up Backblaze B2 storage for my app with:
- Private bucket for user uploads with encryption
- Public bucket for static assets with CORS
- Lifecycle rules to auto-delete temp files
- Application keys with minimal permissions
```

### Sync Backups to Backblaze

```
Help me set up automated backups to Backblaze B2:
- Daily database dumps synced with b2 sync
- 30-day retention with lifecycle rules
- Encrypted at rest
```

## File Structure

```
majestic-devops/
├── skills/
│   ├── opentofu-coder/
│   │   ├── SKILL.md
│   │   └── resources/
│   │       ├── hcl-patterns.md
│   │       ├── state-management.md
│   │       ├── provider-examples.md
│   │       └── makefile-automation.md
│   ├── 1password-cli-coder/
│   │   └── SKILL.md
│   ├── backblaze-coder/
│   │   └── SKILL.md
│   ├── cloud-init-coder/
│   │   └── SKILL.md
│   ├── cloudflare-coder/
│   │   └── SKILL.md
│   ├── digitalocean-coder/
│   │   └── SKILL.md
│   ├── hetzner-coder/
│   │   └── SKILL.md
│   └── wrangler-coder/
│       └── SKILL.md
├── agents/
│   └── infra-security-review.md
├── README.md
└── CHANGELOG.md
```

## Contributing

See the main [majestic-marketplace](https://github.com/majestic-marketplace) repository for contribution guidelines.
