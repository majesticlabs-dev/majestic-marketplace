---
name: majestic:build-task
description: Autonomous task implementation - research, plan, build, review, fix, ship
argument-hint: "<task-reference or plan-file>"
allowed-tools: Bash, Read, Grep, Glob, WebFetch, TodoWrite, Task, Skill
---

# Build Task

Implement a task autonomously through the full development lifecycle.

## Input

<task_reference> $ARGUMENTS </task_reference>

**Formats:**
- *(empty)* → Auto-detect most recent `docs/plans/*.md`
- `docs/plans/*.md` → Blueprint file from `/majestic:blueprint`
- `#123`, `PROJ-123`, URL → Task reference (GitHub, Beads, Linear)
- `--no-ship` → Flag to skip shipping (used by run-blueprint for batch shipping)

## Step 0: Detect Input Type

```bash
# If empty, find most recent plan
ls -t docs/plans/*.md 2>/dev/null | head -1
```

**Parse flags:**
- `--no-ship`: Set `skip_ship=true`, remove flag
- `--ac "<criteria>"`: Set `ac_items` to provided criteria, remove flag

| Input | Source | Skip Steps |
|-------|--------|------------|
| Empty + plan found | `plan` | 1, 2, 5 |
| `*.md` file path | `plan` | 1, 2, 5 |
| Task reference | `task` | (none) |
| Empty + no plan | Ask user | — |

**For plans:** Extract `TASK_ID` from filename slug, `TITLE` from first `# ` heading.

---

## Workflow (Context Gathering)

### 1. Fetch Task (task source only)

```
Task (majestic-engineer:workflow:task-fetcher):
  prompt: Task: <reference>
```

### 2. Claim Task (task source only)

```
Task (majestic-engineer:workflow:task-status-updater):
  prompt: Action: claim | Task: <ID>
```

### 3. Set Terminal Title

Run `/rename <task-title>` to set the terminal title for visibility.

### 4. Setup Workspace

**Read config values (run these 4 bash commands in parallel):**
- Workflow: !`claude -p "/majestic:config workflow branches"`
- Branch naming: !`claude -p "/majestic:config branch_naming issue-desc"`
- Default branch: !`claude -p "/majestic:config default_branch main"`
- Post-create hook: !`claude -p "/majestic:config workspace_setup.post_create ''"`

**Then setup workspace:**
```
Task (majestic-engineer:workflow:workspace-setup):
  prompt: |
    Task ID: <ID>
    Title: <title>
    Type: <type>
    Workflow: <workflow>
    Branch Naming: <branch_naming>
    Default Branch: <default_branch>
    Post-Create Hook: <post_create>
```

### 5. Verify Branch (MANDATORY)

**After workspace setup, verify we are NOT on a protected branch:**

```bash
CURRENT_BRANCH=$(git branch --show-current)
```

| Current Branch | Action |
|----------------|--------|
| `main` | STOP - workspace setup failed |
| `master` | STOP - workspace setup failed |
| `<default_branch>` | STOP - workspace setup failed |
| Feature branch | Continue |

**If on protected branch:** STOP and report error. Do not proceed.

### 6. Resolve Toolbox

```
Task (majestic-engineer:workflow:toolbox-resolver):
  prompt: |
    Stage: build-task
    Task Title: <title>
    Task Description: <description>
```

**Stores:** `methodology`, `build_agent`, `fix_agent`, `coding_styles`, `design_system_path`, `research_hooks`, `pre_ship_hooks`, `quality_gate.reviewers`

### 7. Auto Research (if triggers match)

For each `mode: auto` hook where triggers match task text:
```
Task (majestic-engineer:workflow:context-proxy):
  prompt: agent: <hook.agent> | budget: 2000 | prompt: Research for: <title> | Context: <description>
```

### 8. Context Check (Post-Research)

If research agents returned outputs and combined output > 4000 chars:
- Run `/smart-compact` before planning
- Focus on SUMMARIZE for research findings
- Preserve task title, description, and key patterns

### 9. Plan (task source only)

```
Task (majestic-engineer:workflow:context-proxy):
  prompt: agent: architect | budget: 3000 | prompt: Task: <title> | Description: <description> | Research: <findings>
```

**Note:** Skip if source is `plan` - use plan file content instead.

---

## Delegate to Build Workflow Manager

Pass all gathered context to the build-task-workflow-manager agent:

```
agent build-task-workflow-manager "
Task ID: <ID or 'plan'>
Title: <title>
Branch: <branch>
Plan: <plan content>
Acceptance Criteria:
  <ac_items>
Methodology: <methodology>
Build Agent: <build_agent>
Fix Agent: <fix_agent>
Coding Styles: <styles>
Design System Path: <path>
Pre-Ship Hooks: <hooks>
Quality Gate Reviewers: <reviewers>
Source: <task or plan>
Skip Ship: <skip_ship>
"
```

**AC source:**
| Input | AC Source |
|-------|-----------|
| `--ac` flag provided | Use provided AC directly |
| Plan file | Extract from `**Acceptance Criteria:**` section |
| GitHub Issue | Extract from issue body (look for AC section) |
| Linear/Beads | Extract from task description |

The agent handles:
1. Loading design system (if configured)
2. Activating coding style skills
3. Building the implementation
4. Slop removal (MANDATORY)
5. AC Verification (MANDATORY)
6. Quality gate (MANDATORY)
7. Fix loop (if needed, max 3 attempts)
8. Capture learnings
9. Pre-ship hooks
10. Shipping (PR creation)
11. Task completion (if task source)

**Agent returns:**
- AC verification results (which criteria passed/failed)
- Learnings discovered
- Status (PASS or FAIL)

**Caller responsibility:** If caller needs to persist results (e.g., update blueprint checkboxes), it handles that based on the returned results.

---

## Output

**Task source:**
```
## Build Complete: #<ID> - <title>
- Backend: <github|beads|linear>
- Branch: <branch>
- PR: #<number>
- Quality: Passed (attempt <n>)
- Next: PR awaits review, task closes on merge
```

**Plan source:**
```
## Build Complete: <title>
- Plan: <file-path>
- Branch: <branch>
- PR: #<number>
- Quality: Passed (attempt <n>)
- Next: PR awaits review
```

---

## Examples

```bash
/majestic:build-task                           # Auto-detect recent plan
/majestic:build-task docs/plans/add-auth.md    # Explicit plan
/majestic:build-task #42                       # GitHub issue
/majestic:build-task PROJ-123                  # Beads/Linear
```

---

## Notes

- This command gathers context (steps 1-9), then delegates execution
- The workflow manager ensures no build/verify/ship steps are skipped
- Branch safety check prevents accidental commits to main/master
- Research agents run conditionally based on toolbox triggers
