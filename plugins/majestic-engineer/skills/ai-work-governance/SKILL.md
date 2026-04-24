---
name: ai-work-governance
description: >
  Use when designing AI agents that autonomously create work items (GitHub
  issues, tasks, PRs) without per-item human review. Covers strategic alignment
  gates, sensitive data scrubbing, budget guardrails, and approval gate design.
  Not for manual issue creation or single-session task tracking — use
  backlog-manager or task-coordinator instead.
version: 1.0.0
triggers:
  - AI agent creating issues
  - autonomous issue filing
  - validate work alignment
  - prevent busy work
  - issue governance
  - strategic alignment gate
  - autonomous development pipeline
---

# AI Work Governance

Patterns for AI agents that file work items autonomously. Without these gates, agents create busy work that doesn't compound product value, flood queues, and leak sensitive data into issue trackers.

## Design Principle

Governance lives in output schema and machine-enforced ceilings, not in process checklists. Human review gates erode within weeks without active discipline; machine gates run forever. Order of reliability: **config-enforced ceilings > regex scans > schema field presence > agent self-checks > human review files > human per-item review**. Design your system so it degrades gracefully to machine-only enforcement — the human layer is augmentation, not the critical path.

---

## Budget Cap (Most Durable Gate)

A hard config-enforced ceiling is the single most important control. Even a fully unsupervised agent cannot cause catastrophic queue flooding if the cap holds.

### Configuration

```yaml
# In .agents.yml or equivalent config
ai_work_governance:
  max_items_per_repo_per_cycle: 5    # hard ceiling per run — defend this number
  reapproval_threshold: 3            # soft gate (see Human Approval section)
```

### Enforcement

```
CYCLE_COUNT = count items filed this cycle for target_repo
If CYCLE_COUNT >= max_items_per_repo_per_cycle:
  STOP — log: "Budget exhausted for {repo} this cycle ({CYCLE_COUNT}/{max})"
  Do NOT file more items until next cycle
```

**Defend the number.** A cap of 5 means even a runaway agent creates at most 5 noise items per cycle — recoverable. A cap of 9999 is no cap. If you find yourself raising the ceiling to keep the agent productive, the agent prompt is wrong, not the cap.

---

## Output Schema Gate (Field Presence)

Make alignment fields part of the agent's output format, not a post-generation check. If the agent can't populate the fields from its seeded context, it produces nothing — the gate is a constraint on generation, not a validation after the fact.

### Required Output Schema

```yaml
title: string
strategic_goal: string        # agent must derive from approved context
capability: string            # reusable capability, not one-off feature
measurable_outcome: string    # specific metric, behavior, or artifact
sensitive_data_present: bool  # explicit declaration
within_budget: bool           # agent self-checks against config
```

### Filing Logic

```
If any of [strategic_goal, capability, measurable_outcome] is empty:
  REJECT — the agent had no context to work from
  Log and skip, do not retry

If sensitive_data_present == true AND body still contains raw identifiers:
  REJECT — scrub step failed
```

**Why presence, not quality:** Quality checks on field content require judgment the validator doesn't have. Presence checks are binary and reliable. Quality comes from the agent being seeded with good context — not from downstream validation.

---

## Sensitive Data Scrub (Machine-Enforced)

Scan issue title, body, and frontmatter before filing. Regex runs automatically, no human needed.

### Detection Patterns

```
SENSITIVE_PATTERNS = [
  /\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z]{2,}\b/i,  # email addresses
  /\b\d{3}-\d{2}-\d{4}\b/,                               # SSN
  /\b4[0-9]{12}(?:[0-9]{3})?\b/,                         # Visa card
  /\b(?:password|secret|token|api_key)\s*[:=]\s*\S+/i,   # credentials
  /postgres:\/\/[^@]+@/,                                  # DB connection strings
  /-----BEGIN .* KEY-----/,                               # private keys
]

COMPANY_NAME_PATTERNS = [
  # Populate from your customer list — any real company/person name in evidence
]

For each PATTERN in SENSITIVE_PATTERNS + COMPANY_NAME_PATTERNS:
  If PATTERN matches item.title or item.body:
    SCRUB — replace match with [REDACTED] or generalize
    Log: "Sensitive data scrubbed: {pattern_type}"
```

### Handling Customer Evidence

When an agent uses a customer conversation, support ticket, or production log as evidence:

