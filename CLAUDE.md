# Majestic Marketplace - Ultimate Company Management Toolkit

This repository is a Claude Code plugin marketplace that provides an **ultimate company management toolkit** - AI-powered tools covering every business function: Engineering, Marketing, Sales, and Company Operations.

## Repository Structure

```
majestic-marketplace/
├── .claude-plugin/
│   └── marketplace.json          # Marketplace catalog (lists available plugins)
└── plugins/
    ├── majestic-engineer/        # Language-agnostic engineering workflows
    ├── majestic-rails/           # Ruby/Rails development tools
    ├── majestic-python/          # Python development tools
    ├── majestic-marketing/       # Marketing and SEO tools
    ├── majestic-sales/           # Sales acceleration tools
    ├── majestic-company/         # Business operations tools
    └── majestic-tools/           # Claude Code customization tools
```

## Business Function Coverage

| Function | Plugin | Focus |
|----------|--------|-------|
| Engineering | majestic-engineer, majestic-rails, majestic-python | Development workflows, code quality, testing |
| Marketing | majestic-marketing | SEO, content, GEO (AI visibility), branding |
| Sales | majestic-sales | Funnels, playbooks, prospecting, proposals |
| Operations | majestic-company | Strategy, hiring, legal, business planning |
| Meta | majestic-tools | Claude Code customization |

## Architecture Principles

- DRY: don't repeat yourself
- YAGNI: you aren't gonna need it
- KISS: keep it simple, stupid
- Separation of concerns

## Plugin Architecture

### Hub-and-Spoke Dependency Model

This marketplace uses a **hub-and-spoke architecture** where `majestic-engineer` serves as the central orchestration hub:

```
              ┌─────────────────────────────────────┐
              │          majestic-engineer          │
              │        (Central Orchestrator)       │
              └─────────────────────────────────────┘
                    │         │          │
           ┌───────┼─────────┼──────────┼───────┐
           │       │         │          │       │
           ▼       ▼         ▼          ▼       ▼
      rails    python     react     tools    (generic)
           │       │                    │
           └───────┴────────────────────┘
                   │
                   ▼ (back-references for shared reviewers)
            majestic-engineer
```

### Dependency Rules

1. **`majestic-engineer` is the central orchestrator** - It may reference language-specific plugins (rails, python, react) and utility plugins (tools) for quality gates and code review orchestration.

2. **Language-specific plugins depend on `majestic-engineer`** - They inherit shared reviewers (simplicity-reviewer, project-topics-reviewer) and generic workflows.

3. **Business function plugins are isolated** - `majestic-marketing`, `majestic-sales`, and `majestic-company` have NO cross-plugin dependencies.

4. **`majestic-tools` provides utilities** - Referenced by `majestic-engineer` for external LLM reviewers and terminal utilities.

5. **Documentation references are allowed** - `majestic-guide` may reference all plugins for discovery purposes (no runtime dependency).

### Allowed Dependencies

| Plugin | Can Reference |
|--------|--------------|
| `majestic-engineer` | rails, python, react, tools |
| `majestic-rails` | engineer |
| `majestic-python` | engineer |
| `majestic-react` | engineer |
| `majestic-tools` | (none at runtime, all for docs) |
| `majestic-marketing` | (none) |
| `majestic-sales` | (none) |
| `majestic-company` | (none) |

## Rules for This Repository

### Agent Naming Convention

Agents use simple, descriptive names without prefixes. Claude Code automatically namespaces them with plugin name and directory path:

- **Pattern**: Simple kebab-case names in `name:` field
- **Example**: `gem-research`, `web-research`, `rails-code-review`
- **Implementation**: Add `name: agent-name` to agent frontmatter (no prefix)
- **Directory structure**: Keep subdirectories (`agents/research/gem-research.md`)
- **Display**: Claude Code shows as `plugin-name:directory:agent-name` (e.g., `majestic-rails:research:gem-research`)
- **Invocation**: Use simple name: `agent gem-research`

**Why no prefix?**
- Claude Code automatically namespaces with plugin name + directory path
- Prevents collisions across plugins
- Simpler invocation and shorter names

### Skill Naming Convention

Skills use simple, descriptive names without prefixes. Claude Code automatically namespaces them:

- **Pattern**: Simple kebab-case names in `name:` field
- **Example**: `ruby-coder`, `frontend-design`, `bofu-keywords`
- **Invocation**: Claude Code namespaces as `plugin-name:skill-name`
- **Actual usage**: `majestic-rails:ruby-coder`, `majestic-engineer:frontend-design`

