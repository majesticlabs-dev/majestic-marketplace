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
| Empty + plan found | `plan` | 1, 2, 6, 14 |
| `*.md` file path | `plan` | 1, 2, 6, 14 |
| Task reference | `task` | (none) |
| Empty + no plan | Ask user | — |

**For plans:** Extract `TASK_ID` from filename slug, `TITLE` from first `# ` heading.

---

## Workflow

| Step | Action | Condition | Enforce |
|------|--------|-----------|---------|
| 0. Config | `/majestic:config` command | As needed | — |
| 1. Fetch | `task-fetcher` agent | Skip if `plan` | — |
| 2. Claim | `task-status-updater` agent (claim) | Skip if `plan` | — |
| 3. Workspace | `workspace-setup` | — | — |
| 3.5. Branch Check | Verify not on main/master | — | MANDATORY |
| 4. Toolbox | `toolbox-resolver` | — | — |
| 5. Research | Auto hooks from toolbox | If triggers match | — |
| 6. Plan | `architect` | Skip if `plan` (use file content) | — |
| 7. Build | Toolbox executor + coding_styles | — | — |
| 8. Slop | `slop-remover` | — | ⛔ MANDATORY |
| 9. Verify | `always-works-verifier` | — | ⛔ MANDATORY |
| 10. Quality | `quality-gate` | — | ⛔ MANDATORY |
| 11. Fix | Toolbox executor (max 3×) | If verify/quality fails | — |
| 12. Pre-ship | Hooks from toolbox | — | — |
| 13. Ship | `/majestic-engineer:workflows:ship-it` | — | — |
| 14. Complete | `task-status-updater` (ship) | Skip if `plan` | — |

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

### Step 2.5: Rename Task

Run `/rename <task-title>` to set the task name.

### Step 3: Setup Workspace

**Read config values:**
- Workflow: !`claude -p "/majestic:config workflow branches"`
- Branch naming: !`claude -p "/majestic:config branch_naming issue-desc"`
- Default branch: !`claude -p "/majestic:config default_branch main"`
- Post-create hook: !`claude -p "/majestic:config workspace_setup.post_create ''"`

**Then pass values to workspace-setup:**
```
agent workspace-setup "Task ID: <ID> | Title: <title> | Type: <type> | Workflow: <workflow> | Branch Naming: <branch_naming> | Default Branch: <default_branch> | Post-Create Hook: <post_create>"
```

### Step 3.5: Verify Branch (MANDATORY)

**After workspace setup, verify we are NOT on a protected branch:**

```bash
CURRENT_BRANCH=$(git branch --show-current)
```

| Current Branch | Action |
|----------------|--------|
| `main` | STOP - workspace setup failed |
| `master` | STOP - workspace setup failed |
| `<default_branch>` | STOP - workspace setup failed |
| Feature branch | Continue to Step 4 |

**If on protected branch:**
1. **STOP** - Do not proceed to build
2. Report error:
   ```
   ERROR: Branch Safety Check Failed

   Current branch: <branch>
   Expected: Feature branch (not main/master)

   Workspace setup did not create/switch to a feature branch.
   This prevents accidental commits to the default branch.

   To fix:
   - Check workspace-setup output for errors
   - Manually create branch: git checkout -b <branch-name>
   - Re-run /majestic:build-task
   ```
3. **Do not continue** - this is a hard gate

### Step 4: Resolve Toolbox
```
agent toolbox-resolver "Stage: build-task
Task Title: <title>
Task Description: <description>"
```
Stores: `build_agent`, `fix_agent`, `coding_styles`, `design_system_path`, `research_hooks`, `pre_ship_hooks`, `quality_gate.reviewers`

### Step 5: Auto Research
For each `mode: auto` hook where triggers match task text:
```
agent context-proxy "agent: <hook.agent> | budget: 2000 | prompt: Research for: <title> | Context: <description>"
```

### Step 5.5: Context Check (Post-Research)

If research agents returned outputs, check context budget:
- If combined research output > 4000 chars: Run `/smart-compact` before planning
- Focus compaction on SUMMARIZE for research findings
- Preserve task title, description, and key patterns found

### Step 6: Plan (task source only)
```
agent context-proxy "agent: architect | budget: 3000 | prompt: Task: <title> | Description: <description> | Research: <findings>"
```

**Note:** Architect has larger budget (3000) as it produces the implementation plan.

### Step 7: Build

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

### Step 8-10: Verify & Review

```
agent slop-remover "Clean branch changes"
agent always-works-verifier "Verify branch: <branch>"
agent quality-gate "Context: <title> | Branch: <branch>"
```

### Step 11: Fix Loop
If verify or quality fails (max 3 attempts):
```
agent <fix_agent or general-purpose> "Fix: <findings>"
```
Then re-run verify → quality.

---

## ⛔ QUALITY GATE CHECKPOINT (HARD GATE)

**Before ANY shipping actions, confirm all mandatory checks passed:**

| Check | Requirement |
|-------|-------------|
| slop-remover | Ran and cleaned code |
| always-works-verifier | Returned PASS |
| quality-gate | All reviewers approved |

**If ANY step was skipped or failed:**
1. **STOP** - do not proceed to Ship
2. Return to the skipped/failed step
3. Complete it before continuing

This gate is **NOT optional**. Even "simple" or "obvious" fixes must pass quality checks.

### Recovery: If You Got Sidetracked

If you already committed but skipped quality steps:

1. **STOP** before creating PR
2. Run `slop-remover` on committed code
3. Run `always-works-verifier`
4. Run `quality-gate`
5. Amend commit if fixes are needed
6. Then proceed with PR creation

**Never ship without quality verification.**

---

### Step 12: Pre-ship Hooks
For each hook in `pre_ship_hooks`:
```
agent <hook.agent> "Pre-ship check on branch: <branch>"
```
Required hooks block on failure. Optional hooks log warnings.

### Step 13: Ship

For task source (with task ID):
```
/majestic-engineer:workflows:ship-it closes #<ID>
```

For plan source (no task):
```
/majestic-engineer:workflows:ship-it
```

### Step 14: Complete (task source only)
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
