---
name: premortem
description: Run a premortem on any plan, launch, product, hire, strategy, or decision. Assumes it already failed 6 months from now and works backward to find every reason why. Produces a revised plan with blind spots exposed. Triggers on "premortem this", "premortem my", "run a premortem", "what could kill this", "future-proof this", "stress test this plan", "what am i missing here", "find the blind spots", "what could go wrong", "poke holes in this", "where will this break", "devil's advocate this". Do NOT trigger on simple feedback requests, factual questions, or LLM Council requests. DO trigger when someone has a plan or commitment where the cost of being wrong is high.
allowed-tools: Read Write Glob Grep Task AskUserQuestion
---

# Premortem

**Audience:** Anyone about to commit to a plan, launch, hire, pricing change, partnership, or strategic pivot where being wrong is expensive.

**Goal:** Use Klein's prospective-hindsight method — assume the plan already failed 6 months from now and work backward to identify every genuine failure mode, then produce a revised plan with the blind spots exposed.

**Why this works:** Asking "what could go wrong?" yields cautious, hedged answers. Framing it as "this already failed, explain why" switches the brain into narrative mode and surfaces specific, honest reasons. Wharton/Cornell research calls this "prospective hindsight."

## When to Apply

Good targets:
- A product or feature about to be built
- A launch with money or reputation at stake
- A pricing change or business model shift
- A hire about to be made
- A strategy or positioning pivot
- A partnership or deal under evaluation

Skip when:
- Vague aspiration with no concrete plan → suggest `strategic-planning` or `first-principles` first
- Questions with one right answer → just answer them
- Editing/feedback on a draft → use a writer/reviewer skill
- Already-irreversible decision → no leverage left
- User wants quick gut-check → suggest `devils-advocate` or `challenge-mode`
- User wants multiple perspectives on a live decision → suggest LLM Council

## Step 1: Gather Context (Minimum Bar)

```
RAW = user's plan/decision text
CONTEXT_FILES = Glob("CLAUDE.md", "claude.md", "memory/**/*.md") | filter exists
For each F in CONTEXT_FILES: Read(F) → extract relevant business/audience/constraint signals

Required: WHAT, WHO, SUCCESS
- WHAT  = the thing being premortemed (one sentence)
- WHO   = audience / customer / stakeholders affected
- SUCCESS = what a win looks like (failure is its inverse)

If any of {WHAT, WHO, SUCCESS} missing from RAW or context:
  Ask ONE focused question via AskUserQuestion for the most important gap
  Re-evaluate after each answer
  Max 3 rounds — never more than needed
Else: proceed
```

Time budget for context scan: 30 seconds. Don't audit the workspace; grab the obvious signals and move on.

## Step 2: Set the Frame (Explicit, Required)

Output verbatim to the user:

> "OK, I have enough context. Let's run the premortem. Here's the premise: it's 6 months from now. **{WHAT}** has failed. It's done. We're looking back and trying to understand what went wrong."

This frame is the psychological mechanism. Without it, the analysis defaults to polite risk assessment instead of honest failure identification.

## Step 3: Generate Raw Failure List

```
FAILURES = generate failure reasons grounded in {WHAT, WHO, SUCCESS, context}
- comprehensive (no padding, no early stopping)
- each 1-2 sentences
- specific to this plan (not generic risk advice that applies to anything)
- genuine threats (not edge cases, not minor inconveniences)
- count is whatever is real for the plan (typically 4-9)
```

Each failure reason must trace back to a concrete detail of the plan. If you find yourself writing "the team might lose motivation" — that's generic. Rewrite it as "the 5-week prep timeline conflicts with the team's existing Q2 commitments, so corners get cut on the demo environment that the audience needs to see ROI."

## Step 4: Spawn Investigators in Parallel

