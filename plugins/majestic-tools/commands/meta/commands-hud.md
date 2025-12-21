---
name: majestic:commands-hud
description: Display all available commands in a formatted HUD grouped by plugin or category
argument-hint: "[--plugin PLUGIN] [--group plugin|category|flat]"
model: haiku
allowed-tools: Bash
---

# Commands HUD

Display all majestic-marketplace commands in a beautiful formatted HUD.

## Arguments

- `--plugin PLUGIN` - Filter to a specific plugin (e.g., `majestic-engineer`)
- `--group STYLE` - Grouping style:
  - `plugin` (default) - Group by plugin (Engineering, Rails, Tools, etc.)
  - `category` - Group by command category (Workflows, Git, Session, etc.)
  - `flat` - Single alphabetical list

## Examples

```bash
# Show all commands grouped by plugin
/majestic-tools:meta:commands-hud

# Show only engineering commands
/majestic-tools:meta:commands-hud --plugin majestic-engineer

# Show commands grouped by category
/majestic-tools:meta:commands-hud --group category
```

## Task

Run the HUD script with the provided arguments:

```bash
bash "$(dirname "$(dirname "$(dirname "$0")")")/helpers/hud-commands.sh" $ARGUMENTS
```

Parse `$ARGUMENTS` and run:

```bash
# Get the script location (relative to marketplace root)
MARKETPLACE_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
bash "$MARKETPLACE_ROOT/plugins/majestic-tools/helpers/hud-commands.sh" $ARGUMENTS
```

If `$ARGUMENTS` is empty, run without arguments (uses default plugin grouping).

Present the output to the user. The script outputs a formatted table showing all available commands grouped appropriately.
