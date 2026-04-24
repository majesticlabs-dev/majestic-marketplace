---
name: minto-pyramid
description: Diagnose and restructure drafts or raw ideas against Barbara Minto's Pyramid Principle. Extracts a one-sentence answer, 2-4 MECE arguments, and one concrete evidence per argument, flags buried claims and missing proof, and delivers an HTML artifact with the visual pyramid, a replacement opener, and a numbered restructuring plan. Use when pressure-testing an argument, checking MECE, or finding the one-sentence takeaway before drafting or polishing prose. Triggers on "minto this", "pyramid this", "is this MECE", "pressure-test this". Not for drafting content, editing voice, humanizing prose, or compressing to a platform — those are downstream skills (copy-editor, humanizer, thread-builder).
triggers:
  - minto this
  - run minto
  - apply minto
  - minto-ify
  - pyramid this
  - build the pyramid
  - pyramid principle this
  - answer-first this
  - structure this as a pyramid
  - is this MECE
  - pressure-test this
  - what is the takeaway
  - give me the one-sentence answer
  - does this hold up logically
allowed-tools: Read Write Edit AskUserQuestion
---

# Minto Pyramid

**Audience:** Writers, founders, marketers pressure-testing an argument before drafting or publishing.
**Goal:** Fix the thinking and structure so downstream voice/editing skills work on a sound skeleton.

Do NOT trigger on requests to draft content, edit voice, humanize, or compress for a platform. Those are downstream skills.

## Inputs

```
SUBJECT = scan recent conversation for one of:
  raw_idea    # topic the user wants to write about, no draft yet
  draft       # existing prose the user wants pressure-tested

If multiple candidates AND target ambiguous:
  Ask one sentence: "Are we minto-ing [X] or [Y]?"
  Wait for answer.
Else if exactly one obvious target:
  Proceed without asking.
```

Never invent a topic. Never pull from memory. Work from what is in the conversation.

## Workflow

### Step 1: Extract the Pyramid

```
LEVEL_1 = extract_answer(SUBJECT)
  # One contestable sentence stating what reader should believe.
  # Apply tests from references/extraction-tests.md (Level 1 section).
  If fails tests AND SUBJECT == draft:
    Surface buried candidate OR write answer yourself + flag "draft never states this"
  If fails tests AND SUBJECT == raw_idea:
    Stop. Tell user what blocks compression. Ask them to resolve.

LEVEL_2 = extract_arguments(SUBJECT, LEVEL_1)
  # 2-4 full-sentence claims that together prove LEVEL_1.
  # Must be MECE. Three is the sweet spot. Never more than 4.
  # Each claim = subject + verb + position. Labels and single words fail.
  # Apply MECE tests from references/extraction-tests.md (Level 2 section).

LEVEL_3 = extract_evidence(SUBJECT, LEVEL_2)
  # One concrete piece per argument. Types: stat | named_example | named_person | anecdote.
  # Use evidence already in conversation first. Never fabricate.
  # If absent, mark WEAK/MISSING. Apply rules from references/extraction-tests.md (Level 3 section).
```

### Step 2: Diagnose the Structure

```
For LEVEL_1:
  - stated_in_draft: yes/no + location (paragraph, sentence)
  - contestable: yes/no
  - scope: right-sized | too-broad (split candidate)

For each ARG in LEVEL_2:
  - supported_by_section: section reference OR none
  - mece_violations: overlaps with which sibling arguments
  - counterargument_gap: obvious skeptic objection the draft ignores
  - working_or_tangential: does it prove LEVEL_1

For each EVIDENCE in LEVEL_3:
  - type: stat | named_example | named_person | anecdote
  - strength: STRONG (concrete, named, specific) | WEAK | MISSING
  - proves_argument: yes | decorative

For DRAFT as a whole:
  - piece_shape: principle | case_study
    # principle: subject is a claim, examples illustrate it (default, most common)
    # case_study: subject is a specific case, principle is extracted from it
  - dead_weight_sections: map any section to no argument = cut candidate
  - split_sections: sections serving two arguments at once
  - answer_placement: top | buried_middle | buried_end
  - argument_order: logical | needs_resequencing

Full diagnosis rubric: references/diagnosis-framework.md
```

### Step 3: Build the Restructuring Plan

