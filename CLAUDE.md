# Majestic Marketplace - Claude Code Plugin Marketplace

This repository is a Claude Code plugin marketplace that distributes the `majestic` plugins to build with AI-powered tools.

## Repository Structure

```
majestic-marketplace/
├── .claude-plugin/
│   └── marketplace.json          # Marketplace catalog (lists available plugins)
└── plugins/
    ├── majestic-engineer/        # Language-agnostic engineering workflows
    │   ├── .claude-plugin/
    │   │   └── plugin.json
    │   ├── agents/               # 5 agents
    │   ├── commands/             # 18 commands
    │   ├── skills/               # 4 skills
    │   └── README.md
    ├── majestic-rails/           # Ruby/Rails development tools
    │   ├── .claude-plugin/
    │   │   └── plugin.json
    │   ├── agents/               # 2 agents
    │   ├── skills/               # 4 skills
    │   └── README.md
    └── majestic-tools/           # Claude Code customization tools
        ├── .claude-plugin/
        │   └── plugin.json
        ├── agents/               # 2 agents
        ├── commands/             # 12 commands
        ├── output-styles/        # 8 output format guides
        └── README.md
```

## Architecture Principles

- DRY: don't repeat yourself
- YAGNI: you aren't gonna need it
- KISS: keep it simple, stupid
- Separation of concerns

## Rules for This Repository

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

## Key Learnings

_This section captures important learnings as we work on this repository._

**Learning:** Stick to the official spec. Custom fields may confuse users or break compatibility with future versions.

**Learning:** When updating files to add new patterns or tools, always preserve existing content. Don't simplify or remove example formats, question templates, or detailed instructions. Add the new pattern alongside existing content, not as a replacement.

**Learning:** Interactive skills (those with "Conversation Starter" or "Begin by asking:" patterns) should include `AskUserQuestion` in their `allowed-tools:` frontmatter and use the format: "Use `AskUserQuestion` to gather initial context. Begin by asking:"

**Learning:** Mermaid diagrams use different node shapes to distinguish component types: `()` creates stadium/rounded nodes for commands, `{{}}` creates hexagons for agents, and `[]` creates rectangles for manual actions or external steps.
