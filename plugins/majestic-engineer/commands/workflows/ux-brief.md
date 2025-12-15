---
name: majestic:ux-brief
description: Plan UI/UX design direction through guided discovery before implementation
allowed-tools: Read, Grep, Glob, WebSearch, WebFetch
argument-hint: "[component, page, or feature to design]"
---

# Design Plan

Help users define a clear design direction through guided discovery, producing a design brief that guides implementation with the `frontend-design` skill and `ui-ux-designer` agent.

## Design Target

<design_target> $ARGUMENTS </design_target>

**If the design target above is empty, ask the user:** "What would you like to design? Describe the component, page, or feature."

Do not proceed until you have a clear design target.

## Phase 1: Context Gathering

Before asking questions, understand the project context:

1. Check for existing design tokens (tailwind.config.js, CSS variables, design-tokens.css)
2. Look at existing UI components for patterns
3. Identify the tech stack (React, Vue, Rails/Hotwire, vanilla)
4. Check for any style guides or brand documentation

Use this context to tailor questions and pre-fill obvious answers.

## Phase 2: Discovery Questions

Ask questions **ONE AT A TIME**. Prefer multiple choice when options are bounded.

### Core Design Questions

Work through these areas, skipping any already answered by context:

1. **Purpose & Goals**
   - What is this UI trying to achieve?
   - What action should users take?
   - What feeling should it evoke?

2. **Target Audience**
   - Who will use this interface?
   - What are their expectations?
   - Technical sophistication level?

