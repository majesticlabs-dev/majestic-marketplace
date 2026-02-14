---
name: majestic:commands-hud
description: Display all available commands in a formatted HUD grouped by plugin or category
argument-hint: "[--plugin PLUGIN] [--group plugin|category|flat]"
model: haiku
allowed-tools: Glob, Read, Bash
disable-model-invocation: true
---

# Commands HUD

Display all majestic-marketplace commands in a beautiful formatted HUD.

## Arguments

- `--plugin PLUGIN` - Filter to a specific plugin (e.g., `majestic-engineer`)
- `--group STYLE` - Grouping style:
  - `plugin` (default) - Group by plugin (Engineering, Rails, Tools, etc.)
  - `category` - Group by command category (Workflows, Git, Session, etc.)
  - `flat` - Single alphabetical list

## Task

1. **Find marketplace root** - Check these locations in order:
   - `~/.claude/managed-plugins/majestic-marketplace/` (installed plugin)
   - Git root via `git rev-parse --show-toplevel` if in majestic-marketplace repo
   - Skip with message if neither found
2. Use Glob to find command files: `{marketplace_root}/plugins/*/commands/**/*.md`
3. Read each command file to extract frontmatter (`name:` and `description:`)
4. Group commands based on `$ARGUMENTS`:
   - Parse `--plugin PLUGIN` to filter by plugin name
   - Parse `--group STYLE` to determine grouping (default: `plugin`)
5. Render as a formatted table

## Plugin Name Mapping

| Plugin | Display Name |
|--------|-------------|
| majestic-engineer | Engineering Workflows |
| majestic-rails | Rails Development |
| majestic-python | Python Development |
| majestic-tools | Claude Code Tools |
| majestic-marketing | Marketing & SEO |
| majestic-sales | Sales Acceleration |
| majestic-company | Business Operations |
| majestic-experts | Expert Panels |

## Output Format

```
╔═══════════════════════════════════════════════════════════════╗
║          Majestic Marketplace - Available Commands            ║
╚═══════════════════════════════════════════════════════════════╝

┌─────────────────── Engineering Workflows ────────────────────┐
│ /command-name          │ Description of the command          │
│ /another-command       │ Another description                 │
└──────────────────────────────────────────────────────────────┘
```

Render the HUD with all discovered commands, properly grouped and sorted alphabetically within each group.
