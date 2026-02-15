---
name: majestic:expert-panel
description: Lead a panel of experts to address difficult questions from multiple perspectives
allowed-tools: Read, Grep, Glob, AskUserQuestion, Task, Write
argument-hint: "[topic or question]"
disable-model-invocation: true
---

# Expert Panel Discussion Command

Assemble a panel of thought leaders to explore difficult questions. Get consensus findings, divergent viewpoints, and actionable recommendations.

## Usage

```bash
/expert-panel [topic or question]
/expert-panel --resume {panel-id}
/expert-panel --list
/expert-panel --export {panel-id}
```

## Process

### Step 1: Parse Input and Handle Flags

#### Flag: --list

1. Glob `.claude/panels/*.json`
2. For each file, Read and display: `id`, `topic`, `status`, `rounds.length`, `created_at`
3. Exit after listing

#### Flag: --resume {panel-id}

1. Extract panel ID from arguments
2. Read `.claude/panels/{panel-id}.json`
3. If not found: error and exit
4. Display resume info, then skip to Step 6 with `RESUME_DATA`

#### Flag: --export {panel-id}

1. Read `.claude/panels/{panel-id}.json`
2. If not found: error and exit
3. Generate markdown export (see Export section)
4. Write to `expert-panel-{panel-id}.md` in current directory
5. Confirm and exit

#### No Flags

If `$ARGUMENTS` provided, use as topic. Otherwise use AskUserQuestion:

```
Question: "What topic would you like the expert panel to discuss?"
Header: "Panel Topic"
Options:
  - Technical Architecture
  - Testing Strategy
  - Business Strategy
  - Custom topic
multiSelect: false
```

### Step 2: Load Experts & Apply Filters

1. Read `experts/registry.yml`
2. Check `.agents.yml` for `expert_panel` config:

```yaml
expert_panel:
  enabled_categories: [engineering, product]  # Only these
  disabled_categories: [business]              # OR exclude these
  disabled_experts: [peter-thiel]              # Remove individuals
  custom_experts_path: "docs/experts/"         # Add project experts
```

3. Apply filters: enabled → disabled_categories → disabled_experts → merge custom

### Step 3: Select Experts (3-5)

Match topic keywords to expert subcategories from registry. Select for:
- **Relevance:** Subcategories match topic
- **Diversity:** Different perspectives/schools of thought
- **Disagreement potential:** Experts known to disagree

### Step 4: Confirm Expert List

```
AskUserQuestion:
  Question: "Suggested experts: [list]. Modify?"
  Header: "Experts"
  Options:
    - Accept suggested experts (Recommended)
    - Add expert (Custom)
    - Remove expert (Custom)
    - Replace list (Custom)
  multiSelect: false
```

Constraints: minimum 2, maximum 5 experts.

### Step 5: Confirm Discussion Type

Suggest based on topic:
- Clear opposing views ("X vs Y") → debate
- Need decision ("Which...", "What's best...") → consensus-seeking
- Complex/strategic → deep-dive
- High stakes, risky, or "stress test" keywords → devils-advocate
- Default → round-table

```
AskUserQuestion:
  Question: "What type of discussion?"
  Header: "Type"
  Options:
    - round-table: Single round, each expert shares their perspective
    - debate: Opposing camps with rebuttals across 2-3 rounds
    - consensus-seeking: Iterate until agreement or impasse
    - deep-dive: Three rounds of progressively deeper exploration
    - devils-advocate: Experts argue for, then against their positions (stress-testing)
  multiSelect: false
```

### Step 6: Launch Orchestrator

Generate panel ID: `YYYYMMDD-HHMMSS-topic-slug`

**IMPORTANT:** Use the **Task tool** with `subagent_type` parameter. Do NOT use Skill tool.

#### New Discussion:

```
Tool: Task
subagent_type: majestic-experts:expert-panel-discussion
description: "Expert panel on [topic]"
prompt: |
  Mode: new
  Panel ID: [generated]
  Topic: [topic]
  Experts:
    - name: [Expert]
      credentials: [from registry]
      definition: experts/{category}/{name}.md
  Discussion Type: [confirmed type]
  Audience: [from .agents.yml tech_stack or "technical team"]
  Save Path: .claude/panels/[panel-id].json
```

#### Resume Discussion:

```
Tool: Task
subagent_type: majestic-experts:expert-panel-discussion
description: "Resume expert panel [panel-id]"
prompt: |
  Mode: resume
  Resume Data: [JSON from file]
  Panel ID: [from file]
  Save Path: .claude/panels/[panel-id].json
```

### Step 7: Present Results

Show full synthesis with sections:
- ✅ **Consensus Findings** (high confidence)
- ⚖️ **Divergent Perspectives** (needs judgment)
- 💡 **Unique Insights**
- 🎯 **Actionable Recommendations**

## Export Format

Generate markdown with:
- Header: topic, panel ID, type, date, status
- Experts consulted with color emoji
- Each round's responses and key points
- Analysis: consensus, divergence, unique insights
- Actionable recommendations with confidence levels

Save to `expert-panel-{panel-id}.md` in current directory.

## Example

```
User: /expert-panel Should we migrate from monolith to microservices?

1. Topic: "monolith to microservices"
2. Load registry, apply filters
3. Select: DHH, Martin Fowler, Rich Hickey (architecture experts, different views)
4. Confirm experts → accepted
5. Suggest debate (clear opposing views) → confirmed
6. Launch orchestrator
7. Present synthesis with consensus, divergence, recommendations
```

## Notes

- Unknown experts: Accept and pass to orchestrator (agent uses built-in knowledge)
- Odd experts in debate: Assign camps as evenly as possible
- Simple topics: Suggest direct question instead of panel

Now execute based on `$ARGUMENTS`!
