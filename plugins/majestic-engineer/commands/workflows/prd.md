---
name: majestic:prd
description: Create a Product Requirements Document (PRD) for a new product or feature
argument-hint: "[--guided] [product or feature description]"
allowed-tools: Read, Write, Edit, WebSearch, WebFetch, AskUserQuestion
---

# Create a Product Requirements Document (PRD)

Generate a comprehensive PRD that defines WHAT to build and WHY.

## Arguments

<raw_arguments>$ARGUMENTS</raw_arguments>

- If `--guided`: Enable guided discovery (one question at a time)
- Otherwise: Batch 3-5 questions upfront

---

## Phase 1: Clarifying Questions

### Default Mode

Use `AskUserQuestion` to ask 3-5 essential questions **in a single batch**:

- **Problem/Goal**: What problem does this solve?
- **Target Users**: Who will use this?
- **MVP Boundaries**: What's the minimum to ship?
- **Success Criteria**: How will we measure success?
- **Technical Context**: Any existing systems to integrate?

### Guided Mode (`--guided`)

Ask questions **ONE AT A TIME**:

1. **Problem/Opportunity** - What problem, who experiences it, how painful?
2. **Solution Concept** - How does your product solve this?
3. **Target Users** - Who specifically, technical level, current workaround?
4. **Core Capabilities** - 3-5 must-have features, what's NOT in v1?
5. **Success Criteria** - How will you know it's working?
6. **Constraints** - Technical, time, resource, dependencies?

After sufficient info, synthesize and confirm before PRD generation.

---

## Phase 2: Generate PRD

Read the PRD template from `resources/prd/prd-template.txt` (relative to this command file).

Customize with user's answers:
- Fill in problem statement, user personas
- Write user stories with acceptance criteria
- Prioritize features using MoSCoW
- Set success metrics

---

## Phase 3: Review & Options

1. **Save** to `docs/prd/prd-[feature-name].md`

2. **Auto-Preview Check**
   Read: !`claude -p "/majestic:config auto_preview false"`
   If "true": Execute `open docs/prd/prd-[feature-name].md`

3. **Present options** via AskUserQuestion:
   - **Done (Recommended)** - Balanced PRD is sufficient
   - **Expand with technical depth** - Add API, Data Model, Security, Performance sections
   - **Revise sections** - Provide feedback on specific sections
   - **Preview in editor** (if not auto-previewed)

---

## Phase 4: Technical Expansion (If Requested)

Add sections from `resources/prd/technical-expansion.txt`:
- API Specifications (endpoints, schemas, auth)
- Data Model with Mermaid ERD
- Security Considerations (AuthN/AuthZ, OWASP)
- Performance & Scalability (SLOs, scaling strategy)

---

## Phase 5: Create Backlog Items (Optional)

Offer backlog creation:
- **Create Must Have items** - From Must Have features only
- **Create all items** - From all prioritized features
- **Skip**

If accepted:
1. Read backlog configuration from project CLAUDE.md
2. For each user story/feature:
   - Extract title and acceptance criteria
   - Set priority (Must=p1, Should=p2, Could=p3)
   - Create item using configured backend

---

## Output

Save to: `docs/prd/prd-[feature-name].md`

Create directory if needed.
