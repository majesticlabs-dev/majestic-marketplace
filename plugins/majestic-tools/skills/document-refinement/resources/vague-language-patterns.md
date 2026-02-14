# Vague Language Patterns

Patterns that indicate insufficient specificity in technical documents.

## Qualifier Words

Flag these when they weaken a requirement:

| Pattern | Problem | Better |
|---------|---------|--------|
| "should" (in requirements) | Non-binding | "must" or "returns X" |
| "appropriate" | Undefined standard | State the specific standard |
| "properly" | Subjective | Define the specific behavior |
| "as needed" | Who decides? When? | "when X occurs" or "if Y > threshold" |
| "etc." | Incomplete list | List all items or state boundary |
| "various" | How many? Which? | Name them specifically |
| "some" | Unquantified | "3-5" or "at least N" |
| "relevant" | Relevant to whom? | Specify the context or criteria |

## Hedge Phrases

Flag entire phrases that defer decisions:

| Pattern | Problem | Better |
|---------|---------|--------|
| "handle errors appropriately" | No error strategy defined | "return 422 with {field: message} JSON" |
| "consider performance" | No target set | "P95 latency < 200ms" |
| "may need to" | Deferred decision | Decide now or create explicit spike task |
| "TBD" / "TODO" | Unresolved in shipped doc | Resolve or move to explicit backlog item |
| "similar to X" | Undefined delta | Specify exactly how it differs from X |
| "good user experience" | Subjective | Define specific UX criteria |
| "scalable solution" | No scale target | "handles 10K concurrent users" |
| "clean architecture" | Opinion, not spec | Name the specific pattern |

## When NOT to Flag

Acceptable vagueness in these contexts:
- **Risk sections**: "may cause issues if..." is correctly hedged uncertainty
- **Explicit deferral**: "Deferred to Phase 2: [specific item]" with tracking
- **Brainstorm documents**: Looser language acceptable in early ideation
  - Still flag in brainstorm: completely undefined terms, missing problem statement
- **Alternative analysis**: "could use X or Y" when presenting options (not when specifying)
- **Known unknowns**: "Requires spike: [question]" with clear next action
