# Majestic Browser

Real browser automation via Chrome DevTools Protocol (CDP). Control Chrome, Brave, or Edge using your actual browser profile - undetectable by bot detection.

## Why This Plugin?

| Feature | majestic-browser | Playwright/Puppeteer |
|---------|------------------|---------------------|
| Browser | Your installed browser | Bundled Chromium |
| Profile | Real cookies & logins | Fresh test profile |
| Fingerprint | Identical to you | Automation flags |
| Bot detection | Bypasses | Easily detected |

## Installation

```bash
claude plugin add majestic-browser@majestic-marketplace
```

## Skills

| Skill | Description |
|-------|-------------|
| `web-browser` | Control real browsers via CDP using browser-cdp CLI |

## Quick Start

```bash
# Start browser with CDP enabled
bunx browser-cdp start

# Navigate
bunx browser-cdp nav https://example.com

# Take screenshot
bunx browser-cdp screenshot

# Run JavaScript
bunx browser-cdp eval 'document.title'
```

## Use Cases

- **Scraping** sites with Cloudflare or bot detection
- **Automating** tasks on sites you're already logged into
- **Testing** with real browser extensions
- **Debugging** with familiar DevTools

## Requirements

- Chrome, Brave, or Edge installed
- Node.js / Bun for `bunx` command
