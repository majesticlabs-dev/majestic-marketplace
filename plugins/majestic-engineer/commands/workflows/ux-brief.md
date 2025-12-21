---
name: majestic:ux-brief
description: Create junior-dev-ready design systems through guided discovery before implementation
allowed-tools: Read, Write, Edit, Grep, Glob, WebSearch, WebFetch, AskUserQuestion, Task
argument-hint: "[component, page, or feature to design]"
---

# Design System Generator

Create comprehensive, junior-dev-ready design system documents through guided discovery. The output is detailed enough that a developer won't have questions about what UI rules to apply.

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
   - Browser support requirements
   - Performance budgets
   - Accessibility requirements (WCAG level)

9. **Framework & Implementation** (REQUIRED)
   Ask about CSS framework preference. Suggest defaults based on `tech_stack` from `.agents.yml`:
   - `tech_stack: rails` → Suggest DaisyUI + Tailwind
   - `tech_stack: react` → Suggest Tailwind or styled-components
   - `tech_stack: node` with Next.js → Suggest Tailwind
   - Default → Suggest plain Tailwind

   Options to present:
   - **DaisyUI + Tailwind** - Component classes + utilities (Recommended for Rails)
   - **Plain Tailwind** - Utility-first only
   - **CSS Variables + Tailwind** - Custom properties with utilities
   - **Other** - Ask for specification

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

## Phase 4: Design System Generation

After gathering sufficient information, synthesize into a **comprehensive Design System**.

**This document must be detailed enough that a junior developer has no questions about what UI rules to apply.**

### Design System Template

Write the following markdown structure to `docs/design/design-system.md`:

