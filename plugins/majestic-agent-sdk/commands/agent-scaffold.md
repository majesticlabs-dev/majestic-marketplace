---
name: agent-sdk:agent-scaffold
description: Scaffold a new Claude Agent SDK project with interactive configuration
allowed-tools: Read, Write, Edit, AskUserQuestion, Bash, Skill
argument-hint: "[project-name]"
disable-model-invocation: true
---

# Agent SDK Project Scaffold

Generate a complete Claude Agent SDK project with interactive configuration.

## Arguments

- `[project-name]` - Name of project directory (optional, will ask if not provided)

---

## Phase 1: Gather Requirements

Use `AskUserQuestion` to collect configuration.

### Question Set 1: Basics

```
Question 1: "Which language?"
- TypeScript: "Modern TypeScript with full type safety"
- Python: "Python 3.12+ with uv package manager"

Question 2: "What type of agent?"
- Coding Agent: "Code review, refactoring, testing"
- Business Agent: "Legal, financial, content"
- Custom: "Describe your agent's purpose"
```

### Question Set 2: Capabilities

```
Question 3: "Which tools?" (multiSelect: true)
- File Operations: "Read, Write, Edit files"
- Code Execution: "Run bash commands"
- Web Search: "Search the web"
- MCP Tools: "Extensible MCP tools"

Question 4: "Authentication provider?"
- Anthropic API: "Direct API key"
- Amazon Bedrock: "AWS-hosted Claude"
- Google Vertex AI: "GCP-hosted Claude"
```

### Question Set 3: Scope

```
Question 5: "Which Claude Code features?" (multiSelect: true)
- Subagents: "Specialized agents (.claude/agents/)"
- Skills: "Knowledge files (.claude/skills/)"
- Hooks: "Event triggers (.claude/settings.json)"
- Commands: "Slash commands (.claude/commands/)"

Question 6: "Scope?"
- Minimal: "Essentials only"
- Standard: "Above + README, .claude/ examples"
- Full: "Above + Dockerfile, GitHub Actions, tests"
```

---

## Phase 2: Generate Project

Invoke the agent-scaffold skill for templates:

```
Skill(skill="agent-scaffold")
```

Follow the skill's instructions to read templates from the resources directory:

### Directory Structure

```
{project-name}/
├── src/
│   └── agent.ts OR agent.py
├── package.json OR pyproject.toml
├── .env.example
├── .gitignore
│
│ # Standard scope:
├── README.md
├── .claude/
│   ├── agents/     (if Subagents selected)
│   ├── skills/     (if Skills selected)
│   ├── commands/   (if Commands selected)
│   └── settings.json (if Hooks selected)
│
│ # Full scope:
├── Dockerfile
├── .github/workflows/ci.yml
└── tests/
```

### Template Substitutions

Replace placeholders in templates:
- `{{project-name}}` → user's project name
- `{{tools_array}}` / `{{tools_list}}` → based on tool selections
- `{{system_prompt}}` → based on agent type

### Tool Mapping

| Selection | Tools |
|-----------|-------|
| File Operations | `Read`, `Write`, `Edit`, `Glob`, `Grep` |
| Code Execution | `Bash` |
| Web Search | `WebSearch`, `WebFetch` |

---

## Phase 3: Execute Generation

1. Create project directory: `mkdir -p {project-name}/src`
2. Write files using templates with substitutions
3. Copy appropriate .env.example based on auth provider
4. Add .claude/ structure if Standard/Full scope
5. Add Dockerfile, CI, tests if Full scope

---

## Phase 4: Next Steps

Present summary and offer options:

```
📁 {project-name}/
├── src/agent.{ext}
├── package.json / pyproject.toml
├── .env.example
└── [additional files]
```

Use AskUserQuestion:
- Initialize git: `git init && git add . && git commit -m "Initial commit"`
- Install deps: `npm install` or `uv sync`
- Open in editor: `code {project-name}`
- Done: Show getting started instructions
