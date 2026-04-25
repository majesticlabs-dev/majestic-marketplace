# Naming Conventions

This document defines naming conventions for agents, skills, and commands in the Majestic Marketplace.

## Agent Naming

Agents use simple, descriptive names without prefixes. Claude Code automatically namespaces them with plugin name and directory path.

| Aspect | Pattern |
|--------|---------|
| **Name format** | Simple kebab-case in `name:` field |
| **Examples** | `gem-research`, `web-research`, `rails-code-review` |
| **Implementation** | Add `name: agent-name` to agent frontmatter (no prefix) |
| **Directory structure** | Keep subdirectories (`agents/research/gem-research.md`) |
| **Display** | Claude Code shows as `plugin-name:directory:agent-name` |
| **Invocation** | Use simple name: `agent gem-research` |

**Why no prefix?**
- Claude Code automatically namespaces with plugin name + directory path
- Prevents collisions across plugins
- Simpler invocation and shorter names

## Skill Naming

Skills use simple, descriptive names without prefixes. Claude Code automatically namespaces them.

| Aspect | Pattern |
|--------|---------|
| **Name format** | Simple kebab-case in `name:` field |
| **Examples** | `ruby-coder`, `frontend-design`, `bofu-keywords` |
| **Invocation** | Claude Code namespaces as `plugin-name:skill-name` |
| **Actual usage** | `majestic-rails:ruby-coder`, `majestic-engineer:frontend-design` |

**Why different from agents?**
- Skills use the `Skill` tool with automatic namespacing by Claude Code
- Plugin namespace provides important context (e.g., `majestic-rails:ruby-coder` clearly indicates Rails-specific skill)
- No collision risk due to automatic plugin-level namespacing
- Consistency with broader Claude Code plugin ecosystem

**Implementation:**
- Set `name: skill-name` in SKILL.md frontmatter (no prefix, no namespace)
- Keep directory structure as `plugins/{plugin-name}/skills/{skill-name}/SKILL.md`
- Claude Code handles the namespacing automatically

## Command Naming

Bare names by default. Prefix only when the bare name loses meaning.

### Default: Bare Names

| Aspect | Pattern |
|--------|---------|
| **Pattern** | `name: command-name` (no prefix) |
| **Examples** | `/commit`, `/handoff`, `/migrate`, `/upgrade`, `/triage-prs`, `/expert-panel` |
| **When to use** | Self-descriptive verb commands — name communicates what it does |
| **Invocation** | `/<command-name>` |

### Exception: Workflow-Starter Prefix

Commands that open a workflow or create a new artifact need context — bare name alone is meaningless.

| Aspect | Pattern |
|--------|---------|
| **Pattern** | `name: <plugin-or-group>:<command>` |
| **Examples** | `/majestic-founder:start`, `/majestic-company:start`, `/tasks:new`, `/style-guide:new` |
| **When to use** | Entry-point routers (`start`) or generic verbs (`new`) where context is needed |
| **Prefix choice** | Use plugin name for top-level entry points; use group name for subdirectory commands |

### Rules

1. Default to bare names — choose self-descriptive verbs
2. Add prefix only when bare would collide OR lose meaning (e.g., `/start`, `/new`)
3. Never use full plugin prefix on top of a group prefix (e.g., `majestic-engineer:git:commit` — pick one)
4. Every `name:` field must match one of these two patterns; no `majestic:*` legacy prefixes

## Skill Subdirectories

Skills use three subdirectory types based on content (agentskills.io spec):

| Directory | Content | Examples |
|-----------|---------|----------|
| `references/` | Documentation, templates, guides (`.md`) | `references/patterns.md`, `references/template.md` |
| `assets/` | Data files, configs (`.yaml`, `.yml`, `.json`, `.txt`) | `assets/config.yaml`, `assets/word-library.txt` |
| `scripts/` | Executable tools (`.py`, `.ts`, `.sh`) | `scripts/validate.sh`, `scripts/agent.py` |

**Always use markdown link format for references:**

```markdown
See [references/patterns.md](references/patterns.md) for detailed examples.
Read [references/template.md](references/template.md) before implementing.
```

**Exception: Tables displaying file paths as data are acceptable with backticks:**

```markdown
| Template | File |
|----------|------|
| Rails    | `assets/rails.yaml` |
| Python   | `assets/python.yaml` |
```

### Scripts (Executable Tools)

**Use `{baseDir}` template variable for script paths:**

```markdown
bash {baseDir}/scripts/script_name.sh [arguments]
```

| Aspect | Pattern |
|--------|---------|
| **Format** | `bash {baseDir}/scripts/script_name.sh [args]` |
| **Location** | `skills/{skill-name}/scripts/` |
| **Template variable** | `{baseDir}` is replaced at runtime with skill's actual path |
| **Script requirements** | Must be executable, include shebang, handle arguments |

### Agent & Command Resources

For agents and commands, resources go in dedicated subdirectories:

| Component | Resource Location |
|-----------|------------------|
| Skills | `skills/{skill-name}/references/`, `assets/`, `scripts/` |
| Agents | `agents/**/resources/{agent-name}/` |
| Commands | `commands/**/resources/{command-name}/` |

Reference pattern is the same: use relative markdown links from the markdown file
