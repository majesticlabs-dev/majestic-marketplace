---
name: majestic:interview
description: Deep requirements interview to refine specs before planning or building
argument-hint: "[feature description, file path, or task reference]"
allowed-tools: Read, Glob, Grep, AskUserQuestion, Write, Edit
---

# Interview

Discovery-driven specification through conversational probing. Ask questions that reveal what the user hasn't fully thought through.

## Input

<feature_input> $ARGUMENTS </feature_input>

**Formats:**
- File path (`docs/plans/*.md`, `specs/*.md`) → Read and refine existing spec
- Task reference (`#123`, `PROJ-123`) → Fetch task details first
- Inline text → Treat as feature description
- Empty → Ask user what they want to explore

## Step 0: Determine Input Type

```
If file path → Read(file_path)
If task reference → Task(subagent_type="majestic-engineer:workflow:task-fetcher", prompt="...")
If empty → AskUserQuestion: "What feature, system, or problem do you want to explore?"
```

Store the feature context for grounding questions.

## Step 1: Load Project Context (Optional)

Check for existing architecture documentation to ground questions:

```bash
ls docs/architecture/*.md docs/design/*.md ARCHITECTURE.md 2>/dev/null | head -5
```

If found, skim key files to understand existing systems. This helps ask informed questions rather than generic ones.

## Step 2: The Interview

**Core Methodology:**
- Ask ONE question at a time using `AskUserQuestion`
- Go DEEP on answers that reveal uncertainty or assumptions
- Skip obvious questions - push on things they haven't fully thought through
- Capture quotable moments verbatim when reasoning surfaces naturally

**Three Domains to Cover:**

### Technical & Architecture
- Implementation approach and tradeoffs
- How this fits with existing systems
- What could break, need migration, or have edge cases
- Data model implications
- Performance/scale considerations

### Human & Workflow
- Who else is affected (users, team members, external parties)?
- What's the manual fallback if automation fails?
- How will you know it's working? What does success look like?
- What's the learning curve or adoption path?

### Strategic
- Why now? What's the cost of waiting?
- What's the simplest version that delivers value (MVP)?
- What would make you regret building this?
- What are you explicitly NOT building?

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

Create a structured summary:

```markdown
## Interview Summary: [Feature Name]

### Core Intent
[One paragraph capturing what they're really trying to achieve]

### Key Decisions Made
- [Decision 1] — [Rationale captured during interview]
- [Decision 2] — [Rationale]

### Quotable Moments
> "[Verbatim quote that captures intent clearly]"
> "[Another quote worth preserving]"

### Open Questions
- [ ] [Question that needs more thought]
- [ ] [Question requiring external input]

### Out of Scope (Explicitly)
- [Thing they decided NOT to build]

### Success Criteria
- [How they'll know it's working]

### Risks & Concerns
- [Thing that could go wrong]
- [Uncertainty that surfaced]
```

## Step 5: Output

**If input was a file path:**
- Update the existing file with refined spec
- Preserve original content, add interview findings

**If input was inline text or task:**
- Create new spec file: `docs/specs/[YYYY-MM-DD]-[slug].md`
- Or if `docs/specs/` doesn't exist: `docs/plans/[YYYY-MM-DD]-[slug].md`

**Always end with:**

```
AskUserQuestion: "Interview complete. What's next?"
Options:
- "Create a blueprint from this" → Skill(skill: "majestic:blueprint", args: "[spec file path]")
- "I need to think more" → End workflow
- "Refine specific section" → Continue interview on that section
```

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
