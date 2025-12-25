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
    ├── majestic-llm/             # External LLM integration (Codex, Gemini)
    └── majestic-tools/           # Claude Code customization tools
```

## Business Function Coverage

| Function | Plugin | Focus |
|----------|--------|-------|
| Engineering | majestic-engineer, majestic-rails, majestic-python | Development workflows, code quality, testing |
| Marketing | majestic-marketing | SEO, content, GEO (AI visibility), branding |
| Sales | majestic-sales | Funnels, playbooks, prospecting, proposals |
| Operations | majestic-company | Strategy, hiring, legal, business planning |
| LLM Integration | majestic-llm | External LLM consulting (Codex, Gemini) |
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
      rails    python     react      llm     tools
           │       │                    │
           └───────┴────────────────────┘
                   │
                   ▼ (back-references for shared reviewers)
            majestic-engineer
```

### Dependency Rules

1. **`majestic-engineer` is the central orchestrator** - It may reference language-specific plugins (rails, python, react), LLM integration (llm), and utility plugins (tools) for quality gates and code review orchestration.

2. **Language-specific plugins depend on `majestic-engineer`** - They inherit shared reviewers (simplicity-reviewer, project-topics-reviewer) and generic workflows.

3. **Business function plugins are isolated** - `majestic-marketing`, `majestic-sales`, and `majestic-company` have NO cross-plugin dependencies.

4. **`majestic-llm` provides external LLM integration** - Referenced by `majestic-engineer` for multi-LLM code review and architecture consulting.

5. **`majestic-tools` provides utilities** - Referenced by `majestic-engineer` for reasoning tools and terminal utilities.

6. **Documentation references are allowed** - `majestic-guide` may reference all plugins for discovery purposes (no runtime dependency).

### Allowed Dependencies

| Plugin | Can Reference |
|--------|--------------|
| `majestic-engineer` | rails, python, react, llm, tools |
| `majestic-rails` | engineer |
| `majestic-python` | engineer |
| `majestic-react` | engineer |
| `majestic-llm` | (none) |
| `majestic-tools` | (none at runtime, all for docs) |
| `majestic-marketing` | (none) |
| `majestic-sales` | (none) |
| `majestic-company` | (none) |

## Rules for This Repository

### Naming Conventions

See [docs/plugin-architecture/NAMING-CONVENTIONS.md](docs/plugin-architecture/NAMING-CONVENTIONS.md) for agent, skill, and command naming rules.

**Quick reference:**
- **Agents**: Simple kebab-case names, auto-namespaced by Claude Code
- **Skills**: Simple kebab-case names, invoked as `plugin-name:skill-name`
- **Commands**: Three-tier system (`majestic:*`, `framework:*`, or path-based)

### ⛔ FORBIDDEN: Never Modify ~/.claude/

**NEVER modify `~/.claude/` when working on this repository.** All plugin files belong in `majestic-marketplace/plugins/`. The user's personal `~/.claude/` directory is separate from this plugin marketplace.

- ❌ `~/.claude/commands/` - DO NOT TOUCH
- ❌ `~/.claude/skills/` - DO NOT TOUCH
- ❌ `~/.claude/hooks/` - DO NOT TOUCH
- ✅ `plugins/*/` - THIS IS WHERE YOU WORK

### Plugin Operations

See [docs/plugin-architecture/PLUGIN-OPERATIONS.md](docs/plugin-architecture/PLUGIN-OPERATIONS.md) for:
- Adding new plugins
- Updating plugin components (agents, commands, skills)
- Testing changes locally
- Common maintenance tasks
- Commit conventions

### JSON Schemas

See [docs/plugin-architecture/JSON-SCHEMAS.md](docs/plugin-architecture/JSON-SCHEMAS.md) for:
- marketplace.json structure and allowed fields
- plugin.json structure and component definitions
- Validation instructions

## Project Configuration: .agents.yml

See [docs/plugin-architecture/CONFIG-SYSTEM.md](docs/plugin-architecture/CONFIG-SYSTEM.md) for complete configuration documentation.

**Quick reference - Core fields:**

| Field | Description | Default |
|-------|-------------|---------|
| `default_branch` | Main branch for git operations | `main` |
| `tech_stack` | Primary tech stack (`rails`, `python`, `generic`) | `generic` |
| `task_management` | Task tracking system | `none` |
| `workflow` | Development workflow (`worktrees`, `branches`) | `branches` |
| `review_topics_path` | Path to review topics file | (none) |

**Config access:** Always use `config-reader` agent - never grep `.agents.yml` directly.

## Resources

