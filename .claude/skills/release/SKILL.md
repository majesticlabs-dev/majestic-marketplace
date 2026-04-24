---
name: release
description: Release a marketplace plugin - bump version, verify checklist, commit, and push in one invocation. Use when shipping a new version of any plugin in plugins/.
disable-model-invocation: true
model: sonnet
argument-hint: "[plugin-name] [patch|minor|major]"
allowed-tools: Read Edit Glob Grep Bash(git status:*) Bash(git add:*) Bash(git commit:*) Bash(git push:*) Bash(git diff:*) Bash(git log:*) Bash(jq:*) Bash(ls:*)
---

# Plugin Release

Ship a single plugin version bump with enforced checklist and atomic commit.

## Input Schema

```yaml
plugin_name: string  # $0 - e.g., "majestic-engineer" (optional, auto-detect if omitted)
bump_type: string    # $1 - "patch" (default) | "minor" | "major"
```

## Workflow

### 1. Resolve Plugin

```
If $0 provided:
  PLUGIN = $0
  Validate: plugins/{PLUGIN}/.claude-plugin/plugin.json exists
  If not: ERROR "Unknown plugin: {PLUGIN}. Available: $(ls plugins/)"
Else:
  CHANGED = Bash: git diff --name-only HEAD
  TOUCHED = unique first-path-segment after "plugins/" in CHANGED
  If TOUCHED.length == 1: PLUGIN = TOUCHED[0]
  Else: AskUserQuestion "Which plugin to release?" options=ls plugins/
```

### 2. Resolve Bump Type

```
BUMP = $1 or "patch"
If BUMP not in [patch, minor, major]: ERROR "Invalid bump: {BUMP}"
```

### 3. Read Current Versions

```
PLUGIN_JSON = plugins/{PLUGIN}/.claude-plugin/plugin.json
MARKETPLACE_JSON = .claude-plugin/marketplace.json

CURRENT_PLUGIN_VER = jq -r '.version' PLUGIN_JSON
CURRENT_MARKET_VER = jq -r --arg n {PLUGIN} '.plugins[] | select(.name==$n) | .version' MARKETPLACE_JSON

If CURRENT_PLUGIN_VER != CURRENT_MARKET_VER:
  ERROR "Version mismatch before bump - plugin.json={CURRENT_PLUGIN_VER} vs marketplace.json={CURRENT_MARKET_VER}. Fix alignment first."
```

### 4. Compute New Version

```
PARSE CURRENT_PLUGIN_VER as MAJOR.MINOR.PATCH
If BUMP == "patch": NEW_VER = "{MAJOR}.{MINOR}.{PATCH+1}"
If BUMP == "minor": NEW_VER = "{MAJOR}.{MINOR+1}.0"
If BUMP == "major": NEW_VER = "{MAJOR+1}.0.0"
```

### 5. Checklist Enforcement

Before writing any version, verify all gates. Any FAIL blocks release.

```
GATES = []

# Gate A: staged+unstaged changes exist for this plugin
CHANGES = Bash: git status --short
If CHANGES is empty:
  GATES.append(FAIL: "No changes to release")

# Gate B: no stale /majestic:* refs if commands were migrated to skills
LEGACY_REFS = Bash: grep -rn "/majestic:{PLUGIN-suffix}" plugins/{PLUGIN}/ --include="*.md" | grep -v CHANGELOG || true
If LEGACY_REFS non-empty AND files named commands/ no longer contain those targets:
  GATES.append(WARN: "Legacy /majestic: refs remain - may be broken: {LEGACY_REFS}")

# Gate C: skill-linter passes for any new/modified skill in this plugin
MODIFIED_SKILLS = Bash: git diff --name-only HEAD | grep "^plugins/{PLUGIN}/skills/.*/SKILL.md" | xargs -n1 dirname || true
For each S in MODIFIED_SKILLS:
  RESULT = Bash: bash .claude/skills/skill-linter/scripts/validate-skill.sh {S}
  If RESULT exit_code != 0: GATES.append(FAIL: "skill-linter failed: {S}")

# Gate D: new plugin needs "What Makes This Different" (only if plugin.json is untracked)
IS_NEW = Bash: git log --oneline -- plugins/{PLUGIN}/.claude-plugin/plugin.json | wc -l
If IS_NEW == 0:
  HAS_SECTION = Bash: grep -l "What Makes This Different" plugins/{PLUGIN}/README.md || true
  If HAS_SECTION empty: GATES.append(FAIL: "New plugin README missing 'What Makes This Different' section")

# Gate E: plugin.json name field matches directory name
JSON_NAME = jq -r '.name' PLUGIN_JSON
If JSON_NAME != PLUGIN: GATES.append(FAIL: "plugin.json name={JSON_NAME} != directory {PLUGIN}")

Report GATES to user.
If any GATE status == FAIL: ABORT with summary.
```

