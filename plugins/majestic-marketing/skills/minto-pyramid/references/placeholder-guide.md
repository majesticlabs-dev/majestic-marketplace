# HTML Placeholder Guide

How to fill `html-template.html` from the pyramid + diagnosis + plan.

## Placeholder Map

| Placeholder | Fill With |
|-------------|-----------|
| `{{TOPIC_TITLE}}` | 3-8 word title for the draft |
| `{{LEVEL_1_ANSWER}}` | The one-sentence answer from Step 1 |
| `{{ARGUMENT_N}}` | Full-sentence claim for each supporting argument |
| `{{EVIDENCE_N}}` | Concrete evidence for STRONG; description of gap + target evidence type for WEAK/MISSING |
| `{{EN_MISSING_CLASS}}` | Empty string `""` if STRONG; `missing` if WEAK/MISSING |
| `{{EN_STRENGTH_LABEL}}` | `(strong)` \| `(weak)` \| `(missing)` appended to evidence title |
| `{{OPENER_CONTEXT}}` | Short framing line matched to piece shape |
| `{{OPENER_QUOTE}}` | Exact opening sentence the draft should use |
| `{{OPENER_NOTE}}` | 1-2 sentences explaining why this beats current opener |
| `{{STEP_N_HEADLINE}}` | Action as short directive (e.g., "Move the claim to sentence one.") |
| `{{STEP_N_BODY}}` | 1-2 sentences explaining the move |
| `{{STEP_N_EXAMPLE_OR_OMIT}}` | Exact suggested sentence/phrase OR remove entire `<div class="example">` line |

## Opener Context Lines

```
If piece_shape == principle:
  OPENER_CONTEXT = "State the principle up top, then let the example prove it:"
Else (case_study):
  OPENER_CONTEXT = "Open with the concrete case, then extract the principle:"
```

Default to principle framing unless the draft is clearly a case study.

## Argument Tier Sizing

The template has 3 argument boxes and 3 evidence boxes. Flex to match LEVEL_2 count:

```
If LEVEL_2.count == 2:
  Remove ARGUMENT_3 box AND EVIDENCE_3 box
If LEVEL_2.count == 3:
  Use template as-is
If LEVEL_2.count == 4:
  Add ARGUMENT_4 box AND EVIDENCE_4 box (copy markup pattern)
```

Flexbox layout handles width automatically.

## File Naming

```
FILENAME = "minto-pyramid-{slug}.html"
slug = 3-5 words from topic, kebab-case, lowercase
Examples:
  minto-pyramid-pricing-change.html
  minto-pyramid-b2b-onboarding.html
  minto-pyramid-first-hire.html
```

## Chat Response Format

```markdown
[View your Minto pyramid](./path/to/file.html)

[2-4 lines highlighting THE biggest structural issue + the fix.
Example: "Your main claim is buried in paragraph 3. Move it to
sentence one, use the case study as proof in the second beat, and
cut the hypothetical archetypes at the end."]
```

Nothing else in chat. The HTML holds the full analysis.
