# Diagnosis Framework

Structured checks run after the pyramid is extracted. Output from this drives the restructuring plan.

## Answer-Level Checks

| Check | Question | Action if Fails |
|-------|----------|-----------------|
| Stated | Is LEVEL_1 actually in the draft? Where (paragraph, sentence)? | Flag "answer missing" or "answer buried at paragraph N" |
| Contestable | Would a reasonable reader disagree? | Flag "too safe, sharpen claim" |
| Scope | Does it try to cover too much? | Flag "split candidate: narrow to X or Y" |
| Placement | Top | middle | end | If middle/end: add "move to sentence one" step |

## Argument-Level Checks (for each argument)

```
supported_by_section:
  Which section/paragraph supports this argument? None = gap.

mece_overlap:
  Does this argument partially restate a sibling? If yes, which one?

counterargument_gap:
  What obvious skeptic objection does this argument fail to address?

working_vs_tangential:
  Does the argument prove LEVEL_1, or is it interesting but off-thesis?
```

## Evidence-Level Checks (for each argument)

```
type:        stat | named_example | named_person | anecdote
strength:    STRONG | WEAK | MISSING
proves_arg:  yes | decorative
```

`decorative` evidence decorates the argument but does not prove it. Flag these as WEAK.

## Structural Checks (draft as a whole)

**Piece shape classification:**

```
If the subject is a claim and examples illustrate it:
  piece_shape = principle
  # Default. Most drafts brought to Minto are principle pieces.

Else if the subject is a specific case and the principle is extracted from it:
  piece_shape = case_study
```

This classification changes opener strategy (see workflow Step 3). Decide before recommending the opener.

**Dead weight and splits:**

```
For each SECTION in DRAFT:
  maps_to_argument = is this section serving any argument in LEVEL_2?
  If not: add to dead_weight candidates (cut or earn-its-place list)
  If serves two arguments: add to split candidates

For each argument in LEVEL_2:
  section_count = how many sections support it
  If 0: evidence gap (downstream plan step)
  If >1: ordering or consolidation check
```

**Ordering:**

```
Is the argument sequence logical?
  # e.g., claim → cause → consequence → alternative
  # e.g., common case → edge case → counterargument
If not: add "reorder sections" to plan with exact new order
```

## Output of Diagnosis

A mental map the restructuring plan draws from:

```yaml
answer:
  stated: yes|no
  location: "paragraph N, sentence N" | "missing"
  contestable: yes|no
  scope: right_sized | too_broad
  placement: top | middle | end

arguments:
  - text: "..."
    support_section: "..."
    mece_ok: yes|no
    counterargument_gap: "..." | none
    on_thesis: yes|no

evidence:
  - arg_index: 1
    type: stat|named_example|named_person|anecdote
    strength: STRONG|WEAK|MISSING
    proves: yes|decorative

draft_shape:
  piece_type: principle | case_study
  dead_weight: ["paragraph 4", "sidebar X"]
  splits: ["section 3 serves args 1 and 2, split at sentence..."]
  reorder: ["current order: 2,1,3 → new order: 1,2,3"]
```
