# Extraction Tests

Tests for pulling each level of the pyramid out of a draft or raw idea.

## Level 1: The Answer

One sentence stating what the reader should walk away believing. It is a claim that takes a position.

**Fail tests (any one = not ready):**

| Failure | Example | Fix |
|---------|---------|-----|
| Takes more than one sentence | Multi-clause compound claims | Compress or split the piece |
| Names a topic without taking a position | "Meetings.", "Hiring.", "Pricing." | Make a contestable claim about the topic |
| Hedges | Contains "it depends", "sometimes", "in some cases" | Remove hedge, commit to the position |
| Uncontestable | "Good marketing matters." | Sharpen until a reasonable reader could disagree |
| Is a question | "How should startups price?" | Answer it |

**Contestability test:** Ask yourself what the piece is about in one phrase. If the honest answer is a topic label ("meetings", "pricing"), the writer has a subject but no claim. A Level 1 answer makes a contestable claim about that subject.

**Source of the answer:**

```
If SUBJECT == draft:
  Find sentence closest to the answer. May be buried in paragraph 3 or the conclusion. Surface it.
  If no sentence qualifies: write the answer yourself, flag "draft never states this."

If SUBJECT == raw_idea:
  Compress until one sentence does the full job.
  If cannot compress: stop. Tell user what blocks compression. Ask them to resolve.
```

## Level 2: Supporting Arguments

2-4 claims that together prove the Level 1 answer. Each is its own full sentence.

**Count rules:**
- Minimum: 2
- Sweet spot: 3
- Maximum: 4
- 5+ arguments = Level 1 is too broad; push back on the answer

**MECE tests:**

```
Mutually Exclusive:
  For each PAIR in LEVEL_2:
    If ARG_B partially restates ARG_A with different words:
      Collapse them into one argument.

Collectively Exhaustive:
  SKEPTIC = imagine a reader who disagrees with LEVEL_1
  FIRST_COUNTER = first counterargument SKEPTIC would raise
  If no argument in LEVEL_2 addresses FIRST_COUNTER:
    Gap. Add the missing branch OR narrow LEVEL_1.
```

If MECE cannot be achieved, the problem is usually upstream in Level 1. The answer may be too broad.

**Form rules:**
- Full sentence with subject, verb, and position
- Bullet-pointed label fails ("Cost", "Speed")
- One-word category fails ("Pricing", "Team")

**Mapping rule (for drafts):**

```
For each ARG in LEVEL_2:
  sections_supporting = paragraphs/sections in draft that support ARG
  Note:
    - which sections support which argument
    - which sections support no argument (dead weight candidates)
    - which arguments have no section supporting them (evidence gaps)
```

## Level 3: Evidence

One concrete piece of evidence per Level 2 argument. Exactly four acceptable types.

**Evidence type decision table:**

| Type | Concrete Form | Fail Form |
|------|---------------|-----------|
| Stat | "A 2023 Bain study found 70% of M&A deals destroy value within three years." | "Studies show..." |
| Named example | "Costco caps gross margin on any item at 15%." | "Some companies cap margins." |
| Named person's position | "Paul Graham has argued startups should launch before they feel ready." | "Experts believe..." |
| Concrete anecdote | Specific story naming who, when, what happened | "I've seen this work many times." |

**Rules:**
- Use evidence already in the conversation first
- Never fabricate stats, sources, or quotes
- If an argument needs evidence you do not have, mark WEAK or MISSING and flag the gap
- One piece per argument. Do not double up.

**Strength classification:**

```
If evidence is concrete + named + specific:
  strength = STRONG
Else if evidence is asserted, vague, or hypothetical:
  strength = WEAK
Else if no evidence is provided:
  strength = MISSING
```

Strength drives HTML color coding: STRONG = blue, WEAK/MISSING = red.
