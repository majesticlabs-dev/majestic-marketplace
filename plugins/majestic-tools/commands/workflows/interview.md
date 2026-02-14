---
name: interview
description: Deep discovery interview for any domain - engineering, brand, product, marketing, sales
argument-hint: "[topic or domain to explore]"
allowed-tools: Read, Glob, Grep, AskUserQuestion, Write, Edit, Task
---

# Interview

Discovery-driven specification through conversational probing. Ask questions that reveal what the user hasn't fully thought through.

## Input

<feature_input> $ARGUMENTS </feature_input>

**Formats:**
- File path (`docs/plans/*.md`, `specs/*.md`) → Read and refine existing spec
- Task reference (`#123`, `PROJ-123`) → Fetch task details first
- Inline text → Treat as topic description
- Empty → Ask user what they want to explore

## Step 0: Determine Input Type & Domain

### Input Type
```
If file path → Read(file_path)
If task reference → Task(subagent_type="majestic-engineer:workflow:task-fetcher", prompt="...")
If empty → AskUserQuestion: "What do you want to explore?"
```

Store the context for grounding questions.

### Domain Detection

Detect interview domain from input keywords:

| Domain | Trigger Keywords | Resource |
|--------|-----------------|----------|
| brand | "brand voice", "tone", "writing style", "voice guide", "brand style" | [brand.yaml](resources/interview/domains/brand.yaml) |
| product | "product", "user research", "discovery", "jobs to be done", "user needs" | [product.yaml](resources/interview/domains/product.yaml) |
| marketing | "campaign", "content strategy", "audience", "messaging", "launch" | [marketing.yaml](resources/interview/domains/marketing.yaml) |
| sales | "sales process", "objections", "pitch", "deal", "pricing", "proposal" | [sales.yaml](resources/interview/domains/sales.yaml) |
| engineering | (default) features, bugs, systems, architecture | [engineering.yaml](resources/interview/domains/engineering.yaml) |

Load the matching domain resource for domain-specific:
- Discovery domains and question themes
- Question style examples
- Synthesis template

## Step 1: Load Project Context (Optional)

Check for existing documentation to ground questions:

```bash
ls docs/architecture/*.md docs/design/*.md ARCHITECTURE.md 2>/dev/null | head -5
```

If found, skim key files to understand existing context. This helps ask informed questions rather than generic ones.

## Step 2: The Interview

**Core Methodology:**
- Ask ONE question at a time using `AskUserQuestion`
- Go DEEP on answers that reveal uncertainty or assumptions
- Skip obvious questions - push on things they haven't fully thought through
- Capture quotable moments verbatim when reasoning surfaces naturally

**Domain-Specific Questions:**

Use the discovery domains from the loaded domain resource. Each domain file contains:
- 3-5 discovery areas with specific question themes
- "Dig deeper when they say..." triggers
- Question style examples (Instead of... → Ask...)

**Interview Flow:**

1. Start with an open question about their mental model
2. Follow threads that reveal uncertainty
3. When they say "I think..." or "probably..." - dig deeper
4. When they give a clear, confident answer - move on
5. Capture particularly clear explanations verbatim (these become spec gold)

**Question Style Examples:**

| Instead of... | Ask... |
|---------------|--------|
| "What are the requirements?" | "Walk me through how a user would actually use this" |
| "What are the edge cases?" | "What happens when [specific scenario from their answer]?" |
| "Is this important?" | "What breaks if we ship without this?" |
| "What's the timeline?" | "What's forcing the timing here?" |

## Step 3: The Reflection Question

**Before wrapping up, ALWAYS ask:**

> "What did I forget to ask about?"

This surfaces blind spots. The most important insight often emerges when reflecting on what wasn't covered.

## Step 4: Synthesize Findings

Use the **Synthesis Template** from the loaded domain resource. Each domain has a tailored output format:

- **Engineering:** Core intent, key decisions, technical approach, open questions, risks
- **Brand:** Voice identity, personality traits, audience, tone boundaries, style rules
- **Product:** Problem space, user context, alternatives, success signals, scope decisions
- **Marketing:** Campaign goal, audience, message, differentiation, constraints
- **Sales:** Deal overview, buyer journey, decision makers, objections, competition

Always include:
- **Quotable Moments** - Verbatim quotes that capture key insights
- **Open Questions** - Things that need more thought
- **Next Step Options** - Domain-appropriate follow-up actions

## Step 5: Output

**If input was a file path:**
- Update the existing file with refined spec
- Preserve original content, add interview findings

**If input was inline text or task:**
- Create new spec file: `docs/specs/[YYYY-MM-DD]-[slug].md`
- Or if `docs/specs/` doesn't exist: `docs/plans/[YYYY-MM-DD]-[slug].md`

**Always end with:**

Use the **Next Step Options** from the domain resource. Common patterns:

| Domain | Primary Next Step |
|--------|------------------|
| engineering | `/blueprint` → Create implementation plan |
| brand | `brand-voice` skill → Generate full voice guide |
| product | `/prd` → Create product requirements doc |
| marketing | `content-calendar` skill → Plan content execution |
| sales | `proposal-writer` skill → Generate proposal |

Always offer:
- Domain-specific creation action
- "I need to think more" → End workflow
- "Refine specific section" → Continue interview

## Anti-Patterns

- Asking 40 questions in sequence (feels like interrogation)
- Sticking rigidly to domains (follow the interesting threads)
- Accepting "I'll figure it out later" without probing why
- Writing formal requirements instead of capturing natural language
- Skipping the "what did I forget" question

## Notes

- This is a CONVERSATION, not a form to fill out
- 10 deep questions > 40 surface questions
- Off-the-cuff explanations often beat formal requirements
- Uncertainty is valuable data - don't rush past it
- The goal is DISCOVERY, not documentation
