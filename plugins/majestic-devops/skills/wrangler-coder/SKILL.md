---
name: wrangler-coder
description: This skill guides Cloudflare Workers and Pages development with Wrangler CLI. Use when creating Workers, configuring D1 databases, R2 storage, KV namespaces, Queues, or deploying to Cloudflare Pages.
allowed-tools: Read, Write, Edit, Grep, Glob, Bash
---

# Wrangler Coder

## Overview

Wrangler is Cloudflare's official CLI for Workers, Pages, D1, R2, KV, Queues, and AI. This skill covers Wrangler configuration patterns and deployment workflows.

## Installation

```bash
# npm
npm install -g wrangler

# pnpm
pnpm add -g wrangler

# Verify installation
wrangler --version
```

## Authentication

```bash
# Interactive login (opens browser)
wrangler login

# Check authentication status
wrangler whoami

# Logout
wrangler logout
```

**Environment Variables:**

```bash
# API Token (preferred for CI/CD)
export CLOUDFLARE_API_TOKEN="your-api-token"

# Or with 1Password
CLOUDFLARE_API_TOKEN=op://Infrastructure/Cloudflare/wrangler_token

# Account ID (optional, can be in wrangler.toml)
export CLOUDFLARE_ACCOUNT_ID="your-account-id"
```

## Project Initialization

```bash
# Create new Worker project
wrangler init my-worker

# Create from template
wrangler init my-worker --template cloudflare/worker-template

# Initialize in existing directory
wrangler init
```

## wrangler.toml Configuration

### Basic Worker

```toml
name = "my-worker"
main = "src/index.ts"
compatibility_date = "2024-12-01"

# Account ID (can also use CLOUDFLARE_ACCOUNT_ID env var)
account_id = "your-account-id"

# Worker settings
workers_dev = true  # Enable *.workers.dev subdomain
```

### Worker with Routes

```toml
name = "api-worker"
main = "src/index.ts"
compatibility_date = "2024-12-01"
account_id = "your-account-id"

# Custom domain routes
routes = [
  { pattern = "api.example.com/*", zone_name = "example.com" },
  { pattern = "example.com/api/*", zone_name = "example.com" }
]

# Or single route
# route = { pattern = "api.example.com/*", zone_name = "example.com" }
```

### Worker with Custom Domain

```toml
name = "my-worker"
main = "src/index.ts"
compatibility_date = "2024-12-01"
account_id = "your-account-id"

# Custom domains (requires DNS to be on Cloudflare)
[env.production]
routes = [
  { pattern = "api.example.com", custom_domain = true }
]
```

### Multi-Environment Configuration

```toml
name = "my-worker"
main = "src/index.ts"
compatibility_date = "2024-12-01"
account_id = "your-account-id"

# Development (default)
workers_dev = true

# Staging environment
[env.staging]
name = "my-worker-staging"
routes = [
  { pattern = "staging-api.example.com/*", zone_name = "example.com" }
]
vars = { ENVIRONMENT = "staging" }

# Production environment
[env.production]
name = "my-worker-production"
routes = [
  { pattern = "api.example.com/*", zone_name = "example.com" }
]
vars = { ENVIRONMENT = "production" }
```

## KV Namespaces

### Configuration

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

### CLI Commands

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

### Usage in Worker

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

## D1 Database & R2 Storage

See [resources/d1-r2.md](resources/d1-r2.md) for D1 database (migrations, queries, batch operations) and R2 object storage (upload, download, delete) configuration and usage.

## Queues & Durable Objects

See [resources/queues-durable-objects.md](resources/queues-durable-objects.md) for Queues (producers, consumers, dead letter queues) and Durable Objects (stateful edge storage) configuration and usage.

## Workers AI

### Configuration

```toml
name = "my-worker"
main = "src/index.ts"
compatibility_date = "2024-12-01"

[ai]
binding = "AI"
```

### Usage

```typescript
export interface Env {
  AI: Ai;
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    // Text generation
    const response = await env.AI.run("@cf/meta/llama-2-7b-chat-int8", {
      prompt: "What is Cloudflare Workers?",
    });

    // Image generation
    const image = await env.AI.run("@cf/stabilityai/stable-diffusion-xl-base-1.0", {
      prompt: "A cat wearing sunglasses",
    });

    // Text embeddings
    const embeddings = await env.AI.run("@cf/baai/bge-base-en-v1.5", {
      text: ["Hello world", "Goodbye world"],
    });

    return Response.json(response);
  }
};
```

