---
description: Get external LLM perspectives on architecture/design decisions from Codex and Gemini
allowed-tools: Bash, Read, Grep, Glob, Task
argument-hint: "<question> [--llm codex|gemini|all] [--codex-model <model>] [--gemini-model <model>]"
---

# External Consult

Get alternative AI perspectives on architectural decisions and feature planning from external LLMs (Codex, Gemini).

## Arguments

<input_arguments> $ARGUMENTS </input_arguments>

**Format:** `<question> [options]`

**Options:**
- `--llm codex` - Use only Codex (GPT-5.1)
- `--llm gemini` - Use only Gemini
- `--llm all` - Use both (default)
- `--codex-model <model>` - Codex model (default: `gpt-5.1-codex`)
- `--gemini-model <model>` - Gemini model (default: `gemini-3.0-pro-preview`)

**Example:**
```
/majestic-llm:consult Should we use Redis or PostgreSQL for caching?
/majestic-llm:consult --llm codex What's the best way to structure this API?
/majestic-llm:consult --codex-model gpt-5.1-codex-max Critical architecture decision
/majestic-llm:consult --codex-model gpt-5.1-codex-max --gemini-model gemini-2.5-pro Compare approaches
```

## Available Models

### Codex (OpenAI)
| Model | Use Case |
|-------|----------|
| `gpt-5.1-codex-mini` | Fast, cost-effective |
| `gpt-5.1-codex` | Balanced (default) |
| `gpt-5.1-codex-max` | Maximum intelligence |

### Gemini (Google)
| Model | Use Case |
|-------|----------|
| `gemini-2.5-flash` | Fast, cost-effective |
| `gemini-2.5-pro` | Balanced |
| `gemini-3.0-pro-preview` | Latest (default) |

## Process

### Step 1: Parse Arguments

Extract from `$ARGUMENTS`:
- **Question:** Everything before `--` flags (or interspersed with flags)
- **LLM selection:** `--llm` value (default: `all`)
- **Codex model:** `--codex-model` value (default: `gpt-5.1-codex`)
- **Gemini model:** `--gemini-model` value (default: `gemini-3.0-pro-preview`)

**Auto-inference:** If only `--codex-model` is specified without `--llm`, infer `--llm codex`. Same for `--gemini-model`.

### Step 2: Check CLI Availability

```bash
which codex >/dev/null 2>&1 && echo "codex:ok" || echo "codex:missing"
which gemini >/dev/null 2>&1 && echo "gemini:ok" || echo "gemini:missing"
```

If a requested LLM is missing, warn and continue with available ones.

### Step 3: Gather Context

Read project context to include in prompts:
- Check for CLAUDE.md, AGENTS.md
- Note the tech stack from .agents.yml if present
- Include relevant context in the query

### Step 4: Launch Queries

**Single LLM Mode:**
Use Task tool with appropriate agent:
```
Task: majestic-llm:codex-consult
Prompt: "[question with context]. Model: [codex-model]"
```

**Multi-LLM Mode:**
Launch BOTH agents in parallel using Task tool:
```
Task 1: majestic-llm:codex-consult
Prompt: "[question]. Model: [codex-model]"

Task 2: majestic-llm:gemini-consult
Prompt: "[question]. Model: [gemini-model]"
```

### Step 5: Present Results

**Single LLM:** Present the response directly with model attribution.

**Multi-LLM:** Use the multi-llm-coordinator synthesis format:
- Highlight consensus points
- Note divergent recommendations
- Surface unique insights from each

## Output Format

### Single LLM

```markdown
## External Consult Results

**Question:** [question]
**LLM:** [Codex/Gemini] ([model])

### Perspectives

[Structured response from the LLM]

### Key Takeaways
- [Point 1]
- [Point 2]
- [Point 3]
```

### Multi-LLM

```markdown
## External Consult Results

**Question:** [question]
**LLMs:** Codex ([model]), Gemini ([model])

---

### Consensus
Points where both LLMs agree:
- [Agreement 1]
- [Agreement 2]

### Divergence
Where they disagree:
| Topic | Codex | Gemini |
|-------|-------|--------|
| [Topic] | [Position] | [Position] |

### Unique Insights

**From Codex:**
- [Insight]

**From Gemini:**
- [Insight]

---

<details>
<summary>Full Codex Response</summary>

[Response]

</details>

<details>
<summary>Full Gemini Response</summary>

[Response]

</details>
```

## Examples

### Simple Query (Both LLMs with Defaults)
```
/majestic-llm:consult Should we use a service object or concern for this logic?
```

### Specific LLM
```
/majestic-llm:consult --llm gemini How should we structure the API versioning?
```

### High-Stakes with Max Codex Model
```
/majestic-llm:consult --codex-model gpt-5.1-codex-max Critical: Database migration strategy for 10M rows
```

### Both LLMs with Custom Models
```
/majestic-llm:consult --codex-model gpt-5.1-codex-max --gemini-model gemini-2.5-pro Architecture review
```

## Error Handling

### No LLMs Available
```markdown
**Error:** No external LLMs available

Please install at least one:
- Codex: `npm install -g @openai/codex && codex login`
- Gemini: See https://github.com/google-gemini/gemini-cli
```

### Query Too Vague
If the question lacks context, ask for clarification:
```markdown
Your question could benefit from more context. Consider including:
- What problem are you solving?
- What constraints exist?
- What have you already considered?
```