### 6. Apply Version Bump

```
Edit(PLUGIN_JSON):
  old: "\"version\": \"{CURRENT_PLUGIN_VER}\""
  new: "\"version\": \"{NEW_VER}\""

Edit(MARKETPLACE_JSON):
  old: "\"name\": \"{PLUGIN}\",\n      \"description\": \"...\",\n      \"version\": \"{CURRENT_PLUGIN_VER}\""
  new: "\"name\": \"{PLUGIN}\",\n      \"description\": \"...\",\n      \"version\": \"{NEW_VER}\""
```

Verify both match:
```
POST_PLUGIN = jq -r '.version' PLUGIN_JSON
POST_MARKET = jq -r --arg n {PLUGIN} '.plugins[] | select(.name==$n) | .version' MARKETPLACE_JSON
If POST_PLUGIN != NEW_VER OR POST_MARKET != NEW_VER:
  ERROR "Bump failed - aborting before commit"
```

### 7. Confirm With User

```
DIFF = Bash: git diff --stat HEAD
AskUserQuestion:
  question: "Release {PLUGIN} {CURRENT_PLUGIN_VER} → {NEW_VER}?\n\nChanges:\n{DIFF}"
  options:
    - "Ship it" → Continue to step 8
    - "Cancel" → Bash: git checkout PLUGIN_JSON MARKETPLACE_JSON; END
```

### 8. Stage, Commit, Push

```
# Stage only files related to this release (never git add -A)
CHANGED_FILES = Bash: git status --short | awk '{print $2}' | grep -E "^(plugins/{PLUGIN}/|\.claude-plugin/marketplace\.json$|docs/)"

Bash: git add {CHANGED_FILES}

# Generate subject from most recent refactor/feat in diff context
SCOPE = detect from touched paths ("engineer" from "plugins/majestic-engineer/...")
TYPE = "chore" if only version bumps, else detect from diff (refactor/feat/fix)

COMMIT_MSG = "{TYPE}({SCOPE}): bump {PLUGIN} v{NEW_VER}"
# If release bundles substantive changes, ask user for commit body

Bash: git commit -m "{COMMIT_MSG}"

# Confirm before push
AskUserQuestion:
  question: "Push to origin master?"
  options:
    - "Push" → Bash: git push origin master
    - "Stay local" → END
```

### 9. Post-Release Report

```
Report:
  - Plugin: {PLUGIN}
  - Version: {CURRENT_PLUGIN_VER} → {NEW_VER}
  - Commit: {commit_sha}
  - Pushed: yes/no
  - Gate warnings: {GATES filtered to WARN}
```

## Output Schema

```yaml
plugin: string
old_version: string
new_version: string
commit_sha: string | null
pushed: boolean
gate_warnings: array
```

## Error Handling

| Scenario | Action |
|----------|--------|
| Plugin directory missing | Abort, list available plugins |
| Version mismatch pre-bump | Abort, ask user to align versions first |
| skill-linter FAIL | Abort, surface lint errors |
| Gate FAIL (any) | Abort with all failures listed |
| Edit produces no change | Abort - unexpected JSON shape |
| git commit fails (hook) | Do NOT amend - fix, re-stage, new commit |
| git push rejected | Abort, show rejection reason |
| User cancels at step 7 or 8 | Revert edits, exit cleanly |
