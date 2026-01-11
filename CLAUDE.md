# Majestic Marketplace

Claude Code plugin marketplace. **Work in `plugins/*/` only.**

## ⛔ FORBIDDEN

NEVER modify `~/.claude/`. All plugin work goes in `majestic-marketplace/plugins/`.

## Git Merge Operations

- NEVER merge branches to master without explicit user approval
- Always ask: "Ready to merge to master?" or create a PR for review
- Merging to production is irreversible - requires conscious decision

## Structure

```
plugins/{engineer,rails,python,react,marketing,sales,company,llm,tools,agent-sdk,devops,experts,ralph}/
```

**Wiki repo**: `../majestic-marketplace.wiki/` (separate git repo, requires separate commit/push)

## Dependencies

| Plugin | Can Reference |
|--------|--------------|
| `engineer` | rails, python, react, llm, tools, ralph |
| `rails`, `python`, `react` | engineer |
| `ralph` | (none) |
| `marketing`, `sales`, `company`, `llm`, `tools`, `agent-sdk`, `devops`, `experts` | (none) |

## Documentation

- [Naming](docs/plugin-architecture/NAMING-CONVENTIONS.md)
- [Operations](docs/plugin-architecture/PLUGIN-OPERATIONS.md)
- [Schemas](docs/plugin-architecture/JSON-SCHEMAS.md)
- [Config](docs/plugin-architecture/CONFIG-SYSTEM.md)

## Config Access

```
!`claude -p "/majestic:config field default"`
```

## Key Rules

### Limits
- Skills: <500 lines
- Agents: <300 lines

### Step Numbering Conventions

| Pattern | When to Use | Example |
|---------|-------------|---------|
| `1, 2, 3...` | Main sequential steps | Step 1, Step 2, Step 3 |
| `1.1, 1.2` | Substeps or alternatives under a parent | Step 11.1, Step 11.2, Step 11.3 |

**Rules:**
- Start numbering at 1, never 0
- Prefer adding new main steps over decimals (renumber if needed)
- ❌ Never use: `0A`, `8.5`, `Step 0`, letter suffixes

### File Locations
- Skill resources → `skills/*/resources/`
- Agent resources → `agents/**/resources/{agent-name}/`
- Command resources → `commands/**/resources/{command-name}/`
- Resources referenced via relative paths from the markdown file
- No `.md` files in `commands/` (they become executable)
- Templates in command resources must use `.txt` or `.yml` extensions

