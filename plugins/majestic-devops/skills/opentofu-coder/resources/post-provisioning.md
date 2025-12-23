# Post-Provisioning Scripts

Scripts that bridge between infrastructure provisioning (OpenTofu) and deployment (Kamal, Docker, etc.).

## Why Post-Provisioning Scripts?

Cloud-init runs at first boot with limited context. Post-provisioning scripts:
- Run from your local machine with full project context
- Can be re-run if needed
- Allow interactive troubleshooting
- Bridge the gap between infra and deployment

## bin/setup-server Pattern

```bash
#!/usr/bin/env bash
set -euo pipefail

# Colors for visibility
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SERVER_IP=${1:-}

if [ -z "$SERVER_IP" ]; then
  echo -e "${RED}Usage: bin/setup-server <server-ip>${NC}"
  echo "Example: bin/setup-server 95.217.xxx.xxx"
  exit 1
fi

echo -e "${YELLOW}==> Preparing server $SERVER_IP for deployment...${NC}"

# SSH configuration
SSH_KEY="${SSH_KEY:-$HOME/.ssh/myapp_deploy}"
SSH_OPTS="-o StrictHostKeyChecking=accept-new"

if [ -f "$SSH_KEY" ]; then
  SSH_OPTS="$SSH_OPTS -i $SSH_KEY"
fi

# Test connection before running remote commands
echo -e "${YELLOW}==> Testing SSH connection...${NC}"
if ! ssh $SSH_OPTS root@$SERVER_IP echo "Connected" &>/dev/null; then
  echo -e "${RED}ERROR: Cannot connect to server. Check IP and SSH key.${NC}"
  exit 1
fi

# Run remote script via heredoc
ssh $SSH_OPTS root@$SERVER_IP << 'REMOTE_SCRIPT'
set -euo pipefail

echo "==> Updating system packages..."
apt-get update && apt-get upgrade -y

echo "==> Installing Docker..."
if ! command -v docker &> /dev/null; then
  curl -fsSL https://get.docker.com | sh
  systemctl enable docker
  systemctl start docker
  echo "Docker installed successfully"
else
  echo "Docker already installed"
fi

echo "==> Creating application directories..."
mkdir -p /var/lib/myapp/config

# Performance tuning
if ! grep -q "vm.swappiness=10" /etc/sysctl.conf; then
  echo "vm.swappiness=10" >> /etc/sysctl.conf
  sysctl -p
fi

# Set timezone
timedatectl set-timezone UTC

# Cleanup
apt-get autoremove -y
apt-get clean

echo ""
echo "Server preparation complete!"
echo "Next steps:"
echo "  1. Ensure DNS is configured"
echo "  2. Run: kamal setup"
REMOTE_SCRIPT

echo -e "${GREEN}==> Server preparation complete!${NC}"
```

## Key Patterns

### 1. Connection Test First

Always verify SSH access before running remote commands:

```bash
if ! ssh $SSH_OPTS root@$SERVER_IP echo "Connected" &>/dev/null; then
  echo -e "${RED}ERROR: Cannot connect${NC}"
  exit 1
fi
```

### 2. Quoted Heredoc for Remote Script

Use `<< 'REMOTE_SCRIPT'` (quoted) to prevent local variable expansion:

```bash
ssh root@$SERVER_IP << 'REMOTE_SCRIPT'
# $HOME here refers to remote $HOME, not local
echo $HOME
REMOTE_SCRIPT
```

### 3. Idempotent Commands

Make commands safe to re-run:

```bash
# BAD - appends every time
echo "vm.swappiness=10" >> /etc/sysctl.conf

# GOOD - check first
if ! grep -q "vm.swappiness=10" /etc/sysctl.conf; then
  echo "vm.swappiness=10" >> /etc/sysctl.conf
fi

# GOOD - use command -v for binaries
if ! command -v docker &> /dev/null; then
  curl -fsSL https://get.docker.com | sh
fi
```

### 4. Colored Output

Make progress visible:

```bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'  # No Color

echo -e "${YELLOW}==> Working...${NC}"
echo -e "${GREEN}==> Success!${NC}"
echo -e "${RED}==> Error!${NC}"
```

## Integration with OpenTofu

Reference the script in your outputs:

```hcl
output "next_steps" {
  value = <<-EOT
    1. Run: bin/setup-server ${hcloud_server.web.ipv4_address}
    2. Run: kamal setup
  EOT
}
```

## When to Use What

| Task | Cloud-Init | Post-Provisioning Script |
|------|------------|-------------------------|
| Package install | ✅ | |
| User creation | ✅ | |
| SSH hardening | ✅ | |
| Docker install | ✅ or ✅ | Either works |
| App-specific setup | | ✅ |
| Docker login | | ✅ |
| Complex conditionals | | ✅ |
| Re-runnable tasks | | ✅ |
