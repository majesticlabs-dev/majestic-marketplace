# Plugin Operations

This document covers plugin lifecycle operations: adding new plugins, updating existing ones, and common maintenance tasks.

## Adding a New Plugin

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

## Updating the Plugin

When agents, commands, or skills are added/removed, follow this checklist:

### 1. Count all components accurately

```bash
# Count agents
ls plugins/{plugin-name}/agents/*.md | wc -l

# Count commands
ls plugins/{plugin-name}/commands/*.md | wc -l

# Count skills
ls -d plugins/{plugin-name}/skills/*/ 2>/dev/null | wc -l
```

### 2. Update ALL description strings with correct counts

The description appears in multiple places and must match everywhere:

- [ ] `plugins/{plugin-name}/.claude-plugin/plugin.json` → `description` field
- [ ] `.claude-plugin/marketplace.json` → plugin `description` field
- [ ] `plugins/{plugin-name}/README.md` → intro paragraph

Format: `"Includes X specialized agents, Y commands, and Z skill(s)."`

### 3. Update version numbers

When adding new functionality, bump the version in:

- [ ] `plugins/{plugin-name}/.claude-plugin/plugin.json` → `version`
- [ ] `.claude-plugin/marketplace.json` → plugin `version`

### 4. Update documentation

- [ ] `plugins/{plugin-name}/README.md` → list all components
- [ ] `plugins/{plugin-name}/CHANGELOG.md` → document changes
- [ ] `CLAUDE.md` → update structure diagram if needed

### 5. Validate JSON files

```bash
cat .claude-plugin/marketplace.json | jq .
cat plugins/{plugin-name}/.claude-plugin/plugin.json | jq .
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

## Wiki

The GitHub wiki is maintained in a **sibling repository**: `../majestic-marketplace.wiki/`

**To update the wiki:**
```bash
cd ../majestic-marketplace.wiki
# Edit files
git add -A && git commit -m "docs: ..." && git push
```
