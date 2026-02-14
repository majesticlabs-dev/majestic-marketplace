---
name: majestic:startup-blueprint
description: Interactive 7-phase startup planning tailored to skills, budget, and goals
argument-hint: "[optional: industry, idea, or constraints to start with]"
---

# Startup Blueprint

Launch the startup-blueprint agent to create a complete business blueprint.

```
CONTEXT = $ARGUMENTS or ""

Task(subagent_type: "majestic-company:ceo:startup-blueprint",
  prompt: "Create a startup blueprint. User context: {CONTEXT}")
```