**Why different from agents?**
- Skills use the `Skill` tool with automatic namespacing by Claude Code
- Plugin namespace provides important context (e.g., `majestic-rails:ruby-coder` clearly indicates Rails-specific skill)
- No collision risk due to automatic plugin-level namespacing
- Consistency with broader Claude Code plugin ecosystem

**Implementation**:
- Set `name: skill-name` in SKILL.md frontmatter (no prefix, no namespace)
- Keep directory structure as `plugins/{plugin-name}/skills/{skill-name}/SKILL.md`
- Claude Code handles the namespacing automatically

### Command Naming Convention

Commands use a strategic three-tier naming system based on scope and purpose:

**1. Generic/Cross-Project Commands** - Use `majestic:` prefix for workflows that work across all project types:
- **Pattern**: `name: majestic:command-name`
- **Examples**: `/majestic:plan`, `/majestic:debug`, `/majestic:prd`, `/majestic:code-review`
- **When to use**: Workflows that are language/framework-agnostic
- **Location**: `plugins/majestic-engineer/commands/workflows/`

**2. Framework-Specific Commands** - Use framework prefix for workflows tied to specific technologies:
- **Pattern**: `name: framework:command-name`
- **Examples**: `/rails:build`, `/rails:code-review`
- **When to use**: Workflows specific to Rails, Python, etc.
- **Location**: `plugins/majestic-{framework}/commands/workflows/`

**3. Utility Commands** - Omit `name:` field to use automatic path-based naming:
- **Pattern**: No `name:` field → auto-named as `/category:command-name`
- **Examples**: `/git:commit`, `/gemfile:organize`, `/tasks:backlog`
- **When to use**: Category-specific utilities (git operations, gemfile management, etc.)
- **Location**: `plugins/*/commands/{category}/{command-name}.md`
- **Result**: Invoked as `/{category}:{command-name}`

**Why three tiers?**
- Generic `majestic:` commands work everywhere and are easy to discover
- Framework prefixes provide context (e.g., `/rails:build` clearly indicates Rails workflow)
- Path-based naming organizes utilities by category without manual naming

**Implementation rules**:
- Only add `name:` field for tier 1 (majestic:) and tier 2 (framework:) commands
- Omit `name:` field for tier 3 (utility) commands to use automatic naming
- Never use full plugin prefix (e.g., `majestic-engineer:git:commit`) - inconsistent with convention

### ⛔ FORBIDDEN: Never Modify ~/.claude/

**NEVER modify `~/.claude/` when working on this repository.** All plugin files belong in `majestic-marketplace/plugins/`. The user's personal `~/.claude/` directory is separate from this plugin marketplace.

- ❌ `~/.claude/commands/` - DO NOT TOUCH
- ❌ `~/.claude/skills/` - DO NOT TOUCH
- ❌ `~/.claude/hooks/` - DO NOT TOUCH
- ✅ `plugins/*/` - THIS IS WHERE YOU WORK

### Adding a New Plugin

1. Create plugin directory: `plugins/new-plugin-name/`
2. Add plugin structure:
   ```
   plugins/new-plugin-name/
   ├── .claude-plugin/plugin.json
   ├── agents/
   ├── commands/
   └── README.md
   ```
3. Update `.claude-plugin/marketplace.json` to include the new plugin
4. Test locally before committing

### Updating the Plugin

When agents, commands, or skills are added/removed, follow this checklist:

#### 1. Count all components accurately

```bash
# Count agents
ls plugins/{new-plugin-name}/agents/*.md | wc -l

# Count commands
ls plugins/{new-plugin-name}/commands/*.md | wc -l

# Count skills
ls -d plugins/{new-plugin-name}/skills/*/ 2>/dev/null | wc -l
```

#### 2. Update ALL description strings with correct counts

The description appears in multiple places and must match everywhere:

- [ ] `plugins/{new-plugin-name}/.claude-plugin/plugin.json` → `description` field
- [ ] `.claude-plugin/marketplace.json` → plugin `description` field
- [ ] `plugins/{new-plugin-name}/README.md` → intro paragraph

Format: `"Includes X specialized agents, Y commands, and Z skill(s)."`

#### 3. Update version numbers

When adding new functionality, bump the version in:

- [ ] `plugins/{new-plugin-name}/.claude-plugin/plugin.json` → `version`
- [ ] `.claude-plugin/marketplace.json` → plugin `version`

#### 4. Update documentation

- [ ] `plugins/{new-plugin-name}/README.md` → list all components
- [ ] `plugins/{new-plugin-name}/CHANGELOG.md` → document changes
- [ ] `CLAUDE.md` → update structure diagram if needed

#### 5. Validate JSON files

```bash
cat .claude-plugin/marketplace.json | jq .
cat plugins/{new-plugin-name}/.claude-plugin/plugin.json | jq .
```

