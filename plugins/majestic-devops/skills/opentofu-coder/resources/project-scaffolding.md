# Project Scaffolding Patterns

## Directory Structure

```
infra/
├── main.tf           # Providers and terraform blocks
├── variables.tf      # All input variables
├── outputs.tf        # All outputs including next_steps
├── server.tf         # Compute resources
├── network.tf        # Networking and firewalls
├── storage.tf        # Storage resources
├── .gitignore        # OpenTofu-specific ignores
└── templates/        # Cloud-init and config templates
    └── cloud-init.yaml
```

## .gitignore for OpenTofu/Terraform

```gitignore
# OpenTofu/Terraform State
*.tfstate
*.tfstate.*
.terraform/
.terraform.lock.hcl

# Variable files (may contain secrets)
*.tfvars
!*.tfvars.example

# Crash logs
crash.log
crash.*.log

# Override files (local development)
override.tf
override.tf.json
*_override.tf
*_override.tf.json

# Secrets and keys
*.pem
*.key
*.p12
*.pfx

# Plan output
*.tfplan

# IDE
.idea/
*.swp
.vscode/

# macOS
.DS_Store
```

## next_steps Output Pattern

Provide actionable guidance after provisioning:

```hcl
output "next_steps" {
  description = "Next steps after provisioning"
  value       = <<-EOT
    Infrastructure provisioned successfully!

    Next steps:
    1. Update DNS: ${var.domain} -> ${hcloud_server.web.ipv4_address}
    2. Update config/deploy.yml with server IP
    3. Run: bin/setup-server ${hcloud_server.web.ipv4_address}
    4. Run: kamal setup

    Server details:
    - IP: ${hcloud_server.web.ipv4_address}
    - IPv6: ${hcloud_server.web.ipv6_address}
    - S3 bucket: ${aws_s3_bucket.backups.bucket}
  EOT
}
```

**Benefits:**
- Users know exactly what to do next
- Reduces documentation drift
- Dynamic values like IPs are included

## Security-First Variables

Force explicit values for security-sensitive variables:

```hcl
variable "admin_ip" {
  description = "Admin IP for SSH access (CIDR) - REQUIRED, no default for security"
  type        = string
  # NO DEFAULT - forces user to explicitly provide their IP
}

variable "ssh_public_key" {
  description = "SSH public key for server access"
  type        = string
  # NO DEFAULT - forces explicit key provision
}
```

**Why no defaults:**
- Prevents accidental `0.0.0.0/0` SSH access
- Makes security decisions explicit
- Fails fast if forgotten

**Usage:**

```bash
tofu apply \
  -var="admin_ip=$(curl -s ifconfig.me)/32" \
  -var="ssh_public_key=$(cat ~/.ssh/mykey.pub)"
```

## Sensitive Variables

Mark credentials as sensitive:

```hcl
variable "hcloud_token" {
  description = "Hetzner Cloud API token"
  type        = string
  sensitive   = true
}

variable "s3_secret_key" {
  description = "S3 secret access key"
  type        = string
  sensitive   = true
}
```

**Effects of `sensitive = true`:**
- Hidden in plan/apply output
- Hidden in state show
- Still visible in state file (encrypt state!)

## Complete variables.tf Example

```hcl
# Required - Provider Authentication
variable "hcloud_token" {
  description = "Hetzner Cloud API token"
  type        = string
  sensitive   = true
}

# Required - Security (no defaults)
variable "admin_ip" {
  description = "Admin IP for SSH access (CIDR notation)"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key for server access"
  type        = string
}

# Optional - Infrastructure
variable "server_location" {
  description = "Hetzner datacenter location"
  type        = string
  default     = "fsn1"
}

variable "server_type" {
  description = "Hetzner server type"
  type        = string
  default     = "cx22"
}

# Optional - Storage
variable "s3_access_key" {
  description = "S3 access key"
  type        = string
  sensitive   = true
  default     = ""
}

variable "s3_secret_key" {
  description = "S3 secret key"
  type        = string
  sensitive   = true
  default     = ""
}

variable "s3_endpoint" {
  description = "S3 endpoint URL"
  type        = string
  default     = "https://fsn1.your-objectstorage.com"
}
```

## Complete outputs.tf Example

```hcl
# Primary outputs for deployment
output "server_ip" {
  description = "Public IPv4 address"
  value       = hcloud_server.web.ipv4_address
}

output "server_ipv6" {
  description = "Public IPv6 address"
  value       = hcloud_server.web.ipv6_address
}

output "server_status" {
  description = "Server status"
  value       = hcloud_server.web.status
}

# Storage outputs
output "s3_bucket" {
  description = "S3 bucket name"
  value       = aws_s3_bucket.backups.bucket
}

output "s3_endpoint" {
  description = "S3 endpoint for config"
  value       = var.s3_endpoint
}

# Human-readable next steps
output "next_steps" {
  description = "Post-provisioning instructions"
  value       = <<-EOT
    1. Update DNS: app.example.com -> ${hcloud_server.web.ipv4_address}
    2. Update config/deploy.yml with server IP
    3. Run: bin/setup-server ${hcloud_server.web.ipv4_address}
    4. Run: kamal setup
  EOT
}
```
