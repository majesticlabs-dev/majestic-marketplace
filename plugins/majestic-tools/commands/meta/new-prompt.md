---
name: majestic:new-prompt
allowed-tools: WebFetch, WebSearch, AskUserQuestion
description: Build or optimize prompts following Anthropic's best practices
argument-hint: "[prompt description or 'optimize: <prompt>']"
---

# Prompt Engineer

Build new prompts or optimize existing ones following Anthropic's best practices.

## Mode Detection

**Optimization Mode** - When:
- Arguments contain `optimize:` followed by a prompt
- Keywords like "improve", "optimize", "refine" + prompt
- User provides existing prompt for improvements

**Creation Mode** - When:
- Arguments contain component parameters
- No existing prompt provided
- Building from scratch

If unclear, ask: "Would you like to optimize an existing prompt or create a new one?"

---

# Optimization Mode

## Assessment Steps

1. **Check intent** - Can you understand what they want?
2. **Evaluate structure** - Would restructuring improve quality?
3. **Identify missing context** - What info does LLM need?
4. **Assess organization** - Would better organization help?

## Rules

- Only change what meaningfully improves outcomes
- Preserve user's voice and personality
- Add structure only when needed
- Simpler is usually better

## Strategies

| Issue | Solution |
|-------|----------|
| Vague | Add specific aspects, output format, depth |
| Missing context | Add constraints, audience, background |
| Complex | Break into steps, add headers, define success |
| Unclear scope | Set boundaries, depth level, completion criteria |

## Output Formats

**When improvements needed:**
```
## Optimized Prompt
[Enhanced version]

## Key Improvements
1. **[Change]**: [Why it helps]
```

**When already good:**
```
## Assessment
Your prompt is clear and well-structured. [Optional minor suggestion]
```

**When unclear:**
```
## Clarification Needed
To optimize effectively, please clarify:
- [Question about intent]
```

---

# Creation Mode

Build prompts by collecting parameters and assembling per Anthropic's format.

## Components

### Required
- **taskContext**: Context and background
- **finalRequest**: Specific ask or instruction

### Optional
- **toneContext**: Desired output tone
- **backgroundData**: Relevant documents/data
- **detailedTaskInstructions**: Step-by-step rules
- **examples**: Good/bad output exemplars
- **conversationHistory**: Previous dialogue
- **chainOfThought**: Reasoning approach
- **outputFormatting**: Format requirements (JSON, XML, etc.)

## Process

1. Parse provided arguments for components
2. Check for required parameters (taskContext, finalRequest)
3. Ask for missing parameters if needed
4. Generate structured prompt

## Prompt Structure

```markdown
## Context
[taskContext]

## Tone
[toneContext if provided]

## Background Information
[backgroundData if provided]

## Instructions
[detailedTaskInstructions if provided]

## Examples
[examples if provided]

## Approach
[chainOfThought if provided]

## Task
[finalRequest]

## Output Format
[outputFormatting if provided]
```

## Best Practices

1. **Clear Structure**: Each component has own section
2. **Context First**: Background before request
3. **Examples When Helpful**: Clarify expectations
4. **Explicit Instructions**: Specific constraints
5. **Output Formatting Last**: After main request
6. **Chain of Thought**: Add for complex reasoning

## Example Usage

```bash
# Create with parameters
/new-prompt taskContext:"Review code" finalRequest:"Analyze for security issues"

# Optimize existing
/new-prompt optimize:"Write a blog post about AI"
```
