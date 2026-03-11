# Agent Audit Report: Full Marketplace

**Date:** 2026-03-11
**Scope:** All 120 agents across 16 plugins

## Executive Summary

| Action | Count | % |
|--------|-------|---|
| **KEEP as agent** | 45 | 38% |
| **CONVERT to skill** | 49 | 41% |
| **MERGE into existing skill** | 20 | 17% |
| **REMOVE (redundant)** | 2 | 2% |
| **Borderline** | 1 | 1% |
| **Total agents audited** | **~117** | |

**Net result:** 120 agents → ~45 agents + ~69 new/merged skills
**62% of agents don't need to be agents**

---

## 1. majestic-engineer (38 agents → 20 remain) — DONE ✅

> **Commit:** `9e5cfa7` — 18 agents converted/merged, 1 deleted. 38→20 agents, 31→43 skills (v3.67.2)

### KEEP (20) — orchestrators, state managers, workflow engines

- `architect`, `build-task-workflow-manager`, `quality-gate`, `task-breakdown`
- `blueprint-to-epics`, `init-playlist`, `learning-processor`
- `task-fetcher`, `task-status-updater`, `toolbox-resolver`
- `workspace-setup`, `lessons-discoverer`, `always-works-verifier`
- `ship`, `context-proxy`, `github-resolver`, `security-review`
- `ui-ux-designer`, `refactor-plan`, `slop-remover`

### CONVERT to skill (8) — ✅ DONE

| Agent | Actual Skill Name | Status |
|-------|-------------------|--------|
| `plan-review` | `plan-review` | ✅ Done |
| `spec-reviewer` | `spec-reviewer` | ✅ Done |
| `pr-comment-resolver` | `pr-comment-resolver` | ✅ Done |
| `test-reviewer` | `test-reviewer` | ✅ Done |
| `ui-code-auditor` | `ui-code-auditor` | ✅ Done (resources moved) |
| `visual-validator` | `visual-validator` | ✅ Done |
| `rp-reviewer` | `rp-reviewer` | ✅ Done |
| `session-checkpoint` | `session-checkpoint` | ✅ Done |

### MERGE (9) — ✅ DONE

| Agent | Merged Into | Status |
|-------|-----------|--------|
| `ci-resolver` | `check-ci` skill | ✅ Done |
| `docs-architect` | `technical-writer` skill | ✅ Done |
| `docs-researcher` | new `docs-researcher` skill | ✅ Done (converted, no merge target) |
| `best-practices-researcher` | `research-compound` skill | ✅ Done |
| `git-researcher` | new `git-researcher` skill | ✅ Done (converted, no merge target) |
| `repo-analyst` | `blueprint-discovery` skill | ✅ Done |
| `web-research` | new `web-research` skill | ✅ Done (converted, kept separate) |
| `test-create` | `tdd-workflow` skill | ✅ Done |
| `test-runner` | new `test-runner` skill | ✅ Done (converted, target was agent not skill) |

### REMOVE (1) — ✅ DONE

- ~~`acceptance-criteria-verifier`~~ — deleted, absorbed by `always-works-verifier` + `quality-gate`

### Post-conversion fix — ✅ DONE

- `github-resolver` updated to reference `check-ci` and `pr-comment-resolver` as skills instead of Task subagents

---

## 2. majestic-marketing (16 agents → 5 remain) — DONE ✅

> **Commit:** pending — 11 agents converted/merged (including `structure-architect` missed in original audit). 16→5 agents, 49→66 skills (v3.25.4)

### KEEP (5) — multi-skill orchestrators with complex workflows

- `email-sequence-builder`, `content-planner`, `authority-builder`, `entity-builder`, `llm-optimizer`

### CONVERT to skill (8+1) — ✅ DONE

| Agent | Actual Skill Name | Status |
|-------|-------------------|--------|
| `namer` | `brand-namer` | ✅ Done |
| `fact-checker` | `fact-checker` | ✅ Done |
| `content-auditor` | `content-auditor` | ✅ Done |
| `content-refresher` | `content-refresher` | ✅ Done |
| `meta-optimizer` | `meta-optimizer` | ✅ Done |
| `schema-architect` | `schema-architect` | ✅ Done (resources moved) |
| `snippet-hunter` | `snippet-hunter` | ✅ Done |
| `keyword-strategist` | `keyword-strategist` | ✅ Done |
| `structure-architect` | `structure-architect` | ✅ Done (missed in original audit) |

### MERGE (2) — ✅ DONE

