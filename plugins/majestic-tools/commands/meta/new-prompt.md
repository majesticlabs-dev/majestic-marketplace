---
allowed-tools: WebFetch, WebSearch, AskUserQuestion
description: Build or optimize prompts following Anthropic's best practices
---

# Prompt Engineer

Build new prompts or optimize existing ones following Anthropic's best practices.

## Mode Detection

First, determine which mode to use based on the arguments:

**Optimization Mode** - Use when:
- Arguments contain `optimize:` followed by a prompt
- Arguments contain keywords like "improve", "optimize", "refine", "enhance" followed by a prompt
- User provides an existing prompt and asks for improvements

**Creation Mode** - Use when:
- Arguments contain prompt component parameters (taskContext, finalRequest, etc.)
- No existing prompt is provided
- User wants to build a new prompt from scratch

If the mode is unclear, use `AskUserQuestion` to ask:
- "Would you like to optimize an existing prompt or create a new one?"

---

# Optimization Mode

When optimizing an existing prompt, follow this methodology.

## Assessment Steps

Evaluate the prompt in order:

1. **Check user intent** - Can you understand what they want the LLM to do?
2. **Evaluate structure** - Would restructuring improve response quality?
3. **Identify missing context** - What information does the LLM need to succeed?
4. **Assess organization** - Would better organization help?

## Optimization Rules

- Only change what meaningfully improves outcomes - don't change things that already work
- Preserve the user's voice and personality - keep their writing style and tone
- Add structure only when needed - don't over-engineer simple requests
- Don't add complexity for complexity's sake - simpler is usually better

## Optimization Strategies

Apply these techniques based on the issues identified:

### For Vague Prompts
- Add specific aspects to examine
- Define the desired output format
- Specify the analysis depth

### For Missing Context
- Add relevant constraints
- Specify the target audience
- Include necessary background

### For Complex Prompts
- Break into numbered steps
- Add clear section headers
- Define success criteria

### For Unclear Scope
- Set boundaries
- Specify depth level
- Define completion criteria

## Output Formats

Choose exactly one format based on assessment:

### When Improvements Needed

```markdown
## Optimized Prompt

[Enhanced version of the prompt]

## Key Improvements

1. **[Change]**: [Why it helps]
2. **[Change]**: [Why it helps]
```

### When Prompt Is Already Good

```markdown
## Assessment

Your prompt is clear and well-structured. [Optional minor suggestion if any]
```

### When Intent Is Unclear

Do not attempt optimization. Instead, ask clarifying questions:

```markdown
## Clarification Needed

To optimize your prompt effectively, please clarify:

- [Specific question about intent]
- [Alternative interpretation to confirm]
```

## Optimization Principles

- Less is often more - avoid unnecessary additions
- Respect the user's expertise
- Remove friction, don't add it
- Focus on practical improvements only
- Ask for clarification rather than guessing intent

---

# Creation Mode

Build new prompts by collecting parameters and assembling them according to Anthropic's recommended format. If parameters are missing, ask for them interactively.

## Process

1. **Parse provided arguments** to identify which components are already specified
2. **Check for required parameters** (taskContext and finalRequest are mandatory)
3. **Ask for missing parameters** if needed, with explanations of each component
4. **Generate the final prompt** using best practices

## Prompt Components

### Required Components

- **taskContext**: The context and background of what needs to be done
- **finalRequest**: The specific ask or instruction for the LLM

### Optional Components
- **toneContext**: Guidance about the desired output tone (professional, casual, technical, etc.)
- **backgroundData**: Relevant background information, documents, or data
- **detailedTaskInstructions**: Step-by-step instructions, rules, or constraints
- **examples**: Exemplars showing good/bad outputs or expected formats
- **conversationHistory**: Previous relevant dialogue or context
- **chainOfThought**: Instructions for reasoning approach (e.g., "Think step-by-step")
- **outputFormatting**: Specific format requirements (e.g., "Use XML tags", "Reply in JSON")

## Parameter Collection

If parameters are missing, use `AskUserQuestion` to gather them. Example format:

