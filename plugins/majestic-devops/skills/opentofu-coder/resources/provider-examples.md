# Provider Configuration Examples

## Multi-Cloud Setup

### Required Providers Block

```hcl
terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}
```

## AWS Provider

### Basic Configuration

```hcl
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project
      Environment = var.environment
      ManagedBy   = "OpenTofu"
    }
  }
}
```

### Multi-Region

```hcl
provider "aws" {
  alias  = "us_east"
  region = "us-east-1"
}

provider "aws" {
  alias  = "us_west"
  region = "us-west-2"
}

provider "aws" {
  alias  = "eu_west"
  region = "eu-west-1"
}

# Usage
resource "aws_s3_bucket" "us_east" {
  provider = aws.us_east
  bucket   = "${var.project}-us-east"
}

resource "aws_s3_bucket" "us_west" {
  provider = aws.us_west
  bucket   = "${var.project}-us-west"
}
```

### Assume Role (Cross-Account)

```hcl
provider "aws" {
  region = var.aws_region

  assume_role {
    role_arn     = "arn:aws:iam::${var.target_account_id}:role/TerraformDeployRole"
    session_name = "TofuDeployment"
    external_id  = var.external_id  # Optional, for security
  }
}
```

### With SSO / Identity Center

```hcl
# Use AWS SSO profile
provider "aws" {
  region  = var.aws_region
  profile = "my-sso-profile"
}
```

## Azure Provider

### Basic Configuration

```hcl
provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}
```

### Service Principal Authentication

```hcl
provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  client_id       = var.client_id
  client_secret   = var.client_secret  # Use env: ARM_CLIENT_SECRET
}
```

### Managed Identity (Azure VMs / AKS)

```hcl
provider "azurerm" {
  features {}

  use_msi         = true
  subscription_id = var.subscription_id
}
```

### Multi-Subscription

```hcl
provider "azurerm" {
  alias           = "production"
  subscription_id = var.prod_subscription_id
  features {}
}

provider "azurerm" {
  alias           = "development"
  subscription_id = var.dev_subscription_id
  features {}
}
```

## Google Cloud Provider

### Basic Configuration

```hcl
provider "google" {
  project = var.gcp_project
  region  = var.gcp_region
}
```

### With Credentials File

```hcl
provider "google" {
  project     = var.gcp_project
  region      = var.gcp_region
  credentials = file(var.credentials_file)  # Or use GOOGLE_CREDENTIALS env var
}
```

### Impersonation (Recommended)

```hcl
provider "google" {
  project = var.gcp_project
  region  = var.gcp_region

  impersonate_service_account = "terraform@${var.gcp_project}.iam.gserviceaccount.com"
}
```

### Multi-Project

```hcl
provider "google" {
  alias   = "project_a"
  project = var.project_a
  region  = var.gcp_region
}

provider "google" {
  alias   = "project_b"
  project = var.project_b
  region  = var.gcp_region
}
```

## Kubernetes Provider

### With Kubeconfig

```hcl
provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = var.kube_context
}
```

### With EKS

```hcl
data "aws_eks_cluster" "main" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "main" {
  name = var.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.main.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.main.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.main.token
}
```

### With GKE

```hcl
data "google_container_cluster" "main" {
  name     = var.cluster_name
  location = var.gcp_region
}

data "google_client_config" "current" {}

provider "kubernetes" {
  host                   = "https://${data.google_container_cluster.main.endpoint}"
  cluster_ca_certificate = base64decode(data.google_container_cluster.main.master_auth[0].cluster_ca_certificate)
  token                  = data.google_client_config.current.access_token
}
```

### With AKS

```hcl
data "azurerm_kubernetes_cluster" "main" {
  name                = var.cluster_name
  resource_group_name = var.resource_group
}

provider "kubernetes" {
  host                   = data.azurerm_kubernetes_cluster.main.kube_config[0].host
  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.main.kube_config[0].client_certificate)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.main.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.main.kube_config[0].cluster_ca_certificate)
}
```

## Helm Provider

```hcl
provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.main.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.main.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.main.token
  }
}

resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "ingress-nginx"
  version    = "4.8.0"

  create_namespace = true

  set {
    name  = "controller.replicaCount"
    value = "2"
  }
}
```

## Docker Provider

```hcl
provider "docker" {
  host = "unix:///var/run/docker.sock"
}

# Or with remote Docker host
provider "docker" {
  host = "tcp://docker-host:2376"

  registry_auth {
    address  = "registry.example.com"
    username = var.registry_username
    password = var.registry_password
  }
}
```

## Datadog Provider

```hcl
provider "datadog" {
  api_key = var.datadog_api_key  # Or DD_API_KEY env var
  app_key = var.datadog_app_key  # Or DD_APP_KEY env var
  api_url = "https://api.datadoghq.com/"
}
```

## GitHub Provider

```hcl
provider "github" {
  token = var.github_token  # Or GITHUB_TOKEN env var
  owner = var.github_org
}

resource "github_repository" "example" {
  name        = "example-repo"
  description = "Managed by OpenTofu"
  visibility  = "private"

  has_issues    = true
  has_wiki      = false
  has_downloads = false

  auto_init = true
}
```

## Cloudflare Provider

```hcl
provider "cloudflare" {
  api_token = var.cloudflare_api_token  # Or CLOUDFLARE_API_TOKEN env var
}

resource "cloudflare_record" "www" {
  zone_id = var.cloudflare_zone_id
  name    = "www"
  value   = aws_lb.main.dns_name
  type    = "CNAME"
  proxied = true
}
```

## Provider Composition Pattern

### All Providers in One File

```hcl
# providers.tf
terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
}

# Configure AWS first (for EKS data)
provider "aws" {
  region = var.aws_region
}

# Get EKS cluster data
data "aws_eks_cluster" "main" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "main" {
  name = var.cluster_name
}

# Configure K8s provider with EKS data
provider "kubernetes" {
  host                   = data.aws_eks_cluster.main.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.main.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.main.token
}

# Configure Helm with same credentials
provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.main.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.main.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.main.token
  }
}
```
