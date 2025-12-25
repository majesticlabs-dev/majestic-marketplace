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
- `docs/plans/*.md` → Plan file from `/majestic:plan`
- `#123`, `PROJ-123`, URL → Task reference (GitHub, Beads, Linear)

## Step 0: Detect Input Type

```bash
# If empty, find most recent plan
ls -t docs/plans/*.md 2>/dev/null | head -1
```

| Input | Source | Skip Steps |
|-------|--------|------------|
| Empty + plan found | `plan` | 1, 2, 7, 15 |
| `*.md` file path | `plan` | 1, 2, 7, 15 |
| Task reference | `task` | (none) |
| Empty + no plan | Ask user | — |

**For plans:** Extract `TASK_ID` from filename slug, `TITLE` from first `# ` heading.

---

## Workflow

| Step | Agent | Condition |
|------|-------|-----------|
| 1. Fetch | `task-fetcher` | Skip if `plan` |
| 2. Claim | `task-status-updater` (claim) | Skip if `plan` |
| 3. Terminal | `printf` (ANSI escape) | — |
| 4. Workspace | `workspace-setup` | — |
| 5. Toolbox | `toolbox-resolver` | — |
| 6. Research | Auto hooks from toolbox | If triggers match |
| 7. Plan | `architect` | Skip if `plan` (use file content) |
| 8. Build | Toolbox executor + coding_styles | — |
| 9. Slop | `slop-remover` | — |
| 10. Verify | `always-works-verifier` | — |
| 11. Quality | `quality-gate` | — |
| 12. Fix | Toolbox executor (max 3×) | If verify/quality fails |
| 13. Pre-ship | Hooks from toolbox | — |
| 14. Ship | `/majestic-engineer:workflows:ship-it` | — |
| 15. Complete | `task-status-updater` (ship) | Skip if `plan` |

---

## Agent Invocations

### Step 1: Fetch Task
```
agent task-fetcher "Task: <reference>"
```

### Step 2: Claim Task
```
agent task-status-updater "Action: claim | Task: <ID>"
```

### Step 3: Set Terminal Title
```bash
printf '\033]0;🔨 <ID>: <title>\007'
```

### Step 4: Setup Workspace

**First, read config** (required - haiku agents can't reliably invoke config-reader):
```
agent config-reader "field: workflow, default: branches"
agent config-reader "field: branch_naming, default: issue-desc"
agent config-reader "field: default_branch, default: main"
```

**Then pass values to workspace-setup:**
```
agent workspace-setup "Task ID: <ID> | Title: <title> | Type: <type> | Workflow: <workflow> | Branch Naming: <branch_naming> | Default Branch: <default_branch>"
```

### Step 5: Resolve Toolbox
```
agent toolbox-resolver "Stage: build-task | Task: <title> <description>"
```
Stores: `build_agent`, `fix_agent`, `coding_styles`, `design_system_path`, `research_hooks`, `pre_ship_hooks`, `quality_gate.reviewers`

### Step 6: Auto Research
For each `mode: auto` hook where triggers match task text:
```
agent <hook.agent> "Research for: <title> | Context: <description>"
```

### Step 7: Plan (task source only)
```
agent architect "Task: <title> | Description: <description> | Research: <findings>"
```

### Step 8: Build

**Before invoking build agent, set up context:**

1. **Load design system** (if configured):
   - Check toolbox output for `design_system_path`
   - If path exists, read the file using Read tool
   - Store content for inclusion in build prompt

   ```bash
   # Check for design_system_path in toolbox output
   # If set and file exists, read it
   ```

2. **Activate coding_styles skills** (if non-empty):
   ```
   Skill(skill: "majestic-rails:dhh-coder")
   Skill(skill: "majestic-engineer:tdd-workflow")
   ```

**Note:** `coding_styles` contains **skill names** (not agents). Skills provide knowledge/context that influences how the build agent writes code. They are invoked via the `Skill` tool, not the `Task` tool.

**Then invoke build agent with design context:**

If design system was loaded:
```
agent <build_agent or general-purpose> "Implement: <title> | Plan: <plan content> | Design System: Follow these specifications for all UI work: <design_system_content>"
```

If no design system:
```
agent <build_agent or general-purpose> "Implement: <title> | Plan: <plan content>"
```

**UI Detection Heuristic:** Load design system if ANY of:
- Plan file contains UI keywords (form, button, page, component, modal, card, input)
- Task description contains UI keywords
- `design_system_path` is explicitly configured and file exists

The activated skills and design system context guide the build agent's implementation approach.

### Step 9-11: Verify & Review
```
agent slop-remover "Clean branch changes"
agent always-works-verifier "Verify branch: <branch>"
agent quality-gate "Context: <title> | Branch: <branch>"
```

### Step 12: Fix Loop
If verify or quality fails (max 3 attempts):
```
agent <fix_agent or general-purpose> "Fix: <findings>"
```
Then re-run verify → quality.

### Step 13: Pre-ship Hooks
For each hook in `pre_ship_hooks`:
```
agent <hook.agent> "Pre-ship check on branch: <branch>"
```
Required hooks block on failure. Optional hooks log warnings.

### Step 14: Ship
For task source (with task ID):
```
/majestic-engineer:workflows:ship-it closes #<ID>
```

For plan source (no task):
```
/majestic-engineer:workflows:ship-it
```

### Step 15: Complete (task source only)
```
agent task-status-updater "Action: ship | Task: <ID> | PR: <number>"
```

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
