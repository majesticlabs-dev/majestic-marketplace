---
name: backblaze-coder
description: This skill guides Backblaze B2 Cloud Storage integration with OpenTofu/Terraform and B2 CLI. Use when managing B2 buckets, application keys, file uploads, lifecycle rules, or S3-compatible storage.
allowed-tools: Read, Write, Edit, Grep, Glob, Bash
---

# Backblaze Coder

## Overview

Backblaze B2 is an affordable S3-compatible cloud storage service. This skill covers B2 CLI usage, Terraform provisioning, and S3-compatible API integration.

## B2 CLI Installation

```bash
# macOS
brew install b2-tools

# Linux (Debian/Ubuntu)
sudo apt install backblaze-b2

# Linux (via pip)
pip install b2

# Verify installation
b2 version
```

## CLI Authentication

```bash
# Authorize with application key (preferred)
b2 authorize-account <applicationKeyId> <applicationKey>

# Or with 1Password
b2 authorize-account $(op read "op://Infrastructure/Backblaze/key_id") \
                     $(op read "op://Infrastructure/Backblaze/application_key")

# Credentials stored in ~/.b2_account_info (SQLite)
# Override with B2_ACCOUNT_INFO env var
```

**Application Key Capabilities:**

| Capability | Operations |
|------------|------------|
| `listBuckets` | List buckets (minimum required) |
| `listFiles` | List files in bucket |
| `readFiles` | Download files |
| `writeFiles` | Upload files |
| `deleteFiles` | Delete files |
| `writeBucketRetentions` | Modify retention settings |
| `readBucketEncryption` | Read encryption settings |
| `writeBucketEncryption` | Modify encryption settings |

## B2 CLI Operations

### Bucket Management

```bash
# List buckets
b2 bucket list

# Create bucket (allPrivate or allPublic)
b2 bucket create my-bucket allPrivate

# Create with lifecycle rules
b2 bucket create my-bucket allPrivate \
  --lifecycle-rules '[{"daysFromHidingToDeleting": 30, "fileNamePrefix": "logs/"}]'

# Delete bucket (must be empty)
b2 bucket delete my-bucket

# Update bucket type
b2 bucket update my-bucket allPrivate
```

### File Operations

```bash
# List files in bucket
b2 ls my-bucket
b2 ls my-bucket path/to/folder/

# Upload file
b2 upload-file my-bucket local-file.txt remote/path/file.txt

# Upload with content type
b2 upload-file --content-type "application/json" my-bucket data.json data.json

# Download file
b2 download-file-by-name my-bucket remote/path/file.txt local-file.txt

# Download by file ID
b2 download-file-by-id <fileId> local-file.txt

# Delete file
b2 rm my-bucket path/to/file.txt

# Delete all versions
b2 rm --recursive --versions my-bucket path/to/folder/
```

### Sync Operations

```bash
# Sync local to B2
b2 sync /local/path b2://my-bucket/prefix/

# Sync B2 to local
b2 sync b2://my-bucket/prefix/ /local/path

# Sync B2 to B2 (copy between buckets)
b2 sync b2://source-bucket/ b2://dest-bucket/

# Sync with options
b2 sync /local/path b2://my-bucket/ \
  --threads 20 \
  --delete \
  --keep-days 30 \
  --exclude-regex ".*\.tmp$"

# Compare by size and modification time
b2 sync --compare-versions size /local/path b2://my-bucket/
```

**Sync Flags:**

| Flag | Description |
|------|-------------|
| `--threads N` | Parallel threads (default 10, max 99) |
| `--delete` | Delete files not in source |
| `--keep-days N` | Keep old versions for N days |
| `--replace-newer` | Replace if source is newer |
| `--skip-newer` | Skip if dest is newer |
| `--exclude-regex` | Exclude matching files |
| `--include-regex` | Include only matching files |
| `--no-progress` | Disable progress (for scripts) |

### Application Keys

