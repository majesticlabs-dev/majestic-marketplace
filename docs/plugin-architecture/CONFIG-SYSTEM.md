# Configuration System

Commands and scripts read project configuration from `.agents.yml` in the project root. This file is created by `/majestic:init` during project setup.

**AGENTS.md should reference this file:** `Load config: @.agents.yml`

## Structure Overview

The config file has **core fields** plus **stack-specific fields** based on tech stack.

## Version History

| Version | Changes |
|---------|---------|
| 1.9 | Added `task_tracking` section for native Task system integration |
| 1.8 | Added `quality_gate.strictness` for controlling fix loop threshold |
| 1.7 | Migrated project knowledge from `.claude/` to `.agents-os/` (lessons, handoffs, session ledger) |
| 1.6 | Added `owner.level` for experience-based skill tailoring |
| 1.5 | Added `lessons_path` for learnings discovery |
| 1.4 | Multi-stack `tech_stack` (array support), built-in toolbox presets |
| 1.3 | (removed - commit hooks deprecated in favor of git native hooks) |
| 1.2 | Moved `auto_create_task` under `plan:` namespace |
| 1.1 | Added `workflow_labels`, `workspace_setup.post_create` |
| 1.0 | Initial release |

### Migration from 1.6 to 1.7

**Backwards compatible:** Path change with optional migration.

Project knowledge storage moves from `.claude/` to `.agents-os/`:

| Old Path | New Path |
|----------|----------|
| `.claude/lessons/` | `.agents-os/lessons/` |
| `.claude/handoffs/` | `.agents-os/handoffs/` |
| `.claude/session_ledger.md` | `.agents-os/session_ledger.md` |

**Why the change:** Separates tool configuration (`.claude/` - settings, hooks, commands) from project knowledge (`.agents-os/` - lessons, handoffs, context). This makes project knowledge portable and tool-agnostic.

**Migration steps:**
1. Update `config_version: 1.7` in `.agents.yml`
2. Move existing directories: `mv .claude/lessons .agents-os/lessons && mv .claude/handoffs .agents-os/handoffs`
3. Update `.gitignore` if you have custom entries for these paths

**Note:** `.claude/` remains for Claude Code tool configuration (settings.json, hooks, commands).

### Migration from 1.8 to 1.9

**Backwards compatible:** New optional section for Task system integration.

New format (1.9) adds task tracking configuration:
```yaml
# Task Tracking - Native Claude Code Task system integration
task_tracking:
  enabled: true                               # Master switch
  ledger: true                                # YAML ledger for crash recovery
  ledger_path: .agents-os/workflow-ledger.yml # Checkpoint file location
  auto_cleanup: true                          # Remove tasks after workflow completion
```

**What it does:**
- `enabled: true` - Workflows create Tasks for visibility (ctrl+t shows progress)
- `ledger: true` - Checkpoints written to YAML for crash recovery
- `ledger_path` - Where checkpoints are stored (gitignored by default)
- `auto_cleanup: true` - Completed workflow tasks are removed to prevent pollution

**Why the change:** Leverages Claude Code's native Task system for dependency tracking, parallel execution coordination, and cross-session persistence. The YAML ledger provides detailed receipts for crash recovery.

**No action required** - existing configs continue to work. Task tracking is opt-in (default: disabled).

### Migration from 1.7 to 1.8

**Backwards compatible:** New optional field with sensible default.

New format (1.8) adds quality gate strictness control:
```yaml
quality_gate:
  strictness: pedantic  # pedantic | strict | standard
  reviewers:
    - security-review
    - pragmatic-rails-reviewer
```

**Strictness levels:**
- `pedantic` (default) - Fix ALL issues while context is fresh
- `strict` - Fix MEDIUM+ issues, defer LOW to log
- `standard` - Fix HIGH+ issues, defer MEDIUM/LOW to log

**Why the change:** Previously, MEDIUM/LOW findings were "approved with notes" but never addressed. With `pedantic` default, all issues are fixed while the session has context. Lower strictness defers findings to `.agents-os/relay/deferred-findings.log`.

**No action required** - existing configs continue to work with `pedantic` default.

### Migration from 1.5 to 1.6

**Backwards compatible:** New optional field.

