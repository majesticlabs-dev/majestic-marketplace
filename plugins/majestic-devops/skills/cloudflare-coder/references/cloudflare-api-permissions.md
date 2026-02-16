# Cloudflare API Token Permissions

Minimum required permissions by use case:

| Resource | Permission | Use Case |
|----------|------------|----------|
| Zone | Read | List zones, read settings |
| Zone | Edit | Modify zone settings |
| DNS | Edit | Manage DNS records |
| Firewall | Edit | WAF, firewall rules |
| SSL | Edit | Certificate management |
| Cache | Purge | Cache invalidation |
| Page Rules | Edit | Page rule management |
| Workers Routes | Edit | Worker route configuration |
| Load Balancers | Edit | Load balancer management |

## Token Types

- **API Token** (preferred) - Scoped to specific permissions and zones
- **Global API Key** (legacy) - Full account access, avoid if possible

## Environment Variables

```bash
# API Token (preferred)
export CLOUDFLARE_API_TOKEN="your-api-token"

# Global API Key (legacy)
export CLOUDFLARE_API_KEY="your-global-api-key"
export CLOUDFLARE_EMAIL="your-email@example.com"
```
