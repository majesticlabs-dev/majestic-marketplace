---
allowed-tools: Bash, Read, Edit, AskUserQuestion
description: Reflect on current session and suggest AGENTS.md improvements based on patterns and feedback.
model: haiku
---

# Reflect

Analyze the current session and suggest improvements to AGENTS.md based on patterns, feedback, and lessons learned.

**For cross-session learning from git history and handoffs, use `/learn` instead.**

## Data Sources

| Source | What to Extract |
|--------|-----------------|
| Conversation history | User corrections, repeated feedback, preferences |
| `.agents-os/session_ledger.md` | Key Decisions, patterns from current work (if exists) |

## Process

### Step 1: Review Conversation History

Analyze all messages in this conversation:
- User feedback and corrections
- Moments where instructions weren't followed
- Repeated issues or preferences
- Patterns that emerged during interaction

### Step 2: Check Session Ledger (if exists)

```bash
[ -f ".agents-os/session_ledger.md" ] && cat ".agents-os/session_ledger.md"
```

Extract any Key Decisions or patterns documented there.

### Step 3: Identify Improvement Opportunities

Look for:
- Gaps in current AGENTS.md that led to misunderstandings
- User preferences that should be encoded
- Patterns that could prevent future issues
- Corrections that apply broadly (not one-off incidents)

### Step 4: Generate Specific Improvements

Create actionable, specific edits. Each suggestion should:
- Be concrete (not vague principles)
- Prevent similar issues in future
- Address patterns, not one-off incidents

### Step 5: Present Suggestions

Use this format:

```markdown
## Session Reflection

### 1. [Pattern Name]
**Gap**: What's missing or unclear in AGENTS.md
**Proposed**: Specific text to add
**Reasoning**: Evidence from this session (e.g., "You corrected this 3 times")

### 2. [Pattern Name]
...
```

### Step 6: Apply Changes (if approved)

Use `AskUserQuestion`:
- "Would you like me to apply these improvements to AGENTS.md?"

If yes:
- Use Edit tool to update AGENTS.md
- Confirm changes were applied

## Guidelines

- Only suggest improvements that genuinely enhance behavior
- Keep suggestions specific and actionable
- Don't suggest redundant rules
- Focus on patterns, not one-off incidents
- Maintain existing AGENTS.md structure and style

## Example Output

```
## Session Reflection

### 1. Error Handling Preference
**Gap**: No guidance on error handling style
**Proposed**: "Always use try-catch blocks with specific error types rather than generic catches"
**Reasoning**: You corrected this pattern 3 times during our session

### 2. Import Organization
**Gap**: No import organization rules
**Proposed**: "Group imports by: 1) External packages, 2) Internal modules, 3) Types"
**Reasoning**: You consistently reorganized imports this way

Would you like me to apply these improvements to AGENTS.md?
```
