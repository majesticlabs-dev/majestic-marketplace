---
description: Generate a new Claude Code sub-agent configuration file from a description
allowed-tools: mcp__sequential-thinking__sequentialthinking, Edit, MultiEdit, Write, NotebookEdit, WebFetch, AskUserQuestion
---

# New Agent Builder `/new-agent`

Generate a complete, ready-to-use Claude Code sub-agent configuration file from your description.

## Arguments

- `[agent-description]` - Description of the agent you want to create

## Example Usage

```bash
# Generate a code review agent
/new-agent "reviews pull requests for security vulnerabilities"

# Create a documentation agent
/new-agent "generates API documentation from code comments"

# Build a testing agent
/new-agent "writes unit tests for Ruby/Rails applications"
```

## Instructions

**0. Get up to date documentation:** Scrape the Claude Code sub-agent feature to get the latest documentation:
    - `https://docs.anthropic.com/en/docs/claude-code/sub-agents` - Sub-agent feature
    - `https://docs.anthropic.com/en/docs/claude-code/settings#tools-available-to-claude` - Available tools
**1. Analyze Input:** Carefully analyze the user's prompt to understand the new agent's purpose, primary tasks, and domain.
   - If the description is vague or ambiguous, use `AskUserQuestion` to clarify:
     - What specific tasks should this agent handle?
     - What tools does it need access to?
     - Should it be proactive or only invoked explicitly?
**2. Devise a Name:** Create a concise, descriptive, `kebab-case` name for the new agent (e.g., `dependency-manager`, `api-tester`).
**3. Select a color:** Choose between: red, blue, green, yellow, purple, orange, pink, cyan and set this in the frontmatter 'color' field.
**4. Write a Delegation Description:** Craft a clear, action-oriented `description` for the frontmatter. This is critical for Claude's automatic delegation. It should state *when* to use the agent. Use phrases like "Use proactively for..." or "Specialist for reviewing...".
**5. Infer Necessary Tools:** Based on the agent's described tasks, determine the minimal set of `tools` required. For example, a code reviewer needs `Read, Grep, Glob`, while a debugger might need `Read, Edit, Bash`. If it writes new files, it needs `Write`.
**6. Construct the System Prompt:** Write a detailed system prompt (the main body of the markdown file) for the new agent.
**7. Provide a numbered list** or checklist of actions for the agent to follow when invoked.
**8. Incorporate best practices** relevant to its specific domain.
**9. Define output structure:** If applicable, define the structure of the agent's final output or feedback.
**10. Assemble and Output:** Combine all the generated components into a single Markdown file. Adhere strictly to the `Output Format` below. Your final response should ONLY be the content of the new agent file. Write the file to the `.claude/agents/<generated-agent-name>.md` directory.

## Output Format

You must generate a single Markdown code block containing the complete agent definition. The structure must be exactly as follows:

```md
---
name: <generated-agent-name>
description: <generated-action-oriented-description>
tools: <inferred-tool-1>, <inferred-tool-2>
model: haiku | sonnet | opus  # OPTIONAL - defaults to 'sonnet' if omitted. Use 'haiku' for fast/cheap tasks, 'opus' for complex reasoning
---

# Purpose

You are a <role-definition-for-new-agent>.

## Instructions

When invoked, you must follow these steps:
1. <Step-by-step instructions for the new agent.>
2. <...>
3. <...>

**Best Practices:**
- <List of best practices relevant to the new agent's domain.>
- <...>

## Report / Response

Provide your final response in a clear and organized manner.
```