3. **Aesthetic Direction**
   Pick one extreme (commit, don't hedge):
   - **Brutalist**: Raw, honest, utilitarian, high contrast
   - **Minimalist**: Restrained, precise, essential, white space
   - **Maximalist**: Bold, layered, expressive, dense
   - **Luxury**: Refined, spacious, premium, elegant
   - **Playful**: Animated, colorful, delightful, friendly
   - **Retro-futuristic**: Nostalgic tech, neon, gradients, sci-fi

4. **Typography Direction**
   - Display font preference (bold headlines vs elegant serifs)
   - Body font preference (geometric vs humanist)
   - Specific fonts they like or want to avoid

5. **Color Palette**
   - Primary brand color (if any)
   - Light or dark theme preference
   - Accent color strategy (bold vs subtle)
   - Any colors to avoid

6. **Motion & Interaction**
   - Animation intensity (none, subtle, dramatic)
   - Key moments to animate (load, hover, transitions)
   - Performance constraints

7. **Inspiration & References**
   - Sites they admire (Stripe, Linear, Vercel, Notion, etc.)
   - Specific elements they want to emulate
   - Things they explicitly want to avoid

8. **Technical Constraints**
   - Framework (Tailwind, vanilla CSS, styled-components)
   - Browser support requirements
   - Performance budgets
   - Accessibility requirements (WCAG level)

### Question Guidelines

- **ONE question per turn** - never batch questions
- **Multiple choice preferred** - when options are bounded, offer 3-4 choices
- **Skip obvious questions** - if context already answered, move on
- **Summarize every 2-3 questions** - confirm understanding before continuing
- **Research references** - if user mentions a site, fetch it to understand what they like

### Example Question Formats

**Multiple choice (preferred):**
```
**What aesthetic direction fits your vision?**
- Brutalist (raw, honest, high contrast)
- Minimalist (clean, precise, essential)
- Maximalist (bold, layered, expressive)
- Luxury (refined, spacious, elegant)
```

**Follow-up with research:**
```
You mentioned you like Linear's design. Let me look at their site...

[Fetch linear.app]

From Linear, I see: dark theme, monospace accents, subtle gradients,
confident whitespace. **Which elements appeal most?**
- The dark color scheme
- The typography choices
- The minimal animation approach
- The confident use of space
```

## Phase 3: Reference Research

When user mentions reference sites, proactively research them:

1. **Fetch the site** using WebFetch
2. **Identify specific techniques**:
   - Typography choices (font families, sizes, weights)
   - Color palette (extract key colors)
   - Layout patterns
   - Animation approaches
   - Unique details

3. **Present findings** to confirm what resonates with user

### Common Reference Sites

If user is unsure, offer these as starting points:

- **Stripe**: Clean gradients, depth, premium feel, documentation excellence
- **Linear**: Dark themes, minimal, focused, developer-oriented
- **Vercel**: Typography-forward, confident whitespace, tech-forward
- **Notion**: Friendly, approachable, illustration-forward
- **Raycast**: Dark, utility-focused, keyboard-first
- **Arc Browser**: Playful, colorful, unconventional
- **Apple**: Refined, spacious, product-focused

## Phase 4: Design Brief Generation

After gathering sufficient information, synthesize into a **Design Brief**:

```markdown
# Design Brief: [Component/Page Name]

## Overview
[1-2 sentence summary of what's being designed]

## Goals
- Primary action: [what users should do]
- Emotional response: [how it should feel]
- Business outcome: [what success looks like]

## Aesthetic Direction
**Style**: [Chosen direction - e.g., "Minimalist with luxury touches"]
**Inspiration**: [Reference sites and specific elements to emulate]

## Typography
- **Display font**: [Font name] - [why it fits]
- **Body font**: [Font name] - [why it fits]
- **Scale**: [Dramatic/moderate/subtle]

## Color Palette
- **Background**: [color]
- **Foreground**: [color]
- **Accent**: [color]
- **Supporting**: [colors]
- **Theme**: [Light/Dark/Both]

## Motion
- **Intensity**: [None/Subtle/Dramatic]
- **Key moments**: [Page load, hover states, transitions]
- **Approach**: [CSS-only, Framer Motion, GSAP, etc.]

## Layout Principles
- [Specific layout guidance]
- [Grid/spacing approach]
- [Responsive strategy]

## Anti-Patterns to Avoid
- [Specific things NOT to do based on user input]
- [Generic AI aesthetics to avoid]

## Technical Implementation
- **Framework**: [Tailwind/CSS/etc.]
- **Components**: [ViewComponent/React/Vue]
- **Accessibility**: [WCAG level]

## Reference Screenshots
[If fetched, include key observations from reference sites]
```

## Phase 5: Confirmation & Next Steps

After generating the design brief:

1. **Save the file** to `docs/design/[component-name]-brief.md`

2. **Auto-Preview Check (REQUIRED)**

   **BEFORE presenting options, you MUST:**

   1. Invoke `config-reader` agent to get merged config (base + local overrides)
   2. Check the returned config for `auto_preview: true`
   3. **If auto_preview is true:**
      - Execute: `open docs/design/[component-name]-brief.md`
      - Tell user: "Opened design brief in your editor."
      - Use the "auto-previewed" options below
   4. **If false or not found:** Use the "not auto-previewed" options below

3. **Present options** via AskUserQuestion:

**Options (if NOT auto-previewed):**
- **Preview in editor** - Open the brief file (`open <path>`)
- **Start building (Recommended)** - Invoke `skill frontend-design` then begin implementation
- **Refine sections** - Ask what to change, update brief
- **Research more** - Ask for additional reference sites

**Options (if auto-previewed):**
- **Start building (Recommended)** - Invoke `skill frontend-design` then begin implementation
- **Refine sections** - Ask what to change, update brief
- **Research more** - Ask for additional reference sites

Based on selection:
- **Preview in editor** → Run `open <path>`, then re-present options
- **Start building** → Invoke `skill frontend-design` then begin implementation
- **Refine** → Ask what to change, update brief
- **Research more** → Ask for additional reference sites

## Output Location

Save design briefs to: `docs/design/[component-name]-brief.md`

## Integration with Design Tools

After completing the brief:

1. **For implementation**: Recommend invoking `skill frontend-design`
2. **For iteration**: Recommend using `ui-ux-designer` agent with the brief as context
3. **For validation**: Recommend `visual-validator` agent after implementation

## Key Principles

- **Commit to a direction** - Avoid wishy-washy "a bit of everything" designs
- **Avoid AI slop** - No Inter font, no purple gradients, no predictable layouts
- **Research references** - Actually look at the sites users mention
- **Be opinionated** - Push back on generic choices, suggest distinctive alternatives
- **Context-specific** - A fintech app needs different design than a gaming community
