---
name: majestic:brand-audit
description: Comprehensive brand health check. Evaluates voice consistency, visual coherence, positioning alignment, and competitor differentiation across all brand touchpoints.
allowed-tools: Read, Write, Edit, Grep, Glob, WebSearch, WebFetch, AskUserQuestion, Task
argument-hint: "[scope: full, voice, visual, positioning]"
---

# Brand Audit

Comprehensive brand health evaluation across voice, visual, and positioning dimensions.

## Audit Scope

<audit_scope> $ARGUMENTS </audit_scope>

**Default:** `full` (all dimensions)

**Options:**
- `full` - Complete audit across all dimensions
- `voice` - Voice consistency audit only
- `visual` - Visual coherence audit only
- `positioning` - Positioning alignment and differentiation only

## Phase 1: Asset Discovery

Scan for brand documentation:

```bash
# Brand strategy documents
glob "**/brand-positioning.md" || glob ".claude/brand-positioning.md"
glob "**/brand-voice.md" || glob ".claude/brand-voice.md"
glob "**/STYLE_GUIDE.md" || glob ".claude/style-guide.md"

# Design system
glob "**/design-system.md" || glob "docs/design/*.md"

# Configuration files
glob "**/tailwind.config.*"
glob "**/*.css" | head -5

# Content samples
glob "content/**/*.md" || glob "blog/**/*.md" || glob "app/views/**/*.erb"
```

### Asset Inventory

Report what exists and what's missing:

| Asset | Status | Location |
|-------|--------|----------|
| Brand Positioning | ✓ Found / ⚠ Missing | [path] |
| Brand Voice Guide | ✓ Found / ⚠ Missing | [path] |
| Style Guide | ✓ Found / ⚠ Missing | [path] |
| Design System | ✓ Found / ⚠ Missing | [path] |
| Content Samples | ✓ Found / ⚠ Missing | [paths] |

**If critical assets missing:**
- Recommend creating them before audit
- Offer to run `/brand-positioning`, `/brand-voice`, `/style-guide:new`

## Phase 2: Voice Consistency Audit

### 2.1 Extract Voice Standards

From `brand-voice.md` or `STYLE_GUIDE.md`, extract:
- Personality traits
- Tone guidelines
- Words to use/avoid
- Sentence style rules

### 2.2 Sample Content

Collect 5-10 content samples across touchpoints:
- Homepage copy
- Key landing pages
- Blog posts (if any)
- Email templates (if found)
- UI copy (button labels, error messages)

### 2.3 Voice Analysis

For each sample, evaluate:

| Criterion | Alignment | Evidence |
|-----------|-----------|----------|
| Personality match | ✓ / ⚠ / ✗ | [Quote showing match/mismatch] |
| Tone appropriate | ✓ / ⚠ / ✗ | [Quote showing match/mismatch] |
| Forbidden words | ✓ / ⚠ / ✗ | [Found words from avoid list] |
| Sentence style | ✓ / ⚠ / ✗ | [Examples] |

### 2.4 Voice Score

Calculate voice consistency:
- **90-100%**: Strong voice consistency
- **70-89%**: Minor inconsistencies
- **50-69%**: Moderate drift from voice
- **<50%**: Voice not established or severely inconsistent

## Phase 3: Visual Coherence Audit

### 3.1 Extract Design Standards

From `design-system.md` or config files, extract:
- Color palette (hex values)
- Typography (fonts, sizes)
- Spacing scale
- Border radius
- Component patterns

### 3.2 Scan Implementations

Search codebase for:

```bash
# Color usage
grep -r "#[0-9a-fA-F]{3,6}" --include="*.css" --include="*.scss"
grep -r "bg-\|text-\|border-" --include="*.html" --include="*.erb" --include="*.jsx"

# Font usage
grep -r "font-family\|font-sans\|font-serif" --include="*.css"

# Hardcoded values (potential violations)
grep -r "px\|em\|rem" --include="*.css" | head -20
```

### 3.3 Visual Analysis

| Criterion | Alignment | Issues Found |
|-----------|-----------|--------------|
| Color palette | ✓ / ⚠ / ✗ | [Off-brand colors found] |
| Typography | ✓ / ⚠ / ✗ | [Inconsistent fonts/sizes] |
| Spacing | ✓ / ⚠ / ✗ | [Arbitrary values] |
| Components | ✓ / ⚠ / ✗ | [Inconsistent patterns] |

### 3.4 Visual Score

Calculate visual coherence:
- **90-100%**: Strong design system adherence
- **70-89%**: Minor deviations
- **50-69%**: Inconsistent implementation
- **<50%**: Design system not followed or doesn't exist

## Phase 4: Positioning Audit

