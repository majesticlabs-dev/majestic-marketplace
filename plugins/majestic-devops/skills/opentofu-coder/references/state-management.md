# State Management

## State Fundamentals

The state file tracks:
- Resource instance IDs and attributes
- Resource dependencies
- Metadata for provider configuration
- Sensitive values (hence encryption is critical)

## Remote Backends

### S3 Backend (AWS)

```hcl
terraform {
  backend "s3" {
    bucket         = "company-terraform-state"
    key            = "prod/network/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-locks"

    # Optional: assume role for cross-account
    role_arn = "arn:aws:iam::123456789012:role/TerraformStateAccess"
  }
}
```

**Setup DynamoDB for locking:**

```hcl
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-state-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
```

### GCS Backend (Google Cloud)

```hcl
terraform {
  backend "gcs" {
    bucket = "company-terraform-state"
    prefix = "prod/network"
  }
}
```

### Azure Backend

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate"
    storage_account_name = "companytfstate"
    container_name       = "tfstate"
    key                  = "prod/network.tfstate"
  }
}
```

## OpenTofu State Encryption

OpenTofu's built-in state encryption (not available in Terraform):

### PBKDF2 Key Provider

```hcl
terraform {
  encryption {
    key_provider "pbkdf2" "main" {
      passphrase = var.state_passphrase  # From env: TF_VAR_state_passphrase
    }

    method "aes_gcm" "default" {
      keys = key_provider.pbkdf2.main
    }

    state {
      method   = method.aes_gcm.default
      enforced = true
    }

    plan {
      method   = method.aes_gcm.default
      enforced = true
    }
  }
}
```

### AWS KMS Key Provider

```hcl
terraform {
  encryption {
    key_provider "aws_kms" "main" {
      kms_key_id = "alias/terraform-state-key"
      region     = "us-east-1"
      key_spec   = "AES_256"
    }

    method "aes_gcm" "default" {
      keys = key_provider.aws_kms.main
    }

    state {
      method = method.aes_gcm.default
    }
  }
}
```

### GCP KMS Key Provider

```hcl
terraform {
  encryption {
    key_provider "gcp_kms" "main" {
      kms_encryption_key = "projects/my-project/locations/us/keyRings/my-ring/cryptoKeys/my-key"
      key_length         = 32
    }

    method "aes_gcm" "default" {
      keys = key_provider.gcp_kms.main
    }

    state {
      method = method.aes_gcm.default
    }
  }
}
```

## State Operations

### Viewing State

```bash
# List all resources
tofu state list

# Show specific resource
tofu state show aws_instance.web

# Show full state (JSON)
tofu show -json > state.json
```

### Moving Resources

```bash
# Rename resource
tofu state mv aws_instance.old aws_instance.new

# Move to module
tofu state mv aws_instance.web module.compute.aws_instance.web

# Move from module to root
tofu state mv module.old.aws_vpc.main aws_vpc.main
```

### Removing from State

```bash
# Remove without destroying (for import elsewhere)
tofu state rm aws_instance.imported

# Remove entire module
tofu state rm module.legacy
```

### Importing Existing Resources

```bash
# Import single resource
tofu import aws_instance.web i-1234567890abcdef0

# Import with for_each key
tofu import 'aws_iam_user.users["alice"]' alice

# Import module resource
tofu import module.vpc.aws_vpc.main vpc-12345678
```

### Import Blocks (OpenTofu 1.5+)

```hcl
import {
  to = aws_instance.web
  id = "i-1234567890abcdef0"
}

import {
  to = aws_iam_user.users["alice"]
  id = "alice"
}
```

## State Manipulation Best Practices

### Before Refactoring

1. **Backup state**: `tofu state pull > backup.tfstate`
2. **Plan refactoring**: Document all moves needed
3. **Execute moves**: One `tofu state mv` at a time
4. **Verify**: `tofu plan` should show no changes

### Handling Drift

```bash
# Detect drift
tofu plan

# Refresh state from infrastructure
tofu refresh

# Or apply just the refresh
tofu apply -refresh-only
```

### State Recovery

```bash
# Pull state to local file
tofu state pull > local.tfstate

# Push local state to backend
tofu state push local.tfstate

# Force push (dangerous!)
tofu state push -force local.tfstate
```

## Workspace State Isolation

```bash
# Each workspace has separate state
tofu workspace new staging
# State at: env:/staging/terraform.tfstate

tofu workspace new prod
# State at: env:/prod/terraform.tfstate
```

### Workspace-Aware Backend

```hcl
terraform {
  backend "s3" {
    bucket = "company-terraform-state"
    key    = "network/terraform.tfstate"
    region = "us-east-1"

    # Workspaces stored under workspace_key_prefix
    workspace_key_prefix = "env"
  }
}
```

## State Security

### Sensitive Data in State

State contains sensitive values. Always:

1. **Encrypt at rest**: Use encrypted backend (S3 SSE, GCS encryption)
2. **Use OpenTofu encryption**: Add client-side encryption layer
3. **Restrict access**: IAM policies limiting state bucket access
4. **Audit access**: Enable CloudTrail/audit logs on state bucket
5. **Never commit**: Add `*.tfstate*` to `.gitignore`

### IAM Policy for State Access

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      "Resource": "arn:aws:s3:::company-terraform-state/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:DeleteItem"
      ],
      "Resource": "arn:aws:dynamodb:*:*:table/terraform-state-locks"
    }
  ]
}
```

## Troubleshooting

### State Lock Issues

```bash
# Force unlock (use with caution!)
tofu force-unlock LOCK_ID

# The lock ID is shown in the error message
```

### Corrupted State

```bash
# Pull and inspect
tofu state pull | jq .

# If corrupted, restore from backup or:
# 1. Move old state aside
# 2. Import critical resources
# 3. Let tofu manage going forward
```

### Resource Address Changes

When refactoring causes address changes, use `moved` blocks:

```hcl
moved {
  from = aws_instance.web
  to   = module.compute.aws_instance.web
}

moved {
  from = aws_security_group.main
  to   = aws_security_group.web
}
```