```markdown
# Design System: [Project Name]

> [1-2 sentence design philosophy summary]

## Quick Reference

Copy-paste ready classes for common elements:

| Element | Classes |
|---------|---------|
| Primary Button | `btn btn-primary` or `px-4 py-2 bg-primary text-white rounded-lg hover:bg-primary/90` |
| Secondary Button | `btn btn-secondary` or `px-4 py-2 bg-secondary text-secondary-content rounded-lg` |
| Text Input | `input input-bordered` or `w-full px-3 py-2 border border-base-300 rounded-lg` |
| Card | `card bg-base-100 shadow-md` or `bg-white rounded-xl shadow-md p-6` |
| Page Container | `container mx-auto px-4 max-w-6xl` |

---

## Color System

### Primary Colors

| Name | HEX | OKLCH | CSS Variable | Tailwind | Usage |
|------|-----|-------|--------------|----------|-------|
| Primary | #[hex] | oklch([l]% [c] [h]) | --color-primary | bg-primary | Main CTAs, key actions |
| Primary Content | #[hex] | oklch([l]% [c] [h]) | --color-primary-content | text-primary-content | Text on primary |
| Primary Focus | #[hex] | oklch([l]% [c] [h]) | --color-primary-focus | bg-primary/90 | Hover state |

### Secondary Colors

| Name | HEX | OKLCH | CSS Variable | Tailwind | Usage |
|------|-----|-------|--------------|----------|-------|
| Secondary | #[hex] | oklch([l]% [c] [h]) | --color-secondary | bg-secondary | Secondary actions |
| Secondary Content | #[hex] | oklch([l]% [c] [h]) | --color-secondary-content | text-secondary-content | Text on secondary |

### Semantic Colors

| Name | HEX | Background | Text | Border | Usage |
|------|-----|------------|------|--------|-------|
| Info | #[hex] | bg-info | text-info-content | border-info | Informational alerts |
| Success | #[hex] | bg-success | text-success-content | border-success | Success states |
| Warning | #[hex] | bg-warning | text-warning-content | border-warning | Warning states |
| Error | #[hex] | bg-error | text-error-content | border-error | Error states, destructive |

### Base Colors

| Name | HEX | CSS Variable | Tailwind | Usage |
|------|-----|--------------|----------|-------|
| Base 100 | #[hex] | --color-base-100 | bg-base-100 | Primary background |
| Base 200 | #[hex] | --color-base-200 | bg-base-200 | Secondary background |
| Base 300 | #[hex] | --color-base-300 | bg-base-300 | Borders, dividers |
| Base Content | #[hex] | --color-base-content | text-base-content | Primary text |
| Neutral | #[hex] | --color-neutral | bg-neutral | Subtle backgrounds |
| Neutral Content | #[hex] | --color-neutral-content | text-neutral-content | Subtle text |

---

## Typography

### Font Stack

```css
--font-sans: '[Primary Font]', '[Fallback]', ui-sans-serif, system-ui, sans-serif;
--font-display: '[Display Font]', '[Fallback]', ui-sans-serif, sans-serif;
--font-mono: '[Mono Font]', ui-monospace, monospace;
```

**Tailwind config:**
```javascript
fontFamily: {
  sans: ['[Primary Font]', '[Fallback]', 'ui-sans-serif', 'system-ui', 'sans-serif'],
  display: ['[Display Font]', '[Fallback]', 'ui-sans-serif', 'sans-serif'],
  mono: ['[Mono Font]', 'ui-monospace', 'monospace'],
}
```

### Type Scale

| Name | Size | Weight | Line Height | Letter Spacing | Tailwind | Usage |
|------|------|--------|-------------|----------------|----------|-------|
| Display | 48px / 3rem | 700 | 1.1 | -0.02em | text-5xl font-bold tracking-tight | Hero headlines |
| H1 | 36px / 2.25rem | 600 | 1.2 | -0.01em | text-4xl font-semibold | Page titles |
| H2 | 30px / 1.875rem | 600 | 1.25 | 0 | text-3xl font-semibold | Section headers |
| H3 | 24px / 1.5rem | 600 | 1.3 | 0 | text-2xl font-semibold | Subsections |
| H4 | 20px / 1.25rem | 500 | 1.4 | 0 | text-xl font-medium | Card titles |
| Body | 16px / 1rem | 400 | 1.6 | 0 | text-base | Paragraphs |
| Body Small | 14px / 0.875rem | 400 | 1.5 | 0 | text-sm | Secondary text |
| Caption | 12px / 0.75rem | 500 | 1.4 | 0.02em | text-xs font-medium tracking-wide | Labels, captions |

---

## Spacing System

Base unit: **4px**

| Name | Value | Tailwind | Usage |
|------|-------|----------|-------|
| 0 | 0px | p-0, m-0, gap-0 | Reset |
| 1 | 4px | p-1, m-1, gap-1 | Tight spacing |
| 2 | 8px | p-2, m-2, gap-2 | Icon gaps, inline elements |
| 3 | 12px | p-3, m-3, gap-3 | Small component padding |
| 4 | 16px | p-4, m-4, gap-4 | Standard component padding |
| 5 | 20px | p-5, m-5, gap-5 | Medium spacing |
| 6 | 24px | p-6, m-6, gap-6 | Card padding, section gaps |
| 8 | 32px | p-8, m-8, gap-8 | Large section spacing |
| 10 | 40px | p-10, m-10, gap-10 | Major section breaks |
| 12 | 48px | p-12, m-12, gap-12 | Page section spacing |
| 16 | 64px | p-16, m-16, gap-16 | Hero spacing |

### Component Spacing Rules

| Component | Padding | Gap | Margin |
|-----------|---------|-----|--------|
| Button (sm) | py-1.5 px-3 | gap-1.5 | — |
| Button (md) | py-2 px-4 | gap-2 | — |
| Button (lg) | py-3 px-6 | gap-2 | — |
| Input | py-2 px-3 | — | — |
| Card | p-6 | gap-4 | — |
| Form field stack | — | gap-1.5 | mb-4 |
| Section | py-12 | gap-8 | — |

---

## Border Radius Scale

| Name | Value | Tailwind | Usage |
|------|-------|----------|-------|
| None | 0 | rounded-none | Sharp edges |
| Small | 4px | rounded-sm | Subtle rounding |
| Default | 8px | rounded-lg | Buttons, inputs |
| Medium | 12px | rounded-xl | Cards |
| Large | 16px | rounded-2xl | Modals, large cards |
| Full | 9999px | rounded-full | Pills, avatars |

---

## Shadow / Elevation Scale

| Level | Tailwind | CSS | Usage |
|-------|----------|-----|-------|
| 0 | shadow-none | none | Flat elements |
| 1 | shadow-sm | 0 1px 2px rgba(0,0,0,0.05) | Subtle lift |
| 2 | shadow-md | 0 4px 6px rgba(0,0,0,0.1) | Cards, dropdowns |
| 3 | shadow-lg | 0 10px 15px rgba(0,0,0,0.1) | Modals, popovers |
| 4 | shadow-xl | 0 20px 25px rgba(0,0,0,0.15) | Floating elements |

---

## Component Specifications

### Buttons

#### Size Variants

| Size | Height | Padding | Font Size | Icon Size | Tailwind |
|------|--------|---------|-----------|-----------|----------|
| xs | 24px | py-1 px-2 | 12px | 14px | btn btn-xs |
| sm | 32px | py-1.5 px-3 | 14px | 16px | btn btn-sm |
| md | 40px | py-2 px-4 | 14px | 18px | btn btn-md |
| lg | 48px | py-3 px-6 | 16px | 20px | btn btn-lg |

#### Button States - Primary

| State | Background | Text | Border | Shadow | Cursor | Other |
|-------|------------|------|--------|--------|--------|-------|
| Default | bg-primary | text-primary-content | none | shadow-sm | pointer | — |
| Hover | bg-primary/90 | text-primary-content | none | shadow-md | pointer | scale-[1.02] |
| Focus | bg-primary | text-primary-content | ring-2 ring-primary/50 ring-offset-2 | shadow-sm | pointer | outline-none |
| Active | bg-primary/80 | text-primary-content | none | shadow-none | pointer | scale-[0.98] |
| Disabled | bg-primary/50 | text-primary-content/50 | none | none | not-allowed | opacity-50 |
| Loading | bg-primary | text-primary-content | none | shadow-sm | wait | spinner visible |

#### Button States - Secondary

| State | Background | Text | Border | Shadow | Cursor |
|-------|------------|------|--------|--------|--------|
| Default | bg-secondary | text-secondary-content | none | shadow-sm | pointer |
| Hover | bg-secondary/90 | text-secondary-content | none | shadow-md | pointer |
| Focus | bg-secondary | text-secondary-content | ring-2 ring-secondary/50 | shadow-sm | pointer |
| Active | bg-secondary/80 | text-secondary-content | none | none | pointer |
| Disabled | bg-secondary/50 | text-secondary-content/50 | none | none | not-allowed |

#### Button States - Ghost/Outline

| State | Background | Text | Border | Shadow |
|-------|------------|------|--------|--------|
| Default | transparent | text-base-content | border border-base-300 | none |
| Hover | bg-base-200 | text-base-content | border border-base-300 | none |
| Focus | transparent | text-base-content | ring-2 ring-primary/50 | none |
| Active | bg-base-300 | text-base-content | border border-base-300 | none |
| Disabled | transparent | text-base-content/50 | border border-base-300/50 | none |

### Form Inputs

#### Size Variants

| Size | Height | Padding | Font Size | Tailwind |
|------|--------|---------|-----------|----------|
| sm | 32px | py-1.5 px-3 | 14px | input input-sm |
| md | 40px | py-2 px-3 | 14px | input input-md |
| lg | 48px | py-3 px-4 | 16px | input input-lg |

#### Input States

| State | Background | Text | Border | Shadow | Placeholder |
|-------|------------|------|--------|--------|-------------|
| Default | bg-base-100 | text-base-content | border-base-300 | none | text-base-content/50 |
| Hover | bg-base-100 | text-base-content | border-base-content/30 | none | text-base-content/50 |
| Focus | bg-base-100 | text-base-content | border-primary ring-2 ring-primary/20 | none | text-base-content/50 |
| Filled | bg-base-100 | text-base-content | border-base-300 | none | — |
| Error | bg-error/5 | text-base-content | border-error | none | text-base-content/50 |
| Success | bg-success/5 | text-base-content | border-success | none | text-base-content/50 |
| Disabled | bg-base-200 | text-base-content/50 | border-base-300/50 | none | text-base-content/30 |
| Read-only | bg-base-200 | text-base-content | border-base-300 | none | — |

#### Form Labels

| Element | Classes | Example |
|---------|---------|---------|
| Label | text-sm font-medium text-base-content | `<label class="...">Email</label>` |
| Required indicator | text-error ml-0.5 | `<span class="...">*</span>` |
| Helper text | text-sm text-base-content/70 mt-1 | `<p class="...">We'll never share your email.</p>` |
| Error message | text-sm text-error mt-1 | `<p class="...">Email is required.</p>` |

