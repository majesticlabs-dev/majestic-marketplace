# AGENTS.md Best Practices

## Constraints

| Constraint | Reason |
|------------|--------|
| **Under 300 lines** | Ideally 60-100 for simple projects |
| **~100 usable instructions** | Claude's ~150 limit minus ~50 system prompt |
| **Universal rules only** | Claude is told context "may or may not be relevant" - non-universal = ignored |
| **No config data** | Config belongs in `.agents.yml` |
| **Manual > auto-generated** | Hand-crafted instructions get more leverage |

## The WHAT/WHY/HOW Framework

```markdown
# Project Name

Ask more questions until you have enough context to give an accurate & confident answer.

## WHAT (Architecture)
- Tech stack, project structure
- Major directories and their purpose

## WHY (Purpose)
- What this project does
- Where to find relevant code

## HOW (Workflows)
- Essential commands (build, test, lint)
- Verification procedures
```
