---
name: web-browser
description: "Browser automation using browser-cdp CLI. Control Chrome, Brave, or Edge browsers for testing, scraping, and web interaction. Uses your real browser (not test mode) for authentic sessions."
---

# Web Browser Skill

Control real browsers via CDP (Chrome DevTools Protocol) using [browser-cdp](https://github.com/dpaluy/browser-cdp). Connects to your actual browser - same fingerprint, real cookies, no automation detection.

## Commands

| Command | Description |
|---------|-------------|
| `!bunx browser-cdp start` | Start browser with CDP enabled |
| `!bunx browser-cdp start brave` | Start Brave (also: `chrome`, `edge`) |
| `!bunx browser-cdp start chrome --isolated` | Fresh profile (no cookies/logins) |
| `!bunx browser-cdp start brave --profile=Work` | Use specific profile |
| `!bunx browser-cdp nav URL` | Navigate current tab |
| `!bunx browser-cdp nav URL --new` | Navigate in new tab |
| `!bunx browser-cdp nav URL --console` | Navigate and capture console (5s default) |
| `!bunx browser-cdp nav URL --console --duration=10` | Navigate and capture for N seconds |
| `!bunx browser-cdp eval 'JS'` | Run JavaScript, return result |
| `!bunx browser-cdp eval 'JS' --console` | Eval and capture console (3s default) |
| `!bunx browser-cdp eval 'JS' --console --duration=5` | Eval and capture for N seconds |
| `!bunx browser-cdp dom` | Capture full DOM HTML |
| `!bunx browser-cdp screenshot` | Save screenshot, return path |
| `!bunx browser-cdp pick "prompt"` | Interactive element picker |
| `!bunx browser-cdp console --reload` | Reload page and capture console output |
| `!bunx browser-cdp console --reload --duration=10` | Reload, capture for N seconds |
| `!bunx browser-cdp insights` | Performance metrics (TTFB, FCP, etc.) |
| `!bunx browser-cdp insights --json` | JSON format |
| `!bunx browser-cdp lighthouse` | Full Lighthouse audit |
| `!bunx browser-cdp close` | Close browser |

### Pick Elements

Interactive picker: click to select, Cmd/Ctrl+Click multi-select, Enter confirm, ESC cancel.

## Configuration

Optional settings in `.agents.yml` or `.agents.local.yml`:

```yaml
browser:
  type: brave       # chrome, brave, or edge (default: chrome)
  debug_port: 9222  # CDP port (default: 9222)
```

Use `config-reader` agent to check for `browser.type` and `browser.debug_port`. Pass as `BROWSER` and `DEBUG_PORT` env vars if configured.

## Smart Start

`start` checks if browser is already running on configured port:
- **Already running with CDP** → Exits successfully (no restart)
- **Running without CDP** → Error with instructions
- **Not running** → Starts browser with CDP enabled

## Why Real Browser?

| Aspect | browser-cdp | Playwright Test Mode |
|--------|-------------|---------------------|
| Browser | Your installed Chrome/Brave | Bundled Chromium |
| Profile | Real cookies/logins | Fresh test profile |
| Detection | Not detectable | Automation flags present |
| Use case | Real-world testing, scraping | Isolated E2E tests |