### 4.1 Extract Positioning

From `brand-positioning.md`, extract:
- Positioning statement
- Key differentiators
- Target audience
- Brand promise

### 4.2 Messaging Analysis

Scan key pages for positioning alignment:
- Does homepage headline match positioning?
- Do feature descriptions support differentiators?
- Is target audience clearly addressed?

### 4.3 Competitor Research

Use `WebSearch` to check:
- Are competitors using similar messaging?
- Is differentiation still valid?
- Any new positioning opportunities?

```
Search: "[competitor name] + [your key differentiator]"
Search: "[your category] + [your positioning claim]"
```

### 4.4 Positioning Score

| Criterion | Score | Notes |
|-----------|-------|-------|
| Message consistency | /25 | [How aligned is messaging?] |
| Differentiation clarity | /25 | [Is differentiation clear?] |
| Audience targeting | /25 | [Is audience addressed?] |
| Competitive uniqueness | /25 | [Is positioning defensible?] |

## Phase 5: Generate Report

```markdown
# Brand Audit Report: [Company Name]

*Generated: [Date]*

---

## Executive Summary

**Overall Brand Health Score: [X]/100**

| Dimension | Score | Status |
|-----------|-------|--------|
| Voice Consistency | [X]/100 | [Strong/Moderate/Weak] |
| Visual Coherence | [X]/100 | [Strong/Moderate/Weak] |
| Positioning Alignment | [X]/100 | [Strong/Moderate/Weak] |

---

## Asset Inventory

| Asset | Status | Recommendation |
|-------|--------|----------------|
| Brand Positioning | [Status] | [Action if needed] |
| Brand Voice | [Status] | [Action if needed] |
| Design System | [Status] | [Action if needed] |
| Style Guide | [Status] | [Action if needed] |

---

## Voice Audit Results

### Score: [X]/100

### Strengths
- [What's working well]

### Issues Found

| Location | Issue | Severity | Fix |
|----------|-------|----------|-----|
| [File/page] | [Description] | High/Med/Low | [Recommendation] |

### Samples Analyzed
[List of content pieces reviewed]

---

## Visual Audit Results

### Score: [X]/100

### Strengths
- [What's working well]

### Issues Found

| Location | Issue | Severity | Fix |
|----------|-------|----------|-----|
| [File] | [Description] | High/Med/Low | [Recommendation] |

### Off-Brand Elements
[List specific violations with file paths]

---

## Positioning Audit Results

### Score: [X]/100

### Current Positioning Statement
> [Extracted positioning]

### Alignment Check

| Page/Asset | Aligned? | Notes |
|------------|----------|-------|
| Homepage headline | [Y/N] | [Details] |
| About page | [Y/N] | [Details] |
| Product page | [Y/N] | [Details] |

### Competitive Landscape

| Competitor | Similar Messaging? | Risk Level |
|------------|-------------------|------------|
| [Comp 1] | [Y/N] | [High/Med/Low] |
| [Comp 2] | [Y/N] | [High/Med/Low] |

### Differentiation Assessment
[Is current differentiation still unique and defensible?]

---

## Priority Recommendations

### High Priority (Fix Now)
1. [Issue] → [Specific action]
2. [Issue] → [Specific action]

### Medium Priority (This Quarter)
1. [Issue] → [Specific action]
2. [Issue] → [Specific action]

### Low Priority (Backlog)
1. [Issue] → [Specific action]

---

## Next Steps

1. [ ] Address high-priority voice inconsistencies
2. [ ] Fix visual deviations in [specific files]
3. [ ] Update [page] to align with positioning
4. [ ] Consider repositioning if competitive overlap found
5. [ ] Schedule next audit: [Recommended date]

---

## Appendix: Files Analyzed

[List all files scanned during audit]
```

## Output Location

Save report to: `docs/brand-audit-[YYYY-MM-DD].md`

## Follow-Up Actions

After generating report, offer:

1. **Fix issues automatically** - Edit files to correct violations
2. **Create missing assets** - Run `/brand-positioning`, `/brand-voice`, etc.
3. **Deep dive on specific dimension** - Re-run with scope parameter
4. **Competitor analysis** - Run `competitive-positioning` skill

## Quality Standards

- **Evidence-based** - Every finding needs a file path and example
- **Actionable** - Recommendations should be specific and doable
- **Prioritized** - Don't overwhelm with low-impact issues
- **Objective** - Score based on documented standards, not opinion

## Audit Cadence

Recommend:
- **Quarterly**: Full audit for established brands
- **Monthly**: Voice-only audit for content-heavy sites
- **Post-campaign**: Positioning check after major launches
- **After rebrand**: Full audit to establish new baseline