1. **Generalize** — rewrite the scenario as a product capability gap, not a client story
2. **Strip identifiers** — no company names, user IDs, email addresses, or account numbers
3. **Verify** — after scrubbing, confirm the issue still makes sense without the identifiers

```
EVIDENCE_SECTION = extract_evidence_from_body(item)
If EVIDENCE_SECTION contains client identifiers:
  REWRITE as: "A user reported that [generalized scenario]..."
  Do NOT include: "Acme Corp said that...", "user@client.com complained..."
```

---

## Audit Ledger (Machine-Written)

Append one record per agent run to an immutable log. The machine writes it; humans may or may not read it, but the record survives either way.

### Schema

```jsonl
{"ts": "ISO8601", "agent": "string", "repo": "string", "action": "filed|skipped|rejected", "item_id": "string|null", "reason": "string", "strategic_goal": "string"}
```

### Write Pattern

```
RECORD = {
  ts: NOW(),
  agent: AGENT_NAME,
  repo: TARGET_REPO,
  action: "filed" | "skipped" | "rejected",
  item_id: filed_issue_number or null,
  reason: one-line explanation,
  strategic_goal: item.strategic_goal or "N/A"
}
Append RECORD to ledger/runs.jsonl   # append-only, never overwrite
```

**Rules:**
- One record per item decision (file, skip, reject)
- Never delete or modify past entries
- Include `rejected` records — rejections are as valuable as filings for auditing agent behavior

---

## Strategic Alignment Fields (Agent Self-Fill)

The content of the alignment fields depends on the agent being seeded with meaningful context. This is the weakest machine-enforceable layer — the validator can check presence but not quality.

### Generic Value Detection (Best-Effort)

Reject items whose fields match these patterns:

| Field | Reject if value is |
|-------|-------------------|
| `strategic_goal` | "improve the product", "fix bugs", "tech debt" |
| `capability` | Client name, account ID, proper noun from a specific customer |
| `measurable_outcome` | "better UX", "faster", "cleaner code" |

Require specificity: `"reduce P95 latency on /api/search below 200ms"` not `"make search faster"`.

**Limitation:** A determined (or poorly-prompted) agent can still produce fields that pass the regex but are meaningless. The real quality control is the input context the agent is given — not downstream validation. Treat this as a cheap sanity check, not a real gate.

---

## Human Approval Gates (Aspirational)

**These gates will erode within weeks without active discipline. Design your system to degrade gracefully to machine-only enforcement.**

Not all autonomous actions need per-item approval. Design gates at the right level, expect them to decay, and make sure the machine layer holds when they do.

### Gate Levels

| Gate | What requires approval | Durability |
|------|----------------------|------------|
| **Scope gate** | New strategic goals, new repos in scope | High — infrequent, high-stakes |
| **Theme gate** | Weekly themes that define extraction direction | Medium — weekly cadence hard to sustain |
| **Epic gate** | Cross-repo coordination, multi-week work | Medium |
| **Item gate** | Individual issues | Low — will be ignored after week two |

**Default:** Require approval at the Scope level only. Trust machine gates (budget cap, schema, regex) for everything downstream.

### Approval Artifact Pattern

Gate approvals via committed files, not ad-hoc messages:

```
themes/active.md     ← human commits once to authorize a scope
```

Agents read these files to determine scope. Absence of the file = no approval = no action.

```
ACTIVE_THEMES = read("themes/active.md")
If ACTIVE_THEMES is empty or not found:
  STOP — log: "No approved themes. Commit themes/active.md to authorize work."
```

**Why committed files beat messages:** Messages are ambiguous and untracked. A committed file is auditable and passive — the human updates it once, then walks away. The file keeps gating even when attention drifts.

**What NOT to rely on:**
- Per-item review queues (will be ignored)
- Reapproval thresholds as behavioral gates (will be raised to 9999)
- Slack/email notifications (will be muted)

---

## Error Handling

| Error | Action |
|-------|--------|
| Alignment fields missing | Reject item, log, continue to next |
| Sensitive data found | Scrub and re-validate, or reject if unscrubable |
| Budget exhausted | Stop run, log summary, do not retry same cycle |
| Approval file missing | Stop run, surface clear message to human |
| Issue filing fails (API error) | Log error, do not retry more than once |
| Ledger write fails | Log warning, continue — ledger failure must not block filing |
