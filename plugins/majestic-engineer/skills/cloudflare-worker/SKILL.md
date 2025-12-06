---
name: cloudflare-worker
description: Build edge-first TypeScript applications on Cloudflare Workers. Covers Workers API, Hono framework, KV/D1/R2 storage, Durable Objects, Queues, and testing patterns. Use when creating serverless workers, edge functions, or Cloudflare-deployed services.
allowed-tools: Read, Write, Edit, MultiEdit, Grep, Glob, Bash, WebSearch, WebFetch
---

# Cloudflare Workers

## Overview

This skill provides patterns for building TypeScript applications on Cloudflare Workers - the edge-first serverless platform. Apply these standards when creating workers, edge functions, API endpoints, or any Cloudflare-deployed service.

## Core Principles

### Edge-First Thinking

- **Stateless by default**: Workers don't persist state between requests
- **Global distribution**: Code runs in 300+ data centers worldwide
- **Cold start optimized**: V8 isolates start in milliseconds, not seconds
- **Request/response model**: Each invocation handles one request

### When to Use Each Storage

| Storage | Use Case | Consistency | Latency |
|---------|----------|-------------|---------|
| **KV** | Config, feature flags, cached data | Eventually consistent | ~10ms reads |
| **D1** | Relational data, queries, transactions | Strong (single region) | ~30-50ms |
| **R2** | Files, images, large objects | Strong | ~50-100ms |
| **Durable Objects** | Real-time state, WebSockets, coordination | Strong (per-object) | ~50ms first, then fast |
| **Queues** | Async processing, batching, retries | At-least-once delivery | Async |

## Project Setup

### Basic Worker Structure

```
my-worker/
├── src/
│   ├── index.ts          # Entry point
│   ├── routes/           # Route handlers (if using Hono)
│   ├── services/         # Business logic
│   ├── types.ts          # Type definitions
│   └── utils/            # Helpers
├── test/
│   └── index.test.ts     # Vitest tests
├── wrangler.toml         # Cloudflare config
├── package.json
└── tsconfig.json
```

### wrangler.toml Configuration

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

### TypeScript Configuration

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

## Environment Bindings

### Type-Safe Bindings

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

### Basic Worker Export

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

## Hono Framework

### Why Hono?

- **Ultrafast**: Built for edge runtimes
- **Type-safe**: Full TypeScript support with typed bindings
- **Minimal**: ~14KB, no dependencies
- **Familiar**: Express-like API

### Basic Hono Setup

```typescript
// src/index.ts
import { Hono } from 'hono';
import { cors } from 'hono/cors';
import { logger } from 'hono/logger';
import { Env } from './types';

const app = new Hono<{ Bindings: Env }>();

// Middleware
app.use('*', logger());
app.use('*', cors());

// Routes
app.get('/', (c) => c.json({ status: 'ok' }));

app.get('/config', async (c) => {
  // Access env bindings via c.env
  const config = await c.env.CACHE.get('config', 'json');
  return c.json(config);
});

// Error handling
app.onError((err, c) => {
  console.error('Error:', err);
  return c.json({ error: 'Internal Server Error' }, 500);
});

app.notFound((c) => c.json({ error: 'Not Found' }, 404));

export default app;
```

### Route Organization

```typescript
// src/routes/users.ts
import { Hono } from 'hono';
import { Env } from '../types';

const users = new Hono<{ Bindings: Env }>();

users.get('/', async (c) => {
  const { results } = await c.env.DB.prepare(
    'SELECT id, name, email FROM users LIMIT 100'
  ).all();
  return c.json(results);
});

users.get('/:id', async (c) => {
  const id = c.req.param('id');
  const user = await c.env.DB.prepare(
    'SELECT * FROM users WHERE id = ?'
  ).bind(id).first();

  if (!user) {
    return c.json({ error: 'User not found' }, 404);
  }
  return c.json(user);
});

users.post('/', async (c) => {
  const body = await c.req.json<{ name: string; email: string }>();

  const result = await c.env.DB.prepare(
    'INSERT INTO users (name, email) VALUES (?, ?) RETURNING *'
  ).bind(body.name, body.email).first();

  return c.json(result, 201);
});

export { users };
```

```typescript
// src/index.ts
import { Hono } from 'hono';
import { users } from './routes/users';

const app = new Hono<{ Bindings: Env }>();

app.route('/users', users);

export default app;
```

### Middleware Patterns

