---
name: session:ledger-clear
description: Clear the session ledger file to start fresh
model: haiku
allowed-tools: Bash, Task
disable-model-invocation: true
---

# Clear Session Ledger

Removes the session ledger file to start fresh.

## Process

### Step 1: Get Ledger Path

Read session config:
- Session config: !`claude -p "/majestic:config session {}"`

Use `session.ledger_path` if set, otherwise default to `.agents/session_ledger.md`.

### Step 2: Check if File Exists

```bash
[ -f "<ledger_path>" ] && echo "exists" || echo "not found"
```

### Step 3: Delete if Exists

If file exists:

```bash
rm "<ledger_path>"
```

### Step 4: Confirm

Report result:

- **File deleted**: `Session ledger cleared: <path>`
- **No file found**: `No session ledger found at <path> - nothing to clear`