### Cards

#### Variants

| Variant | Classes | Usage |
|---------|---------|-------|
| Default | bg-base-100 rounded-xl shadow-md p-6 | Standard content card |
| Bordered | bg-base-100 rounded-xl border border-base-300 p-6 | Subtle card |
| Compact | bg-base-100 rounded-lg shadow-sm p-4 | List items |
| Elevated | bg-base-100 rounded-xl shadow-lg p-6 | Featured content |

#### Card Anatomy

```html
<div class="card bg-base-100 shadow-md">
  <figure class="px-6 pt-6"><!-- Optional image --></figure>
  <div class="card-body p-6">
    <h3 class="card-title text-xl font-semibold">Title</h3>
    <p class="text-base-content/70">Description text</p>
    <div class="card-actions justify-end mt-4">
      <!-- Buttons -->
    </div>
  </div>
</div>
```

### Alerts / Notifications

| Variant | Background | Border | Icon | Text |
|---------|------------|--------|------|------|
| Info | bg-info/10 | border-l-4 border-info | info icon, text-info | text-info-content |
| Success | bg-success/10 | border-l-4 border-success | check icon, text-success | text-success-content |
| Warning | bg-warning/10 | border-l-4 border-warning | warning icon, text-warning | text-warning-content |
| Error | bg-error/10 | border-l-4 border-error | error icon, text-error | text-error-content |

