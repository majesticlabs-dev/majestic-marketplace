---
allowed-tools: Bash(git *)
description: Reflect on conversation history and suggest improvements to AGENTS.md based on patterns, feedback, and lessons learned.
model: haiku
---

# Reflect on Conversation

Analyze our conversation history and suggest improvements to AGENTS.md based on patterns, feedback, and lessons learned.

## Process

1. **Review Conversation History**
   - Analyze all user feedback and corrections
   - Identify moments where instructions weren't followed
   - Note any repeated issues or preferences

2. **Identify Improvement Opportunities**
   - Look for patterns that could be addressed with better instructions
   - Find gaps in current AGENTS.md that led to misunderstandings
   - Consider user preferences that emerged during interaction

3. **Generate Specific Improvements**
   - Create actionable, specific edits for AGENTS.md
   - Focus on preventing similar issues in future interactions
   - Prioritize changes that address user feedback directly

4. **Present Suggestions**
   - Show proposed changes using diff-style format
   - Explain the reasoning behind each suggestion
   - Group related improvements together

5. **Apply Changes (if approved)**
   - Ask user: "Would you like me to apply these improvements to AGENTS.md?"
   - If yes, use Edit tool to update AGENTS.md
   - Confirm changes were applied successfully

## Guidelines

- Only suggest improvements that genuinely enhance LLM's behavior
- Keep suggestions specific and actionable, not vague principles
- Don't suggest redundant rules that duplicate existing instructions
- Focus on patterns, not one-off incidents
- Maintain the existing structure and style of AGENTS.md

## Example Output Format

```
ℹ️ I've identified these improvement opportunities:

### 1. Error Handling Preference
**Current gap**: No guidance on error handling style
**Proposed addition**: "Always use try-catch blocks with specific error types rather than generic catches"
**Reasoning**: You corrected this pattern 3 times during our session

### 2. Import Organization
**Current gap**: No import organization rules
**Proposed addition**: "Group imports by: 1) External packages, 2) Internal modules, 3) Types"
**Reasoning**: You consistently reorganized imports this way

Would you like me to apply these improvements to AGENTS.md?
```
