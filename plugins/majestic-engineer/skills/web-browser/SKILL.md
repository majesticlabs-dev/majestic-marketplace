---
name: web-browser
description: "Browser automation using browser-cdp CLI. Control Chrome, Brave, or Edge browsers for testing, scraping, and web interaction. Uses your real browser (not test mode) for authentic sessions."
---

# Web Browser Skill

Control real browsers via CDP (Chrome DevTools Protocol) using [browser-cdp](https://github.com/dpaluy/browser-cdp). Unlike test-mode automation, this connects to your actual browser installation - same fingerprint, real cookies, no automation detection.

## Install

```bash
npm install -g browser-cdp
```

Or run directly with `bunx browser-cdp`.

## Commands

### Start Browser

```bash
# Chrome (default) with real profile
bunx browser-cdp start

# Brave with specific profile
bunx browser-cdp start brave --profile=Work

# Chrome with isolated profile (no cookies/logins)
bunx browser-cdp start chrome --isolated

# Custom port
DEBUG_PORT=9333 bunx browser-cdp start
```

### Navigate

```bash
bunx browser-cdp nav https://example.com        # Current tab
bunx browser-cdp nav https://example.com --new  # New tab
```

### Evaluate JavaScript

```bash
bunx browser-cdp eval 'document.title'
bunx browser-cdp eval 'document.querySelectorAll("a").length'
bunx browser-cdp eval '(() => { document.querySelector("input").value = "hello"; return "done"; })()'
```

### Capture DOM

```bash
bunx browser-cdp dom > page.html
```

### Screenshot

```bash
bunx browser-cdp screenshot
# Returns: /tmp/screenshot-2024-01-01T12-00-00.png
```

### Pick Elements

```bash
bunx browser-cdp pick "Select the login button"
```

Interactive element picker:
- Click to select single element
- Cmd/Ctrl+Click to multi-select
- Enter to confirm, ESC to cancel

### Console Output

```bash
bunx browser-cdp console                # Stream until Ctrl+C
bunx browser-cdp console --duration=10  # Stream for 10 seconds
```

Captures network errors, exceptions, and console.log output.

### Performance Insights

```bash
bunx browser-cdp insights        # Human readable
bunx browser-cdp insights --json # JSON output
```

Returns: TTFB, First Paint, FCP, DOM loaded, resources, memory.

### Lighthouse Audit

```bash
bunx browser-cdp start chrome --isolated
bunx browser-cdp nav https://example.com
bunx browser-cdp lighthouse
```

Returns: Performance, Accessibility, Best Practices, SEO scores.

### Close Browser

```bash
bunx browser-cdp close
```

## Configuration

Set in `.agents.local.yml`:

```yaml
browser: brave
debug_port: 9222
```

Before running commands, use `config-reader` agent to get settings and pass as env vars:

```bash
BROWSER=brave DEBUG_PORT=9222 bunx browser-cdp start
```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `BROWSER` | Browser (chrome, brave, edge) | `chrome` |
| `BROWSER_PATH` | Custom browser executable | (auto-detect) |
| `DEBUG_PORT` | CDP debugging port | `9222` |

## Supported Browsers

| Browser | Command |
|---------|---------|
| Chrome | `chrome` (default) |
| Brave | `brave` |
| Edge | `edge` |

## Smart Start

`start` checks if a browser is already running on the configured port:

- **Already running with CDP** → Exits successfully (no restart)
- **Running without CDP** → Error with instructions
- **Not running** → Starts browser with CDP enabled

Pre-start your browser with debugging:

```bash
# Add to ~/.zshrc
alias brave-debug='/Applications/Brave\ Browser.app/Contents/MacOS/Brave\ Browser --remote-debugging-port=9222'
```

## Why Real Browser?

| Aspect | browser-cdp | Playwright Test Mode |
|--------|-------------|---------------------|
| Browser | Your installed Chrome/Brave/etc | Bundled Chromium |
| Profile | Real cookies/logins by default | Fresh test profile |
| Detection | Not detectable as automation | Automation flags present |
| Use case | Real-world testing, scraping | Isolated E2E tests |