```
### Missing Parameters

I need some additional information to build your prompt:

**Required:**
- taskContext: [if missing] What is the context/background of this task?
- finalRequest: [if missing] What specific action should the LLM take?

**Optional (press Enter to skip):**
- toneContext: What tone should the output use? (professional/casual/technical)
- backgroundData: Any relevant documents or data to include?
- detailedTaskInstructions: Specific rules or step-by-step instructions?
- examples: Example inputs/outputs to demonstrate expectations?
- conversationHistory: Previous conversation context to include?
- chainOfThought: Should the LLM think through its answer? (yes/no)
- outputFormatting: Specific format requirements? (JSON/XML/markdown/etc.)
```

## Prompt Building Logic

```typescript
const createPrompt = (opts: {
  taskContext: string;
  toneContext?: string;
  backgroundData?: string;
  detailedTaskInstructions?: string;
  examples?: string;
  conversationHistory?: string;
  finalRequest: string;
  chainOfThought?: string;
  outputFormatting?: string;
}) => {
  const sections = [];
  
  // Task Context (Required)
  if (opts.taskContext) {
    sections.push(`## Context\n${opts.taskContext}`);
  }
  
  // Tone Guidance
  if (opts.toneContext) {
    sections.push(`## Tone\n${opts.toneContext}`);
  }
  
  // Background Information
  if (opts.backgroundData) {
    sections.push(`## Background Information\n${opts.backgroundData}`);
  }
  
  // Detailed Instructions
  if (opts.detailedTaskInstructions) {
    sections.push(`## Instructions\n${opts.detailedTaskInstructions}`);
  }
  
  // Examples
  if (opts.examples) {
    sections.push(`## Examples\n${opts.examples}`);
  }
  
  // Conversation History
  if (opts.conversationHistory) {
    sections.push(`## Previous Conversation\n${opts.conversationHistory}`);
  }
  
  // Chain of Thought
  if (opts.chainOfThought) {
    sections.push(`## Approach\n${opts.chainOfThought}`);
  }
  
  // Final Request (Required)
  sections.push(`## Task\n${opts.finalRequest}`);
  
  // Output Formatting
  if (opts.outputFormatting) {
    sections.push(`## Output Format\n${opts.outputFormatting}`);
  }
  
  return sections.join('\n\n');
};
```

## Best Practices Applied

1. **Clear Structure**: Each component has its own section with clear headers
2. **Context First**: Background and context come before the specific request
3. **Examples When Helpful**: Include examples to clarify expectations
4. **Explicit Instructions**: Be specific about constraints and requirements
5. **Output Formatting Last**: Format requirements come after the main request
6. **Chain of Thought**: Add reasoning instructions when complex thinking is needed

## Output Format

The final prompt will be formatted as:

```markdown
# Generated Prompt

[The assembled prompt with all components properly structured]

---

## Prompt Metadata
- Components used: [list of included components]
- Total length: [character count]
- Optimization suggestions: [if any]
```

## Example Usage

### Creation Mode

```bash
# Minimal usage - will ask for required parameters
/new-prompt

# With inline parameters
/new-prompt taskContext:"Create a data analysis report" finalRequest:"Analyze the sales data and provide insights"

# With detailed parameters
/new-prompt taskContext:"Review code for security issues" toneContext:"Professional and thorough" chainOfThought:"yes" outputFormatting:"Use markdown with code blocks"
```

### Optimization Mode

```bash
# Optimize an existing prompt
/new-prompt optimize:"Write a blog post about AI"

# Natural language
/new-prompt improve this prompt: "You are a helpful assistant. Answer questions about cooking."

# Refine a complex prompt
/new-prompt enhance:"As a senior developer, review this code for bugs and security issues. Be thorough."
```

## Arguments Format

Arguments can be provided in these formats:
- `parameterName:"value with spaces"`
- `parameterName:value-without-spaces`
- Multiple parameters separated by spaces
- Or interactively when prompted

## Anthropic Resources

For more best practices, I can fetch the latest guidance from:
- Anthropic's prompt engineering documentation
- Claude's prompt library examples
- Recent best practices updates

## Start Building

$ARGUMENTS

Let me help you build a professional prompt. First, let me check what parameters you've provided and identify what's still needed.
