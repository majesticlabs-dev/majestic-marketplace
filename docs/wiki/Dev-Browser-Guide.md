# Dev Browser Guide

Browser automation plugin for Claude Code that enables Claude to control your browser for testing and verification during development.

## Why Dev Browser?

| Problem | Solution |
|---------|----------|
| Manual browser testing is slow | Claude automates navigation, clicks, form fills |
| Screenshots require context switching | Inline verification during development |
| Web scraping needs custom scripts | LLM-optimized DOM snapshots for easy extraction |
| Page state lost between commands | Persistent pages survive across scripts |

## Installation

### Prerequisites

- Claude Code CLI installed
- Node.js v18+ with npm

### Install the Plugin

```bash
/plugin marketplace add sawyerhood/dev-browser
/plugin install dev-browser@sawyerhood/dev-browser
```

Restart Claude Code after installation.

### Configure Permissions (Recommended)

Add to `~/.claude/settings.json` to avoid repeated prompts:

```json
{
  "permissions": {
    "allow": [
      "Skill(dev-browser:dev-browser)",
      "Bash(npx tsx:*)"
    ]
  }
}
```

## Using the Skill

### Invoke with Natural Language

Simply ask Claude to interact with your browser:

```
Open localhost:3000 and verify the signup form works
```

```
Go to the settings page and check why the save button is disabled
```

```
Take a screenshot of the dashboard after logging in
```

Claude will use the `/dev-browser` skill automatically when browser interaction is needed.

### Explicit Skill Invocation

```
/dev-browser navigate to example.com and extract all product prices
```

## How It Works

### Architecture

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────┐
│   Claude Code   │────▶│  Dev Browser     │────▶│   Browser   │
│   (requests)    │◀────│  Server          │◀────│   (Chrome)  │
└─────────────────┘     └──────────────────┘     └─────────────┘
                              │
                              ▼
                        ┌──────────────────┐
                        │  Persistent      │
                        │  Page State      │
                        └──────────────────┘
```

### Key Concepts

| Concept | Description |
|---------|-------------|
| **Persistent Pages** | Named pages survive across scripts - navigate once, interact many times |
| **AI Snapshots** | ARIA accessibility tree optimized for LLM understanding |
| **Refs** | Stable element references for reliable interactions |
| **Headless Mode** | Run browser without visible window (`--headless` flag) |

## Script Execution Pattern

Claude generates and executes scripts like this:

```bash
cd skills/dev-browser && npx tsx <<'EOF'
import { connect } from "@/client.js";

const client = await connect();
const page = await client.page("my-app");

await page.goto("http://localhost:3000");
await page.click('button:has-text("Login")');
await page.fill('input[name="email"]', 'test@example.com');

// Get AI-readable snapshot
const snapshot = await client.getAISnapshot("my-app");
console.log(snapshot);

await client.disconnect();
EOF
```

## Client API Reference

### Page Management

| Method | Description |
|--------|-------------|
| `client.page("name")` | Get or create a named page |
| `client.list()` | List all active pages |
| `client.disconnect()` | Clean disconnect (always call at end) |

### Inspection

| Method | Description |
|--------|-------------|
| `client.getAISnapshot("name")` | Get ARIA tree with element refs |
| `client.selectSnapshotRef("name", "ref")` | Interact with element by ref |
| `waitForPageLoad(page)` | Wait for navigation to complete |

### AI Snapshot Output

The snapshot provides semantic information:

```
button "Submit Form" [ref=btn-1] [enabled]
textbox "Email Address" [ref=input-2] [value=""]
link "Forgot Password?" [ref=link-3]
```

Use refs for reliable element selection:

```javascript
await client.selectSnapshotRef("my-app", "btn-1");
```

## Common Use Cases

### 1. Verify Feature Implementation

```
I just added a dark mode toggle. Open localhost:3000, click the toggle,
and verify the background color changes.
```

### 2. Debug UI Issues

```
The form submission isn't working. Go to the contact page, fill out
the form, submit it, and tell me what happens.
```

### 3. Screenshot Documentation

```
Take screenshots of the signup flow: landing page, signup form,
confirmation page.
```

### 4. Web Scraping

```
Go to example-shop.com and extract all product names and prices
into a JSON array.
```

### 5. E2E Testing Assistance

```
Walk through the checkout flow as a guest user and verify each
step works correctly.
```

## Performance

Dev Browser outperforms alternatives:

| Metric | Dev Browser | Playwright MCP | Chrome Extension |
|--------|-------------|----------------|------------------|
| Time | 3m 53s | 4m 30s | 12m+ |
| Cost | $0.88 | $1.45 | $2.81 |
| Success | 100% | 95% | 80% |

## Troubleshooting

### Server Not Starting

```bash
# Check if server is running
ps aux | grep dev-browser

# Start manually with logs
cd ~/.claude/skills/dev-browser && npm install && npm run start-server
```

### Permission Denied

Ensure permissions are configured in `~/.claude/settings.json` or run with `--dangerously-skip-permissions`.

### Element Not Found

Use `getAISnapshot()` first to discover available elements:

```javascript
const snapshot = await client.getAISnapshot("my-page");
console.log(snapshot);
// Find the correct ref, then interact
```

### Page State Lost

Use descriptive, unique page names:

```javascript
// Good - specific and memorable
await client.page("checkout-flow");
await client.page("admin-dashboard");

// Bad - generic, easy to overwrite
await client.page("main");
await client.page("page1");
```

## Best Practices

1. **Descriptive page names** - Use `"product-catalog"` not `"page1"`
2. **Always disconnect** - Call `await client.disconnect()` at script end
3. **Snapshot first** - Use `getAISnapshot()` to discover elements before interacting
4. **Plain JS in evaluate** - Use JavaScript, not TypeScript, inside `page.evaluate()`
5. **Single-purpose scripts** - Each script should accomplish one focused task

## Links

- [GitHub Repository](https://github.com/SawyerHood/dev-browser)
- [Playwright Documentation](https://playwright.dev/docs/api/class-page) (underlying browser API)