```typescript
// src/middleware/auth.ts
import { Context, Next } from 'hono';
import { Env } from '../types';

export async function authMiddleware(c: Context<{ Bindings: Env }>, next: Next) {
  const authHeader = c.req.header('Authorization');

  if (!authHeader?.startsWith('Bearer ')) {
    return c.json({ error: 'Unauthorized' }, 401);
  }

  const token = authHeader.slice(7);

  // Validate token (example: check against KV)
  const session = await c.env.CACHE.get(`session:${token}`, 'json');

  if (!session) {
    return c.json({ error: 'Invalid token' }, 401);
  }

  // Attach user to context
  c.set('user', session);
  await next();
}
```

```typescript
// Usage
app.use('/api/*', authMiddleware);
```

## KV Storage

### Basic Operations

```typescript
// Read
const value = await env.CACHE.get('key');
const json = await env.CACHE.get('key', 'json');
const stream = await env.CACHE.get('key', 'stream');

// Write
await env.CACHE.put('key', 'value');
await env.CACHE.put('key', JSON.stringify(data));

// Write with expiration
await env.CACHE.put('key', 'value', {
  expirationTtl: 3600,  // Seconds
  // OR
  expiration: Math.floor(Date.now() / 1000) + 3600,  // Unix timestamp
});

// Write with metadata
await env.CACHE.put('key', 'value', {
  metadata: { version: 1, createdAt: Date.now() },
});

// Delete
await env.CACHE.delete('key');

// List keys
const { keys, cursor, list_complete } = await env.CACHE.list({
  prefix: 'user:',
  limit: 100,
});
```

### KV Caching Pattern

```typescript
async function getCachedData<T>(
  kv: KVNamespace,
  key: string,
  fetcher: () => Promise<T>,
  ttl: number = 300
): Promise<T> {
  // Try cache first
  const cached = await kv.get(key, 'json');
  if (cached) return cached as T;

  // Fetch fresh data
  const data = await fetcher();

  // Cache in background (don't await)
  kv.put(key, JSON.stringify(data), { expirationTtl: ttl });

  return data;
}

// Usage
const config = await getCachedData(
  env.CACHE,
  'app:config',
  () => fetchConfigFromAPI(),
  3600
);
```

## D1 Database

### Schema & Migrations

```sql
-- migrations/0001_initial.sql
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  email TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  created_at TEXT DEFAULT (datetime('now'))
);

CREATE INDEX idx_users_email ON users(email);

CREATE TABLE posts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL REFERENCES users(id),
  title TEXT NOT NULL,
  content TEXT,
  published_at TEXT,
  created_at TEXT DEFAULT (datetime('now'))
);

CREATE INDEX idx_posts_user ON posts(user_id);
CREATE INDEX idx_posts_published ON posts(published_at);
```

Apply migrations:
```bash
wrangler d1 migrations apply my-database
```

### Query Patterns

```typescript
// Single row
const user = await env.DB.prepare(
  'SELECT * FROM users WHERE id = ?'
).bind(userId).first<User>();

// Multiple rows
const { results } = await env.DB.prepare(
  'SELECT * FROM posts WHERE user_id = ? ORDER BY created_at DESC'
).bind(userId).all<Post>();

// With joins
const { results } = await env.DB.prepare(`
  SELECT p.*, u.name as author_name
  FROM posts p
  JOIN users u ON p.user_id = u.id
  WHERE p.published_at IS NOT NULL
  ORDER BY p.published_at DESC
  LIMIT ?
`).bind(10).all();

// Insert returning
const newUser = await env.DB.prepare(
  'INSERT INTO users (email, name) VALUES (?, ?) RETURNING *'
).bind(email, name).first<User>();

// Batch operations
const batch = await env.DB.batch([
  env.DB.prepare('INSERT INTO users (email, name) VALUES (?, ?)').bind('a@example.com', 'Alice'),
  env.DB.prepare('INSERT INTO users (email, name) VALUES (?, ?)').bind('b@example.com', 'Bob'),
]);
```

### Type Generation

```bash
# Generate types from D1 schema
wrangler d1 generate-types my-database --output src/db-types.ts
```

```typescript
// src/db-types.ts (generated)
export interface User {
  id: number;
  email: string;
  name: string;
  created_at: string;
}

export interface Post {
  id: number;
  user_id: number;
  title: string;
  content: string | null;
  published_at: string | null;
  created_at: string;
}
```

## R2 Object Storage

### Basic Operations