### Marketplace.json Structure

The marketplace.json follows the official Claude Code spec:

```json
{
  "name": "marketplace-identifier",
  "owner": {
    "name": "Majestic Labs LLC",
    "url": "https://github.com/majesticlabs-dev"
  },
  "metadata": {
    "description": "Marketplace description",
    "version": "1.0.0"
  },
  "plugins": [
    {
      "name": "plugin-name",
      "description": "Plugin description",
      "version": "1.0.0",
      "author": { ... },
      "homepage": "https://...",
      "tags": ["tag1", "tag2"],
      "source": "./plugins/plugin-name"
    }
  ]
}
```

**Only include fields that are in the official spec.** Do not add custom fields like:

- `downloads`, `stars`, `rating` (display-only)
- `categories`, `featured_plugins`, `trending` (not in spec)
- `type`, `verified`, `featured` (not in spec)

### Plugin.json Structure

Each plugin has its own plugin.json with detailed metadata:

```json
{
  "name": "plugin-name",
  "version": "1.0.0",
  "description": "Plugin description",
  "author": { ... },
  "keywords": ["keyword1", "keyword2"],
  "components": {
    "agents": 15,
    "commands": 6,
    "hooks": 2
  },
  "agents": {
    "category": [
      {
        "name": "agent-name",
        "description": "Agent description",
        "use_cases": ["use-case-1", "use-case-2"]
      }
    ]
  },
  "commands": {
    "category": ["command1", "command2"]
  }
}
```

## Testing Changes

### Test Locally

1. Install the marketplace locally:

   ```bash
   claude /plugin marketplace add /Users/{YourUsername}/majestic-marketplace
   ```

2. Install the plugin:

   ```bash
   claude /plugin install {plugin-name}
   ```

3. Test agents and commands:
   
   ```bash
   claude /{new-command}
   claude agent {new-agent} "{arguments}"
   ```

### Validate JSON

Before committing, ensure JSON files are valid:

```bash
cat .claude-plugin/marketplace.json | jq .
cat plugins/{plugin-name}/.claude-plugin/plugin.json | jq .
```

## Common Tasks

### Adding a New Agent

1. Create `plugins/{plugin-name}/agents/new-agent.md`
2. Update plugin.json agent count and agent list
3. Update README.md agent list
4. Test with `claude agent new-agent "test"`

### Adding a New Command

1. Create `plugins/{plugin-name}/commands/{new-command}.md`
2. Update plugin.json command count and command list
3. Update README.md command list
4. Test with `claude /{new-command}`

### Adding a New Skill

1. Create skill directory: `plugins/{plugin-name}/skills/{skill-name}/`
2. Add skill structure:
   ```
   skills/skill-name/
   ├── SKILL.md           # Skill definition with frontmatter (name, description)
   └── scripts/           # Supporting scripts (optional)
   ```
3. Update plugin.json description with new skill count
4. Update marketplace.json description with new skill count
5. Update README.md with skill documentation
6. Update CHANGELOG.md with the addition
7. Test with `claude skill skill-name`

### Updating Tags/Keywords

Tags should reflect the compounding engineering philosophy:

- Use: `ai-powered`, `workflow-automation`, `knowledge-management`
- Avoid: Framework-specific tags unless the plugin is framework-specific

## Commit Conventions

Follow these patterns for commit messages:

- `Add [agent/command name]` - Adding new functionality
- `Remove [agent/command name]` - Removing functionality
- `Update [file] to [what changed]` - Updating existing files
- `Fix [issue]` - Bug fixes
- `Refactor [component] to [improvement]` - Refactoring


## Resources to search for when needing more information