**Resource file patterns:**
- One primary concern per file (don't mix unrelated templates)
- Keep shared content in parent folder, reference via relative path
  - Example: email-nurture references `../email-sequences/subject-formulas.md`
- Split files if they serve different purposes:
  - ✅ email-structure.md + re-engagement-copy.md
  - ❌ email-copy-template.md (mixing everything)
- Avoid duplication: If two agents need same resource, one file in shared location

### Behaviors
- Skills = knowledge (Claude MAY follow)
- Hooks = enforcement (FORCES behavior)
- Agents do autonomous work, not just advice
- `name:` in frontmatter overrides path-based naming

**Skill vs Agent distinction:**
- SKILL: Guidance/knowledge executed in main conversation
  - Can have `allowed-tools` (enabled just for that skill's context)
  - Examples: proposal-writer (uses WebSearch), email-nurture (uses AskUserQuestion)
  - Runs inline with user, not as subprocess
- AGENT: Autonomous work spawned as subprocess via Task tool
  - Has own context, runs independently
  - Examples: proposal-generator (spawned to orchestrate workflow)
- RULE: Don't convert skills to agents just because they have `allowed-tools`
  - ❌ Wrong: "This skill uses tools → must be an agent"
  - ✅ Right: "This does autonomous workflow → should be agent"

### Agent/Skill Pairing Pattern
When an agent invokes a skill:
- AGENT responsibility: Workflow steps, validation, error handling, delivery
  - Gather context → Validate inputs → Analyze situation → Invoke skill → Validate output
- SKILL responsibility: Templates, frameworks, patterns
  - Receives structured context from agent
  - Does the actual work (writes, builds, creates)
- RULE: Remove duplication — if agent contains the template, don't duplicate in skill

### Command Naming
- Command names in frontmatter must include full plugin prefix
- Format: `name: plugin-name:command-name` (e.g., `majestic-ralph:start`)
- Matches cross-plugin invocation: `/majestic-ralph:start`
- Avoid redundant patterns like `ralph:ralph` — use descriptive names (`start`, `cancel`, `help`)

### Validation
Run `skill-linter` for new skills.

### Content Rules
- Skills must contain NEW info Claude doesn't know
- Exclude: generic advice, personas, "best practices" prose
- Include: concrete limits, project-specific patterns, exact templates
- **Skills are LLM instructions, not human documentation**
  - ❌ Attribution ("using X's framework") - LLM can't retrieve by author name
  - ❌ Source credits - no functional value for execution
  - ❌ Decorative quotes - human aesthetic, wastes tokens
  - ❌ Persona statements ("You are an expert...") - wastes tokens
  - ✅ Every line must help the LLM execute better
  - Ask: "Does this sentence improve LLM behavior?" If no, cut it.
- **Expert names: patterns vs attribution**
  - ✅ Keep names that define a style/approach (DHH, Warren Buffett) - LLM needs this context
  - ❌ Remove "inspired by X" or "based on X's methodology" - pure credibility signal
  - Ask: Is this name part of what the LLM should DO, or just proof someone credible said it?
- **Audience/Goal framing (instead of personas)**
  - Use `**Audience:**` (who this is for) and `**Goal:**` (what they'll achieve)
  - "Explain X for audience Y" yields better outputs than "Act as persona Z"
- **Self-contained documentation**
  - Remove external implementation references from feature docs
  - Document patterns you implement, not who inspired them
  - Keep credits in separate Credits section, not inline
- **Functional context vs fluff (when refactoring)**
  - Scope/stage context is FUNCTIONAL — affects what advice applies
    - ✅ Keep: "$0-$10M ARR", "early-stage", "enterprise", "high-growth"
    - These are constraints on when to use the guidance
  - Persona statements are FLUFF — remove if they just describe role
    - ❌ Remove: "You are an expert", "VP-level thinking", "has built X"
    - Safe to remove if they don't change the guidance itself
  - Test: "Does removing this change what the agent should do?" If yes, keep it.

### Agent Instruction Patterns
- **Pseudocode format (not prose):**
  - ✅ `If X: do Y | Else: do Z`
  - ✅ `For each ITEM in LIST: process ITEM`
  - ✅ `While CONDITION: loop body`
  - ❌ "Check if X exists, and if so, do Y" (prose)
  - ❌ "This step is optional unless..." (conditional prose)
- **Variables enable control flow (required, not optional):**
  ```
  RESULT = Task(...) → If RESULT.status == PASS: proceed
  ITEMS = /majestic:config ... → For each I in ITEMS: invoke(I)
  ```
- **Schemas over examples:** Document I/O with YAML/JSON schemas
  - ✅ `task_id: string # T1, T2 (from header)`
  - ❌ Markdown example blocks expecting agent to infer structure
- **Command invocation:** `/command-name args` (direct slash syntax)
- **Config reads:** `/majestic:config field default`
- **Arrays for extensibility:** `methodology: [tdd]` not `methodology: tdd`

### Agent/Command Doc Structure
- ✅ Purpose (1 line max)
- ✅ Input Schema (YAML)
- ✅ Workflow (pseudocode only)
- ✅ Output Schema (YAML)
- ✅ Error Handling (decision table)
- ❌ "How It Works" narratives
- ❌ "Critical Rules" / "Notes" / "Safety" prose
- ❌ "Monitoring" / "Examples" sections

### Verification Phase Separation
- **Quality Gate:** lint, typecheck, tests, security (standard checks)
- **Acceptance Criteria:** task-specific behavior (file exists, endpoint returns X)
- ❌ Don't include quality gate checks in AC (no "npm run typecheck passes")

### Anti-Patterns
- ❌ Do NOT hardcode language/framework-specific agents in generic orchestrators
  - Bad: Putting "majestic-rails:auth-researcher" directly in blueprint.md
  - Good: Use toolbox-resolver to discover stack-specific capabilities dynamically
  - Reason: Multi-stack projects need flexible composition, not hard dependencies

### Multi-Stack Projects
- `tech_stack` in .agents.yml can be string or array
- Example: `tech_stack: [rails, react]` is valid
- Toolbox configs must support merging capabilities from multiple stacks
- toolbox-resolver unions configs, not picks one stack

### Version Bumping (Schema Changes)
When modifying .agents.yml schema or adding config dependencies:
- Bump `plugins/majestic-engineer/skills/init-agents-config/CONFIG_VERSION`
- Update `docs/plugin-architecture/CONFIG-SYSTEM.md` version history
- Bump plugin version in `.claude-plugin/plugin.json` for affected plugins
- Update `.claude-plugin/marketplace.json` entries
- All version bumps committed together with schema changes

### Checkpoint Before Major Refactors
When discovering incorrect patterns that require moving/restructuring files:
1. Clarify the correct approach (present options)
2. Wait for user confirmation before refactoring
3. Don't assume path patterns - verify with user or docs

**Before removing content in refactors:**
1. Is this describing a persona/role? → Safe to remove
2. Is this a template/framework? → Keep or move to resources/
3. Is this stage/scope context? → Keep as functional context
4. Is this execution logic? → Move to agent workflow
- When in doubt: Keep it, then ask user if it should be removed
- Don't assume "cleanup" passes are correct — validate against actual usage

### Plugin Architecture Decisions
- For new orchestration systems (loops, workflows), create **separate plugins**
- Don't add to existing feature plugins unless tightly coupled to that plugin's core domain
- Separate plugins are easier to install/remove independently

### State Files: Ephemeral vs Permanent
- Session working files: Use `.local.` suffix (gitignored)
- Example: `.claude/ralph-progress.local.yml` during iteration
- Promote valuable patterns to permanent docs (AGENTS.md) at session end
- Ephemeral files = working memory; Permanent docs = durable knowledge

### Data Format Selection
- For progress/state tracking, prefer YAML over markdown
- YAML: structured, parseable, patterns accessible at top level
- Markdown: patterns buried in narrative, harder to parse

## Plugin Release Checklist

1. Update version in `plugins/*/.claude-plugin/plugin.json`
2. Add/update entry in `.claude-plugin/marketplace.json`:
   - Version number
   - Description (reflect skills/commands count)
   - Tags
   - Source path
3. Update internal references to new plugin namespace
4. Commit registry + plugin files together
5. README must include "What Makes This Different" section for new plugins
