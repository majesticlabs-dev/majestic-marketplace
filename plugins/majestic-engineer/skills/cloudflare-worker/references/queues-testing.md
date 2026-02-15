# Queues & Testing Patterns

## Queue Producer

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
]);

// With delay
await env.QUEUE.send(
  { type: 'reminder', userId: '123' },
  { delaySeconds: 3600 }
);
```

## Queue Consumer

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
        message.ack();
      } catch (error) {
        console.error('Failed:', error);
        message.retry();
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
  }
}
```

## Vitest + Miniflare Setup

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

## Test Examples

```typescript
// test/index.test.ts
import { env } from 'cloudflare:test';
import { describe, it, expect, beforeAll } from 'vitest';
import app from '../src/index';

describe('API', () => {
  it('returns health check', async () => {
    const response = await app.fetch(new Request('http://localhost/health'), env);
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
    expect(await env.CACHE.get('test-key')).toBe('test-value');
  });
});

describe('D1', () => {
  beforeAll(async () => {
    await env.DB.run(`CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY, name TEXT)`);
  });

  it('queries database', async () => {
    await env.DB.prepare('INSERT INTO users (name) VALUES (?)').bind('Alice').run();
    const { results } = await env.DB.prepare('SELECT * FROM users').all();
    expect(results.length).toBeGreaterThan(0);
  });
});
```

## Running Tests

```bash
npm test              # Run all tests
npm test -- --watch   # Watch mode
npm test -- --coverage
```

## Error Handling Pattern

```typescript
// src/errors.ts
export class AppError extends Error {
  constructor(
    message: string,
    public statusCode: number = 500,
    public code: string = 'INTERNAL_ERROR'
  ) {
    super(message);
  }

  toJSON() {
    return { error: this.code, message: this.message };
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

// Usage in app
app.onError((err, c) => {
  if (err instanceof AppError) {
    return c.json(err.toJSON(), err.statusCode);
  }
  return c.json({ error: 'INTERNAL_ERROR' }, 500);
});
```

## Performance Patterns

```typescript
// Parallel fetches (good)
const [user, posts, comments] = await Promise.all([
  getUser(id),
  getPosts(id),
  getComments(id),
]);

// Background tasks with waitUntil
app.post('/webhook', async (c) => {
  const payload = await c.req.json();
  const response = c.json({ received: true });

  c.executionCtx.waitUntil(processWebhook(payload, c.env));

  return response;
});

// Cache API
app.get('/api/expensive', async (c) => {
  const cacheKey = new Request(c.req.url);
  const cache = caches.default;

  let response = await cache.match(cacheKey);
  if (response) return response;

  const data = await expensiveOperation();
  response = c.json(data);

  c.executionCtx.waitUntil(cache.put(cacheKey, response.clone()));

  return response;
});
```