- [Claude Code Plugin Documentation](https://docs.claude.com/en/docs/claude-code/plugins)
- [Plugin Marketplace Documentation](https://docs.claude.com/en/docs/claude-code/plugin-marketplaces)
- [Plugin Reference](https://docs.claude.com/en/docs/claude-code/plugins-reference)

## Project Configuration: .agents.yml

Commands and scripts read project configuration from `.agents.yml` in the project root. This file is created by `/majestic:init-agents-md` during project setup.

**AGENTS.md should reference this file:** `Load config: @.agents.yml`

### Structure

The config file has **core fields** plus **stack-specific fields** based on tech stack.

#### Rails Project Example

```yaml
# .agents.yml - Project configuration for Claude Code commands
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
```

#### Python Project Example

```yaml
# .agents.yml - Project configuration for Claude Code commands
default_branch: main
app_status: development

# Tech Stack
tech_stack: python
python_version: "3.12"
framework: fastapi
package_manager: uv
database: postgres

# Workflow
task_management: github
workflow: worktrees
branch_naming: type/issue-desc
review_topics_path: docs/agents/review-topics.md
```

#### Node Project Example

```yaml
# .agents.yml - Project configuration for Claude Code commands
default_branch: main
app_status: development

# Tech Stack
tech_stack: node
node_version: "22"
framework: nextjs
package_manager: pnpm
typescript: true
styling: tailwind
testing: vitest
deployment: vercel

# Workflow
task_management: github
workflow: worktrees
branch_naming: type/issue-desc
review_topics_path: docs/agents/review-topics.md
```

### Core Fields

| Field | Description | Values | Default |
|-------|-------------|--------|---------|
| `default_branch` | Main branch for git operations | branch name | `main` |
| `tech_stack` | Primary tech stack | `rails` \| `python` \| `generic` | `generic` |
| `app_status` | Application lifecycle stage | `development` \| `production` | `development` |
| `task_management` | Task tracking system | `github` \| `linear` \| `beads` \| `file` \| `none` | `none` |
| `workflow` | Feature development workflow | `worktrees` \| `branches` | `branches` |
| `branch_naming` | Branch naming convention | `feature/desc` \| `issue-desc` \| `type/issue-desc` \| `user/desc` | `feature/desc` |
| `review_topics_path` | Path to review topics file | file path | (none) |

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
| `extras` | Rails 8 Solid gems | list of: `solid_cache`, `solid_queue`, `solid_cable` | (none) |

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

### Quality Gate Fields

| Field | Description | Values | Default |
|-------|-------------|--------|---------|
| `quality_gate.reviewers` | List of reviewers to run | list of agent names | (tech-stack defaults) |

**Behavior:** When `quality_gate.reviewers` is configured, it **completely overrides** the default reviewers. Omit the section to use tech-stack defaults.

#### Available Reviewers

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

#### Example Configuration

```yaml
quality_gate:
  reviewers:
    - security-review
    - pragmatic-rails-reviewer
    - performance-reviewer
    - test-reviewer
    - project-topics-reviewer
```

### Why .agents.yml?

- **Machine-readable** - YAML for commands, AGENTS.md for human guidance
- **Simple reads** - `grep "key:" .agents.yml | awk '{print $2}'`
- **Cross-shell compatible** - Avoids shell-specific parsing issues
- **Single source of truth** - Config in one place, referenced everywhere

### Custom Config Path (AGENTS_CONFIG)

Override the default config filename with the `AGENTS_CONFIG` environment variable:

```bash
# Use custom config file
export AGENTS_CONFIG=".my-config.yml"
```

All commands and scripts respect this override, falling back to `.agents.yml` if not set.

### Reading Config in Commands

```bash
# Read single value with fallback (supports AGENTS_CONFIG override)
TECH=$(grep "tech_stack:" "${AGENTS_CONFIG:-.agents.yml}" 2>/dev/null | awk '{print $2}')
TECH=${TECH:-generic}

# Check boolean-like values
if grep -q "app_status: production" "${AGENTS_CONFIG:-.agents.yml}" 2>/dev/null; then
  echo "Production mode - backward compatibility required"
fi
```

## Key Learnings

_This section captures important learnings as we work on this repository._

**Learning:** Stick to the official spec. Custom fields may confuse users or break compatibility with future versions.

**Learning:** When updating files to add new patterns or tools, always preserve existing content. Don't simplify or remove example formats, question templates, or detailed instructions. Add the new pattern alongside existing content, not as a replacement.

**Learning:** Interactive skills (those with "Conversation Starter" or "Begin by asking:" patterns) should include `AskUserQuestion` in their `allowed-tools:` frontmatter and use the format: "Use `AskUserQuestion` to gather initial context. Begin by asking:"

**Learning:** Mermaid diagrams use different node shapes to distinguish component types: `()` creates stadium/rounded nodes for commands, `{{}}` creates hexagons for agents, and `[]` creates rectangles for manual actions or external steps.

**Learning:** The `model:` field in command/agent frontmatter requires full model IDs (e.g., `claude-haiku-4-5-20251001`), not short names like `haiku`, `sonnet`, or `opus`. Prefer omitting the field entirely to inherit from user's session, except for explicitly cheap/fast operations where haiku is appropriate.

**Learning:** The `name:` field in command frontmatter overrides path-based naming. Without it, Claude Code derives names from file paths (e.g., `plugins/majestic-rails/commands/gemfile/upgrade.md` → `/majestic-rails:gemfile:upgrade`). Adding `name: foo` creates `/foo` instead - simpler but loses plugin namespacing. Use `name:` intentionally for short aliases; omit it when namespacing matters.