New format (1.6) adds owner context for experience-based skill tailoring:
```yaml
# Owner Context - Skills adjust explanations based on level
owner:
  level: intermediate  # beginner | intermediate | senior | expert
  # For multi-stack projects, specify per-technology:
  # rails: senior
  # react: beginner
```

**Level definitions:**
- `beginner` - New to the technology, skills provide detailed explanations
- `intermediate` - Comfortable with basics, focus on advanced patterns
- `senior` - Deep knowledge, skip basics, focus on edge cases
- `expert` - Authoritative, minimal explanation, just show the code

**Why the change:** Skills can now tailor outputs to the user's experience. Instead of "You are an expert..." persona prompting, skills use audience framing that references this config.

### Migration from 1.3 to 1.4

**Backwards compatible:** Single-value `tech_stack` continues to work.

New format (1.4) supports multi-framework projects:
```yaml
# Single stack (unchanged)
tech_stack: rails

# Multi-framework (new)
tech_stack:
  - rails
  - react
```

Built-in toolbox presets now provide sensible defaults. The `toolbox:` section in `.agents.yml` is now optional for overrides only.

### Migration from 1.1 to 1.2

**Backwards compatible:** The config reader automatically falls back to old field locations.

Old format (1.1):
```yaml
auto_preview: true
auto_create_task: true
```

New format (1.2):
```yaml
auto_preview: true  # Stays at top level (used by multiple commands)
plan:
  auto_create_task: true  # Moved under plan: (plan-specific)
```

**No action required** - existing configs continue to work. Update when convenient.

## Example Configurations

### Rails Project

```yaml
# .agents.yml - Project configuration for Claude Code commands
config_version: 1.9
app_status: development

# Tech Stack
tech_stack: rails
ruby_version: "3.4.1"
rails_version: "8.0"
database: sqlite
frontend: hotwire
css: tailwind
assets: propshaft
js: importmap
deployment: kamal
extras:
  - solid_cache
  - solid_queue
  - solid_cable

# Workflow
task_management: github
workflow: worktrees
branch_naming: type/issue-desc
lessons_path: .agents-os/lessons/

# Workspace setup hooks
# workspace_setup:
#   post_create: bin/setup-worktree

# Auto-preview markdown files (plans, PRDs, briefs, handoffs)
auto_preview: true

# Planning
plan:
  auto_create_task: true # Auto-create task when /majestic:plan completes

# Task Tracking - Native Claude Code Task system integration
# task_tracking:
#   enabled: true                               # Workflows create Tasks for visibility
#   ledger: true                                # YAML checkpoints for crash recovery
#   ledger_path: .agents-os/workflow-ledger.yml
#   auto_cleanup: true                          # Remove tasks after workflow completion

# Toolbox customization (optional - overrides plugin defaults)
toolbox:
  build_task:
    coding_styles:
      - majestic-rails:dhh-coder
  quality_gate:
    strictness: pedantic  # Address all issues while context is fresh
    reviewers:
      - majestic-rails:review:pragmatic-rails-reviewer
      - majestic-engineer:qa:security-review
```

### Python Project

```yaml
config_version: 1.9
app_status: development

tech_stack: python
python_version: "3.12"
framework: fastapi
package_manager: uv
database: postgres

task_management: github
workflow: worktrees
branch_naming: type/issue-desc
lessons_path: .agents-os/lessons/

auto_preview: true
plan:
  auto_create_task: true
```

### Node Project

```yaml
config_version: 1.9
app_status: development

tech_stack: node
node_version: "22"
framework: nextjs
package_manager: pnpm
typescript: true
styling: tailwind
testing: vitest
deployment: vercel

task_management: github
workflow: worktrees
branch_naming: type/issue-desc
lessons_path: .agents-os/lessons/

auto_preview: true
plan:
  auto_create_task: true
```

## Field Reference

### Core Fields

