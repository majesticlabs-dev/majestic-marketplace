---
name: devils-advocate
description: Forces adversarial reasoning before committing to decisions. Triggers on architectural choices, approach selection, and planning phases to prevent premature commitment bias.
---

# Devil's Advocate Protocol

Pre-commitment adversarial reasoning to prevent early lock-in and expose blind spots.

## When to Apply

Activate this protocol when:
- Choosing between architectural approaches
- Selecting libraries, frameworks, or tools
- Planning implementation strategy
- Recommending one approach over alternatives
- User asks "should I...", "what's the best way to...", "which approach..."
- During `architect`, `Plan`, or `blueprint` workflows
- Making trade-off decisions with non-obvious answers

## When to Skip

Do NOT apply when:
- Executing already-decided implementation
- Single obvious path exists (no real alternatives)
- User explicitly chose the approach ("use X to do Y")
- Task is mechanical/procedural, not decisional
- Trivial choices with negligible impact

## The Protocol

### Step 1: Identify the Commitment

Before recommending an approach, explicitly state:
- What decision is being made
- What approach you're inclined toward
- Why you're drawn to it

### Step 2: Steel-Man the Opposition

Present the **strongest case AGAINST** your inclination:
- What could go wrong?
- What are you assuming that might be false?
- What would a smart critic say?
- What's the opportunity cost?
- Under what conditions would this fail?

Requirements:
- Be genuinely adversarial, not token objections
- Attack the strongest version of your argument
- Include at least one non-obvious failure mode

### Step 3: Defend or Pivot

After the adversarial pass:
- Explain why the approach might still be correct despite objections
- What conditions make this the right choice?
- What would need to be true for alternatives to win?
- OR: Acknowledge the objections changed your recommendation

### Step 4: Present with Confidence Calibration

Final recommendation should include:
- Clear recommendation with reasoning
- Key assumptions that must hold
- Conditions that would invalidate this choice
- Monitoring signals to watch for

## Output Format

```markdown
## Decision: [What's being decided]

### Initial Inclination
[Approach] because [reasons]

### Adversarial Challenge
**Against this approach:**
- [Strong objection 1]
- [Strong objection 2]
- [Non-obvious failure mode]

**What I might be wrong about:**
- [Assumption that could be false]

### Resolution
[Why it's still correct OR why I'm changing recommendation]

### Recommendation: [Final choice]
- **Key assumptions:** [What must be true]
- **Watch for:** [Signals this was wrong]
```

## Relationship to Other Tools

- **reasoning-verifier**: Post-hoc verification of completed reasoning
- **devils-advocate**: Pre-commitment challenge before reasoning solidifies
- Use both: devils-advocate during planning, reasoning-verifier after execution

## Underlying Principle

LLMs commit to answers early and rationalize backward. This protocol interrupts that pattern by forcing exploration of the solution space before commitment crystallizes.
