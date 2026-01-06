---
name: init-agents-config
description: Generate .agents.yml config from user answers. Provides tech stack templates for Rails, Python, Node, and Generic projects.
allowed-tools: Read, Write
---

# Init Agents Config

Assemble `.agents.yml` from collected user answers during `/majestic:init`.

## Resources

| Resource | Purpose |
|----------|---------|
| `CONFIG_VERSION` | Current .agents.yml schema version |
| `resources/rails.yaml` | Rails config template |
| `resources/python.yaml` | Python config template |
| `resources/node.yaml` | Node config template |
| `resources/generic.yaml` | Generic config template |
| `resources/agents-md-template.md` | AGENTS.md best practices |
| `resources/local-config-template.yaml` | Local overrides template |

## Template Selection by Tech Stack

| Tech Stack | Template |
|------------|----------|
| Rails | `resources/rails.yaml` |
| Python | `resources/python.yaml` |
| Node | `resources/node.yaml` |
| Generic | `resources/generic.yaml` |

## Assembly Instructions

1. Read the appropriate template based on detected `tech_stack`
2. Replace placeholders with collected answers:
   - `{{config_version}}` - Read from `CONFIG_VERSION` file
   - `{{default_branch}}` - From git detection or user answer
   - `{{owner_level}}` - beginner, intermediate, senior, expert
   - `{{task_management}}` - github, linear, beads, file, none
   - Stack-specific fields from user answers
3. Conditionally include/exclude sections:
   - Remove `extras:` section if no Solid gems selected (Rails)
   - Remove `toolbox.build_task.design_system_path` if no design system detected
   - Comment out `browser:` section unless user selected non-Chrome browser
4. Write to `.agents.yml`

## Conditional Sections

### Quality Gate Reviewers
Each stack has default reviewers. Include optional reviewers only if user enables them:
- `dhh-code-reviewer` - Rails strict style
- `data-integrity-reviewer` - Migration safety
- `codex-reviewer` / `gemini-reviewer` - External LLM

### Browser Config
Default is commented out (uses Chrome). Uncomment only if user selects Brave or Edge.

### Extras (Rails only)
Include only Solid gems the user selected:
- `solid_cache`
- `solid_queue`
- `solid_cable`

## Output

Write generated config to `.agents.yml` in project root.
