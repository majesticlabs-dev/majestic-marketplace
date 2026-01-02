# Majestic Marketplace

Claude Code plugin marketplace. **Work in `plugins/*/` only.**

## ⛔ FORBIDDEN

NEVER modify `~/.claude/`. All plugin work goes in `majestic-marketplace/plugins/`.

## Structure

```
plugins/{engineer,rails,python,react,marketing,sales,company,llm,tools,agent-sdk,devops,experts}/
```

## Dependencies

| Plugin | Can Reference |
|--------|--------------|
| `engineer` | rails, python, react, llm, tools |
| `rails`, `python`, `react` | engineer |
| `marketing`, `sales`, `company`, `llm`, `tools`, `agent-sdk`, `devops`, `experts` | (none) |

## Documentation

- [Naming](docs/plugin-architecture/NAMING-CONVENTIONS.md)
- [Operations](docs/plugin-architecture/PLUGIN-OPERATIONS.md)
- [Schemas](docs/plugin-architecture/JSON-SCHEMAS.md)
- [Config](docs/plugin-architecture/CONFIG-SYSTEM.md)

## Config Access

```
!`claude -p "/majestic:config field default"`
```

## Key Rules

### Limits
- Skills: <500 lines
- Agents: <300 lines

### File Locations
- Skill resources → `skills/*/resources/`
- Agent resources → `agents/**/resources/{agent-name}/`
- Command resources → `commands/**/resources/{command-name}/`
- Resources referenced via relative paths from the markdown file
- No .md files in `commands/` (they become executable)

### Behaviors
- Skills = knowledge (Claude MAY follow)
- Hooks = enforcement (FORCES behavior)
- Agents do autonomous work, not just advice
- `name:` in frontmatter overrides path-based naming

### Validation
Run `skill-linter` for new skills.

### Content Rules
- Skills must contain NEW info Claude doesn't know
- Exclude: generic advice, personas, "best practices" prose
- Include: concrete limits, project-specific patterns, exact templates
- **Skills are LLM instructions, not human documentation**
  - ❌ Attribution ("using X's framework") - LLM can't retrieve by author name
  - ❌ Source credits - no functional value for execution
  - ❌ Decorative quotes - human aesthetic, wastes tokens
  - ✅ Every line must help the LLM execute better
  - Ask: "Does this sentence improve LLM behavior?" If no, cut it.

### Anti-Patterns
- ❌ Do NOT hardcode language/framework-specific agents in generic orchestrators
  - Bad: Putting "majestic-rails:auth-researcher" directly in blueprint.md
  - Good: Use toolbox-resolver to discover stack-specific capabilities dynamically
  - Reason: Multi-stack projects need flexible composition, not hard dependencies

### Multi-Stack Projects
- `tech_stack` in .agents.yml can be string or array
- Example: `tech_stack: [rails, react]` is valid
- Toolbox configs must support merging capabilities from multiple stacks
- toolbox-resolver unions configs, not picks one stack

### Version Bumping (Schema Changes)
When modifying .agents.yml schema or adding config dependencies:
- Bump `plugins/majestic-engineer/skills/init-agents-config/CONFIG_VERSION`
- Update `docs/plugin-architecture/CONFIG-SYSTEM.md` version history
- Bump plugin version in `.claude-plugin/plugin.json` for affected plugins
- Update `.claude-plugin/marketplace.json` entries
- All version bumps committed together with schema changes

### Checkpoint Before Major Refactors
When discovering incorrect patterns that require moving/restructuring files:
1. Clarify the correct approach (present options)
2. Wait for user confirmation before refactoring
3. Don't assume path patterns - verify with user or docs

## Plugin Release Checklist

1. Update version in `plugins/*/.claude-plugin/plugin.json`
2. Add/update entry in `.claude-plugin/marketplace.json`:
   - Version number
   - Description (reflect skills/commands count)
   - Tags
   - Source path
3. Update internal references to new plugin namespace
4. Commit registry + plugin files together
