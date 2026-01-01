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

Commands use a strategic three-tier naming system based on scope and purpose.

### Tier 1: Generic/Cross-Project Commands

Use `majestic:` prefix for workflows that work across all project types.

| Aspect | Pattern |
|--------|---------|
| **Pattern** | `name: majestic:command-name` |
| **Examples** | `/majestic:plan`, `/majestic:debug`, `/majestic:prd`, `/majestic:code-review` |
| **When to use** | Workflows that are language/framework-agnostic |
| **Location** | `plugins/majestic-engineer/commands/workflows/` |

### Tier 2: Framework-Specific Commands

Use framework prefix for workflows tied to specific technologies.

| Aspect | Pattern |
|--------|---------|
| **Pattern** | `name: framework:command-name` |
| **Examples** | `/rails:build` |
| **When to use** | Workflows specific to Rails, Python, etc. |
| **Location** | `plugins/majestic-{framework}/commands/workflows/` |

### Tier 3: Utility Commands

Omit `name:` field to use automatic path-based naming.

| Aspect | Pattern |
|--------|---------|
| **Pattern** | No `name:` field → auto-named as `/category:command-name` |
| **Examples** | `/git:commit`, `/gemfile:organize`, `/tasks:new` |
| **When to use** | Category-specific utilities (git operations, gemfile management, etc.) |
| **Location** | `plugins/*/commands/{category}/{command-name}.md` |
| **Result** | Invoked as `/{category}:{command-name}` |

### Why Three Tiers?

- Generic `majestic:` commands work everywhere and are easy to discover
- Framework prefixes provide context (e.g., `/rails:build` clearly indicates Rails workflow)
- Path-based naming organizes utilities by category without manual naming

### Implementation Rules

1. Only add `name:` field for tier 1 (majestic:) and tier 2 (framework:) commands
2. Omit `name:` field for tier 3 (utility) commands to use automatic naming
3. Never use full plugin prefix (e.g., `majestic-engineer:git:commit`) - inconsistent with convention

## Resource & Script References

Skills can include supporting files in `resources/` and `scripts/` subdirectories. Use these patterns for referencing them.

### Resources (Documentation, Templates, Examples)

**Always use markdown link format:**

```markdown
See [resources/patterns.md](resources/patterns.md) for detailed examples.
Read [resources/template.md](resources/template.md) before implementing.
```

| Aspect | Pattern |
|--------|---------|
| **Format** | `[resources/filename.md](resources/filename.md)` |
| **Location** | `skills/{skill-name}/resources/` |
| **Why links?** | Clickable in editors, GitHub preview, enables LSP navigation |

**Avoid backtick references in prose:**

```markdown
# ❌ WRONG - not clickable, harder to navigate
See `resources/patterns.md` for details.

# ✅ CORRECT - clickable, navigable
See [resources/patterns.md](resources/patterns.md) for details.
```

**Exception: Tables displaying file paths as data are acceptable with backticks:**

```markdown
# ✅ OK - table data showing file paths, not navigation instruction
| Template | File |
|----------|------|
| Rails    | `resources/rails.yaml` |
| Python   | `resources/python.yaml` |
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

**Example skill with scripts:**

```markdown
## Usage

Run the worktree manager:

\`\`\`bash
bash {baseDir}/scripts/worktree-manager.sh create feature-branch
bash {baseDir}/scripts/worktree-manager.sh list
bash {baseDir}/scripts/worktree-manager.sh cleanup --force
\`\`\`
```

### Agent & Command Resources

For agents and commands, resources go in dedicated subdirectories:

| Component | Resource Location |
|-----------|------------------|
| Skills | `skills/{skill-name}/resources/` |
| Agents | `agents/**/resources/{agent-name}/` |
| Commands | `commands/**/resources/{command-name}/` |

Reference pattern is the same: use relative markdown links from the markdown file