- **Wiki**: `../majestic-marketplace.wiki/` - Plugin documentation, usage guides, and examples
- [Claude Code Plugin Documentation](https://docs.claude.com/en/docs/claude-code/plugins)
- [Plugin Marketplace Documentation](https://docs.claude.com/en/docs/claude-code/plugin-marketplaces)
- [Plugin Reference](https://docs.claude.com/en/docs/claude-code/plugins-reference)

## Key Learnings

_Synthesized wisdom from working on this repository._

**Learning:** Stick to the official spec. Custom fields may confuse users or break compatibility with future versions.

**Learning:** When updating files to add new patterns or tools, always preserve existing content. Don't simplify or remove example formats, question templates, or detailed instructions. Add the new pattern alongside existing content, not as a replacement.

**Learning:** Interactive skills (those with "Conversation Starter" or "Begin by asking:" patterns) should include `AskUserQuestion` in their `allowed-tools:` frontmatter and use the format: "Use `AskUserQuestion` to gather initial context. Begin by asking:"

**Learning:** Mermaid diagrams use different node shapes to distinguish component types: `()` creates stadium/rounded nodes for commands, `{{}}` creates hexagons for agents, and `[]` creates rectangles for manual actions or external steps.

**Learning:** The `model:` field in command/agent frontmatter requires full model IDs (e.g., `haiku`), not short names like `haiku`, `sonnet`, or `opus`. Prefer omitting the field entirely to inherit from user's session, except for explicitly cheap/fast operations where haiku is appropriate.

**Learning:** The `name:` field in command frontmatter overrides path-based naming. Without it, Claude Code derives names from file paths (e.g., `plugins/majestic-rails/commands/gemfile/upgrade.md` → `/majestic-rails:gemfile:upgrade`). Adding `name: foo` creates `/foo` instead - simpler but loses plugin namespacing. Use `name:` intentionally for short aliases; omit it when namespacing matters.

**Learning:** Skills must contain NEW information Claude doesn't already know. Avoid generic advice like "think step by step", "run tests after changes", or personas like "you are a professional engineer" - the model is trained on the entire internet and knows these. Instead, include: project-specific patterns, synthesized experience, concrete code examples, measurable rules ("max 5 lines per method"), and anti-patterns with specifics.

**Learning:** Skills are for knowledge/context (probabilistic - Claude MAY follow), hooks are for process enforcement (deterministic - FORCES behavior). If you want Claude to ALWAYS do something (run tests, check types), use a hook, not a skill instruction.

**Learning:** Agents should do autonomous work, not just provide advice. If an agent only gives guidance without using tools meaningfully, it should be a skill instead. Good agents: read files, run commands, fetch web content, produce artifacts. Bad agents: "strategic advisor" (just advice), "code mentor" (persona without action).

**Learning:** Thinking frameworks (like first-principles prompts) work better as skills than agents because they need to integrate into the user's ongoing conversation as LENSES for thinking, not produce a separate one-shot report. Structured workflows with distinct intake→analysis→output phases work better as agents.

**Learning:** Skills must stay under 500 lines. When approaching this limit, extract verbose templates (>15 lines) to a `resources/` subdirectory and reference as "See resources/filename.md".

**Learning:** Agents must stay under 300 lines. Agents need detailed instructions for autonomous work, but overly long files cause rules to be ignored. Extract reference material, detailed examples, and edge case handling to resources files.

**Learning:** Skill content must be copy-paste ready. Include: specific email copy, exact question scripts, {{variable}} placeholders. Exclude: "Why it works" explanations, ASCII diagrams, generic frameworks, "best practices" prose. Test: Could someone use this template immediately without reading explanations?

**Learning:** When adding to existing skills, prefer lean additions. Add 3 concrete examples instead of 30 lines of framework. If the addition requires explanation to be useful, it's probably generic advice Claude already knows.

**Learning:** Use existing specialized tools instead of bash workarounds. For config access, use `config-reader` agent - never grep `.agents.yml`. For file searches, use Glob tool - don't write multi-line ls/find commands.

**Learning:** Keep instructions concise - Claude knows how to search. Say "search for design-system.md" not "check docs/, docs/design/, and root with ls commands". Over-specified bash snippets waste tokens and add no value.

**Learning:** All `.agents.yml` access in commands/agents should go through `config-reader` agent. Never document grep patterns for config reading - it bypasses local overrides and is inconsistent with the config system.

**Learning:** When creating a new skill, run `skill-linter` to validate it against the agentskills.io specification before committing. Key requirements: names must start with a letter (not a digit), use kebab-case, match the directory name, and stay under 500 lines.

**Learning:** DevOps/infrastructure code should default to SIMPLE, flat structures. For Ansible: single playbook with inline tasks (~200 lines), use Galaxy roles (geerlingguy.*) instead of custom roles. For Terraform/OpenTofu: flat .tf files in one directory, no custom modules for <5 resources. Only add complexity (multiple playbooks, custom roles, nested modules, environment directories) when explicitly requested or truly justified by scale.
