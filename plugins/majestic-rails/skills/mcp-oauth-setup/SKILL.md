---
name: mcp-oauth-setup
description: Implement MCP server authentication with OAuth Dynamic Client Registration (RFC 7591), Authorization Server Metadata Discovery (RFC 8414), and per-agent credential support. Use when building admin UIs that let users connect to third-party MCP servers using OAuth (Linear, Sentry, Granola), bearer tokens (Render, custom APIs), or API keys. Covers metadata discovery, client registration, PKCE authorization, token exchange, token refresh, tool sync, and credential storage patterns.
---

# MCP Server Authentication & OAuth Dynamic Client Registration

Implement flexible authentication for MCP (Model Context Protocol) server connections.
For OAuth providers, auto-discover endpoints and dynamically register as a client —
the user just provides the MCP server URL and clicks "Connect." For bearer/API key
providers, support both admin-shared and per-agent credentials so different agents
can authenticate with different accounts.

## When to Use

- Building an admin UI for managing MCP server connections
- Integrating with third-party MCP providers (Linear, Sentry, Granola, Render, etc.)
- Implementing the MCP Streamable HTTP transport with authenticated tool sync
- Adding per-agent credential support so each agent can use its own account
- Adding OAuth to an existing MCP connector/server management system

## Core Standards

The OAuth implementation relies on three RFCs:

1. **RFC 8414** - OAuth Authorization Server Metadata Discovery via `.well-known/oauth-authorization-server`
2. **RFC 7591** - Dynamic Client Registration at the provider's registration endpoint
3. **RFC 7636** - PKCE (S256) for authorization code security

**Not all MCP servers use OAuth.** Some (e.g., Render) use bearer tokens with API keys
and handle account/workspace selection at the MCP protocol level. The credential system
must be auth-type-agnostic.

## Architecture Overview

### Credential Mode (Orthogonal to Auth Type)

`credential_mode` applies to **all** auth types (bearer, api_key_header, oauth), not
just OAuth. Different agents may need their own credentials for the same MCP server.

```
credential_mode = "shared"     → Admin provides one credential, all agents use it
credential_mode = "per_agent"  → Each agent has its own credential
```

### OAuth Flow

```
Admin clicks "Connect"
    |
    v
Discover OAuth metadata (RFC 8414)
    |  GET /.well-known/oauth-authorization-server
    v
Register as OAuth client (RFC 7591)
    |  POST /oauth/register
    v
Redirect to provider consent screen
    |  GET /oauth/authorize?client_id=...&code_challenge=...
    v
Provider redirects back with code
    |  GET /callback?code=...&state=...
    v
Exchange code for tokens
    |  POST /oauth/token
    v
Store tokens, sync tools
```

## Implementation Steps

### 1. Database Schema

Two tables: MCP server configuration (OAuth metadata + shared tokens) and per-agent credentials (any auth type).

See: `references/schema.md`

Key decisions:
- Encrypt all secrets at rest (`encrypts :oauth_client_id`, etc.)
- Store both shared tokens and per-agent tokens (join table)
- `credential_mode` (`"shared"` or `"per_agent"`) applies to ALL auth types
- Store `discovered_tools` as JSON array
- `AgentMcpConnection.access_token` stores OAuth tokens, bearer tokens, or API keys

### 2. OAuth Discovery and Registration

Three model methods on the MCP server record.

See: `references/oauth_flow.md`

- **Discovery** (`discover_oauth_metadata!`): Derive `.well-known/oauth-authorization-server` URL, parse JSON response, skip if already configured, handle 404 gracefully (not all servers support RFC 8414)
- **Registration** (`register_oauth_client!`): POST to registration endpoint, store `client_id` and `client_secret`, skip if already present
- **Combined** (`discover_and_register_oauth!`): Run discovery then registration in sequence

### 3. Authorization Controller

Create an OAuth controller with `authorize` and `callback` actions.

See: `references/oauth_flow.md`

**Critical pitfalls:**

**Turbo Drive cross-origin redirects**: `redirect_to` with an external URL is silently swallowed by Turbo Drive — browser stays on current page. Use HTML with `<meta http-equiv="refresh" content="0;url=...">` for the external redirect instead.

**State parameter**: Use a signed, expiring message (Rails `message_verifier`) with connector ID, PKCE code verifier, optional agent ID, and timestamp. Set 10-minute expiry.