---

## Do's and Don'ts

### Color Usage

✓ **Do:**
- Use primary color for main CTAs only (one per view)
- Use semantic colors consistently (error = destructive, success = positive)
- Maintain 4.5:1 contrast ratio for text

✗ **Don't:**
- Use primary color for everything
- Mix semantic colors (error button with success icon)
- Use pure black (#000) for text unless intentional

### Typography

✓ **Do:**
- Use display font for hero headlines only
- Maintain consistent heading hierarchy (H1 → H2 → H3)
- Use font-medium or font-semibold for emphasis, not bold

✗ **Don't:**
- Use more than 2 font families
- Skip heading levels (H1 → H3)
- Use font-light for body text (readability)

### Spacing

✓ **Do:**
- Use 4px grid consistently
- Give content room to breathe (generous whitespace)
- Group related elements with tighter spacing

✗ **Don't:**
- Use arbitrary values (13px, 7px)
- Crowd elements together
- Mix spacing scales inconsistently

### Components

✓ **Do:**
- Use consistent border-radius per component type
- Show clear focus states for accessibility
- Provide feedback for all interactive states

✗ **Don't:**
- Mix rounded and sharp corners randomly
- Rely only on color for state changes
- Disable focus outlines without alternatives

---

## Framework Configuration

### DaisyUI Theme (tailwind.config.js)

```javascript
module.exports = {
  content: [/* your content paths */],
  theme: {
    extend: {
      fontFamily: {
        sans: ['[Primary Font]', 'ui-sans-serif', 'system-ui', 'sans-serif'],
        display: ['[Display Font]', 'ui-sans-serif', 'sans-serif'],
      },
    },
  },
  plugins: [require('daisyui')],
  daisyui: {
    themes: [
      {
        [theme-name]: {
          'primary': '#[hex]',
          'primary-content': '#[hex]',
          'secondary': '#[hex]',
          'secondary-content': '#[hex]',
          'accent': '#[hex]',
          'accent-content': '#[hex]',
          'neutral': '#[hex]',
          'neutral-content': '#[hex]',
          'base-100': '#[hex]',
          'base-200': '#[hex]',
          'base-300': '#[hex]',
          'base-content': '#[hex]',
          'info': '#[hex]',
          'info-content': '#[hex]',
          'success': '#[hex]',
          'success-content': '#[hex]',
          'warning': '#[hex]',
          'warning-content': '#[hex]',
          'error': '#[hex]',
          'error-content': '#[hex]',
          '--rounded-box': '12px',
          '--rounded-btn': '8px',
          '--rounded-badge': '9999px',
          '--animation-btn': '0.2s',
          '--animation-input': '0.2s',
          '--btn-focus-scale': '0.98',
          '--border-btn': '1px',
          '--tab-border': '1px',
          '--tab-radius': '8px',
        },
      },
    ],
  },
}
```

### CSS Variables Alternative

```css
:root {
  /* Colors */
  --color-primary: #[hex];
  --color-primary-content: #[hex];
  --color-secondary: #[hex];
  --color-base-100: #[hex];
  --color-base-200: #[hex];
  --color-base-300: #[hex];
  --color-base-content: #[hex];

  /* Typography */
  --font-sans: '[Primary Font]', ui-sans-serif, system-ui, sans-serif;
  --font-display: '[Display Font]', ui-sans-serif, sans-serif;

  /* Spacing */
  --spacing-unit: 4px;

  /* Border Radius */
  --radius-sm: 4px;
  --radius-md: 8px;
  --radius-lg: 12px;
  --radius-xl: 16px;
  --radius-full: 9999px;
}
```

---

## Motion Guidelines

**Intensity:** [None/Subtle/Dramatic]

### Timing Functions

| Name | Value | Usage |
|------|-------|-------|
| Ease out | cubic-bezier(0.0, 0.0, 0.2, 1) | Entering elements |
| Ease in | cubic-bezier(0.4, 0.0, 1, 1) | Exiting elements |
| Ease in-out | cubic-bezier(0.4, 0.0, 0.2, 1) | Moving elements |

### Duration Scale

| Name | Duration | Usage |
|------|----------|-------|
| Instant | 0ms | Immediate feedback |
| Fast | 100ms | Micro-interactions (hover, toggle) |
| Normal | 200ms | Standard transitions |
| Slow | 300ms | Complex animations |
| Slower | 500ms | Page transitions |

### Key Animations

| Moment | Animation | Duration | Easing |
|--------|-----------|----------|--------|
| Page load | Fade in + slide up | 300ms | ease-out |
| Button hover | Scale + shadow | 100ms | ease-out |
| Modal open | Fade + scale from 95% | 200ms | ease-out |
| Modal close | Fade + scale to 95% | 150ms | ease-in |
| Alert appear | Slide in from top | 200ms | ease-out |

---

## Accessibility Requirements

**Target:** WCAG [AA/AAA]

### Contrast Requirements

| Element | Minimum Ratio | Current Ratio |
|---------|---------------|---------------|
| Body text | 4.5:1 | [X:1] ✓ |
| Large text (18px+) | 3:1 | [X:1] ✓ |
| UI components | 3:1 | [X:1] ✓ |
| Focus indicators | 3:1 | [X:1] ✓ |

### Focus States

All interactive elements MUST have visible focus indicators:
- Minimum: `ring-2 ring-primary/50 ring-offset-2`
- Never use `outline-none` without alternative

### Motion Preferences

Respect `prefers-reduced-motion`:
```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}
```
```

## Phase 5: Save & Configure

After generating the design system:

### Step 1: Determine Output Path

Check `.agents.yml` for `design_system_path`:

```bash
grep "design_system_path:" .agents.yml 2>/dev/null
```

- **If configured**: Use that path
- **If not configured**: Default to `docs/design/design-system.md`

### Step 2: Save Design System

Write the completed design system to the determined path.

### Step 3: Update Configuration

**If `.agents.yml` exists but `design_system_path` is not set:**

Add the path under `toolbox.build_task`:

```yaml
toolbox:
  build_task:
    design_system_path: docs/design/design-system.md
```

Use the Edit tool to add this configuration. If `toolbox:` section exists, add under it. If not, create it.

### Step 4: Auto-Preview Check (REQUIRED)

**BEFORE presenting options, you MUST:**

1. Invoke `config-reader` agent to get merged config (base + local overrides)
2. Check the returned config for `auto_preview: true`
3. **If auto_preview is true:**
   - Execute: `open <design-system-path>`
   - Tell user: "Opened design system in your editor."
   - Use the "auto-previewed" options below
4. **If false or not found:** Use the "not auto-previewed" options below

### Step 5: Present Options

Use AskUserQuestion tool:

**Options (if NOT auto-previewed):**
- **Preview in editor** - Open the design system file
- **Start building (Recommended)** - Invoke `skill frontend-design` then begin implementation
- **Refine sections** - Ask what to change, update design system
- **Research more** - Ask for additional reference sites

**Options (if auto-previewed):**
- **Start building (Recommended)** - Invoke `skill frontend-design` then begin implementation
- **Refine sections** - Ask what to change, update design system
- **Research more** - Ask for additional reference sites

Based on selection:
- **Preview in editor** → Run `open <path>`, then re-present options
- **Start building** → Invoke `skill frontend-design` then begin implementation
- **Refine** → Ask what to change, update design system
- **Research more** → Ask for additional reference sites

---

## Output Location

Default: `docs/design/design-system.md`

Configurable via `.agents.yml`:
```yaml
toolbox:
  build_task:
    design_system_path: docs/design/design-system.md
```

---

## Integration with Workflow

After completing the design system:

1. **`/majestic:plan`** - Automatically detects UI features and references the design system
2. **`/majestic:build-task`** - Loads design system as context before building
3. **`visual-validator`** - Verifies implementation against design system specifications

---

## Key Principles

- **Commit to a direction** - Avoid wishy-washy "a bit of everything" designs
- **Avoid AI slop** - No Inter font, no purple gradients, no predictable layouts
- **Research references** - Actually look at the sites users mention
- **Be opinionated** - Push back on generic choices, suggest distinctive alternatives
- **Context-specific** - A fintech app needs different design than a gaming community
- **Junior-dev ready** - Document should be so complete that no follow-up questions are needed
- **Copy-paste ready** - All classes, values, and configs should be directly usable