| Field | Description | Values | Default |
|-------|-------------|--------|---------|
| `config_version` | Schema version for update detection | version number (e.g., 1.0) | (none) |
| `tech_stack` | Primary tech stack | `rails` \| `python` \| `generic` | `generic` |
| `app_status` | Application lifecycle stage | `development` \| `production` | `development` |
| `task_management` | Task tracking system | `github` \| `linear` \| `beads` \| `file` \| `none` | `none` |
| `workflow` | Feature development workflow | `worktrees` \| `branches` | `branches` |
| `branch_naming` | Branch naming convention | `feature/desc` \| `issue-desc` \| `type/issue-desc` \| `user/desc` | `feature/desc` |
| `lessons_path` | Path to lessons directory for discovery | directory path | `.agents-os/lessons/` |
| `auto_preview` | Auto-open markdown files (plans, PRDs, briefs, handoffs) | `true` \| `false` | `false` |
| `plan.auto_create_task` | Auto-create task when `/majestic:plan` completes | `true` \| `false` | `false` |
| `session.ledger` | Enable session state checkpointing to file | `true` \| `false` | `false` |
| `session.ledger_path` | Path to session ledger file | file path | `.session_ledger.md` |
| `workspace_setup.post_create` | Script to run after creating workspace | script path | (none) |
| `quality_gate.strictness` | Minimum severity that triggers fix loop | `pedantic` \| `strict` \| `standard` | `pedantic` |
| `task_tracking.enabled` | Enable native Task system for workflow visibility | `true` \| `false` | `false` |
| `task_tracking.ledger` | Enable YAML ledger for crash recovery | `true` \| `false` | `false` |
| `task_tracking.ledger_path` | Path to workflow ledger file | file path | `.agents-os/workflow-ledger.yml` |
| `task_tracking.auto_cleanup` | Remove tasks after workflow completion | `true` \| `false` | `true` |

### Rails-Specific Fields

| Field | Description | Values | Default |
|-------|-------------|--------|---------|
| `ruby_version` | Ruby version | version string | auto-detected |
| `rails_version` | Rails version | version string | auto-detected |
| `database` | Database type | `sqlite` \| `postgres` \| `mysql` | `sqlite` |
| `frontend` | Frontend approach | `hotwire` \| `inertia` \| `api-only` | `hotwire` |
| `css` | CSS framework | `tailwind` \| `bootstrap` \| `none` | `tailwind` |
| `assets` | Asset pipeline | `propshaft` \| `sprockets` | `propshaft` |
| `js` | JavaScript strategy | `importmap` \| `esbuild` \| `vite` | `importmap` |
| `deployment` | Deployment tool | `kamal` \| `fly` \| `heroku` \| `render` | (none) |
| `extras` | Rails 8 Solid gems | `solid_cache`, `solid_queue`, `solid_cable` | (none) |

### Python-Specific Fields

| Field | Description | Values | Default |
|-------|-------------|--------|---------|
| `python_version` | Python version | version string | auto-detected |
| `framework` | Web framework | `fastapi` \| `django` \| `flask` \| `none` | auto-detected |
| `package_manager` | Package manager | `uv` \| `poetry` \| `pip` | `pip` |
| `database` | Database type | `postgres` \| `sqlite` \| `none` | `postgres` |

### Node-Specific Fields

| Field | Description | Values | Default |
|-------|-------------|--------|---------|
| `node_version` | Node.js version | version string | auto-detected |
| `framework` | Framework | `nextjs` \| `react` \| `vue` \| `nuxt` \| `svelte` \| `express` \| `fastify` \| `none` | auto-detected |
| `package_manager` | Package manager | `pnpm` \| `npm` \| `yarn` \| `bun` | `npm` |
| `typescript` | TypeScript enabled | `true` \| `false` | auto-detected |
| `styling` | CSS approach | `tailwind` \| `css-modules` \| `styled-components` \| `sass` \| `none` | `tailwind` |
| `testing` | Testing framework | `vitest` \| `jest` \| `playwright` \| `cypress` \| `none` | (none) |
| `deployment` | Deployment platform | `vercel` \| `cloudflare` \| `netlify` \| `railway` \| `none` | (none) |

## Stack Toolbox Registry

The toolbox registry enables **automatic stack-specific tool selection** for generic orchestrators like `/majestic:build-task` and `quality-gate`.

### How It Works