```bash
# List keys
b2 key list

# Create key with specific capabilities
b2 key create my-app-key listBuckets,listFiles,readFiles,writeFiles

# Create key restricted to bucket
b2 key create my-app-key listBuckets,listFiles,readFiles \
  --bucket my-bucket \
  --name-prefix "uploads/"

# Delete key
b2 key delete <applicationKeyId>
```

## Terraform Provider

### Provider Setup

```hcl
terraform {
  required_providers {
    b2 = {
      source  = "Backblaze/b2"
      version = "~> 0.8"
    }
  }
}

provider "b2" {
  # Credentials from environment:
  # B2_APPLICATION_KEY_ID
  # B2_APPLICATION_KEY
}
```

### Authentication

```bash
# Set environment variables
export B2_APPLICATION_KEY_ID="your-key-id"
export B2_APPLICATION_KEY="your-application-key"

# Or with 1Password
B2_APPLICATION_KEY_ID=op://Infrastructure/Backblaze/key_id
B2_APPLICATION_KEY=op://Infrastructure/Backblaze/application_key
```

### Bucket Resource

```hcl
resource "b2_bucket" "storage" {
  bucket_name = "my-app-storage"
  bucket_type = "allPrivate"

  bucket_info = {
    environment = "production"
    application = "my-app"
  }

  lifecycle_rules {
    file_name_prefix              = "logs/"
    days_from_hiding_to_deleting  = 30
    days_from_uploading_to_hiding = 90
  }

  lifecycle_rules {
    file_name_prefix              = "temp/"
    days_from_hiding_to_deleting  = 1
    days_from_uploading_to_hiding = 7
  }
}

output "bucket_id" {
  value = b2_bucket.storage.bucket_id
}
```

### Bucket with CORS

```hcl
resource "b2_bucket" "web_assets" {
  bucket_name = "my-web-assets"
  bucket_type = "allPublic"

  cors_rules {
    cors_rule_name   = "allowWebApp"
    allowed_origins  = ["https://myapp.com", "https://www.myapp.com"]
    allowed_headers  = ["*"]
    allowed_operations = ["s3_get", "s3_head"]
    expose_headers   = ["x-bz-content-sha1"]
    max_age_seconds  = 3600
  }
}
```

### Bucket with Encryption

```hcl
resource "b2_bucket" "encrypted" {
  bucket_name = "my-encrypted-bucket"
  bucket_type = "allPrivate"

  default_server_side_encryption {
    mode      = "SSE-B2"
    algorithm = "AES256"
  }
}
```

### Bucket with File Lock (Immutable)

```hcl
resource "b2_bucket" "compliance" {
  bucket_name = "compliance-records"
  bucket_type = "allPrivate"

  file_lock_configuration {
    is_file_lock_enabled = true

    default_retention {
      mode = "governance"
      period {
        duration = 365
        unit     = "days"
      }
    }
  }
}
```

### Application Key Resource

```hcl
resource "b2_application_key" "app" {
  key_name     = "my-app-key"
  capabilities = ["listBuckets", "listFiles", "readFiles", "writeFiles"]
  bucket_id    = b2_bucket.storage.bucket_id
  name_prefix  = "uploads/"
}

output "application_key_id" {
  value = b2_application_key.app.application_key_id
}

output "application_key" {
  value     = b2_application_key.app.application_key
  sensitive = true
}
```

### Data Sources

```hcl
# Get account info
data "b2_account_info" "current" {}

output "account_id" {
  value = data.b2_account_info.current.account_id
}

# Get bucket by name
data "b2_bucket" "existing" {
  bucket_name = "my-existing-bucket"
}

output "bucket_id" {
  value = data.b2_bucket.existing.bucket_id
}
```

### Upload File

```hcl
resource "b2_bucket_file" "config" {
  bucket_id    = b2_bucket.storage.bucket_id
  file_name    = "config/settings.json"
  source       = "${path.module}/files/settings.json"
  content_type = "application/json"
}

# Upload with file info metadata
resource "b2_bucket_file" "data" {
  bucket_id = b2_bucket.storage.bucket_id
  file_name = "data/export.csv"
  source    = "${path.module}/files/export.csv"

  file_info = {
    exported_at = timestamp()
    version     = "1.0"
  }
}
```

