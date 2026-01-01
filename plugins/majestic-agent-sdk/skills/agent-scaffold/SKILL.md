---
name: agent-scaffold
description: File templates for Claude Agent SDK project scaffolding. Used by /agent-sdk:agent-scaffold command.
---

# Agent Scaffold Skill

Provides file templates for generating Claude Agent SDK projects.

## When to Use

Automatically invoked by `/agent-sdk:agent-scaffold` command.

## Templates

### Core Files
- [resources/typescript/package.json](resources/typescript/package.json) - Node.js package config
- [resources/typescript/agent.ts](resources/typescript/agent.ts) - TypeScript agent entry point
- [resources/python/pyproject.toml](resources/python/pyproject.toml) - Python package config
- [resources/python/agent.py](resources/python/agent.py) - Python agent entry point

### Environment
- [resources/env-anthropic.example](resources/env-anthropic.example) - Anthropic API key config
- [resources/env-bedrock.example](resources/env-bedrock.example) - AWS Bedrock config
- [resources/env-vertex.example](resources/env-vertex.example) - Google Vertex AI config
- [resources/gitignore](resources/gitignore) - Standard gitignore

### Claude Code Files
- [resources/claude/example-subagent.md](resources/claude/example-subagent.md) - Subagent template
- [resources/claude/example-skill.md](resources/claude/example-skill.md) - Skill template
- [resources/claude/example-command.md](resources/claude/example-command.md) - Command template
- [resources/claude/settings.json](resources/claude/settings.json) - Hooks configuration

## Tool Mapping

| User Selection | SDK Tools |
|----------------|-----------|
| File Operations | Read, Write, Edit, Glob, Grep |
| Code Execution | Bash |
| Web Search | WebSearch, WebFetch |
| MCP Tools | (configured via mcpServers) |

## System Prompts

**Coding Agent:**
```
You are a coding assistant that helps developers write better code.
Analyze code for bugs, security issues, and best practices.
```

**Business Agent:**
```
You are a business analyst assistant.
Help with document analysis, data extraction, and report generation.
```
