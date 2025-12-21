# Queues & Durable Objects

## Queues

### Configuration

```toml
name = "my-worker"
main = "src/index.ts"
compatibility_date = "2024-12-01"

# Producer binding
[[queues.producers]]
binding = "MY_QUEUE"
queue = "my-queue"

# Consumer binding
[[queues.consumers]]
queue = "my-queue"
max_batch_size = 10
max_batch_timeout = 30
max_retries = 3
dead_letter_queue = "my-dlq"
```

### CLI Commands

```bash
# Create queue
wrangler queues create my-queue
wrangler queues create my-dlq  # Dead letter queue

# List queues
wrangler queues list

# Delete queue
wrangler queues delete my-queue
```

### Usage in Worker

```typescript
export interface Env {
  MY_QUEUE: Queue;
}

interface MyMessage {
  userId: string;
  action: string;
}

export default {
  // Producer: Send messages to queue
  async fetch(request: Request, env: Env): Promise<Response> {
    await env.MY_QUEUE.send({
      userId: "123",
      action: "signup"
    });

    // Batch send
    await env.MY_QUEUE.sendBatch([
      { body: { userId: "1", action: "a" } },
      { body: { userId: "2", action: "b" } },
    ]);

    return new Response("Queued");
  },

  // Consumer: Process messages
  async queue(batch: MessageBatch<MyMessage>, env: Env): Promise<void> {
    for (const message of batch.messages) {
      try {
        console.log(`Processing: ${message.body.userId}`);
        // Process message...
        message.ack();
      } catch (error) {
        message.retry();  // Will retry or go to DLQ
      }
    }
  }
};
```

## Durable Objects

### Configuration

```toml
name = "my-worker"
main = "src/index.ts"
compatibility_date = "2024-12-01"

[[durable_objects.bindings]]
name = "COUNTER"
class_name = "Counter"

[[migrations]]
tag = "v1"
new_classes = ["Counter"]
```

### Implementation

```typescript
export interface Env {
  COUNTER: DurableObjectNamespace;
}

export class Counter {
  private state: DurableObjectState;
  private value: number = 0;

  constructor(state: DurableObjectState) {
    this.state = state;
    this.state.blockConcurrencyWhile(async () => {
      this.value = (await this.state.storage.get("value")) || 0;
    });
  }

  async fetch(request: Request): Promise<Response> {
    const url = new URL(request.url);

    switch (url.pathname) {
      case "/increment":
        this.value++;
        await this.state.storage.put("value", this.value);
        return new Response(String(this.value));

      case "/value":
        return new Response(String(this.value));

      default:
        return new Response("Not found", { status: 404 });
    }
  }
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const id = env.COUNTER.idFromName("global");
    const stub = env.COUNTER.get(id);
    return stub.fetch(request);
  }
};
```
