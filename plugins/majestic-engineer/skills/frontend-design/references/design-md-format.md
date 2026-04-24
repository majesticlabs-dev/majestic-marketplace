# DESIGN.md Token Format

Machine-readable design system format (Google Labs, alpha). Combines YAML tokens with markdown design rationale.

## File Structure

```markdown
---
colors:
  primary: "#1a1a2e"
  accent: "#e94560"
  bg: "#0f0f23"
  fg: "#eaeaea"

spacing:
  sm: "4px"
  md: "8px"
  lg: "16px"
  xl: "32px"

typography:
  display:
    fontFamily: "Space Grotesk"
    fontSize: "3rem"
    fontWeight: 700
    lineHeight: 1.1
  body:
    fontFamily: "Inter"
    fontSize: "1rem"
    fontWeight: 400
    lineHeight: 1.6

components:
  button:
    backgroundColor: "{colors.accent}"
    textColor: "{colors.fg}"
    padding: "{spacing.md} {spacing.lg}"
    rounded: "8px"
---

# Design System

Design rationale and usage guidelines go here...
```

## Token References

Components reference other tokens with `{category.name}` syntax:
- `{colors.primary}` resolves to the `primary` value under `colors`
- Nested references are resolved recursively

## CLI Tools

When `design-md` package is installed:

```bash
npx design-md lint DESIGN.md          # Validate tokens, check WCAG contrast
npx design-md diff old.md new.md      # Compare design system versions
npx design-md export --format tailwind # Convert to tailwind.config.js theme
npx design-md export --format dtcg     # Convert to Design Token Community Group format
npx design-md spec                     # Output format specification
```

## Consuming Tokens

**CSS custom properties:**
```css
:root {
  --color-primary: #1a1a2e;    /* from {colors.primary} */
  --color-accent: #e94560;     /* from {colors.accent} */
  --font-display: 'Space Grotesk', sans-serif;
  --spacing-md: 8px;
}
```

**Tailwind theme:** Use `npx design-md export --format tailwind` or manually map tokens to `theme.extend` in `tailwind.config.js`.

## When to Use

- Project has a `DESIGN.md` file in root — always parse and use its tokens
- Building UI from a design spec — check if DESIGN.md exists before inventing values
- Token values override any generic defaults from `frontend-css-patterns`
