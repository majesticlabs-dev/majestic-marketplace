# Configuration System

Commands and scripts read project configuration from `.agents.yml` in the project root. This file is created by `/majestic:init` during project setup.

**AGENTS.md should reference this file:** `Load config: @.agents.yml`

## Structure Overview

The config file has **core fields** plus **stack-specific fields** based on tech stack.

## Version History

| Version | Changes |
|---------|---------|
| 1.3 | Added `commit.pre_prompt`, `commit.post_prompt` for LLM-based commit hooks |
| 1.2 | Moved `auto_create_task` under `plan:` namespace |
| 1.1 | Added `workflow_labels`, `workspace_setup.post_create` |
| 1.0 | Initial release |

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
config_version: 1.2
default_branch: main
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
review_topics_path: docs/agents/review-topics.md

# Workspace setup hooks
# workspace_setup:
#   post_create: bin/setup-worktree

# Commit hooks (LLM prompts)
# commit:
#   pre_prompt: "Check staged files for console.log, binding.pry, and TODO comments"
#   post_prompt: "If this is a feature/fix commit, suggest a CHANGELOG.md update"

# Auto-preview markdown files (plans, PRDs, briefs, handoffs)
auto_preview: true

# Planning
plan:
  auto_create_task: true # Auto-create task when /majestic:plan completes

# Toolbox customization (optional - overrides plugin defaults)
toolbox:
  build_task:
    coding_styles:
      - majestic-rails:dhh-coder
  quality_gate:
    reviewers:
      - majestic-rails:review:pragmatic-rails-reviewer
      - majestic-engineer:qa:security-review
```

### Python Project

```yaml
config_version: 1.2
default_branch: main
app_status: development

tech_stack: python
python_version: "3.12"
framework: fastapi
package_manager: uv
database: postgres

task_management: github
workflow: worktrees
branch_naming: type/issue-desc
review_topics_path: docs/agents/review-topics.md

auto_preview: true
plan:
  auto_create_task: true
```

### Node Project

```yaml
config_version: 1.2
default_branch: main
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
review_topics_path: docs/agents/review-topics.md

auto_preview: true
plan:
  auto_create_task: true
```

## Field Reference

### Core Fields

| Field | Description | Values | Default |
|-------|-------------|--------|---------|
| `config_version` | Schema version for update detection | version number (e.g., 1.0) | (none) |
| `default_branch` | Main branch for git operations | branch name | `main` |
| `tech_stack` | Primary tech stack | `rails` \| `python` \| `generic` | `generic` |
| `app_status` | Application lifecycle stage | `development` \| `production` | `development` |
| `task_management` | Task tracking system | `github` \| `linear` \| `beads` \| `file` \| `none` | `none` |
| `workflow` | Feature development workflow | `worktrees` \| `branches` | `branches` |
| `branch_naming` | Branch naming convention | `feature/desc` \| `issue-desc` \| `type/issue-desc` \| `user/desc` | `feature/desc` |
| `review_topics_path` | Path to review topics file | file path | (none) |
| `auto_preview` | Auto-open markdown files (plans, PRDs, briefs, handoffs) | `true` \| `false` | `false` |
| `plan.auto_create_task` | Auto-create task when `/majestic:plan` completes | `true` \| `false` | `false` |
| `session.ledger` | Enable session state checkpointing to file | `true` \| `false` | `false` |
| `session.ledger_path` | Path to session ledger file | file path | `.session_ledger.md` |
| `browser.type` | Browser for web-browser skill | `chrome` \| `brave` \| `edge` | `chrome` |
| `browser.debug_port` | CDP port for browser control | port number | `9222` |
| `workspace_setup.post_create` | Script to run after creating workspace | script path | (none) |
| `commit.pre_prompt` | LLM prompt to execute before committing | text | (none) |
| `commit.post_prompt` | LLM prompt to execute after successful commit | text | (none) |

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
    - majestic-engineer:review:project-topics-reviewer
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
      - majestic-engineer:review:project-topics-reviewer
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
| `project-topics-reviewer` | majestic-engineer | Custom rules from review_topics_path |
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

# Browser preference (for web-browser skill)
browser:
  type: brave
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
- `/majestic:handoff` → `.claude/handoffs/<timestamp>-<slug>.md`