## S3-Compatible API

Backblaze B2 supports S3-compatible API endpoints for tools like AWS CLI, rclone, and S3 SDKs.

### S3 Endpoint

```bash
# Format: s3.<region>.backblazeb2.com
# Example regions: us-west-004, us-west-002, eu-central-003

# Get your endpoint from B2 console or:
b2 get-account-info
```

### AWS CLI Configuration

```bash
# Configure AWS CLI for B2
aws configure --profile backblaze

# Enter:
# AWS Access Key ID: Your B2 applicationKeyId
# AWS Secret Access Key: Your B2 applicationKey
# Default region name: us-west-004
# Default output format: json
```

```ini
# ~/.aws/config
[profile backblaze]
region = us-west-004
output = json

# ~/.aws/credentials
[backblaze]
aws_access_key_id = your-key-id
aws_secret_access_key = your-application-key
```

### AWS CLI Usage

```bash
# List buckets
aws --profile backblaze --endpoint-url https://s3.us-west-004.backblazeb2.com s3 ls

# List objects
aws --profile backblaze --endpoint-url https://s3.us-west-004.backblazeb2.com \
  s3 ls s3://my-bucket/

# Upload file
aws --profile backblaze --endpoint-url https://s3.us-west-004.backblazeb2.com \
  s3 cp local-file.txt s3://my-bucket/path/file.txt

# Sync directory
aws --profile backblaze --endpoint-url https://s3.us-west-004.backblazeb2.com \
  s3 sync /local/path s3://my-bucket/prefix/
```

### Rclone Configuration

```ini
# ~/.config/rclone/rclone.conf
[backblaze]
type = b2
account = your-key-id
key = your-application-key
endpoint = s3.us-west-004.backblazeb2.com
```

```bash
# List buckets
rclone lsd backblaze:

# Sync
rclone sync /local/path backblaze:my-bucket/prefix/

# Copy with progress
rclone copy -P /local/path backblaze:my-bucket/
```

## Complete Production Setup

See [resources/production-setup.md](resources/production-setup.md) for a complete production setup with storage buckets, backup bucket with retention, public assets bucket, and application keys.

## Makefile Automation

```makefile
# B2 sync targets
.PHONY: b2-sync-up b2-sync-down b2-backup

B2_BUCKET ?= my-bucket
B2_PREFIX ?= data/
LOCAL_PATH ?= ./data

b2-sync-up:
	b2 sync --threads 20 $(LOCAL_PATH) b2://$(B2_BUCKET)/$(B2_PREFIX)

b2-sync-down:
	b2 sync --threads 20 b2://$(B2_BUCKET)/$(B2_PREFIX) $(LOCAL_PATH)

b2-backup:
	b2 sync --threads 20 --keep-days 30 \
		$(LOCAL_PATH) b2://$(B2_BUCKET)/backups/$(shell date +%Y-%m-%d)/
```

## Cost Optimization

- **Use lifecycle rules** - Auto-delete temp files and old versions
- **Optimize threads** - Tune based on network/CPU (default 10, max 99)
- **Prefer Native API** - B2 CLI is more efficient than S3-compatible for large syncs
- **Monitor storage** - Versioned files count toward storage (old versions charged)
- **Auto-cancel large uploads** - Enable via lifecycle to prevent "zombie" upload costs
- **Use application keys** - Scoped keys prevent accidental operations on wrong buckets

## Best Practices

- **Application keys over master key** - Limit scope and capabilities
- **Enable encryption** - Use SSE-B2 for at-rest encryption
- **Lifecycle rules** - Auto-manage temporary and old files
- **Versioning strategy** - Enable for backups, consider costs for large datasets
- **S3 compatibility** - Use for existing S3 tools, prefer native API for performance
- **Terraform state** - Store in separate bucket with file lock for compliance
