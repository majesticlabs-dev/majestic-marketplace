# Workers AI

## Configuration

```toml
name = "my-worker"
main = "src/index.ts"
compatibility_date = "2024-12-01"

[ai]
binding = "AI"
```

## Usage

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
