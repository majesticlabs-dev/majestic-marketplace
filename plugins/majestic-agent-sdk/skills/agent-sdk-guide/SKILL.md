---
name: agent-sdk-guide
description: Guide for Claude Agent SDK - build custom AI agents powered by Claude. Triggers on agent sdk, claude-agent-sdk, @anthropic-ai/claude-agent, build agent, programmatic agent, embed claude, custom ai agent, agent infrastructure. Covers installation, authentication providers, tool permissions, file-based configuration, and TypeScript/Python code examples.
---

# Claude Agent SDK Guide

## Overview

The Claude Agent SDK enables developers to build custom AI agents powered by Claude. It's the same agent infrastructure that powers Claude Code, now available for embedding in your own applications.

**Key Value:**
- Build autonomous agents that perform complex, multi-step tasks
- Same battle-tested infrastructure as Claude Code
- Production-ready with built-in error handling and monitoring

## Installation

### TypeScript

```bash
npm install @anthropic-ai/claude-agent-sdk
```

### Python

```bash
pip install claude-agent-sdk
```

## Core Features

### Context Management

Automatic compaction ensures your agent doesn't run out of context during extended operations. The SDK handles token management transparently.

### Tool Ecosystem

Built-in capabilities include:
- **File operations** - Read, write, edit files
- **Code execution** - Run bash commands safely
- **Web search** - Access real-time information
- **MCP extensibility** - Add custom tools via Model Context Protocol

### Permission Controls

Fine-grained control over agent capabilities:

```typescript
{
  allowedTools: ['Read', 'Write', 'Bash'],  // Explicit allowlist
  disallowedTools: ['WebSearch'],            // Explicit blocklist
  permissionMode: 'default' | 'strict'       // Overall strategy
}
```

### Production Features

- Built-in error handling and retries
- Session management for long-running agents
- Monitoring and observability hooks
- Automatic prompt caching for performance

## Authentication Providers

### Anthropic API (Default)

```bash
export ANTHROPIC_API_KEY=sk-ant-...
```

