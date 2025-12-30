# Majestic Marketplace

Claude Code plugin marketplace. **Work in `plugins/*/` only.**

## ⛔ FORBIDDEN

NEVER modify `~/.claude/`. All plugin work goes in `majestic-marketplace/plugins/`.

## Structure

```
plugins/{engineer,rails,python,marketing,sales,company,llm,tools}/
```

## Dependencies

| Plugin | Can Reference |
|--------|--------------|
| `engineer` | rails, python, react, llm, tools |
| `rails`, `python`, `react` | engineer |
| `marketing`, `sales`, `company`, `llm`, `tools` | (none) |

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

<limits>
- Skills: <500 lines
- Agents: <300 lines
</limits>

<file-locations>
- Skill resources → `skills/*/resources/`
- No .md files in `commands/` (they become executable)
</file-locations>

<behaviors>
- Skills = knowledge (Claude MAY follow)
- Hooks = enforcement (FORCES behavior)
- Agents do autonomous work, not just advice
- `name:` in frontmatter overrides path-based naming
</behaviors>

<validation>
Run `skill-linter` for new skills.
</validation>

<content-rules>
- Skills must contain NEW info Claude doesn't know
- Exclude: generic advice, personas, "best practices" prose
- Include: concrete limits, project-specific patterns, exact templates
</content-rules>

<plugin-release>
## Plugin Release Checklist
1. Update version in `plugins/*/.claude-plugin/plugin.json`
2. Add/update entry in `.claude-plugin/marketplace.json`:
   - Version number
   - Description (reflect skills/commands count)
   - Tags
   - Source path
3. Update internal references to new plugin namespace
4. Commit registry + plugin files together
</plugin-release>
