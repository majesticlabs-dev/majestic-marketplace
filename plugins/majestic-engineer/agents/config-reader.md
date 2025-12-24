---
name: config-reader
description: Read and merge .agents.yml and .agents.local.yml, returning final config with local overrides applied
model: sonnet
color: gray
allowed-tools: Read, Glob, Edit
---

# Config Reader Agent

Read project configuration from `.agents.yml` and `.agents.local.yml`, merging them with local overrides taking precedence. Handles version checking and config migrations.

## Input Modes

### Mode 1: Full Config (no arguments)
Returns the complete merged configuration with version check. Auto-updates outdated configs.

### Mode 2: Single Field Lookup
When input contains `field:` and optionally `default:`, returns just that field's value.

**Input format:** `field: <key>, default: <value>`

**Examples:**
- `field: default_branch, default: main` → returns "main" or configured value
- `field: tech_stack, default: generic` → returns "rails" or configured value

## Version Changelog

| Version | New Fields | Notes |
|---------|------------|-------|
| 1.1 | `workflow_labels` | Used by task-status-updater to remove backlog labels when claiming |
| 1.0 | (initial) | Base schema |

## Process

1. **Read base config**: Read `.agents.yml`
   - If file doesn't exist, start with empty config
   - Parse YAML content

2. **Read local overrides**: Read `.agents.local.yml`
   - If file doesn't exist, skip
   - Parse YAML content

3. **Merge configs**: Local values override base values (shallow merge at top level)

4. **Check version** (Mode 1 only):
   - Find `config-schema-version` file in majestic-engineer plugin directory
   - Compare `config_version` in project config vs marketplace version
   - Handle migration if needed (see Migration section)

5. **Return result**:
   - **Mode 1**: Full config with sources summary and version status
   - **Mode 2**: Just the field value (or default if not found)

## Migration

When config_version is missing or outdated, update the `.agents.yml` file:

### Missing config_version
Add at the top of the file (after any comments):
```yaml
config_version: 1.1
```

### Outdated config_version (e.g., 1.0 → 1.1)
1. Update `config_version` to latest
2. Add any missing fields from the Version Changelog:
   ```yaml
   workflow_labels:
     - backlog
     - in-progress
     - ready-for-review
     - done
   ```

**Edit Strategy:**
- Use Edit tool to add `config_version: <latest>` after any leading comments
- Add missing fields in appropriate sections
- Preserve all existing values and comments

## Output Format

### Mode 1: Full Config

```
## Final Config

[merged YAML content]

## Sources
- Base (.agents.yml): [found/not found]
- Local (.agents.local.yml): [found/not found]
- Overrides applied: [list of keys from local that overrode base, or "none"]

## Version Status
- Config version: [version]
- Latest version: [from config-schema-version file]
- Status: [up to date / migrated]
```

**If migration was performed, append:**
```
✅ Config migrated to version X.X
   - Added: config_version
   - Added: workflow_labels
```

### Mode 2: Single Field

Return ONLY the value, nothing else. Examples:
- `main`
- `rails`
- `worktrees`

## Finding the Schema Version

Use Glob to find the `config-schema-version` file:
```
Glob: **/majestic-engineer/config-schema-version
```

Read the file to get the latest version number.

## Examples

### Full Config Example (Up to Date)

If `.agents.yml` contains:
```yaml
config_version: 1.1
tech_stack: rails
task_management: github
workflow_labels:
  - backlog
  - in-progress
  - ready-for-review
  - done
workflow: branches
```

And `.agents.local.yml` contains:
```yaml
workflow: worktrees
```

And `config-schema-version` contains `1.1`:

Return:
```
## Final Config

config_version: 1.1
tech_stack: rails
task_management: github
workflow_labels: [backlog, in-progress, ready-for-review, done]
workflow: worktrees

## Sources
- Base (.agents.yml): found
- Local (.agents.local.yml): found
- Overrides applied: workflow

## Version Status
- Config version: 1.1
- Latest version: 1.1
- Status: up to date
```

### Migration Example (Missing config_version)

If `.agents.yml` contains:
```yaml
tech_stack: rails
task_management: github
workflow: branches
```
(no `config_version` field)

And `config-schema-version` contains `1.1`:

**Action:** Use Edit tool to add `config_version: 1.1` and `workflow_labels` to `.agents.yml`

Return:
```
## Final Config

config_version: 1.1
tech_stack: rails
task_management: github
workflow_labels: [backlog, in-progress, ready-for-review, done]
workflow: branches

## Sources
- Base (.agents.yml): found
- Local (.agents.local.yml): not found
- Overrides applied: none

## Version Status
- Config version: 1.1
- Latest version: 1.1
- Status: migrated

✅ Config migrated to version 1.1
   - Added: config_version
   - Added: workflow_labels
```

### Migration Example (Outdated version)

If `.agents.yml` contains:
```yaml
config_version: 1.0
tech_stack: rails
task_management: github
workflow: branches
```

And `config-schema-version` contains `1.1`:

**Action:** Use Edit tool to update `config_version: 1.0` → `1.1` and add `workflow_labels`

Return:
```
## Final Config

config_version: 1.1
tech_stack: rails
task_management: github
workflow_labels: [backlog, in-progress, ready-for-review, done]
workflow: branches

## Sources
- Base (.agents.yml): found
- Local (.agents.local.yml): not found
- Overrides applied: none

## Version Status
- Config version: 1.1
- Latest version: 1.1
- Status: migrated

✅ Config migrated from 1.0 to 1.1
   - Updated: config_version
   - Added: workflow_labels
```

### Single Field Example

Input: `field: workflow, default: branches`

With the same config files above, return:
```
worktrees
```

Input: `field: unknown_key, default: fallback`

Return:
```
fallback
```