```
OPENER = generate_opener(piece_shape, LEVEL_1)
  If piece_shape == principle:
    # Must state or strongly telegraph LEVEL_1 in first 1-2 sentences.
    # Leading with the strongest concrete causes subject-swap (reader misreads subject).
  Else (case_study):
    # Opener can lead with concrete. The concrete IS the subject.

  SUBJECT_TEST: if reader saw only first 1-2 sentences of OPENER,
    would they correctly name what the piece is about?
    If no: rewrite.

  Default to principle treatment unless draft is clearly a case study.

PLAN = numbered steps covering:
  1. Replace opener (exact sentence + why it beats current)
  2. Restructure: reorder | merge overlapping sections | split dual-purpose sections
  3. Cut: specific paragraphs/sections with no argument mapping
  4. Close evidence gaps: for each WEAK/MISSING, specify type + target
  5. Strengthen weak arguments: rewritten sentence version

If SUBJECT == raw_idea:
  Skip steps 2 (restructure) and 3 (cut). Deliver pyramid + opener + evidence gaps + draft skeleton.
```

### Step 4: Deliver the Artifact

```
FILE_PATH = "{output_dir}/minto-pyramid-{kebab-slug}.html"
  # output_dir = current working directory unless user environment specifies elsewhere
  # slug = 3-5 kebab-case words from topic

Render references/html-template.html with placeholders from Steps 1-3.
Placeholder reference: references/placeholder-guide.md
Evidence color coding:
  STRONG  → class="evidence"          (blue)
  WEAK    → class="evidence missing"  (red)
  MISSING → class="evidence missing"  (red)

Argument tier flexes: render exactly 2, 3, or 4 boxes matching LEVEL_2 count.

Write FILE_PATH.

Chat response:
  Line 1: Link to file (markdown link or computer:// URI)
  Lines 2-4: ONE-biggest-structural-issue + the fix (2-4 lines total)
  Nothing else. No wall-of-text analysis.
```

## Voice Rules for Output (non-negotiable)

These apply to the opener, plan steps, and HTML content the skill generates:

- No em dashes. Use commas, periods, parentheses, or restructure.
- No `isn't X / is Y` patterns. Covers all variations: "Not X. Y.", "This isn't X. This is Y.", "Forget X. This is Y.", "Less X, more Y." Rewrite to assert the point directly.
- No fabricated credentials. If a source's credentials were not in the conversation, do not invent them.
- No filler hedges: `genuinely`, `honestly`, `straightforward`. Cut them.

## Output Contract

```yaml
deliverable: single_html_file
chat_response:
  - link_to_file: required
  - summary_lines: 2-4 max
  - no_full_analysis_dump: true
html_contents:
  - visual_pyramid: answer + 2-4 arguments + evidence (color-coded by strength)
  - replacement_opener: exact sentence + why
  - numbered_plan: concrete actionable steps
```

## Anti-Patterns

| Anti-Pattern | Why It Fails | Instead |
|--------------|--------------|---------|
| Rewriting the full draft | That is a downstream job | Deliver plan, let user or voice skill rewrite |
| Applying writer's voice/rhythm | Structure skill, not style | Keep recommendations structural |
| Recommending a format (thread, deck, post) | User picks the container | Stay silent on format |
| Two pieces of evidence per argument | Dilutes the branch | One strong piece per branch |
| 5+ arguments | LEVEL_1 is probably too broad | Push back on answer; split piece |
| Pyramid without an answer | No spine to test | Stop. Tell user what blocks compression |
| Apologies, hedging, caveats | The pyramid commits to a position | State the claim |
| Pasting full pyramid + plan into chat | HTML is the deliverable | Link + 2-4 line summary only |
| Fabricating stats or named sources | Destroys trust | Flag WEAK/MISSING instead |

## Success Bar

User opens the HTML and can immediately:

1. Verify the extracted pyramid matches what they were trying to say
2. See what is broken (buried answer, MECE violations, red evidence boxes, dead weight)
3. Execute fixes in order (replace opener, reorder sections, cut dead weight, close evidence gaps, sharpen weak arguments)

If the user closes the artifact and still does not know what to change next, the skill failed.

## Credits

Framework: Barbara Minto, *The Pyramid Principle* (1987).