| Agent | Merged Into | Status |
|-------|-----------|--------|
| `cannibalization-detector` | `content-optimizer` skill | ✅ Done |
| `content-writer` (agent) | `seo-content` skill | ✅ Done |

---

## 3. majestic-company (17 agents → 8 remain) — DONE ✅

> **Commit:** pending — 9 agents converted/merged. 17→8 agents, 18→24 skills (v3.9.2)

### KEEP (8) — research-heavy with multi-step orchestration

- `problem-research`, `idea-validator`, `growth-audit`, `startup-blueprint`
- `financial-model`, `elevator-pitch`, `funding-ask-optimizer`, `tam-calculator`

### CONVERT to skill (6) — ✅ DONE

| Agent | Actual Skill Name | Status |
|-------|-------------------|--------|
| `future-back` | `future-back` | ✅ Done |
| `thirty-day-launch` | `thirty-day-launch` | ✅ Done |
| `decisions` | `decisions` | ✅ Done |
| `pricing-strategy` | `pricing-strategy` | ✅ Done |
| `market-expansion` | `market-expansion` | ✅ Done |
| `blind-spot-analyzer` | `blind-spot-analyzer` | ✅ Done |

### MERGE (3) — ✅ DONE

| Agent | Merged Into | Status |
|-------|-----------|--------|
| `people-ops` | `strategic-planning` skill | ✅ Done (resources moved) |
| `industry-research` | `industry-pulse` skill | ✅ Done |
| `ai-advantage` | `industry-pulse` skill | ✅ Done |

---

## 4. majestic-rails (15 agents → 5-6 keep) — PENDING

### KEEP (5)

- `code-review-orchestrator`, `data-integrity-reviewer`
- `database-optimizer`, `database-admin`, `gem-research`

### CONVERT to skill (7+1 borderline) — ⏳ TODO

| Agent | Reasoning | Status |
|-------|-----------|--------|
| `graphql-architect` | 162 lines of patterns, no autonomous execution | ⏳ |
| `lint` | Linting workflow guidance, not orchestration | ⏳ |
| `simplicity-reviewer` | Review framework/principles | ⏳ |
| `dhh-code-reviewer` | Review philosophy, not autonomous reviewer | ⏳ |
| `constraints-reviewer` | Checklist-based review guidance | ⏳ |
| `privacy-reviewer` | Compliance checklists | ⏳ |
| `performance-reviewer` | Analysis framework | ⏳ |
| `pragmatic-rails-reviewer` | **Borderline** — keep if used by orchestrator | ⏳ |

### MERGE (2) — ⏳ TODO

| Agent | Merge Into | Status |
|-------|-----------|--------|
| `migration-reviewer` | `rails-refactorer` skill | ⏳ |
| `transaction-reviewer` | `business-logic-coder` skill | ⏳ |

**Key insight:** 6 of 7 CONVERT agents are in review/ — they're review guidance frameworks, not autonomous code reviewers.

---

## 5. majestic-data (11 agents → 3 remain) — DONE ✅

> **Commit:** pending — 8 agents converted/merged/deleted. 11→3 agents, 17→19 skills (v1.1.5)

### KEEP (3)

- `etl-orchestrator`, `backfill-planner`, `pipeline-tester`

### CONVERT to skill (5) — ✅ DONE

| Agent | Actual Destination | Status |
|-------|-------------------|--------|
| `csv-to-sql` | merged into `csv-wrangler` skill | ✅ Done |
| `json-flattener` | merged into `pandas-coder` skill | ✅ Done |
| `migration-builder` | merged into `etl-core-patterns` skill | ✅ Done |
| `source-analyzer` | new `source-analyzer` skill | ✅ Done |
| `schema-discoverer` | new `schema-discoverer` skill | ✅ Done |

### MERGE (2) — ✅ DONE

| Agent | Merged Into | Status |
|-------|-----------|--------|
| `data-profiler` (agent) | `data-profiler` skill | ✅ Done |
| `drift-detector` | `data-quality` skill | ✅ Done |

### REMOVE (1) — ✅ DONE

- ~~`data-validator`~~ — deleted, redundant with `data-validation`, `pandera-validation`, `pydantic-validation`, `great-expectations` skills

---

## 6. majestic-python (6 agents → 2 remain) — DONE ✅

> **Commit:** pending — 4 agents → 3 skills (db-queries+db-models merged). 6→2 agents, 5→8 skills (v3.4.6)

### KEEP (2)

- `python-code-review` (orchestrator), `python-db` (router)

### CONVERT to skill (4) — ✅ DONE

