---
description: Auto-detect changed plugins since last version bump, bump versions, update marketplace.json, and commit. Eliminates manual version matching across 3 files.
argument-hint: "[--bump patch|minor|major] [--plugin PLUGIN] [--dry-run]"
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
---

# Plugin Release

Detect changed plugins, bump versions, update registry, commit.

## Arguments

- `--bump TYPE` — Version bump type: `patch` (default), `minor`, `major`
- `--plugin PLUGIN` — Only release a specific plugin (e.g., `majestic-rails`)
- `--dry-run` — Show what would change without modifying files

## Process

### Step 1: Find Changed Plugins

```bash
# Get the last version-bump commit (chore(*) or chore(plugin) with "bump" in message)
LAST_RELEASE=$(git log --oneline --all --grep="bump" --grep="chore" --all-match -1 --format="%H")

# If no release commit found, use the previous commit
if [ -z "$LAST_RELEASE" ]; then
  LAST_RELEASE="HEAD~5"
fi
```

Find changed plugins by checking which `plugins/*/` directories have modifications since LAST_RELEASE:

```bash
git diff --name-only $LAST_RELEASE HEAD -- 'plugins/*/' | sed 's|plugins/\([^/]*\)/.*|\1|' | sort -u
```

If `--plugin PLUGIN` is specified, filter to only that plugin.

Skip plugins where ONLY `.claude-plugin/plugin.json` or marketplace.json changed (version-only commits).

### Step 2: Validate Changes Exist

For each changed plugin:
1. Read `plugins/PLUGIN/.claude-plugin/plugin.json` to get current version
2. Confirm the plugin has substantive changes (not just version bumps)
3. If `--dry-run`, show: `PLUGIN: current_version → new_version` and stop

If no changed plugins found, print "No plugins changed since last release" and exit.

### Step 3: Bump Versions

For each changed plugin, compute new version:

| Bump Type | Example |
|-----------|---------|
| patch | 4.0.2 → 4.0.3 |
| minor | 4.0.2 → 4.1.0 |
| major | 4.0.2 → 5.0.0 |

Update **both** files (versions MUST match):
1. `plugins/PLUGIN/.claude-plugin/plugin.json` — `"version"` field
2. `.claude-plugin/marketplace.json` — matching plugin entry's `"version"` field

### Step 4: Detect Stale Keywords

Compare plugin content against keywords in plugin.json:
- If a keyword references removed technology (e.g., "traefik" when kamal-proxy replaced it), flag it
- If new technology was added but no keyword exists, suggest adding it
- Present findings to user, ask before modifying keywords

### Step 5: Commit

Stage all changed files and commit:

```
chore(SCOPE): bump PLUGIN1 vX.Y.Z and PLUGIN2 vA.B.C

- PLUGIN1 X.Y.Z-1 → X.Y.Z: brief summary of changes
- PLUGIN2 A.B.C-1 → A.B.C: brief summary of changes
```

Where SCOPE is comma-separated short plugin names (e.g., `rails,devops`).

### Step 6: Summary

Print a table:

```
| Plugin | Version | Changes |
|--------|---------|---------|
| majestic-rails | 4.0.2 → 4.0.3 | Kamal 2 rewrite, SQLite VACUUM |
```

Do NOT push — let the user decide when to push.

### Step 7: Re-index Search (if qmd available)

```bash
if command -v qmd &>/dev/null; then
  qmd collection remove majestic-marketplace 2>/dev/null
  qmd collection add . --name majestic-marketplace
  qmd embed
fi
```

Skip silently if `qmd` is not installed.

## Edge Cases

| Situation | Action |
|-----------|--------|
| Plugin has no plugin.json | Skip with warning |
| Plugin not in marketplace.json | Skip with warning |
| Version mismatch between files | Fix to match higher version, then bump |
| No changes detected | Print message and exit |
| `--dry-run` | Show plan, modify nothing |
