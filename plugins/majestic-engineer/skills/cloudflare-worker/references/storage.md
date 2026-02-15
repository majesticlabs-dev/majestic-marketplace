# Storage Patterns (KV, D1, R2)

## KV Operations

```typescript
// Read
const value = await env.CACHE.get('key');
const json = await env.CACHE.get('key', 'json');
const stream = await env.CACHE.get('key', 'stream');

// Write with expiration
await env.CACHE.put('key', 'value', {
  expirationTtl: 3600,  // Seconds
  metadata: { version: 1, createdAt: Date.now() },
});

// Delete
await env.CACHE.delete('key');

// List keys
const { keys, cursor } = await env.CACHE.list({ prefix: 'user:', limit: 100 });
```

### KV Caching Pattern

```typescript
async function getCachedData<T>(
  kv: KVNamespace,
  key: string,
  fetcher: () => Promise<T>,
  ttl: number = 300
): Promise<T> {
  const cached = await kv.get(key, 'json');
  if (cached) return cached as T;

  const data = await fetcher();
  kv.put(key, JSON.stringify(data), { expirationTtl: ttl }); // Don't await
  return data;
}
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
```

Apply: `wrangler d1 migrations apply my-database`

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
  LIMIT ?
`).bind(10).all();

// Insert returning
const newUser = await env.DB.prepare(
  'INSERT INTO users (email, name) VALUES (?, ?) RETURNING *'
).bind(email, name).first<User>();

// Batch operations
const batch = await env.DB.batch([
  env.DB.prepare('INSERT INTO users (name) VALUES (?)').bind('Alice'),
  env.DB.prepare('INSERT INTO users (name) VALUES (?)').bind('Bob'),
]);
```

## R2 Object Storage

```typescript
// Upload
await env.STORAGE.put('path/to/file.json', JSON.stringify(data), {
  httpMetadata: { contentType: 'application/json' },
  customMetadata: { uploadedBy: 'worker' },
});

// Upload from request (streaming)
await env.STORAGE.put('uploads/image.png', request.body, {
  httpMetadata: { contentType: request.headers.get('Content-Type') || 'application/octet-stream' },
});

// Download
const object = await env.STORAGE.get('path/to/file.txt');
if (object) {
  return new Response(object.body, {
    headers: { 'Content-Type': object.httpMetadata?.contentType || 'application/octet-stream' },
  });
}

// Check existence
const head = await env.STORAGE.head('path/to/file.txt');

// Delete
await env.STORAGE.delete('path/to/file.txt');

// List
const { objects } = await env.STORAGE.list({ prefix: 'uploads/', limit: 100 });
```

### File Download Route

```typescript
app.get('/download/:key', async (c) => {
  const key = c.req.param('key');
  const object = await c.env.STORAGE.get(key);

  if (!object) return c.json({ error: 'Not found' }, 404);

  return new Response(object.body, {
    headers: {
      'Content-Type': object.httpMetadata?.contentType || 'application/octet-stream',
      'Content-Disposition': `attachment; filename="${key.split('/').pop()}"`,
    },
  });
});
```