```typescript
// Upload
await env.STORAGE.put('path/to/file.txt', 'content');
await env.STORAGE.put('path/to/file.json', JSON.stringify(data), {
  httpMetadata: { contentType: 'application/json' },
  customMetadata: { uploadedBy: 'worker' },
});

// Upload from request body (streaming)
await env.STORAGE.put('uploads/image.png', request.body, {
  httpMetadata: {
    contentType: request.headers.get('Content-Type') || 'application/octet-stream',
  },
});

// Download
const object = await env.STORAGE.get('path/to/file.txt');
if (object) {
  const text = await object.text();
  // OR
  const json = await object.json();
  // OR
  return new Response(object.body, {
    headers: { 'Content-Type': object.httpMetadata?.contentType || 'application/octet-stream' },
  });
}

// Check existence
const head = await env.STORAGE.head('path/to/file.txt');
if (head) {
  console.log('Size:', head.size);
  console.log('Uploaded:', head.uploaded);
}

// Delete
await env.STORAGE.delete('path/to/file.txt');

// List objects
const { objects, truncated, cursor } = await env.STORAGE.list({
  prefix: 'uploads/',
  limit: 100,
});
```

### Signed URLs (Presigned)

```typescript
// R2 doesn't have built-in signed URLs, use Workers to proxy
app.get('/download/:key', async (c) => {
  const key = c.req.param('key');
  const object = await c.env.STORAGE.get(key);

  if (!object) {
    return c.json({ error: 'Not found' }, 404);
  }

  return new Response(object.body, {
    headers: {
      'Content-Type': object.httpMetadata?.contentType || 'application/octet-stream',
      'Content-Disposition': `attachment; filename="${key.split('/').pop()}"`,
      'Cache-Control': 'private, max-age=3600',
    },
  });
});
```

## Durable Objects

### When to Use

- **Real-time coordination**: Chat rooms, game state, collaborative editing
- **WebSocket management**: Long-lived connections with state
- **Rate limiting**: Per-user or per-IP counters
- **Distributed locks**: Coordination between workers

### Basic Durable Object

```typescript
// src/counter.ts
import { DurableObject } from 'cloudflare:workers';
import { Env } from './types';

export class Counter extends DurableObject<Env> {
  private count: number = 0;

  constructor(ctx: DurableObjectState, env: Env) {
    super(ctx, env);
  }

  async fetch(request: Request): Promise<Response> {
    const url = new URL(request.url);

    switch (url.pathname) {
      case '/increment':
        this.count++;
        await this.ctx.storage.put('count', this.count);
        return new Response(String(this.count));

      case '/decrement':
        this.count--;
        await this.ctx.storage.put('count', this.count);
        return new Response(String(this.count));

      case '/':
        return new Response(String(this.count));

      default:
        return new Response('Not found', { status: 404 });
    }
  }

  // Called when DO wakes up
  async initialize() {
    const stored = await this.ctx.storage.get<number>('count');
    this.count = stored ?? 0;
  }
}
```

### Calling Durable Objects

```typescript
// From Worker
app.post('/counter/:name/increment', async (c) => {
  const name = c.req.param('name');

  // Get DO stub by name (creates if doesn't exist)
  const id = c.env.COUNTER.idFromName(name);
  const stub = c.env.COUNTER.get(id);

  // Call DO method
  const response = await stub.fetch(new Request('http://do/increment'));
  const count = await response.text();

  return c.json({ count: Number(count) });
});
```

### WebSocket Hibernation (Recommended)

```typescript
// src/chat-room.ts
import { DurableObject } from 'cloudflare:workers';

interface Session {
  name: string;
  joinedAt: number;
}

export class ChatRoom extends DurableObject {
  async fetch(request: Request): Promise<Response> {
    const url = new URL(request.url);

    if (url.pathname === '/websocket') {
      // Handle WebSocket upgrade
      const upgradeHeader = request.headers.get('Upgrade');
      if (upgradeHeader !== 'websocket') {
        return new Response('Expected WebSocket', { status: 426 });
      }

      const [client, server] = Object.values(new WebSocketPair());

      // Accept with Hibernation API (NOT server.accept())
      const name = url.searchParams.get('name') || 'Anonymous';
      this.ctx.acceptWebSocket(server, [name]);

      return new Response(null, { status: 101, webSocket: client });
    }

    return new Response('Not found', { status: 404 });
  }

  // Hibernation API handlers
  async webSocketMessage(ws: WebSocket, message: string | ArrayBuffer) {
    const data = JSON.parse(message as string);
    const [name] = this.ctx.getTags(ws);

    // Broadcast to all connected clients
    const sockets = this.ctx.getWebSockets();
    const broadcast = JSON.stringify({
      type: 'message',
      from: name,
      content: data.content,
      timestamp: Date.now(),
    });

    for (const socket of sockets) {
      socket.send(broadcast);
    }
  }

  async webSocketClose(ws: WebSocket, code: number, reason: string) {
    const [name] = this.ctx.getTags(ws);
    console.log(`${name} disconnected: ${code} ${reason}`);
  }

  async webSocketError(ws: WebSocket, error: unknown) {
    console.error('WebSocket error:', error);
    ws.close(1011, 'Internal error');
  }
}
```