```
┌─────────────────────────────────────────────────────┐
│  Generic Orchestrator (/build-task, quality-gate)   │
│    1. Read .agents.yml → tech_stack                 │
│    2. Invoke toolbox-resolver                       │
│    3. Use returned config for decisions             │
└─────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────┐
│  Toolbox Resolver Agent                             │
│    1. Discover toolbox.yml from plugin paths        │
│    2. Filter by tech_stack match                    │
│    3. Merge by priority (deterministic)             │
│    4. Apply user overrides from .agents.yml         │
│    5. Return canonical config                       │
└─────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────┐
│  Stack Plugin Manifests                             │
│    majestic-rails/.claude-plugin/toolbox.yml        │
│    majestic-python/.claude-plugin/toolbox.yml       │
└─────────────────────────────────────────────────────┘
```

### Toolbox Manifest Location

Stack plugins declare capabilities in `.claude-plugin/toolbox.yml`:

```yaml
# Example: plugins/majestic-rails/.claude-plugin/toolbox.yml
schema_version: 1
plugin: majestic-rails
tech_stack: rails
priority: 100

build_task:
  executor:
    build_agent: general-purpose
    fix_agent: general-purpose
  coding_styles:
    - majestic-rails:dhh-coder
  design_system_path: docs/design/design-system.md
  research_hooks:
    - id: gem_research
      mode: auto
      agent: majestic-rails:research:gem-research
      triggers:
        any_substring: ["Gemfile", "gem ", "bundle", "dependency"]
  pre_ship_hooks:
    - id: rails_lint
      agent: majestic-rails:lint
      required: false

quality_gate:
  reviewers:
    - majestic-rails:review:pragmatic-rails-reviewer
    - majestic-engineer:qa:security-review
    - majestic-rails:review:performance-reviewer
```

### Key Concepts

| Concept | Description |
|---------|-------------|
| **Coding styles** | Skills activated during build phase to influence code style |
| **Design system path** | Path to design system document (generated by `/majestic:ux-brief`) |
| **Auto research hooks** | Run automatically BEFORE planning when triggers match |
| **Manual research hooks** | Available for architect/builder to invoke when needed |
| **Pre-ship hooks** | Pipeline steps before shipping (NOT reviewers) |
| **Quality gate reviewers** | Agents that produce structured review findings |
| **Priority-based merge** | Higher priority wins in collisions (deterministic) |

### Research Hook Modes

| Mode | Behavior | Use Case |
|------|----------|----------|
| `auto` | Orchestrator runs when `triggers` match | Gem research when "Gemfile" mentioned |
| `manual` | Builder/architect invokes when needed | Deep research during implementation |

### Trigger Types

```yaml
triggers:
  any_substring: ["Gemfile", "gem ", "bundle"]  # Match if ANY found
  all_substring: ["migration", "database"]       # Match if ALL found
  regex: "add.*gem|install.*package"             # Regex pattern
```

### Precedence Rules

1. `.agents.yml toolbox.<section>.<field>` → User override (highest)
2. Plugin `toolbox.yml` manifest → Stack-specific default
3. Hardcoded fallback → Last resort

### User Overrides

Override toolbox settings in `.agents.yml`:

```yaml
toolbox:
  build_task:
    executor:
      build_agent: general-purpose
      fix_agent: general-purpose
    coding_styles:
      - majestic-rails:dhh-coder
      - majestic-engineer:tdd-workflow
    design_system_path: docs/design/design-system.md
    research_hooks:
      - id: api_docs
        mode: manual
        agent: majestic-engineer:research:docs-researcher

  quality_gate:
    reviewers:
      - majestic-engineer:qa:security-review
      - majestic-rails:review:pragmatic-rails-reviewer
      - majestic-rails:review:performance-reviewer
```

**Override behavior:**
- `coding_styles` → Replaces manifest list entirely
- `design_system_path` → Replaces manifest scalar value
- `quality_gate.reviewers` → Replaces manifest list entirely
- `research_hooks` → Extends manifest hooks (additive)

### Available Coding Styles (Skills)

| Skill | Plugin | Description |
|-------|--------|-------------|
| `dhh-coder` | majestic-rails | DHH's 37signals Ruby/Rails philosophy |
| `tdd-workflow` | majestic-engineer | Test-driven development patterns |
| `frontend-design` | majestic-engineer | Frontend component design |

**Invocation:** `Skill(skill: "majestic-rails:dhh-coder")`

### Available Reviewers (Agents)

