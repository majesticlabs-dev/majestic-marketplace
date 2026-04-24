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

## Strategic Alignment Gate

Every AI-created work item must trace to an explicit strategic goal before filing. Items that cannot be traced are discarded, not filed.

### Required Fields (YAML frontmatter or structured body)

```yaml
strategic_goal: string    # which top-level product goal this advances
capability: string        # reusable capability being built, not one-off feature
measurable_outcome: string # how success is verified (metric, behavior, artifact)
```

### Validation (run before any `gh issue create` or equivalent)

```
GOAL = item.strategic_goal
CAPABILITY = item.capability
OUTCOME = item.measurable_outcome

If any of [GOAL, CAPABILITY, OUTCOME] is empty or generic:
  REJECT — log: "Missing alignment fields: {missing_fields}"
  Do NOT file the item

If CAPABILITY contains client-specific identifiers (company names, account IDs):
  REJECT — log: "Capability must be reusable, not client-specific"
  Rewrite as generalized capability or discard
```

**Generic value detection** — reject items whose fields match these patterns:

| Field | Reject if value is |
|-------|-------------------|
| `strategic_goal` | "improve the product", "fix bugs", "tech debt" |
| `capability` | Client name, account ID, proper noun from a specific customer |
| `measurable_outcome` | "better UX", "faster", "cleaner code" |

Require specificity: `"reduce P95 latency on /api/search below 200ms"` not `"make search faster"`.

---

## Sensitive Data Gate

Scan issue title, body, and all frontmatter fields before filing. If any pattern matches, scrub before filing or discard.

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

When an AI agent uses a customer conversation, support ticket, or production log as evidence for an issue:

1. **Generalize** — rewrite the scenario as a product capability gap, not a client story
2. **Strip identifiers** — no company names, user IDs, email addresses, or account numbers in filed issues
3. **Verify** — after scrubbing, confirm the issue still makes sense without the identifiers

```
EVIDENCE_SECTION = extract_evidence_from_body(item)
If EVIDENCE_SECTION contains client identifiers:
  REWRITE as: "A user reported that [generalized scenario]..."
  Do NOT include: "Acme Corp said that...", "user@client.com complained..."
```

---

## Budget Guardrails

Prevent queue flooding when agents run on a schedule.

### Configuration

```yaml
# In .agents.yml or equivalent config
ai_work_governance:
  max_items_per_repo_per_cycle: 5    # hard ceiling per run
  reapproval_threshold: 3            # pause after N items without human review
  require_approval_for_new_scope: true
```

### Enforcement

```
CYCLE_COUNT = count items filed this cycle for target_repo
If CYCLE_COUNT >= max_items_per_repo_per_cycle:
  STOP — log: "Budget exhausted for {repo} this cycle ({CYCLE_COUNT}/{max})"
  Do NOT file more items until next cycle

UNREVIEWED_COUNT = count items filed since last human approval
If UNREVIEWED_COUNT >= reapproval_threshold:
  PAUSE — log: "Reapproval threshold reached ({UNREVIEWED_COUNT} items)"
  Surface queue for human review before continuing
```

**Why this matters:** Without caps, a single agent run can flood a repo with 20+ issues, making the backlog unusable and burying legitimate human-filed work.

---

## Human Approval Gate Design

Not all autonomous actions need per-item approval. Design gates at the right level.

### Gate Levels

| Gate | What requires approval | When to pause |
|------|----------------------|---------------|
| **Scope gate** | New strategic goals, new repos in scope | Before first item in new scope |
| **Theme gate** | Weekly themes that define extraction direction | Before agent runs for that week |
| **Epic gate** | Cross-repo coordination, multi-week work | Before decomposing into issues |
| **Item gate** | Individual issues | Only for p1 items or budget overrides |

**Default:** Require approval at the Theme level. Trust agents to decompose approved themes into bounded issues autonomously.

### Approval Artifact Pattern

Gate approvals via committed artifacts, not ad-hoc messages:

```
themes/active.md     ← human commits this to approve themes
epics/approved/      ← human merges PR to approve epics
```

Agents read these files to determine scope. Absence of the file = no approval = no action.

```
ACTIVE_THEMES = read("themes/active.md")
If ACTIVE_THEMES is empty or not found:
  STOP — log: "No approved themes. Commit themes/active.md to authorize work."
```

**Why committed files, not messages:** Messages are ambiguous and untracked. A committed file creates an auditable record of what was approved, when, and by whom.

---

## Audit Ledger

Append one record per agent run to an immutable log for traceability.

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
- Include `rejected` records — the rejections are as valuable as the filings for auditing agent behavior

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
