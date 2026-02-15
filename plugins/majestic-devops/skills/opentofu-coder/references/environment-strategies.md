# Environment Strategies

## Workspaces

```bash
# Create and switch workspaces
tofu workspace new dev
tofu workspace new staging
tofu workspace new prod

# Switch workspace
tofu workspace select prod

# List workspaces
tofu workspace list
```

```hcl
# Use workspace in configuration
locals {
  environment = terraform.workspace

  instance_type = {
    dev     = "t3.micro"
    staging = "t3.small"
    prod    = "t3.medium"
  }[terraform.workspace]
}
```

## Directory-Based Environments (Alternative)

```
infrastructure/
├── modules/           # Shared modules
│   ├── vpc/
│   └── eks/
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   └── terraform.tfvars
│   ├── staging/
│   │   ├── main.tf
│   │   └── terraform.tfvars
│   └── prod/
│       ├── main.tf
│       └── terraform.tfvars
```
