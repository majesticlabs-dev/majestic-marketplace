---
name: majestic:init
description: Initialize AGENTS.md with hierarchical structure and .agents.yml config
allowed-tools:
  - Bash(${CLAUDE_PLUGIN_ROOT}/commands/workflows/init/*)
  - Bash(ln -s *)
  - Bash(mv *)
  - Write
  - Read
  - Grep
  - Glob
  - AskUserQuestion
  - Skill
---

# Initialize AGENTS.md

Set up AI agent documentation and machine-readable config for this project.

**Architecture:** AGENTS.md (human guidance) + .agents.yml (machine config) + CLAUDE.md (symlink)

## Step 1: Generate AGENTS.md

Check existing state first:

```!
"${CLAUDE_PLUGIN_ROOT}/commands/workflows/init/check-existing.sh"
```

**If AGENTS.md exists**, ask: Regenerate | Enhance | Skip

Then invoke the hierarchical agents skill:

```
Skill(skill: "hierarchical-agents")
```

Complete all 4 phases: Repository Analysis → Root AGENTS.md → Sub-folder files → Special Considerations

For AGENTS.md best practices, see `resources/agents-md-template.md` in the init-agents-config skill.

## Step 2: Gather Configuration

Use `AskUserQuestion` to gather config. Ask in batches of max 4 questions.

### Core Questions (All Users)

| Question | Options |
|----------|---------|
| Tech Stack | Rails, Python, Node, Generic |
| App Status | Development, Production |
| Task Management | GitHub Issues, Linear, Beads, File-based |
| Workflow | Worktrees, Branches |

### Owner Context

Capture experience level to tailor skill outputs (explanations, assumed knowledge).

**Single-stack projects:**

| Question | Options |
|----------|---------|
| Experience Level | Beginner, Intermediate, Senior, Expert |

**Multi-stack projects** (e.g., Rails + React detected):

Ask per-stack:
| Question | Options |
|----------|---------|
| Rails Experience | Beginner, Intermediate, Senior, Expert |
| React Experience | Beginner, Intermediate, Senior, Expert |

**Level definitions:**
- **Beginner**: New to the technology, needs detailed explanations
- **Intermediate**: Comfortable with basics, learning advanced patterns
- **Senior**: Deep knowledge, focus on edge cases and best practices
- **Expert**: Authoritative, skip explanations, just show the code

### Stack-Specific Questions

**Rails** (auto-detect ruby/rails versions first):

| Question | Options |
|----------|---------|
| Database | SQLite, PostgreSQL, MySQL |
| Frontend | Hotwire, Inertia, API-only |
| CSS | Tailwind, Bootstrap, None |
| JavaScript | Importmap, esbuild, Vite |
| Deployment (multi) | Kamal, Fly.io, Heroku, Render |
| Solid Gems (multi) | Solid Cache, Solid Queue, Solid Cable |

**Python** (auto-detect python version, framework):

| Question | Options |
|----------|---------|
| Framework | FastAPI, Django, Flask, None |
| Package Manager | uv, Poetry, pip |
| Database | PostgreSQL, SQLite, None |

**Node** (auto-detect node version, typescript, framework):

| Question | Options |
|----------|---------|
| Framework | Next.js, React, Vue/Nuxt, Express/Fastify |
| Package Manager | pnpm, npm, yarn, bun |
| TypeScript | Yes, No |
| Styling | Tailwind, CSS Modules, Styled Components, Sass |
| Testing | Vitest, Jest, Playwright, Cypress |
| Deployment | Vercel, Cloudflare, Netlify, Railway |

### Final Questions (All Users)

| Question | Options |
|----------|---------|
| Branch Naming | feature/desc, issue-desc, type/issue-desc, user/desc |
| Review Topics | Default (docs/agents/review-topics.md), Skip |
| Track in Git | Yes (shared), No (local-only) |
| Local Overrides | Yes (if tracked), No |
| Browser | Chrome, Brave, Edge, Skip |

## Step 3: Auto-Detect Values

**Run these operations in parallel:**

```!
"${CLAUDE_PLUGIN_ROOT}/commands/workflows/init/detect-branch.sh"
```

```!
"${CLAUDE_PLUGIN_ROOT}/commands/workflows/init/detect-tech-stack.sh" stack
```

```
Glob: "**/design-system.md"                  # Design system file
```

If design system found, record path in toolbox config.

## Step 4: Write .agents.yml

Load the init-agents-config skill:

```
Skill(skill: "init-agents-config")
```

Select template by tech_stack from `resources/`:
- `rails.yaml` | `python.yaml` | `node.yaml` | `generic.yaml`

Replace placeholders with collected values. Handle conditionals:
- Only include `review_topics_path` if user selected Default
- Only include `extras` if user selected Solid gems
- Only include `toolbox.build_task.design_system_path` if detected
- Only uncomment `browser.type` if Brave or Edge selected

### Gitignore + Local Config

```!
"${CLAUDE_PLUGIN_ROOT}/commands/workflows/init/gitignore-add.sh" .claude/current_task.txt
```

If not tracking in git:
```!
"${CLAUDE_PLUGIN_ROOT}/commands/workflows/init/gitignore-add.sh" .agents.yml
```

If local overrides requested:
```!
"${CLAUDE_PLUGIN_ROOT}/commands/workflows/init/gitignore-add.sh" .agents.local.yml
```

If local overrides requested, write `.agents.local.yml` using template from `resources/local-config-template.yaml`.

## Step 5: Finalize Setup

1. **Create review-topics.md** - If selected, create `docs/agents/review-topics.md` with starter template
2. **Create symlink** - `ln -s AGENTS.md CLAUDE.md` (backup if exists)
3. **Verify** - Run verification:

```!
"${CLAUDE_PLUGIN_ROOT}/commands/workflows/init/verify-setup.sh"
```

## Output Summary

Report what was created:
- AGENTS.md structure (line count, sub-folders)
- .agents.yml (key settings)
- Design system status (detected path or suggest /majestic:ux-brief)
- Symlink and local config status
