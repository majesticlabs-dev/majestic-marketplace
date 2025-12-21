# Complete Worker Example

A production-ready Cloudflare Worker with D1, KV, R2 bindings, multi-environment config, and CORS handling.

## wrangler.toml

```toml
name = "my-api"
main = "src/index.ts"
compatibility_date = "2024-12-01"
compatibility_flags = ["nodejs_compat"]

[vars]
APP_NAME = "My API"

[[kv_namespaces]]
binding = "CACHE"
id = "xxx"

[[d1_databases]]
binding = "DB"
database_name = "my-db"
database_id = "xxx"

[[r2_buckets]]
binding = "STORAGE"
bucket_name = "my-bucket"

[env.staging]
name = "my-api-staging"
vars = { ENVIRONMENT = "staging" }
routes = [
  { pattern = "staging-api.example.com/*", zone_name = "example.com" }
]

[env.production]
name = "my-api-production"
vars = { ENVIRONMENT = "production" }
routes = [
  { pattern = "api.example.com/*", zone_name = "example.com" }
]
```

## src/index.ts

```typescript
export interface Env {
  APP_NAME: string;
  ENVIRONMENT: string;
  CACHE: KVNamespace;
  DB: D1Database;
  STORAGE: R2Bucket;
  API_KEY: string;  // Secret
}

export default {
  async fetch(request: Request, env: Env, ctx: ExecutionContext): Promise<Response> {
    const url = new URL(request.url);

    // CORS headers
    const corsHeaders = {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
      "Access-Control-Allow-Headers": "Content-Type, Authorization",
    };

    if (request.method === "OPTIONS") {
      return new Response(null, { headers: corsHeaders });
    }

    try {
      // Route handling
      if (url.pathname === "/health") {
        return Response.json({
          status: "ok",
          app: env.APP_NAME,
          environment: env.ENVIRONMENT
        }, { headers: corsHeaders });
      }

      if (url.pathname.startsWith("/api/users")) {
        return handleUsers(request, env, corsHeaders);
      }

      return new Response("Not found", { status: 404, headers: corsHeaders });

    } catch (error) {
      console.error("Error:", error);
      return Response.json(
        { error: "Internal server error" },
        { status: 500, headers: corsHeaders }
      );
    }
  }
};

async function handleUsers(request: Request, env: Env, headers: HeadersInit): Promise<Response> {
  if (request.method === "GET") {
    const { results } = await env.DB.prepare("SELECT * FROM users").all();
    return Response.json({ users: results }, { headers });
  }

  if (request.method === "POST") {
    const body = await request.json<{ email: string; name: string }>();
    await env.DB.prepare("INSERT INTO users (email, name) VALUES (?, ?)")
      .bind(body.email, body.name)
      .run();
    return Response.json({ success: true }, { status: 201, headers });
  }

  return new Response("Method not allowed", { status: 405, headers });
}
```