## Secrets Management

### CLI Commands

```bash
# Add secret
wrangler secret put API_KEY
# (prompts for value)

# Add secret for specific environment
wrangler secret put API_KEY --env production

# List secrets
wrangler secret list

# Delete secret
wrangler secret delete API_KEY

# Bulk secrets from .dev.vars file (local dev only)
# Create .dev.vars file:
# API_KEY=xxx
# DB_PASSWORD=yyy
```

### Usage

```typescript
export interface Env {
  API_KEY: string;
  DB_PASSWORD: string;
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    // Access secrets from env
    const apiKey = env.API_KEY;
    return new Response(`Key length: ${apiKey.length}`);
  }
};
```

## Development Workflow

### Local Development

```bash
# Start local dev server
wrangler dev

# With specific environment
wrangler dev --env staging

# Custom port
wrangler dev --port 8787

# Remote mode (uses Cloudflare's network)
wrangler dev --remote

# Local mode with persistent storage
wrangler dev --persist-to ./data
```

### Testing

```bash
# Run tests with vitest (recommended)
npm install -D vitest @cloudflare/vitest-pool-workers

# vitest.config.ts
# import { defineWorkersConfig } from '@cloudflare/vitest-pool-workers/config';
# export default defineWorkersConfig({
#   test: { poolOptions: { workers: { wrangler: { configPath: './wrangler.toml' } } } }
# });
```

### Deployment

```bash
# Deploy to workers.dev
wrangler deploy

# Deploy to specific environment
wrangler deploy --env production

# Dry run (show what would be deployed)
wrangler deploy --dry-run

# Deploy with custom name
wrangler deploy --name my-custom-worker
```

### Logs and Debugging

```bash
# Tail logs (real-time)
wrangler tail

# Tail specific environment
wrangler tail --env production

# Filter logs
wrangler tail --status error
wrangler tail --search "user-id-123"
wrangler tail --ip 1.2.3.4

# View deployment versions
wrangler versions list

# Rollback to previous version
wrangler rollback
```

## Cloudflare Pages

### Configuration (wrangler.toml for Functions)

```toml
name = "my-site"
compatibility_date = "2024-12-01"
pages_build_output_dir = "./dist"

[[kv_namespaces]]
binding = "CACHE"
id = "your-namespace-id"

[[d1_databases]]
binding = "DB"
database_name = "my-database"
database_id = "your-database-id"
```

### CLI Commands

```bash
# Create Pages project
wrangler pages project create my-site

# Deploy
wrangler pages deploy ./dist

# Deploy to specific branch/environment
wrangler pages deploy ./dist --branch main
wrangler pages deploy ./dist --branch staging

# List deployments
wrangler pages deployment list --project-name my-site

# Tail logs
wrangler pages deployment tail --project-name my-site
```

### Pages Functions

```
project/
├── functions/
│   ├── api/
│   │   └── [[route]].ts  # Catch-all: /api/*
│   ├── hello.ts          # /hello
│   └── _middleware.ts    # Middleware for all routes
├── public/
└── wrangler.toml
```

```typescript
// functions/api/[[route]].ts
export const onRequest: PagesFunction<Env> = async (context) => {
  const { request, env, params } = context;
  const route = params.route;  // Array of path segments

  return Response.json({ route });
};
```

## Complete Worker Example

See [resources/worker-example.md](resources/worker-example.md) for a production-ready Worker with D1, KV, R2 bindings, multi-environment config, and CORS handling.

## Best Practices

- **Pin compatibility_date** - Ensures reproducible behavior across deployments
- **Use environments** - Separate staging/production configs in same file
- **Secrets via CLI** - Never commit secrets, use `wrangler secret put`
- **Local persistence** - Use `--persist-to` for consistent local dev state
- **Tail logs in production** - Debug issues with `wrangler tail --status error`
- **Version control wrangler.toml** - Track configuration changes
- **Use .dev.vars for local secrets** - Add to .gitignore
- **Batch D1 operations** - Reduce latency with `env.DB.batch()`
- **Cache strategically** - Use KV for frequently accessed data
- **Handle errors gracefully** - Return proper HTTP status codes