## Queues

### Producer

```typescript
// Send single message
await env.QUEUE.send({
  type: 'email',
  payload: { to: 'user@example.com', subject: 'Hello' },
  timestamp: Date.now(),
});

// Send batch
await env.QUEUE.sendBatch([
  { body: { type: 'process', id: 1 } },
  { body: { type: 'process', id: 2 } },
  { body: { type: 'process', id: 3 } },
]);

// With delay
await env.QUEUE.send(
  { type: 'reminder', userId: '123' },
  { delaySeconds: 3600 }  // 1 hour delay
);
```

### Consumer

```typescript
// src/index.ts
export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    // ... HTTP handler
  },

  async queue(batch: MessageBatch<QueueMessage>, env: Env): Promise<void> {
    for (const message of batch.messages) {
      try {
        await processMessage(message.body, env);
        message.ack();  // Acknowledge success
      } catch (error) {
        console.error('Failed to process:', error);
        message.retry();  // Retry later
      }
    }
  },
} satisfies ExportedHandler<Env>;

async function processMessage(msg: QueueMessage, env: Env) {
  switch (msg.type) {
    case 'email':
      await sendEmail(msg.payload);
      break;
    case 'process':
      await processItem(msg.payload, env);
      break;
    default:
      console.warn('Unknown message type:', msg.type);
  }
}
```

## Testing

### Vitest + Miniflare Setup

```typescript
// vitest.config.ts
import { defineWorkersConfig } from '@cloudflare/vitest-pool-workers/config';

export default defineWorkersConfig({
  test: {
    poolOptions: {
      workers: {
        wrangler: { configPath: './wrangler.toml' },
      },
    },
  },
});
```

### Test Examples

```typescript
// test/index.test.ts
import { env, createExecutionContext, waitOnExecutionContext } from 'cloudflare:test';
import { describe, it, expect, beforeAll } from 'vitest';
import app from '../src/index';

describe('API', () => {
  it('returns health check', async () => {
    const response = await app.fetch(
      new Request('http://localhost/health'),
      env
    );
    expect(response.status).toBe(200);
    expect(await response.text()).toBe('OK');
  });

  it('creates a user', async () => {
    const response = await app.fetch(
      new Request('http://localhost/users', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ name: 'Test', email: 'test@example.com' }),
      }),
      env
    );

    expect(response.status).toBe(201);
    const user = await response.json();
    expect(user.name).toBe('Test');
  });
});

describe('KV', () => {
  it('caches data', async () => {
    await env.CACHE.put('test-key', 'test-value');
    const value = await env.CACHE.get('test-key');
    expect(value).toBe('test-value');
  });
});

describe('D1', () => {
  beforeAll(async () => {
    // Setup test data
    await env.DB.run(`
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY,
        name TEXT
      )
    `);
  });

  it('queries database', async () => {
    await env.DB.prepare('INSERT INTO users (name) VALUES (?)').bind('Alice').run();
    const { results } = await env.DB.prepare('SELECT * FROM users').all();
    expect(results.length).toBeGreaterThan(0);
  });
});
```

### Running Tests

```bash
# Run all tests
npm test

# Watch mode
npm test -- --watch

# With coverage
npm test -- --coverage
```

## Error Handling

### Structured Errors

```typescript
// src/errors.ts
export class AppError extends Error {
  constructor(
    message: string,
    public statusCode: number = 500,
    public code: string = 'INTERNAL_ERROR'
  ) {
    super(message);
    this.name = 'AppError';
  }

  toJSON() {
    return {
      error: this.code,
      message: this.message,
    };
  }
}

export class NotFoundError extends AppError {
  constructor(resource: string) {
    super(`${resource} not found`, 404, 'NOT_FOUND');
  }
}

export class ValidationError extends AppError {
  constructor(message: string) {
    super(message, 400, 'VALIDATION_ERROR');
  }
}
```

```typescript
// src/index.ts
import { AppError } from './errors';

app.onError((err, c) => {
  console.error('Error:', err);

  if (err instanceof AppError) {
    return c.json(err.toJSON(), err.statusCode);
  }

  return c.json({ error: 'INTERNAL_ERROR', message: 'Something went wrong' }, 500);
});
```

