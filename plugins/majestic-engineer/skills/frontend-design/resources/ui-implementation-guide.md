# UI Implementation Constraints

Specific, measurable rules for professional-grade interface implementation.

## Typography System

### The Rule of Four

Limit designs to **4 font sizes** maximum:

| Level | iOS Standard | Usage |
|-------|--------------|-------|
| Titles/Actions | 17px | Primary headings, CTAs |
| Subtitles/Body | 15px | Body text, subtitles |
| Secondary Actions | 13px | Secondary buttons, links |
| Metadata | 11px | Timestamps, captions |

### Vertical Rhythm

- **Small headlines**: 8-12px gap to related text (tight connection)
- **Large titles**: Increase spacing for visual balance
- **Paragraph spacing**: Use font-size value, not just line breaks

### Line Heights

| Context | Line Height | Reason |
|---------|-------------|--------|
| Standard paragraphs | 1.5× font size | Optimal breathing room |
| Large headlines | 1.0-1.2× | Tighter for visual cohesion |

### Readability Constraints

- **Max line length**: 9 words or 50-60 characters
- **Baseline alignment**: Align different font sizes to baseline, not vertical center

### Text Cases

| Case | When to Use |
|------|-------------|
| Sentence case | Complete thoughts, sentences |
| Title Case | Buttons, short titles |
| UPPERCASE | Small titles only (appears larger than sentence case) |

---

## Color & Accessibility

### HSB Color Model

Work in HSB (Hue, Saturation, Brightness) instead of HEX for easier manipulation.

**Creating Rich Darks:**
```
WRONG: Add black to darken
RIGHT: Increase saturation + decrease brightness
```

**Interface Grays:**
- True gray = 0% saturation
- Professional grays have small saturation amounts ("cool" or "warm" feel)

### WCAG Accessibility

**Minimum contrast ratio: 4.5:1** (AA Rating) for all essential UI elements.

**When white text fails contrast:**
- Flip it: Use darker text on lighter background version of that color

### Dark Mode Execution

| Rule | Reason |
|------|--------|
| Avoid #FFFFFF on #000000 | Causes "bleeding" and blur |
| Reduce saturation | High saturation "shakes" on dark backgrounds |
| Lighter = closer | Convey elevation with lighter grays, not shadows |

---

## Visual Depth & Layout

### Light Source Consistency

Emulate a single light source (usually from above):

- **Raised elements**: Top border or inner shadow on buttons
- **Shadows**: Larger shadows = more focus, feels closer

### Flat Design Depth

Use lighter shades for elements that should appear "raised" or closer.

### Overlapping

Most effective depth technique - suggests layers without relying on shadows.

### Grid System

**Implicit grid over rigid 12-column:**
- Use systematic negative space between elements
- Avoids resize failures of fixed column grids

### Dashboard Layouts

- Sidebars: Fixed width optimized for content
- Main content: Flex to fill remaining space

---

## Form Components

### Labels

- Keep short and descriptive
- Always visible (never hide on input)
- **Top-aligned labels**: Fastest completion rates, best for mobile

### Placeholders

**Only for example data.** Never use as labels:
- Disappear when typing
- Strain user's short-term memory

### Input States

Design for ALL states:

| State | Visual Treatment |
|-------|------------------|
| Inactive | Default appearance |
| Hover | Subtle highlight |
| Focused | Colorful border |
| Error | Red highlight + icon |
| Validated | Green checkmark |

### Selection Controls

| Control | When to Use |
|---------|-------------|
| Radio buttons | Mutually exclusive (select ONE) |
| Checkboxes | One or many independent choices |
| Toggles | Binary On/Off with immediate effect |

### Logical Sizing

Match input width to expected data:
- Short field for postcodes
- Full width for addresses

---

## Buttons & Navigation

### Action Hierarchy

| Level | Style |
|-------|-------|
| Primary | Solid, high-contrast |
| Secondary | Outlines or lower-contrast backgrounds |
| Tertiary | Styled like links |

### Button Rules

**Padding:**
```
Horizontal ≥ 2× Vertical
Example: 16px top/bottom, 32px left/right
```

**Touch Targets:**
- Minimum: 48×48dp (~9mm)
- Prevents tap mistakes

**Placement:**
- Right side = progression (Next, Submit)
- Left side = regression (Back, Cancel)

### Mobile Navigation

- Use labels WITH icons in tab bars (icons alone are ambiguous)
- Menu elements: minimum 44px for easy tapping

---

## Data Tables

### Readability

- Minimum font size: 12pt
- Avoid smaller text

### Alignment

| Data Type | Alignment | Reason |
|-----------|-----------|--------|
| Numeric | Right-align | Quick value comparison |
| Text | Left-align | Natural reading |
| Headers | Match data below | Visual consistency |

### Efficiency Techniques

**Condensed subtext:**
```
John Smith
john@example.com  ← smaller font, same column
```

### Sticky Headers

Anchor headers at top during scroll - maintains context in large datasets.
