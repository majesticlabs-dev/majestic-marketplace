# Cloudflare Worker Setup Patterns

## Full wrangler.toml Configuration

```toml
name = "my-worker"
main = "src/index.ts"
compatibility_date = "2024-12-01"
compatibility_flags = ["nodejs_compat"]

# Environment variables (non-secret)
[vars]
ENVIRONMENT = "production"

# KV Namespace binding
[[kv_namespaces]]
binding = "CACHE"
id = "xxxxx"

# D1 Database binding
[[d1_databases]]
binding = "DB"
database_name = "my-database"
database_id = "xxxxx"

# R2 Bucket binding
[[r2_buckets]]
binding = "STORAGE"
bucket_name = "my-bucket"

# Durable Objects binding
[[durable_objects.bindings]]
name = "COUNTER"
class_name = "Counter"

[[migrations]]
tag = "v1"
new_classes = ["Counter"]

# Queue Producer binding
[[queues.producers]]
queue = "my-queue"
binding = "QUEUE"

# Queue Consumer
[[queues.consumers]]
queue = "my-queue"
max_batch_size = 10
max_batch_timeout = 30
```

## Type-Safe Environment Bindings

```typescript
// src/types.ts
export interface Env {
  // Variables
  ENVIRONMENT: string;
  API_KEY: string; // Secret (set via wrangler secret)

  // KV
  CACHE: KVNamespace;

  // D1
  DB: D1Database;

  // R2
  STORAGE: R2Bucket;

  // Durable Objects
  COUNTER: DurableObjectNamespace;

  // Queues
  QUEUE: Queue<QueueMessage>;
}

export interface QueueMessage {
  type: string;
  payload: unknown;
  timestamp: number;
}
```

## TypeScript Configuration

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "lib": ["ES2022"],
    "types": ["@cloudflare/workers-types"],
    "strict": true,
    "noEmit": true,
    "skipLibCheck": true
  },
  "include": ["src/**/*", "test/**/*"]
}
```

## Basic Worker Export

```typescript
// src/index.ts
import { Env } from './types';

export default {
  async fetch(request: Request, env: Env, ctx: ExecutionContext): Promise<Response> {
    const url = new URL(request.url);

    if (url.pathname === '/health') {
      return new Response('OK', { status: 200 });
    }

    return new Response('Not Found', { status: 404 });
  },
} satisfies ExportedHandler<Env>;
```
