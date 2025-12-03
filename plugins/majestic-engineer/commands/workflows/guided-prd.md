---
name: majestic:guided-prd
description: Discover and refine a product idea through guided questioning, then generate a PRD
allowed-tools: AskUserQuestion, SlashCommand, Read, Grep, Glob
---

# Guided PRD Discovery

Help users discover and refine their product idea through incremental questioning, then feed the refined description into `/majestic:prd` for PRD generation.

## Phase 1: Context Gathering

Before asking questions, understand the project context:

1. Check for README.md, CLAUDE.md, or docs/ directory
2. Look at recent commits or changes
3. Identify the tech stack and domain

Use this context to tailor questions and skip obvious ones.

## Phase 2: Discovery Questions

Ask questions **ONE AT A TIME**. Prefer multiple choice when options are bounded.

### Core Questions to Cover

Work through these areas, skipping any already answered by context:

1. **Problem/Opportunity**
   - What problem are you solving?
   - Who experiences this problem?
   - How painful is it currently?

2. **Solution Concept**
   - How does your product/feature solve this?
   - What's the core insight or approach?

3. **Target Users**
   - Who specifically will use this? (roles, personas)
   - What's their technical level?
   - How do they currently solve this problem?

4. **Core Capabilities**
   - What are the 3-5 must-have features?
   - What explicitly is NOT included in v1?

5. **Success Criteria**
   - How will you know it's working?
   - What metrics matter?
   - What does "done" look like?

6. **Constraints**
   - Technical constraints (stack, integrations)?
   - Time or resource constraints?
   - Dependencies on other work?

7. **Integrations**
   - Does it need to work with existing systems?
   - External APIs or services?

### Question Guidelines

- **ONE question per turn** - never batch questions
- **Multiple choice preferred** - when options are bounded, offer 3-4 choices
- **Skip obvious questions** - if context already answered, move on
- **Summarize every 2-3 questions** - confirm understanding before continuing
- **Adapt based on answers** - follow interesting threads, skip irrelevant areas

### Example Question Formats

**Multiple choice (preferred):**
```
**What type of product is this?**
- New standalone application
- Feature for existing product
- Internal tool
- API/service
```

**Open-ended (when needed):**
```
**Describe the core problem in one sentence.**
```

**Follow-up:**
```
You mentioned mobile users abandon carts. **What's your hypothesis for why?**
- Checkout form is too long
- Payment options aren't mobile-friendly
- Page load times are slow
- Trust signals aren't visible
```

## Phase 3: Synthesis

After gathering sufficient information:

1. **Summarize** what you've learned in a structured format:
   - Problem statement (1-2 sentences)
   - Target users (who, technical level)
   - Core solution (what it does)
   - Must-have features (3-5 bullets)
   - Success criteria (measurable)
   - Key constraints

2. **Present** a refined product description (2-3 paragraphs) suitable for PRD generation

3. **Confirm** with user:
   ```
   Does this capture your idea? I can:
   - Refine specific sections
   - Proceed to generate the full PRD
   ```

## Phase 4: Handoff to /prd

When user confirms, execute the PRD command:

```
Use SlashCommand to execute: /majestic:prd [refined description]
```

The `/majestic:prd` command will:
- Ask its own clarifying questions if needed
- Generate a comprehensive PRD document
- Save to `docs/prd/prd-[feature-name].md`

## Example Interaction

```
User: /guided-prd

Claude: I'll help you discover and refine your product idea. Let me check
the project context first...

[Reads README, identifies Rails e-commerce app]

I see this is a Rails e-commerce application. Let's start with the basics.

**What problem are you trying to solve?**
- Customers abandon carts due to complex checkout
- Inventory management is manual and error-prone
- No way to offer personalized recommendations
- Something else (describe)

User: Cart abandonment

Claude: Cart abandonment is a significant revenue issue.

**Who specifically experiences this problem most?**
- First-time visitors
- Returning customers who haven't purchased recently
- Mobile users specifically
- All customer segments equally

User: Mobile users

Claude: Let me summarize what we have so far:
- **Problem**: Mobile users abandon carts at high rates
- **Context**: Existing Rails e-commerce application

**What's your hypothesis for why mobile users abandon?**
- Checkout form is too long on mobile
- Payment options aren't mobile-friendly (no Apple/Google Pay)
- Page load times are slow
- Trust signals aren't visible on small screens
- Multiple factors (tell me more)

User: Checkout is too long and no mobile payments

Claude: That's actionable. Two clear issues: form length and payment options.

**What does success look like for this project?**
- Reduce mobile cart abandonment by X%
- Increase mobile conversion rate
- Improve checkout completion time
- All of the above with specific targets

User: Reduce abandonment by 20% in 30 days

Claude: Clear success criteria. Let me confirm what we've discovered:

---

**Product: Mobile Checkout Optimization**

**Problem**: Mobile users abandon carts at a high rate due to a lengthy
checkout form and lack of mobile-native payment options like Apple Pay
and Google Pay.

**Solution**: Streamline the mobile checkout experience with:
- Single-page checkout flow (reduce form fields)
- Apple Pay and Google Pay integration
- Progress indicators for remaining steps
- Mobile-optimized trust signals

**Target Users**: Mobile shoppers on the existing e-commerce platform

**Success Criteria**: 20% reduction in mobile cart abandonment within 30 days

**Constraints**: Must integrate with existing Rails backend and payment
processing infrastructure.

---

Does this capture your idea? I can refine specific sections or proceed
to generate the full PRD.

User: Looks good, generate the PRD

Claude: [Executes /majestic-engineer:workflows:prd with the refined description]
```

## Key Principles

- **Efficient, not exhaustive** - Skip questions when context provides answers
- **Conversational, not interrogative** - Build on previous answers naturally
- **Multiple choice when possible** - Faster for users, clearer options
- **Summarize frequently** - Confirm understanding, catch misalignments early
- **End with a clear description** - Ready for `/majestic:prd` to process
