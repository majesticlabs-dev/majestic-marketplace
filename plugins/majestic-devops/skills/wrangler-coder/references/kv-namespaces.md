# KV Namespaces

## Configuration

```toml
name = "my-worker"
main = "src/index.ts"
compatibility_date = "2024-12-01"

# KV namespace bindings
[[kv_namespaces]]
binding = "CACHE"
id = "your-kv-namespace-id"
preview_id = "your-preview-kv-namespace-id"  # For wrangler dev

[[kv_namespaces]]
binding = "SESSIONS"
id = "another-namespace-id"
```

## CLI Commands

```bash
# Create namespace
wrangler kv:namespace create CACHE
wrangler kv:namespace create CACHE --preview  # For development

# List namespaces
wrangler kv:namespace list

# Put/Get/Delete values
wrangler kv:key put --namespace-id=xxx "my-key" "my-value"
wrangler kv:key get --namespace-id=xxx "my-key"
wrangler kv:key delete --namespace-id=xxx "my-key"

# Bulk operations
wrangler kv:bulk put --namespace-id=xxx ./data.json
wrangler kv:bulk delete --namespace-id=xxx ./keys.json
```

## Usage in Worker

```typescript
export interface Env {
  CACHE: KVNamespace;
  SESSIONS: KVNamespace;
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    // Get value
    const cached = await env.CACHE.get("key");

    // Get with metadata
    const { value, metadata } = await env.CACHE.getWithMetadata("key");

    // Put value with expiration
    await env.CACHE.put("key", "value", {
      expirationTtl: 3600,  // 1 hour
      metadata: { version: 1 }
    });

    // List keys
    const keys = await env.CACHE.list({ prefix: "user:" });

    // Delete
    await env.CACHE.delete("key");

    return new Response("OK");
  }
};
```
