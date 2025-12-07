---
name: majestic:agent-scaffold
description: Scaffold a new Claude Agent SDK project with interactive configuration
allowed-tools: Read, Write, Edit, AskUserQuestion, Bash
argument-hint: "[project-name]"
---

# Agent SDK Project Scaffold `/majestic:agent-scaffold`

Generate a complete Claude Agent SDK project with interactive configuration.

## Arguments

- `[project-name]` - Name of the project directory to create (optional, will ask if not provided)

## Example Usage

```bash
/majestic:agent-scaffold my-agent
/majestic:agent-scaffold
```

---

## Phase 1: Gather Requirements

Use `AskUserQuestion` to collect all configuration options upfront.

### Question Set 1: Basics

```
Question 1: "Which language do you want to use?"
Header: "Language"
Options:
- TypeScript: "Modern TypeScript with full type safety and npm ecosystem"
- Python: "Python 3.12+ with uv package manager and async support"

Question 2: "What type of agent are you building?"
Header: "Agent type"
Options:
- Coding Agent: "Code review, refactoring, testing, documentation"
- Business Agent: "Legal, financial, customer support, content"
- Custom: "Describe your agent's purpose (will prompt for description)"
```

If "Custom" is selected, ask follow-up:
```
"Describe what your agent will do:"
(Open-ended text input via "Other" option)
```

### Question Set 2: Capabilities

```
Question 3: "Which tools should your agent have access to?"
Header: "Tools"
multiSelect: true
Options:
- File Operations: "Read, Write, Edit files in the workspace"
- Code Execution: "Run bash commands and scripts"
- Web Search: "Search the web for information"
- MCP Tools: "Extensible tools via Model Context Protocol"

Question 4: "Which authentication provider will you use?"
Header: "Auth"
Options:
- Anthropic API: "Direct API key from console.anthropic.com"
- Amazon Bedrock: "AWS-hosted Claude with IAM authentication"
- Google Vertex AI: "GCP-hosted Claude with service account"
- Microsoft Foundry: "Azure-hosted Claude"
```

### Question Set 3: Features & Scope

```
Question 5: "Which Claude Code features do you want to include?"
Header: "Features"
multiSelect: true
Options:
- Subagents: "Specialized agents for subtasks (.claude/agents/)"
- Skills: "Knowledge/context files (.claude/skills/)"
- Hooks: "Event-triggered actions (.claude/settings.json)"
- Commands: "Custom slash commands (.claude/commands/)"

Question 6: "How comprehensive should the scaffold be?"
Header: "Scope"
Options:
- Minimal: "Just the essentials: main file, package config, .env.example"
- Standard: "Above + README, .claude/ structure with examples"
- Full: "Above + Dockerfile, GitHub Actions, test scaffold"
```

---

## Phase 2: Generate Project

Based on the collected answers, generate the project structure.

### Directory Structure

```
{project-name}/
├── src/
│   └── agent.ts OR agent.py       # Main agent file
├── package.json OR pyproject.toml  # Package configuration
├── .env.example                    # Environment template
├── .gitignore                      # Git ignore file
│
│ # Standard scope adds:
├── README.md                       # Getting started guide
├── .claude/                        # Claude Code configuration
│   ├── agents/                     # (if Subagents selected)
│   │   └── example-subagent.md
│   ├── skills/                     # (if Skills selected)
│   │   └── example-skill/
│   │       └── SKILL.md
│   ├── commands/                   # (if Commands selected)
│   │   └── example-command.md
│   └── settings.json               # (if Hooks selected)
│
│ # Full scope adds:
├── Dockerfile                      # Container configuration
├── .github/
│   └── workflows/
│       └── ci.yml                  # CI/CD pipeline
└── tests/
    └── agent.test.ts OR test_agent.py
```

### File Templates

#### TypeScript: package.json

```json
{
  "name": "{project-name}",
  "version": "0.1.0",
  "type": "module",
  "scripts": {
    "start": "tsx src/agent.ts",
    "build": "tsc",
    "test": "vitest"
  },
  "dependencies": {
    "@anthropic-ai/claude-agent-sdk": "^0.1.0"
  },
  "devDependencies": {
    "typescript": "^5.7.0",
    "tsx": "^4.19.0",
    "@types/node": "^22.0.0"
  }
}
```

#### TypeScript: src/agent.ts

```typescript
import { Agent } from '@anthropic-ai/claude-agent-sdk';

// Configure allowed tools based on user selection
const allowedTools = {tools_array};

const agent = new Agent({
  model: 'claude-sonnet-4-20250514',
  allowedTools,
  systemPrompt: `{system_prompt}`,
});

async function main() {
  const result = await agent.run({
    prompt: process.argv[2] || 'Hello, what can you help me with?',
  });

  console.log(result.output);
}

main().catch(console.error);
```

#### Python: pyproject.toml

```toml
[project]
name = "{project-name}"
version = "0.1.0"
requires-python = ">=3.12"
dependencies = [
    "claude-agent-sdk>=0.1.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=8.0.0",
    "pytest-asyncio>=0.24.0",
]

[tool.uv]
dev-dependencies = [
    "pytest>=8.0.0",
    "pytest-asyncio>=0.24.0",
]
```

#### Python: src/agent.py

```python
import sys
from claude_agent_sdk import Agent

# Configure allowed tools based on user selection
ALLOWED_TOOLS = {tools_list}

agent = Agent(
    model="claude-sonnet-4-20250514",
    allowed_tools=ALLOWED_TOOLS,
    system_prompt="""{system_prompt}""",
)


def main():
    prompt = sys.argv[1] if len(sys.argv) > 1 else "Hello, what can you help me with?"
    result = agent.run(prompt=prompt)
    print(result.output)


if __name__ == "__main__":
    main()
```