| Agent | Actual Skill Name | Status |
|-------|-------------------|--------|
| `python-reviewer` | `python-reviewer` | ✅ Done |
| `python-db-queries` | `sqlalchemy-patterns` (merged with db-models) | ✅ Done |
| `python-db-migrations` | `alembic-patterns` | ✅ Done |
| `python-db-models` | `sqlalchemy-patterns` (merged with db-queries) | ✅ Done |

Post-conversion: `python-db` and `python-code-review` agents updated to reference skills instead of Task subagents.

---

## 7. majestic-llm (5 agents → 1 remain) — DONE ✅

> **Commit:** pending — 4 agents → 2 unified skills. 5→1 agent, 0→2 skills (v1.1.3)

### KEEP (1)

- `multi-llm-coordinator` (parallel LLM orchestration)

### CONVERT to skill (2) — ✅ DONE

| Agent | Actual Skill Name | Status |
|-------|-------------------|--------|
| `codex-consult` | `external-llm-consulting` (merged) | ✅ Done |
| `gemini-consult` | `external-llm-consulting` (merged) | ✅ Done |

### MERGE (2) — ✅ DONE

| Agent | Actual Skill Name | Status |
|-------|-------------------|--------|
| `codex-reviewer` | `external-llm-review` (merged) | ✅ Done |
| `gemini-reviewer` | `external-llm-review` (merged) | ✅ Done |

Post-conversion: `multi-llm-coordinator` agent updated to reference skills instead of Task subagents.

---

## 8. majestic-sales (4 agents → 0 keep) — DONE ✅

> **Commit:** `9e5cfa7` — All 4 agents converted to skills. 0 agents, 20 skills (v3.2.6)

### CONVERT to skill (4) — ✅ DONE

| Agent | Actual Skill Name | Status |
|-------|-------------------|--------|
| `outbound-optimizer` | `outbound-optimizer` | ✅ Done |
| `pipeline-analyzer` | `pipeline-analyzer` | ✅ Done |
| `proposal-generator` | `proposal-generator` | ✅ Done |
| `sales-strategist` | `sales-strategist` | ✅ Done |

---

## 9. Remaining small plugins — PARTIALLY DONE

| Plugin | Agent | Action | Reasoning | Status |
|--------|-------|--------|-----------|--------|
| **majestic-experts** | `expert-panel-discussion` | **KEEP** | Parallel multi-agent orchestration | ✅ No action needed |
| **majestic-experts** | `expert-perspective` | **KEEP** | Subprocess agent for panel | ✅ No action needed |
| **majestic-react** | `react-architect` | **KEEP** | Autonomous planning + task generation | ✅ No action needed |
| **majestic-react** | `react-reviewer` | **KEEP** | Structured multi-dimensional review | ✅ No action needed |
| **majestic-creative** | `gemini-image-coder` | **CONVERT** | API reference docs, not orchestration | ✅ Done (v1.3.2) |
| **majestic-devops** | `devops-verifier` | **CONVERT** | Routing orchestrator, aggregates skill scores | ✅ Done (v1.4.6) |
| **majestic-tools** | `reasoning-verifier` | **CONVERT** | Pedagogical methodology | ✅ Done (v3.17.2) |
| **majestic-tools** | `skill-grader` | **CONVERT** | Evaluation framework/template | ✅ Done (v3.17.2) |

---

## Patterns Discovered

- **"Router agents"** — 12 agents just gather input and route to skills (sales, devops-verifier, python-db). Most should be skills; keep only if routing logic is genuinely complex
- **"Review guidance agents"** — 15 agents across engineer/rails/python are review checklists masquerading as autonomous reviewers. All should be skills
- **"Research fragmentation"** — engineer has 7 research agents that should be 2-3 unified skills
- **"Duplicate naming"** — data-profiler exists as both agent AND skill with overlapping content
- **"Skill wrappers"** — sales has 4 agents that are literally thin wrappers calling skills

---

## Migration Priority & Progress

1. ✅ **Quick wins (low risk):** Sales (4), tools (2), creative (1), devops (1) — 8 agents converted
2. ✅ **High impact:** Engineer review agents (8) + research agents (9) + 1 deletion — 18 agents converted/merged
3. ⏳ **Moderate effort:** Marketing (11 ✅), company (9 ✅), rails (9) — require merging content
4. ✅ **Careful handling:** Data (8 ✅), python (4 ✅), llm (4 ✅) — skill creation alongside conversion

**Progress:** 62 of 72 conversions complete (86%) | Remaining: rails (10)
