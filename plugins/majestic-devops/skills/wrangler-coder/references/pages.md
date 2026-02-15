# Cloudflare Pages

## Configuration (wrangler.toml for Functions)

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

## CLI Commands

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

## Pages Functions

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
