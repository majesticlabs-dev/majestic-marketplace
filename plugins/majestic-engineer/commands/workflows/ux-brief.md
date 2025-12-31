---
name: majestic:ux-brief
description: Create junior-dev-ready design systems through guided discovery before implementation
allowed-tools: Read, Write, Edit, Grep, Glob, WebSearch, WebFetch, AskUserQuestion, Task, Skill
argument-hint: "[component, page, or feature to design]"
---

# Design System Generator

Create comprehensive, junior-dev-ready design system documents through guided discovery.

## Design Target

<design_target> $ARGUMENTS </design_target>

**If empty, ask:** "What would you like to design? Describe the component, page, or feature."

## Phase 1: Context Gathering

Before asking questions, understand the project:

1. Check for existing design tokens (tailwind.config.js, CSS variables)
2. Look at existing UI components for patterns
3. Identify tech stack (React, Vue, Rails/Hotwire, vanilla)
4. Check for style guides or brand documentation

## Phase 2: Discovery Questions

Ask questions **ONE AT A TIME**. Prefer multiple choice when options are bounded.

### Question Areas

1. **Purpose & Goals** - What is this UI trying to achieve?
2. **Target Audience** - Who will use this interface?
3. **Aesthetic Direction** - Pick one: Brutalist, Minimalist, Maximalist, Luxury, Playful, Retro-futuristic
4. **Typography** - Display and body font preferences
5. **Color Palette** - Primary brand color, light/dark theme, accent strategy
6. **Motion & Interaction** - Animation intensity (none, subtle, dramatic)
7. **Inspiration & References** - Sites they admire (Stripe, Linear, Vercel, etc.)
8. **Technical Constraints** - Browser support, performance, accessibility (WCAG level)
9. **Framework** (REQUIRED) - Based on tech_stack, suggest:
   - `rails` → DaisyUI + Tailwind
   - `react` → Tailwind or styled-components
   - Default → Plain Tailwind

### Visual Language Questions (if comprehensive design system needed)

10. **Photography style** - "What mood should photos convey?"
    - Options: Authentic/candid, Editorial/staged, Abstract/artistic, Product-focused, People-focused

11. **Illustration style** - "Do you need illustrations? If so, what style?"
    - Options: None needed, Geometric/clean, Organic/hand-drawn, Isometric/3D, Flat/minimal

12. **Iconography** - "What icon style fits your brand?"
    - Options: Outlined (Heroicons), Filled (solid), Duotone (Phosphor), Custom/branded

### Question Guidelines

- **ONE question per turn**
- **Multiple choice preferred**
- **Skip obvious questions** from context
- **Summarize every 2-3 questions**
- **Research references** - if user mentions a site, fetch it

## Phase 3: Reference Research

When user mentions reference sites:

1. Fetch the site using WebFetch
2. Identify: typography, color palette, layout patterns, animation, unique details
3. Present findings to confirm what resonates

### Common References

- **Stripe**: Clean gradients, depth, premium, documentation excellence
- **Linear**: Dark themes, minimal, focused, developer-oriented
- **Vercel**: Typography-forward, confident whitespace
- **Notion**: Friendly, approachable, illustration-forward
- **Raycast**: Dark, utility-focused, keyboard-first

## Phase 4: Design System Generation

After gathering information, invoke the ux-brief skill for the template:

```
Skill(skill="ux-brief")
```

Then read and customize the template at `@plugins/majestic-engineer/skills/ux-brief/resources/design-system-template.md` with the user's specific choices:

- Replace all `[placeholder]` values with actual design decisions
- Fill in color hex values based on palette
- Configure typography choices
- Customize component specifications
- Add project-specific do's and don'ts

Write the completed design system to `docs/design/design-system.md`.

## Phase 5: Save & Configure

### Step 1: Determine Output Path

Check `.agents.yml` for `design_system_path`, default to `docs/design/design-system.md`.

### Step 2: Auto-Preview Check

Read auto_preview config: !`claude -p "/majestic:config auto_preview false"`

If "true": Execute `open <design-system-path>`

### Step 3: Present Options

Use AskUserQuestion:

**If NOT auto-previewed:**
- Preview in editor
- Start building (Recommended) - Invoke `skill frontend-design`
- Refine sections
- Research more

**If auto-previewed:**
- Start building (Recommended)
- Refine sections
- Research more

## Integration with Workflow

After completing the design system:

1. **`/majestic:blueprint`** - Automatically detects UI features and references design system
2. **`/majestic:build-task`** - Loads design system as context
3. **`visual-validator`** - Verifies implementation against specifications

## Key Principles

- **Commit to a direction** - Avoid wishy-washy designs
- **Avoid AI slop** - No Inter font, no purple gradients
- **Research references** - Actually look at sites users mention
- **Be opinionated** - Push back on generic choices
- **Junior-dev ready** - Document so complete no follow-up needed
- **Copy-paste ready** - All classes and configs directly usable