| Reviewer | Plugin | Description |
|----------|--------|-------------|
| `security-review` | majestic-engineer | OWASP Top 10, secrets, vulnerabilities |
| `test-reviewer` | majestic-engineer | Test coverage, quality, edge cases |
| `simplicity-reviewer` | majestic-engineer | Complexity and overengineering |
| `pragmatic-rails-reviewer` | majestic-rails | Rails conventions, thin controllers |
| `performance-reviewer` | majestic-rails | N+1 queries, slow operations |
| `data-integrity-reviewer` | majestic-rails | Migration safety, constraints |
| `dhh-code-reviewer` | majestic-rails | DHH's strict Rails philosophy |
| `python-reviewer` | majestic-python | Python conventions and idioms |
| `react-reviewer` | majestic-react | React best practices, hooks, a11y |
| `codex-reviewer` | majestic-tools | External LLM (OpenAI Codex) |
| `gemini-reviewer` | majestic-tools | External LLM (Google Gemini) |

**Invocation:** `Task(subagent_type: "majestic-engineer:qa:security-review")`

### Quality Gate Strictness

Controls the minimum severity that triggers the fix loop:

| Strictness | Fix Loop Addresses | Deferred to Log |
|------------|-------------------|-----------------|
| `pedantic` (default) | ALL issues (LOW+) | Nothing |
| `strict` | MEDIUM+ | LOW only |
| `standard` | HIGH+ | MEDIUM, LOW |

**Why pedantic is default:** Fix issues while context is fresh. Deferring loses context and accumulates tech debt.

**Deferred findings log:** When strictness is not `pedantic`, findings below threshold are logged to `.agents-os/relay/deferred-findings.log` for later review.

```yaml
# .agents.yml
quality_gate:
  strictness: pedantic  # pedantic | strict | standard
  reviewers:
    - security-review
    - pragmatic-rails-reviewer
```

## Why .agents.yml?

- **Machine-readable** - YAML for commands, AGENTS.md for human guidance
- **Cross-shell compatible** - Avoids shell-specific parsing issues
- **Single source of truth** - Config in one place, referenced everywhere

## Custom Config Path

Override the default config filename with `AGENTS_CONFIG`:

```bash
export AGENTS_CONFIG=".my-config.yml"
```

All commands and scripts respect this override, falling back to `.agents.yml` if not set.

## Session State Management

Enable file-based session checkpointing for crash recovery and workflow continuity:

```yaml
# .agents.yml
session:
  ledger: true
  ledger_path: .session_ledger.md  # optional
```

**Important:** Add the ledger file to `.gitignore`:

```gitignore
# Session state (not tracked)
.session_ledger.md
```

When enabled, workflows can invoke `session-checkpoint` agent to save state:
- Before risky operations (major refactors)
- After completing milestones
- Periodically during long tasks

The ledger survives session crashes but is NOT a replacement for `/session:handoff` (use handoff for intentional cross-session continuity).

## Local Overrides

For personal preferences that shouldn't be tracked in git, create `.agents.local.yml`:

```yaml
# .agents.local.yml - Personal overrides (not tracked in git)
workflow: worktrees
branch_naming: user/desc

# Auto-preview markdown files
auto_preview: true

# Planning preferences
plan:
  auto_create_task: false
```

**Merge behavior:**
- Local values override team values key-by-key (deep merge)
- For nested sections (`toolbox.build_task`), local replaces entire section
- If `AGENTS_CONFIG` is set, local file is ignored

**Auto-created:** Running `/majestic:init` prompts to create local overrides.

## Auto-Preview Pattern

When commands create markdown files (plans, PRDs, briefs, handoffs), they follow this pattern:

**REQUIRED steps after writing the file:**

1. **Check auto_preview**: `Skill(skill: "config-reader", args: "auto_preview false")`
2. **If true**: Execute `open <filepath>` immediately
3. **If false/missing**: Present options including "Preview in editor" first

**Commands using this pattern:**
- `/majestic:plan` → `docs/plans/<title>.md`
- `/majestic:prd` → `docs/prd/prd-<name>.md`
- `/majestic:ux-brief` → `docs/design/<name>-brief.md`
- `/majestic:handoff` → `.agents-os/handoffs/<timestamp>-<slug>.md`