## Performance Patterns

### Parallel Fetches

```typescript
// Bad: Sequential
const user = await getUser(id);
const posts = await getPosts(id);
const comments = await getComments(id);

// Good: Parallel
const [user, posts, comments] = await Promise.all([
  getUser(id),
  getPosts(id),
  getComments(id),
]);
```

### Background Tasks with waitUntil

```typescript
app.post('/webhook', async (c) => {
  const payload = await c.req.json();

  // Respond immediately
  const response = c.json({ received: true });

  // Process in background (doesn't block response)
  c.executionCtx.waitUntil(
    processWebhook(payload, c.env)
  );

  return response;
});
```

### Cache API

```typescript
app.get('/api/expensive', async (c) => {
  const cacheKey = new Request(c.req.url);
  const cache = caches.default;

  // Check cache
  let response = await cache.match(cacheKey);
  if (response) {
    return response;
  }

  // Compute expensive result
  const data = await expensiveOperation();
  response = c.json(data);

  // Clone before caching (response body can only be read once)
  c.executionCtx.waitUntil(
    cache.put(cacheKey, response.clone())
  );

  return response;
});
```

## Common Patterns

### API Key Authentication

```typescript
const apiKeyAuth = async (c: Context<{ Bindings: Env }>, next: Next) => {
  const apiKey = c.req.header('X-API-Key');

  if (!apiKey) {
    return c.json({ error: 'API key required' }, 401);
  }

  // Validate against KV
  const keyData = await c.env.CACHE.get(`apikey:${apiKey}`, 'json');
  if (!keyData) {
    return c.json({ error: 'Invalid API key' }, 401);
  }

  c.set('apiKeyData', keyData);
  await next();
};
```

### Rate Limiting with Durable Objects

```typescript
export class RateLimiter extends DurableObject {
  async fetch(request: Request): Promise<Response> {
    const { limit, window } = await request.json<{ limit: number; window: number }>();

    const now = Date.now();
    const windowStart = now - window * 1000;

    // Get current requests
    const requests: number[] = await this.ctx.storage.get('requests') || [];

    // Filter to current window
    const validRequests = requests.filter(ts => ts > windowStart);

    if (validRequests.length >= limit) {
      return new Response('Rate limited', { status: 429 });
    }

    // Add current request
    validRequests.push(now);
    await this.ctx.storage.put('requests', validRequests);

    return new Response('OK', {
      headers: {
        'X-RateLimit-Remaining': String(limit - validRequests.length),
        'X-RateLimit-Reset': String(Math.ceil((windowStart + window * 1000) / 1000)),
      },
    });
  }
}
```

## CLI Commands

```bash
# Development
wrangler dev                    # Start local dev server
wrangler dev --remote           # Dev with remote bindings

# Deploy
wrangler deploy                 # Deploy to production
wrangler deploy --env staging   # Deploy to staging

# D1
wrangler d1 create my-database              # Create database
wrangler d1 run my-database --file=schema.sql  # Run SQL file
wrangler d1 migrations create my-database migration-name
wrangler d1 migrations apply my-database

# KV
wrangler kv namespace create CACHE          # Create namespace
wrangler kv key put --namespace-id=xxx key value

# R2
wrangler r2 bucket create my-bucket

# Secrets
wrangler secret put API_KEY                 # Add secret
wrangler secret list                        # List secrets

# Logs
wrangler tail                               # Stream live logs
```

## Resources

- [Cloudflare Workers Docs](https://developers.cloudflare.com/workers/)
- [Hono Documentation](https://hono.dev/docs/getting-started/cloudflare-workers)
- [D1 Documentation](https://developers.cloudflare.com/d1/)
- [Durable Objects Guide](https://developers.cloudflare.com/durable-objects/)
- [Workers Examples](https://github.com/cloudflare/workers-sdk/tree/main/templates)

## Anti-Patterns to Avoid

- **Don't use Service Worker format**: Always use ES modules
- **Don't await cache writes**: Use `waitUntil` for non-blocking cache updates
- **Don't store large data in KV values**: Use R2 for files > 25MB
- **Don't use `server.accept()` for WebSockets in DOs**: Use `ctx.acceptWebSocket()` (Hibernation API)
- **Don't block on non-critical operations**: Use `waitUntil` for analytics, logging, etc.
- **Don't assume KV is immediately consistent**: Use D1 or DOs for consistency-critical operations
