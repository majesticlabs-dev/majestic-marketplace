---
name: external-llm-consulting
description: Get architecture and design second opinions from external LLMs (OpenAI Codex, Google Gemini) via their CLIs. Use when you need alternative perspectives on design decisions, model selection, or structured comparison of approaches.
allowed-tools: Bash Read Grep Glob
---

# External LLM Consulting

**Audience:** Developers seeking alternative AI perspectives on architecture and design decisions.
**Goal:** Invoke external LLM CLIs in read-only/sandbox mode to get structured second opinions, then present results for comparison with Claude's perspective.

## When to Use

- Validating architectural choices with diverse AI perspectives
- Exploring alternative approaches Claude might not consider
- High-stakes design decisions benefiting from model diversity
- Surfacing blind spots through cross-model analysis

## General Workflow

1. Gather relevant context (CLAUDE.md, AGENTS.md, existing code patterns, constraints)
2. Formulate a focused prompt with context, specific questions, and structured output request
3. Execute the external CLI in sandbox/read-only mode
4. Parse and structure the response for comparison

## Codex Consulting

### Prerequisites

- Codex CLI installed (`codex --version` to verify)
- OpenAI authentication configured (`codex login`)

### Available Models

| Model | Use Case | Cost |
|-------|----------|------|
| `gpt-5.1-codex-mini` | Fast, cost-effective (~4x more usage) | Low |
| `gpt-5.1-codex` | Balanced, optimized for agentic tasks (default) | Medium |
| `gpt-5.1-codex-max` | Maximum intelligence for critical decisions | High |

Parse model from prompt if specified (e.g., "using codex-mini, analyze..." or "model: gpt-5.1-codex-max").

### CLI Execution

Run Codex in read-only sandbox mode:

```bash
codex exec --sandbox read-only --model <model> "<prompt>"
```

**Important flags:**
- `--sandbox read-only` - Prevents any code modifications
- `--model <model>` - Model to use (default: `gpt-5.1-codex`)

**For complex prompts, use heredoc:**

```bash
codex exec --sandbox read-only --model gpt-5.1-codex "$(cat <<'EOF'
Context: [codebase context]

Question: [specific architectural question]

Please provide:
1. 2-3 alternative approaches
2. Trade-offs for each approach
3. Your recommendation with reasoning
EOF
)"
```

### Codex Error Handling

| Error | Resolution |
|-------|------------|
| CLI not found | Install: `npm install -g @openai/codex` then `codex login` |
| Auth failed | Run: `codex login` |
| Timeout (>2 min) | Report partial results or simplify the query |

## Gemini Consulting

### Prerequisites

- Gemini CLI installed (`gemini --version` to verify)
- Google authentication configured

### Available Models

| Model | Use Case | Cost |
|-------|----------|------|
| `gemini-2.5-flash` | Fast, cost-effective consulting | Low |
| `gemini-2.5-pro` | Balanced reasoning | Medium |
| `gemini-3.0-pro-preview` | Latest Gemini 3 Pro (default) | Medium |

Parse model from prompt if specified (e.g., "using flash, analyze..." or "model: gemini-3.0-pro-preview").

### CLI Execution

Run Gemini in sandbox mode:

```bash
gemini --sandbox --output-format text --model <model> "<prompt>"
```

**Important flags:**
- `--sandbox` - Prevents any code modifications
- `--output-format text` - Returns plain text (vs json/stream-json)
- `--model <model>` - Model to use (default: `gemini-3.0-pro-preview`)

**For complex prompts, use heredoc:**

```bash
gemini --sandbox --output-format text --model gemini-3.0-pro-preview "$(cat <<'EOF'
Context: [codebase context]

Question: [specific architectural question]

Please provide:
1. 2-3 alternative approaches
2. Trade-offs for each approach
3. Your recommendation with reasoning
EOF
)"
```

### Gemini Error Handling

| Error | Resolution |
|-------|------------|
| CLI not found | Install: `npm install -g @anthropic-ai/gemini-cli` / See https://github.com/google-gemini/gemini-cli |
| Auth failed | Run `gemini` and follow authentication prompts |
| Timeout (>2 min) | Report partial results or simplify the query |

## Prompt Formulation

Create a focused prompt that:
- Provides necessary context about the codebase
- Asks specific questions about the decision
- Requests structured output (options with trade-offs)

Include relevant sections from CLAUDE.md/AGENTS.md and any project constraints mentioned in the user's request.

## Output Format

```markdown
## [Codex/Gemini] Consulting Results

**Query:** [Original question/topic]

**Model:** [model used] (via [Codex/Gemini] CLI)

### Alternative Perspectives

#### Option 1: [Name]
- **Approach:** [Description]
- **Pros:** [Benefits]
- **Cons:** [Drawbacks]

#### Option 2: [Name]
- **Approach:** [Description]
- **Pros:** [Benefits]
- **Cons:** [Drawbacks]

#### Option 3: [Name]
- **Approach:** [Description]
- **Pros:** [Benefits]
- **Cons:** [Drawbacks]

### Recommendation
[LLM's preferred approach and reasoning]

### Key Insights
- [Insight 1 - something Claude might not have considered]
- [Insight 2]
- [Insight 3]

### Raw Output
<details>
<summary>Full Response</summary>

[Complete unedited response]

</details>
```

## Safety Constraints

- **Always use sandbox/read-only mode** - Never allow code modifications
- **No secrets in prompts** - Don't include API keys, credentials, or sensitive data
- **Verify responses** - External LLM suggestions are opinions, not authoritative answers
