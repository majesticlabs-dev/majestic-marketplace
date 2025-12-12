# Durable Objects Patterns

## Basic Durable Object

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

  async initialize() {
    const stored = await this.ctx.storage.get<number>('count');
    this.count = stored ?? 0;
  }
}
```

## Calling from Worker

```typescript
app.post('/counter/:name/increment', async (c) => {
  const name = c.req.param('name');
  const id = c.env.COUNTER.idFromName(name);
  const stub = c.env.COUNTER.get(id);

  const response = await stub.fetch(new Request('http://do/increment'));
  const count = await response.text();

  return c.json({ count: Number(count) });
});
```

## WebSocket Hibernation (Recommended)

```typescript
// src/chat-room.ts
import { DurableObject } from 'cloudflare:workers';

export class ChatRoom extends DurableObject {
  async fetch(request: Request): Promise<Response> {
    const url = new URL(request.url);

    if (url.pathname === '/websocket') {
      const upgradeHeader = request.headers.get('Upgrade');
      if (upgradeHeader !== 'websocket') {
        return new Response('Expected WebSocket', { status: 426 });
      }

      const [client, server] = Object.values(new WebSocketPair());
      const name = url.searchParams.get('name') || 'Anonymous';

      // Use Hibernation API (NOT server.accept())
      this.ctx.acceptWebSocket(server, [name]);

      return new Response(null, { status: 101, webSocket: client });
    }

    return new Response('Not found', { status: 404 });
  }

  // Hibernation handlers
  async webSocketMessage(ws: WebSocket, message: string | ArrayBuffer) {
    const data = JSON.parse(message as string);
    const [name] = this.ctx.getTags(ws);

    const broadcast = JSON.stringify({
      type: 'message',
      from: name,
      content: data.content,
      timestamp: Date.now(),
    });

    for (const socket of this.ctx.getWebSockets()) {
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

## Rate Limiter Pattern

```typescript
export class RateLimiter extends DurableObject {
  async fetch(request: Request): Promise<Response> {
    const { limit, window } = await request.json<{ limit: number; window: number }>();

    const now = Date.now();
    const windowStart = now - window * 1000;

    const requests: number[] = await this.ctx.storage.get('requests') || [];
    const validRequests = requests.filter(ts => ts > windowStart);

    if (validRequests.length >= limit) {
      return new Response('Rate limited', { status: 429 });
    }

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
