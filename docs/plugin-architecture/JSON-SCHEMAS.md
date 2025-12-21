# JSON Schemas

This document defines the JSON schemas for marketplace.json and plugin.json files.

## Marketplace.json Structure

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
      "author": { "name": "Author Name", "url": "https://..." },
      "homepage": "https://...",
      "tags": ["tag1", "tag2"],
      "source": "./plugins/plugin-name"
    }
  ]
}
```

### Allowed Fields

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Unique marketplace identifier |
| `owner.name` | Yes | Organization or individual name |
| `owner.url` | Yes | Owner's website or GitHub URL |
| `metadata.description` | Yes | Brief marketplace description |
| `metadata.version` | Yes | Marketplace version (semver) |
| `plugins[]` | Yes | Array of plugin definitions |

### Plugin Entry Fields

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Unique plugin identifier |
| `description` | Yes | Brief plugin description with component counts |
| `version` | Yes | Plugin version (semver) |
| `author` | Yes | Author object with `name` and `url` |
| `homepage` | No | Plugin documentation URL |
| `tags` | No | Discovery keywords |
| `source` | Yes | Relative path to plugin directory |

### Forbidden Fields

**Do not add custom fields.** These are not in the official spec:

- `downloads`, `stars`, `rating` (display-only metrics)
- `categories`, `featured_plugins`, `trending` (UI features)
- `type`, `verified`, `featured` (badges/flags)

## Plugin.json Structure

Each plugin has its own plugin.json with detailed metadata:

```json
{
  "name": "plugin-name",
  "version": "1.0.0",
  "description": "Plugin description",
  "author": {
    "name": "Author Name",
    "url": "https://..."
  },
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

### Top-Level Fields

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Plugin identifier (matches directory name) |
| `version` | Yes | Plugin version (semver) |
| `description` | Yes | Brief description with component counts |
| `author` | Yes | Author object with `name` and `url` |
| `keywords` | No | Discovery keywords for search |
| `components` | Yes | Count of agents, commands, hooks |
| `agents` | No | Detailed agent definitions by category |
| `commands` | No | Command names by category |

### Components Object

```json
{
  "components": {
    "agents": 15,
    "commands": 6,
    "hooks": 2
  }
}
```

These counts must match the actual number of files in the plugin.

### Agent Definitions

Agents are grouped by category:

```json
{
  "agents": {
    "review": [
      {
        "name": "pragmatic-rails-reviewer",
        "description": "Reviews Rails code for conventions",
        "use_cases": ["code review", "PR feedback"]
      }
    ],
    "research": [
      {
        "name": "gem-research",
        "description": "Research Ruby gems before adding",
        "use_cases": ["dependency decisions", "security review"]
      }
    ]
  }
}
```

### Validation

Before committing, validate JSON files:

```bash
cat .claude-plugin/marketplace.json | jq .
cat plugins/{plugin-name}/.claude-plugin/plugin.json | jq .
```

A successful validation outputs formatted JSON. An error indicates invalid syntax.
