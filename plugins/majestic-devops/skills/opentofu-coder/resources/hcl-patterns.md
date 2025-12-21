# Advanced HCL Patterns

## Expression Syntax

### String Interpolation

```hcl
# Simple interpolation
name = "web-${var.environment}"

# Expression interpolation
name = "server-${count.index + 1}"

# Conditional in string
description = "Server ${var.is_primary ? "primary" : "secondary"}"
```

### Conditional Expressions

```hcl
# Ternary operator
instance_type = var.environment == "prod" ? "t3.large" : "t3.micro"

# With null coalescing
region = var.region != null ? var.region : "us-east-1"

# Coalesce for first non-null
region = coalesce(var.region, local.default_region, "us-east-1")
```

### For Expressions

```hcl
# Transform list
upper_names = [for name in var.names : upper(name)]

# Filter list
active_users = [for u in var.users : u.name if u.active]

# Transform to map
user_map = { for u in var.users : u.id => u.name }

# Nested iteration
all_subnets = flatten([
  for vpc_key, vpc in var.vpcs : [
    for subnet in vpc.subnets : {
      vpc_key = vpc_key
      subnet  = subnet
    }
  ]
])
```

### Type Constraints

```hcl
variable "users" {
  type = list(object({
    name    = string
    age     = number
    admin   = optional(bool, false)
    tags    = optional(map(string), {})
  }))
}

variable "network_config" {
  type = object({
    vpc_cidr = string
    subnets = map(object({
      cidr = string
      az   = string
      public = optional(bool, false)
    }))
  })
}
```

## Functions Reference

### String Functions

```hcl
# Formatting
formatted = format("Hello, %s! Count: %d", var.name, var.count)
joined    = join("-", ["web", var.env, "server"])
split_parts = split(",", var.csv_string)

# Manipulation
lower_name = lower(var.name)
upper_name = upper(var.name)
trimmed    = trimspace(var.input)
replaced   = replace(var.input, "/old/", "new")

# Substrings
prefix = substr(var.name, 0, 3)
```

### Collection Functions

```hcl
# Transformation
flattened = flatten([var.list1, var.list2])
merged    = merge(local.defaults, var.overrides)
zipped    = zipmap(var.keys, var.values)

# Filtering
filtered = compact(var.list_with_nulls)
distinct_values = distinct(var.duplicated_list)

# Lookup
value = lookup(var.map, "key", "default")
element = element(var.list, count.index)
```

### Numeric Functions

```hcl
max_value = max(var.a, var.b, var.c)
min_value = min(var.a, var.b, var.c)
abs_value = abs(var.potentially_negative)
ceiling   = ceil(var.float_value)
floor     = floor(var.float_value)
```

### Filesystem Functions

```hcl
# Read files
content = file("${path.module}/files/config.json")
template = templatefile("${path.module}/templates/user_data.sh", {
  hostname = var.hostname
  packages = var.packages
})

# File info
hash = filemd5("${path.module}/files/script.sh")
exists = fileexists("${path.module}/optional.conf")
```

### Network Functions

```hcl
# CIDR calculations
subnet = cidrsubnet("10.0.0.0/16", 8, count.index)  # 10.0.0.0/24, 10.0.1.0/24, etc.
host   = cidrhost("10.0.1.0/24", 5)  # 10.0.1.5
netmask = cidrnetmask("10.0.0.0/16")  # 255.255.0.0
```

## Patterns for Complex Scenarios

### Nested Dynamic Blocks

```hcl
resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found"
      status_code  = "404"
    }
  }

  dynamic "default_action" {
    for_each = var.redirect_rules
    content {
      type = "redirect"
      redirect {
        host        = default_action.value.host
        path        = default_action.value.path
        port        = default_action.value.port
        protocol    = default_action.value.protocol
        status_code = "HTTP_301"
      }
    }
  }
}
```

### Resource Chaining

```hcl
# Create resources that depend on each other
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
}

resource "aws_subnet" "private" {
  for_each = var.private_subnets

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name = "${local.name_prefix}-private-${each.key}"
  }
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}
```

### Splat Expressions

```hcl
# Get all IDs from a list of resources
instance_ids = aws_instance.web[*].id

# Get specific attribute from all
public_ips = aws_instance.web[*].public_ip

# With for_each (use values())
subnet_ids = values(aws_subnet.private)[*].id
```

### Try and Can Functions

```hcl
# Graceful fallback
value = try(var.complex.nested.value, "default")

# Check if expression is valid
has_value = can(var.optional_map["key"])

# Multiple fallbacks
config = try(
  var.config.custom,
  var.config.default,
  local.fallback_config
)
```

## Anti-Patterns to Avoid

### Avoid Hardcoding

```hcl
# Bad
resource "aws_instance" "web" {
  ami           = "ami-12345678"
  instance_type = "t3.medium"
  subnet_id     = "subnet-abcd1234"
}

# Good
resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  subnet_id     = module.vpc.private_subnet_ids[0]
}
```

### Avoid count with Named Resources

```hcl
# Bad - index-based, fragile
resource "aws_iam_user" "users" {
  count = length(var.user_names)
  name  = var.user_names[count.index]
}

# Good - key-based, stable
resource "aws_iam_user" "users" {
  for_each = toset(var.user_names)
  name     = each.value
}
```

### Avoid Secrets in Code

```hcl
# Bad
provider "aws" {
  access_key = "AKIAIOSFODNN7EXAMPLE"
  secret_key = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
}

# Good - use environment variables or IAM roles
# AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY env vars
# Or instance profile / IRSA for EKS
```
