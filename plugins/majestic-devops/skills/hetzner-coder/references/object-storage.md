# Hetzner Object Storage with OpenTofu

Hetzner Object Storage is S3-compatible but requires specific AWS provider configuration.

## Provider Configuration

**Critical:** Use AWS provider with these flags - all are required for Hetzner compatibility:

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  alias  = "hetzner_s3"
  region = var.s3_region  # e.g., "fsn1", "nbg1", "hel1"

  access_key = var.s3_access_key
  secret_key = var.s3_secret_key

  endpoints {
    s3 = var.s3_endpoint
  }

  # ALL of these are required for Hetzner Object Storage
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true
}
```

## Variables

```hcl
variable "s3_access_key" {
  description = "Hetzner Object Storage access key"
  type        = string
  sensitive   = true
}

variable "s3_secret_key" {
  description = "Hetzner Object Storage secret key"
  type        = string
  sensitive   = true
}

variable "s3_region" {
  description = "Hetzner Object Storage region"
  type        = string
  default     = "fsn1"
}

variable "s3_endpoint" {
  description = "Hetzner Object Storage endpoint"
  type        = string
  default     = "https://fsn1.your-objectstorage.com"
}
```

## Bucket Resources

```hcl
resource "aws_s3_bucket" "backups" {
  provider = aws.hetzner_s3
  bucket   = "${var.project}-backups"
}

resource "aws_s3_bucket_versioning" "backups" {
  provider = aws.hetzner_s3
  bucket   = aws_s3_bucket.backups.id

  versioning_configuration {
    status = "Enabled"
  }
}
```

## Known Limitations

**Lifecycle configuration NOT supported:**

```hcl
# ⚠️ This WILL NOT WORK with Hetzner Object Storage
# resource "aws_s3_bucket_lifecycle_configuration" "example" { ... }
```

Workaround: Manual cleanup of old versions via CLI or scheduled job.

## Endpoints by Region

| Region | Endpoint |
|--------|----------|
| Falkenstein (fsn1) | `https://fsn1.your-objectstorage.com` |
| Nuremberg (nbg1) | `https://nbg1.your-objectstorage.com` |
| Helsinki (hel1) | `https://hel1.your-objectstorage.com` |

## Creating Credentials (Manual)

Object Storage credentials must be created manually in Hetzner console:

1. Go to https://console.hetzner.cloud/projects
2. Select project → Security → S3 credentials
3. Click **Generate credentials**
4. Save to 1Password:
   ```bash
   op item create \
     --vault myproject \
     --category login \
     --title "production-hetzner-s3" \
     --field "access_key_id=YOUR_ACCESS_KEY" \
     --field "secret_access_key=YOUR_SECRET_KEY"
   ```

## Complete Example with 1Password

```hcl
# main.tf
terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.50"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "hcloud" {
  token = var.hcloud_token
}

provider "aws" {
  alias  = "hetzner_s3"
  region = "fsn1"

  access_key = var.s3_access_key
  secret_key = var.s3_secret_key

  endpoints {
    s3 = "https://fsn1.your-objectstorage.com"
  }

  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true
}
```

**CLI usage:**

```bash
tofu apply \
  -var="hcloud_token=$(op read 'op://myproject/hetzner-api/token')" \
  -var="s3_access_key=$(op read 'op://myproject/production-hetzner-s3/access_key_id')" \
  -var="s3_secret_key=$(op read 'op://myproject/production-hetzner-s3/secret_access_key')"
```

## Outputs

```hcl
output "s3_bucket" {
  description = "S3 bucket for backups"
  value       = aws_s3_bucket.backups.bucket
}

output "s3_endpoint" {
  description = "S3 endpoint for application config"
  value       = var.s3_endpoint
}
```