Get your key from [console.anthropic.com](https://console.anthropic.com)

### Amazon Bedrock

```bash
export CLAUDE_CODE_USE_BEDROCK=1
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
export AWS_REGION=us-east-1
```

### Google Vertex AI

```bash
export CLAUDE_CODE_USE_VERTEX=1
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/credentials.json
export VERTEX_REGION=us-central1
export VERTEX_PROJECT_ID=your-project
```

### Microsoft Foundry

```bash
export CLAUDE_CODE_USE_FOUNDRY=1
# Azure credentials configuration
```

## File-Based Configuration

Agents can leverage Claude Code's file-based architecture for extensibility:

| Directory | Purpose |
|-----------|---------|
| `.claude/agents/` | Subagent definitions (Markdown) |
| `.claude/skills/` | Skill files (`SKILL.md`) |
| `.claude/commands/` | Slash commands (Markdown) |
| `.claude/settings.json` | Hooks configuration |
| `CLAUDE.md` | Project memory/context |

**Important:** To use project settings, explicitly enable with:

```typescript
{
  settingSources: ['project']
}
```

## Code Examples

### TypeScript: Basic Agent

```typescript
import { Agent } from '@anthropic-ai/claude-agent-sdk';

const agent = new Agent({
  model: 'claude-sonnet-4-20250514',
  allowedTools: ['Read', 'Write', 'Bash'],
  systemPrompt: `You are a code review assistant.
    Analyze code for bugs, security issues, and best practices.`,
});

const result = await agent.run({
  prompt: 'Review the code in src/auth.ts for security issues',
});

console.log(result.output);
```

### TypeScript: Agent with MCP Tools

```typescript
import { Agent } from '@anthropic-ai/claude-agent-sdk';

const agent = new Agent({
  model: 'claude-sonnet-4-20250514',
  mcpServers: {
    database: {
      command: 'npx',
      args: ['-y', '@modelcontextprotocol/server-postgres'],
      env: { DATABASE_URL: process.env.DATABASE_URL },
    },
  },
});

const result = await agent.run({
  prompt: 'List all users who signed up in the last 24 hours',
});
```

### Python: Basic Agent

```python
from claude_agent_sdk import Agent

agent = Agent(
    model="claude-sonnet-4-20250514",
    allowed_tools=["Read", "Write", "Bash"],
    system_prompt="""You are a code review assistant.
    Analyze code for bugs, security issues, and best practices.""",
)

result = agent.run(
    prompt="Review the code in src/auth.py for security issues"
)

print(result.output)
```

### Python: Agent with Custom Permissions

```python
from claude_agent_sdk import Agent, PermissionMode

agent = Agent(
    model="claude-sonnet-4-20250514",
    permission_mode=PermissionMode.STRICT,
    allowed_tools=["Read", "Grep", "Glob"],
    disallowed_tools=["Bash"],  # Extra safety
)

result = agent.run(
    prompt="Find all TODO comments in the codebase"
)
```

## Agent Types & Use Cases

### Coding Agents

- **SRE Diagnostics** - Analyze logs, identify issues, suggest fixes
- **Security Auditing** - Scan for vulnerabilities, check dependencies
- **Incident Triage** - Correlate alerts, gather context, draft runbooks
- **Code Review** - Enforce standards, catch bugs, suggest improvements

### Business Agents

- **Legal Review** - Analyze contracts, flag risks, summarize terms
- **Financial Analysis** - Process reports, identify anomalies, forecast
- **Customer Support** - Handle tickets, route issues, draft responses
- **Content Creation** - Generate docs, edit copy, ensure consistency

## Best Practices

### Start Simple

Begin with minimal tool access and expand as needed:

```typescript
// Start here
allowedTools: ['Read']

// Then add as required
allowedTools: ['Read', 'Grep', 'Glob']

// Only if truly needed
allowedTools: ['Read', 'Write', 'Bash']
```

### Use Subagents for Complex Tasks

Break large tasks into specialized subagents:

```
.claude/agents/
├── code-reviewer.md      # Reviews code changes
├── test-writer.md        # Generates tests
└── doc-generator.md      # Creates documentation
```

### Handle Errors Gracefully

```typescript
try {
  const result = await agent.run({ prompt });
  if (result.error) {
    console.error('Agent error:', result.error);
    // Implement retry or fallback logic
  }
} catch (error) {
  console.error('SDK error:', error);
  // Handle network/auth issues
}
```

### Monitor Agent Behavior

```typescript
const agent = new Agent({
  // ... config
  onToolUse: (tool, input) => {
    console.log(`Tool: ${tool}, Input: ${JSON.stringify(input)}`);
  },
  onThinking: (thought) => {
    console.log(`Thinking: ${thought}`);
  },
});
```

## Resources

### GitHub Repositories

- **TypeScript**: [anthropics/claude-agent-sdk-typescript](https://github.com/anthropics/claude-agent-sdk-typescript)
- **Python**: [anthropics/claude-agent-sdk-python](https://github.com/anthropics/claude-agent-sdk-python)

### Documentation

- **Overview**: [platform.claude.com/docs/en/agent-sdk/overview](https://platform.claude.com/docs/en/agent-sdk/overview)

### Issue Reporting

- TypeScript: [GitHub Issues](https://github.com/anthropics/claude-agent-sdk-typescript/issues)
- Python: [GitHub Issues](https://github.com/anthropics/claude-agent-sdk-python/issues)

### Changelogs

- [TypeScript Changelog](https://github.com/anthropics/claude-agent-sdk-typescript/blob/main/CHANGELOG.md)
- [Python Changelog](https://github.com/anthropics/claude-agent-sdk-python/blob/main/CHANGELOG.md)

## Related Skills

- Use `/agent-sdk:agent-scaffold` to generate a new Agent SDK project
- See `new-skill` for creating skills your agent can use
- See `new-agent` for creating subagent definitions
