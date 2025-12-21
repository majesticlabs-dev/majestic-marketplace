# Changelog

All notable changes to this project will be documented in this file.

## [1.1.0] - 2025-12-21

### Added

- `1password-cli-coder` skill for secret management with 1Password CLI
  - `.op.env` file patterns and integration
  - Makefile, Docker Compose, and Kamal integration
  - CI/CD patterns for GitHub Actions
- `backblaze-coder` skill for Backblaze B2 Cloud Storage
  - B2 CLI installation and authentication
  - Bucket, file, and sync operations
  - Terraform provider with bucket resources
  - Lifecycle rules for cost optimization
  - Application key management with minimal permissions
  - S3-compatible API with AWS CLI and rclone
  - Bucket encryption (SSE-B2)
  - File lock for compliance/immutable storage
  - CORS configuration for web assets
  - Complete production setup examples
- `cloud-init-coder` skill for VM provisioning
  - User and SSH key management
  - Package installation and service configuration
  - SSH hardening patterns
  - Docker setup automation
- `cloudflare-coder` skill for Cloudflare infrastructure with OpenTofu/Terraform
  - Zone and DNS record management
  - SSL/TLS strict mode configuration
  - WAF custom rules and managed rulesets
  - Cache rules (modern rulesets over legacy Page Rules)
  - Redirect rules
  - Load balancer and origin pools
  - Origin certificates
  - Complete production zone examples
- `digitalocean-coder` skill for DigitalOcean infrastructure
  - VPC, Droplet, Reserved IP patterns
  - Managed Database configuration
  - Firewall rules and security
  - Complete production stack examples
- `hetzner-coder` skill for Hetzner Cloud infrastructure
  - Server types: shared (cx), AMD EPYC (cpx), ARM64 (cax), dedicated (ccx)
  - Private networks with subnet configuration
  - Firewalls with label selectors
  - Load balancers with health checks and TLS
  - Volumes, snapshots, and backups
  - Placement groups for high availability
  - Complete production stack examples
- `wrangler-coder` skill for Cloudflare Workers and Pages development
  - wrangler.toml configuration patterns
  - Multi-environment setup (staging/production)
  - KV namespace management
  - D1 database and migrations
  - R2 object storage bindings
  - Queues and Durable Objects
  - Workers AI integration
  - Secrets management with `wrangler secret`
  - Local development workflows
  - Pages Functions patterns
  - Deployment, logs, and rollback workflows
- `infra-security-review` agent for IaC security audits
  - State backend security checks
  - Secret exposure detection
  - Network security analysis
  - Compliance-focused reporting
- `makefile-automation.md` resource for `opentofu-coder`
  - Workspace/stack automation patterns
  - Secret loading integration
  - Multi-stack operations
- Plugin README.md documentation

## [1.0.0] - 2025-12-20

### Added

- Initial release of majestic-devops plugin
- `opentofu-coder` skill for Infrastructure as Code development with OpenTofu/Terraform
  - HCL syntax patterns and best practices
  - State management with encryption
  - Module design patterns
  - Provider configuration examples
  - Workspace and environment strategies
