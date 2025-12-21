# Complete Production Setup

A complete Backblaze B2 production setup with storage, backups, public assets, and application keys.

```hcl
# variables.tf
variable "project" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment (prod, staging, dev)"
  type        = string
  default     = "prod"
}

# main.tf
terraform {
  required_providers {
    b2 = {
      source  = "Backblaze/b2"
      version = "~> 0.8"
    }
  }
}

provider "b2" {}

locals {
  bucket_prefix = "${var.project}-${var.environment}"
}

# Primary storage bucket
resource "b2_bucket" "storage" {
  bucket_name = "${local.bucket_prefix}-storage"
  bucket_type = "allPrivate"

  bucket_info = {
    project     = var.project
    environment = var.environment
    managed_by  = "opentofu"
  }

  default_server_side_encryption {
    mode      = "SSE-B2"
    algorithm = "AES256"
  }

  lifecycle_rules {
    file_name_prefix              = "temp/"
    days_from_hiding_to_deleting  = 1
    days_from_uploading_to_hiding = 7
  }
}

# Backup bucket with retention
resource "b2_bucket" "backups" {
  bucket_name = "${local.bucket_prefix}-backups"
  bucket_type = "allPrivate"

  bucket_info = {
    project     = var.project
    environment = var.environment
    purpose     = "backups"
  }

  default_server_side_encryption {
    mode      = "SSE-B2"
    algorithm = "AES256"
  }

  lifecycle_rules {
    file_name_prefix              = ""
    days_from_hiding_to_deleting  = 90
    days_from_uploading_to_hiding = 30
  }
}

# Public assets bucket
resource "b2_bucket" "assets" {
  bucket_name = "${local.bucket_prefix}-assets"
  bucket_type = "allPublic"

  bucket_info = {
    project = var.project
    purpose = "public-assets"
  }

  cors_rules {
    cors_rule_name     = "allowAll"
    allowed_origins    = ["*"]
    allowed_headers    = ["*"]
    allowed_operations = ["s3_get", "s3_head"]
    max_age_seconds    = 86400
  }
}

# Application key for app access
resource "b2_application_key" "app" {
  key_name     = "${local.bucket_prefix}-app"
  capabilities = ["listBuckets", "listFiles", "readFiles", "writeFiles", "deleteFiles"]
  bucket_id    = b2_bucket.storage.bucket_id
}

# Read-only key for backups
resource "b2_application_key" "backup_reader" {
  key_name     = "${local.bucket_prefix}-backup-reader"
  capabilities = ["listBuckets", "listFiles", "readFiles"]
  bucket_id    = b2_bucket.backups.bucket_id
}

# outputs.tf
output "storage_bucket_name" {
  value = b2_bucket.storage.bucket_name
}

output "storage_bucket_id" {
  value = b2_bucket.storage.bucket_id
}

output "assets_bucket_url" {
  value = "https://f${substr(b2_bucket.assets.bucket_id, 0, 3)}.backblazeb2.com/file/${b2_bucket.assets.bucket_name}"
}

output "app_key_id" {
  value = b2_application_key.app.application_key_id
}

output "app_key" {
  value     = b2_application_key.app.application_key
  sensitive = true
}

output "s3_endpoint" {
  value = "s3.${data.b2_account_info.current.s3_api_url}"
}

data "b2_account_info" "current" {}
```
