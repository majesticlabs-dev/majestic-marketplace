# Hono Framework Patterns

## Basic Setup

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

## Route Organization

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

  if (!user) return c.json({ error: 'User not found' }, 404);
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
// src/index.ts - Mount routes
import { users } from './routes/users';
app.route('/users', users);
```

## Auth Middleware

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
  const session = await c.env.CACHE.get(`session:${token}`, 'json');

  if (!session) {
    return c.json({ error: 'Invalid token' }, 401);
  }

  c.set('user', session);
  await next();
}

// Usage
app.use('/api/*', authMiddleware);
```

## API Key Middleware

```typescript
const apiKeyAuth = async (c: Context<{ Bindings: Env }>, next: Next) => {
  const apiKey = c.req.header('X-API-Key');

  if (!apiKey) {
    return c.json({ error: 'API key required' }, 401);
  }

  const keyData = await c.env.CACHE.get(`apikey:${apiKey}`, 'json');
  if (!keyData) {
    return c.json({ error: 'Invalid API key' }, 401);
  }

  c.set('apiKeyData', keyData);
  await next();
};
```