**String keys from message verifier**: After verifying the state token, payload uses **string keys** not symbol keys. Use `payload["connector_id"]`, not `payload[:connector_id]`.

**PKCE (S256)**: Generate a random `code_verifier`, compute `code_challenge` as URL-safe Base64 of SHA-256 digest with no padding.

**Error redirects**: When `agent_id` is present in state, redirect errors to the agent edit page, not the connectors index.

**Auto-sync on first agent connection**: For per-agent OAuth, when the callback stores the first per-agent token, auto-sync tools using that agent's token if tools haven't been discovered yet.

### 4. Routes

```ruby
resources :connectors do
  member do
    get "oauth/authorize", to: "mcp_oauth#authorize", as: :mcp_oauth_authorize
  end
end
get "mcp_oauth/callback", to: "mcp_oauth#callback", as: :mcp_oauth_callback
```

**Route helper naming**: A member route `mcp_oauth_authorize` on `resources :connectors` generates `mcp_oauth_authorize_connector_path(connector)` — resource name comes **last**. Common source of `NoMethodError`.

### 5. Token Management

See: `references/oauth_flow.md` (`ensure_token_fresh!` pattern)

- Check expiry with 5-minute buffer (`token_expires_at < 5.minutes.from_now`)
- Use `with_lock` for thread-safe updates on shared tokens
- Return appropriate token based on credential mode
- Bearer/API key per-agent tokens are static (no refresh needed)

### 6. MCP Tool Sync (Streamable HTTP Protocol)

See: `references/tool_sync.md`

Two-step handshake:
1. Send `initialize` JSON-RPC request → get `Mcp-Session-Id` header
2. Send `tools/list` with session ID header

Critical details:
- Set `Accept: application/json, text/event-stream` — some servers return 406 without this
- Some servers return SSE format — parse both formats
- `sync_tools!` must accept `agent:` parameter for per-agent auth
- Some servers (e.g., Render) allow unauthenticated tool listing

### 7. UI Considerations

See: `references/ui_patterns.md`

**Connector form:**
- `credential_mode` radio applies to ALL auth types
- Hide admin token input when per-agent is selected for bearer/API key
- Show OAuth fields only for OAuth auth type
- Use Stimulus controller to toggle visibility based on both `auth_type` AND `credential_mode`

**Agent edit form — three states for per-agent connectors:**
1. Per-agent OAuth, not connected → grayed card, "Connect" button
2. Per-agent bearer/API key, not connected → inline password input
3. Connected (any type) → tool checkboxes + "Token configured" badge

## Verified MCP Providers

| Provider | URL | Tools | Auth | Notes |
|----------|-----|-------|------|-------|
| Linear | `https://mcp.linear.app/mcp` | 45 | OAuth | SSE response format |
| Sentry | `https://mcp.sentry.dev/mcp` | 14 | OAuth | Standard JSON |
| Granola | `https://mcp.granola.ai/mcp` | 4 | OAuth | Standard JSON |
| Render | `https://mcp.render.com/mcp` | 24 | Bearer token | No OAuth, per-agent API keys |

## Common Failure Modes

| Symptom | Root Cause | Fix |
|---------|-----------|-----|
| Page stays on form, no redirect | Turbo Drive swallows cross-origin 302 | Use HTML meta refresh instead of `redirect_to` |
| `NoMethodError` on route helper | Wrong helper name ordering | Member route generates `mcp_oauth_authorize_connector_path` |
| `payload[:connector_id]` returns nil | Message verifier returns string keys | Use `payload["connector_id"]` |
| 406 from MCP server | Missing Accept header | Add `Accept: application/json, text/event-stream` |
| 400 "Mcp-Session-Id required" | Skipped initialize handshake | Send `initialize` first, use returned session ID |
| JSON parse error on tool sync | Server returns SSE format | Detect and parse both formats |
| Token exchange fails silently | Missing `code_verifier` | Include PKCE verifier from signed state |
| OAuth discovery 404 | Server doesn't use OAuth | Use bearer or API key auth instead |
| Per-agent connector shows no tools | Admin can't sync without token | Tools auto-sync on first agent connection |
| Error redirect goes to wrong page | `agent_id` not checked in rescue | Redirect to agent edit when `agent_id` present |
