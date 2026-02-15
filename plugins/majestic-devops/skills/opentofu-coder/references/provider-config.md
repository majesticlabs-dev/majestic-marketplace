# Provider Configuration

## AWS Provider

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
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}

# Multiple provider configurations
provider "aws" {
  alias  = "us_west"
  region = "us-west-2"
}

resource "aws_instance" "west" {
  provider = aws.us_west
  # ...
}
```

## Provider Authentication

```hcl
# Environment variables (preferred)
# AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY
# AWS_PROFILE for named profiles

# Named profile from ~/.aws/credentials (recommended)
provider "aws" {
  region  = var.aws_region
  profile = "suppli"  # Uses [suppli] section from ~/.aws/credentials
}

# Or explicit (NOT recommended for secrets)
provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key  # Use env vars instead
  secret_key = var.aws_secret_key
}

# Assume role
provider "aws" {
  region = var.aws_region

  assume_role {
    role_arn     = "arn:aws:iam::123456789012:role/DeployRole"
    session_name = "TofuDeployment"
  }
}
```