```
PROMPT_TEMPLATE = Read("./assets/investigator-prompt.txt")
DEEP_DIVES = []

For each F in FAILURES:  # ALL spawned in a single message — parallel, never sequential
  PROMPT = PROMPT_TEMPLATE with {WHAT, WHO, SUCCESS, CONTEXT, F} substituted
  RESULT = Task(subagent_type: "general-purpose",
                description: "Premortem investigator",
                prompt: PROMPT)
  DEEP_DIVES.append({failure: F, story, assumption, signals: RESULT})
```

CRITICAL: emit all Task calls in a single assistant message. Sequential spawning lets earlier responses bias later ones, which defeats the parallel-deep-dive design.

## Step 5: Synthesize

Read every deep-dive, then produce:

```yaml
most_likely_failure:    # which is most probable + why
most_dangerous_failure: # which causes most damage if it hits, even if less likely
hidden_assumption:      # the one biggest unquestioned assumption across all failures
revised_plan:           # concrete changes, each mapped to a specific failure
  - change: string      # an action the user can take this week
    addresses_failure: int  # index in FAILURES
pre_launch_checklist:   # 3-5 verifiable items, each prevents/detects a failure mode
  - item: string
    detects_failure: int
```

Revisions must be concrete actions, not "consider X". Bad: "consider testing pricing." Good: "run a $47 pilot with 20 people before committing to $297 publicly."

The synthesis is the product. Most users will read this and skim the failure cards. Make it specific and actionable.

## Step 6: Write Artifacts

```
TS = current timestamp (YYYYMMDD-HHMMSS)
OUT_DIR = current working directory

TEMPLATE = Read("./assets/report-template.txt")
HTML = TEMPLATE with {WHAT, TS, synthesis, DEEP_DIVES} substituted
Write(OUT_DIR/"premortem-report-{TS}.html", HTML)

TRANSCRIPT = compose markdown:
  ## Context  → {WHAT, WHO, SUCCESS, key context excerpts}
  ## Raw failure list  → FAILURES
  ## Deep dives  → DEEP_DIVES (story, assumption, signals per failure)
  ## Synthesis  → full synthesis block
Write(OUT_DIR/"premortem-transcript-{TS}.md", TRANSCRIPT)
```

## Step 7: Chat Summary (3 Sentences Max)

```
1. Most likely failure (one sentence)
2. Hidden assumption (one sentence)
3. Single most important revision to the plan (one sentence)
+ paths to both files
```

## Output Schema

```yaml
files:
  - premortem-report-{TS}.html   # visual scan, synthesis on top
  - premortem-transcript-{TS}.md # full transcript for reference
chat: string  # 3-sentence summary + file paths
```

## Error Handling

| Condition | Action |
|-----------|--------|
| WHAT/WHO/SUCCESS unclear after 3 question rounds | Stop. Tell user the premortem needs a concrete plan; suggest planning first |
| Plan is vague aspiration ("get more customers") | Stop. Suggest `strategic-planning` or `omtm-growth` skill first |
| User wants quick gut-check, not deep analysis | Suggest `devils-advocate` or `challenge-mode` skill instead |
| User wants multiple perspectives on a live decision | Suggest LLM Council pattern, not premortem |
| Investigator agent fails | Retry once; if still fails, mark that failure mode as "investigation incomplete" in transcript and continue |

## Operating Rules

- Always set the failure frame explicitly. Don't paraphrase; the "this has already failed" wording matters.
- Always spawn all investigators in parallel in a single message. Sequential spawning poisons the well.
- Be comprehensive but not padded. 4 genuine failures > 7 forced ones. 9 genuine failures > stopping at 5.
- Don't sugarcoat. The whole point is to surface things the user doesn't want to hear before reality does.
- Every revision must be a specific action the user can take this week, not advice to "consider."
- Respect the minimum context threshold. A premortem on insufficient context produces generic failures that waste the user's time.

## See Also

- `devils-advocate` (majestic-tools) — adversarial reasoning for engineering/architectural choices
- `challenge-mode` (majestic-founder) — broad founder pushback, not structured failure-mode analysis
- `blind-spot-analyzer` (majestic-company) — finds the ONE critical growth blind spot (different output shape)
- `decision-framework` (majestic-company) — first-principles + cost/benefit + second-order effects