#### .env.example (varies by auth provider)

**Anthropic API:**
```bash
# Get your API key from https://console.anthropic.com
ANTHROPIC_API_KEY=sk-ant-...
```

**Amazon Bedrock:**
```bash
CLAUDE_CODE_USE_BEDROCK=1
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_REGION=us-east-1
```

**Google Vertex AI:**
```bash
CLAUDE_CODE_USE_VERTEX=1
GOOGLE_APPLICATION_CREDENTIALS=/path/to/credentials.json
VERTEX_REGION=us-central1
VERTEX_PROJECT_ID=your-project-id
```

**Microsoft Foundry:**
```bash
CLAUDE_CODE_USE_FOUNDRY=1
# Add Azure credentials
```

#### .gitignore

```gitignore
# Dependencies
node_modules/
.venv/
__pycache__/

# Environment
.env
.env.local

# Build
dist/
build/
*.pyc

# IDE
.vscode/
.idea/

# OS
.DS_Store
```

#### README.md (Standard/Full scope)

```markdown
# {project-name}

An AI agent powered by Claude Agent SDK.

## Setup

### Prerequisites

- {Language prerequisites}
- Anthropic API key (or cloud provider credentials)

### Installation

{Language-specific install commands}

### Configuration

1. Copy `.env.example` to `.env`
2. Add your API credentials
3. Customize `src/agent.{ext}` as needed

## Usage

{Language-specific run commands}

## Project Structure

- `src/agent.{ext}` - Main agent configuration and entry point
- `.claude/` - Claude Code configuration (subagents, skills, commands)
- `.env` - Environment variables (not committed)

## Customization

### Adding Tools

Modify the `allowedTools` array in `src/agent.{ext}`:

{Code example}

### Creating Subagents

Add markdown files to `.claude/agents/`:

{Example subagent}

## Resources

- [Claude Agent SDK Documentation](https://platform.claude.com/docs/en/agent-sdk/overview)
- [Claude Code Guide](https://docs.anthropic.com/en/docs/claude-code)
```

#### Example Subagent (.claude/agents/example-subagent.md)

```markdown
---
name: example-subagent
description: Example subagent for demonstration. Use when you need to delegate a specific task.
tools: Read, Grep, Glob
---

# Example Subagent

You are a specialized agent for [specific purpose].

## Instructions

1. Analyze the task provided
2. Use available tools to gather information
3. Provide a clear, structured response

## Best Practices

- Focus on your specific domain
- Ask clarifying questions if needed
- Provide actionable recommendations
```

#### Example Skill (.claude/skills/example-skill/SKILL.md)

```markdown
---
name: example-skill
description: Example skill that triggers on specific keywords. Modify triggers and content for your use case.
---

# Example Skill

## Purpose

This skill provides guidance for [specific topic].

## When to Use

Automatically activates when you mention:
- keyword1
- keyword2
- specific-topic

## Key Information

[Your skill content here]
```

#### Example Hook (.claude/settings.json)

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "type": "command",
        "command": "echo 'Processing prompt...'",
        "description": "Example hook that runs before processing"
      }
    ]
  }
}
```

#### Example Command (.claude/commands/example-command.md)

```markdown
---
description: Example command that demonstrates slash command structure
---

# Example Command

This command does [specific action].

## Arguments

- `[arg1]` - Description of first argument

## Instructions

1. Parse the arguments: $ARGUMENTS
2. Perform the action
3. Report results

## Example Usage

\`\`\`bash
/example-command arg1
\`\`\`
```

---

## Phase 3: Execute Generation

After collecting all answers:

1. **Create project directory**
   ```bash
   mkdir -p {project-name}/src
   ```

2. **Generate files based on language and scope**
   - Use Write tool for each file
   - Substitute placeholders with user's answers

3. **Generate .claude/ structure if Standard/Full scope**
   - Only include selected features (Subagents, Skills, Hooks, Commands)

4. **Add Full scope extras if selected**
   - Dockerfile
   - .github/workflows/ci.yml
   - tests/ directory with example test

---

## Phase 4: Next Steps

After generating all files, present summary and offer options:

```
Project created successfully!

📁 {project-name}/
├── src/agent.{ext}
├── package.json / pyproject.toml
├── .env.example
├── .gitignore
└── [additional files based on scope]

Use AskUserQuestion to offer:
- Initialize git repository: Run `git init && git add . && git commit -m "Initial commit"`
- Install dependencies: Run `npm install` or `uv sync`
- Open in editor: Run `code {project-name}`
- Done: Show getting started instructions
```

---

## Tool Mapping

Map user selections to actual tool strings:

| Selection | Tools |
|-----------|-------|
| File Operations | `Read`, `Write`, `Edit`, `Glob`, `Grep` |
| Code Execution | `Bash` |
| Web Search | `WebSearch`, `WebFetch` |
| MCP Tools | (configured via mcpServers) |

## System Prompt Templates

**Coding Agent:**
```
You are a coding assistant that helps developers write better code.
Analyze code for bugs, security issues, and best practices.
Suggest improvements and help with refactoring.
```

**Business Agent:**
```
You are a business analyst assistant.
Help with document analysis, data extraction, and report generation.
Provide clear, actionable insights.
```

**Custom:**
```
{User-provided description}
```
