# Granularity Audit Report

**Date:** 2026-01-14
**Scope:** All 19 plugins, 359 components (61 commands, 168 skills, 130 agents)

## Executive Summary

| Category | Total | Issues Found | Resolved | Compliance Rate |
|----------|-------|--------------|----------|-----------------|
| **Commands** | 61 | 8 critical | 1 | 88% |
| **Skills** | 171 | 15 critical | 0 | 91% |
| **Agents** | 130 | 11 critical | 0 | 92% |
| **Overall** | 362 | 34 critical | 1 | 91% |

**Key Finding:** The marketplace demonstrates strong granularity overall. Originally 34 components (9%) violated the "atomic primitives" principle. **1 resolved** (blueprint refactored into 3 skills).

---

## Critical Issues by Plugin

### majestic-engineer (74 components)

| Component | Type | Lines | Issue | Status |
|-----------|------|-------|-------|--------|
| `fix-reporter` | Skill | 498 | Mixes documentation capture with 8-option decision router | Open |
| `cloudflare-worker` | Skill | 165 | Covers 5 distinct Cloudflare services (Workers, Hono, KV, D1, R2, Durable Objects, Queues) | Open |
| `frontend-design` | Skill | 237 | Mixes design philosophy with 4 framework implementations (React, Vue, Rails, Hotwire) | Open |
| ~~`blueprint`~~ | Command | ~~425~~ 151 | ~~11+ phases~~ Refactored to thin orchestrator + 3 skills | **RESOLVED** |
| `build-task` | Command | 235 | 9 sequential phases before delegating to workflow manager | Open |
| `prd` | Command | 107 | 5 distinct phases (questions, generate, review, expand, backlog) | Open |
| `test-create` | Agent | 227 | Duplicates test-reviewer's acceptance criteria validation | Open |
| `github-resolver` | Agent | 244 | Mixes CI failure resolution with PR comment resolution | Open |

**Resolved:**
- ~~Split `blueprint` into discover, plan, review, build phases~~ **DONE** (PR #44)
  - Created `blueprint-discovery` (78 lines)
  - Created `blueprint-research` (75 lines)
  - Created `blueprint-execution` (85 lines)
  - Reduced `blueprint.md` from 425 → 151 lines

**Remaining Recommendations:**
- Split `fix-reporter` into capture + decision router
- Split `cloudflare-worker` into 5 focused skills per service
- Split `frontend-design` into design philosophy + framework-specific skills
- Remove AC verification from `test-create` (delegate to `test-reviewer`)
- Split `github-resolver` into `ci-resolver` + `pr-comment-resolver`

---

### majestic-marketing (62 components)

| Component | Type | Lines | Issue |
|-----------|------|-------|-------|
| `traffic-magnet` | Skill | 368 | 7+ concerns: keyword research, community strategy, content creation, outreach, social templates, case studies, tracking |
| `sales-page` | Skill | 409 | Duplicates competitive-positioning, positioning-angles, irresistible-offer, direct-response-copy |
| `google-ads-strategy` | Skill | 209 | Duplicates keyword research from bofu-keywords |
| `llm-optimizer` | Agent | 223 | 5+ concerns: GEO vs SEO, content framing, structure optimization, fact-density, query fan-out |
| `authority-builder` | Agent | 243 | 6+ concerns: E-E-A-T signals, press strategy, topical authority, behavioral SEO, Bing optimization |
| `entity-builder` | Agent | 228 | 4+ concerns: entity triplets, analyst positioning, brand consistency, review management |
| `content-planner` | Agent | 137 | Mixes content outlines with buyer journey grid (AEO strategy) |
| `schema-architect` | Agent | 185 | Mixes Schema.org implementation with llms.txt file creation |

**Recommendations:**
- Refactor `traffic-magnet` to ~120 lines, delegate keyword research to existing skill
- Convert `sales-page` to orchestration skill that assembles from other skills
- Remove keyword strategy from `google-ads-strategy`, reference `bofu-keywords`
- Split `llm-optimizer` into content optimizer + query expansion strategist
- Split `authority-builder` into E-E-A-T analyzer + topical authority mapper + behavioral SEO optimizer
- Split `entity-builder` into entity optimizer + analyst positioning + review manager

---

### majestic-rails (41 components)

| Component | Type | Lines | Issue |
|-----------|------|-------|-------|
| `business-logic-coder` | Skill | 309 | Mixes ActiveInteraction (typed operations) with AASM (state machines) |
| `dhh-coder` | Skill | 416 | Meta-skill covering entire DHH philosophy; overlaps with hotwire-coder, viewcomponent-coder, stimulus-coder |
| `data-integrity-reviewer` | Agent | 272 | 5 unrelated concerns: migration safety, data constraints, transactions, referential integrity, privacy compliance |
| `pragmatic-rails-reviewer` | Agent | 214 | 8 concerns: Turbo, controllers, services, style, testing, deletions, naming, performance |
| `performance-reviewer` | Agent | 141 | 7 performance areas poorly separated |
| `database-admin` | Agent | 155 | 3+ concerns: operational admin, infrastructure, data lifecycle |

**Recommendations:**
- Split `business-logic-coder` into `active-interaction-coder` + `aasm-coder`
- Narrow `dhh-coder` to coding conventions only; remove architecture decisions and overlapping content
- Split `data-integrity-reviewer` into `migration-reviewer` + `data-constraints-reviewer` + `transaction-reviewer` + `privacy-compliance-reviewer`
- Consolidate `pragmatic-rails-reviewer` or rename to `rails-conventions-reviewer`

---

### majestic-company (26 components)

| Component | Type | Lines | Issue |
|-----------|------|-------|-------|
| `pm-discovery` | Skill | 321 | 6 distinct PM frameworks mixed: interviews, assumption mapping, JTBD, RICE, OST, hypothesis |
| `people-ops` | Agent | 115 | 6 HR functions: hiring, onboarding, PTO, performance, relations, offboarding |
| `thirty-day-launch` | Agent | 216 | 7 launch tasks: blueprint, checklist, outreach, legal, forecast, mistakes, schedule |
| `startup-blueprint` | Agent | 226 | 10-phase monolithic startup planning system |

**Recommendations:**
- Split `pm-discovery` into `pm-customer-interviews`, `pm-assumption-mapping`, `product-prioritization-rice`, `product-hypothesis-jtbd`
- Split `people-ops` into task-specific agents with router
- Extract from `thirty-day-launch`: `copy-paste-outreach-templates`, `rookie-mistakes-by-industry`, `launch-legal-shortcuts`

---

### majestic-tools (17 components)

| Component | Type | Lines | Issue |
|-----------|------|-------|-------|
| `new-skill` | Command | 443 | 8+ topics: design philosophy, 4 archetypes, naming, descriptions, tools, content structure, advanced patterns, validation |
| `interview` | Command | 156 | 5+ domains: engineering, brand, product, marketing, sales with domain-specific resources |
| `learn` | Command | 176 | 80% duplicates compound-learnings skill |
| `command-patterns` | Skill | 87 | Mixes 4 design concerns: intelligence, UX, safety, integration |

**Recommendations:**
- Refactor `new-skill` into: `skill-design-philosophy` skill + `skill-archetypes` skill + `skill-naming-conventions` skill + reduced orchestration command (~100 lines)
- Split `interview` into domain-specific commands or single simple discovery + domain skills
- Reduce `learn` command to pure orchestration referencing `compound-learnings` skill
- Split `command-patterns` to separate safety patterns

---

### majestic-data (23 components)

| Component | Type | Lines | Issue |
|-----------|------|-------|-------|
| `etl-patterns` | Skill | 329 | 9 distinct patterns: idempotency, checkpointing, error handling, chunking, backfill, incremental, retry, orchestration, logging |
| `data-quality` | Skill | 349 | 8 concerns: profiling, quality dims, distribution monitoring, anomaly detection, scorecarding, freshness, volume, reporting |
| `data-validation` | Skill | 299 | 3 frameworks mixed without guidance: Pydantic, Pandera, Great Expectations |
| `pipeline-tester` | Agent | 276 | Mixes test generation with test pattern documentation |

**Recommendations:**
- Split `etl-patterns` into core patterns + incremental strategies
- Keep `data-quality` for quality dimensions/scorecarding; move profiling to `data-profiler` skill; create `anomaly-detection` skill
- Split `data-validation` into 3 framework-specific skills
- Split `pipeline-tester` into `test-fixture-generator` + `testing-patterns`

---

### majestic-sales (12 components)

| Component | Type | Lines | Issue |
|-----------|------|-------|-------|
| `sales-playbook` | Skill | 206 | 9 components: process map, qualification, discovery, demo, objections, battle cards, closing, stages, stakeholder mapping |
| `outbound-sequences` | Skill | 415 | 3 channels mixed: email, phone, LinkedIn with 8 frameworks |
| `pipeline-analyzer` | Agent | 341 | 7 frameworks + reporting templates |
| `funnel-builder` | Command | 272 | Entire funnel lifecycle; duplicates referral-program and win-back skills |
| `sales-strategist` | Agent | 245 | 6 strategy phases mixing frameworks with templates |

**Recommendations:**
- Split `sales-playbook` into `sales-process-builder` + `discovery-framework` + `objection-handling-library`
- Split `outbound-sequences` by channel: email-first, with separate cold call and LinkedIn skills
- Split `pipeline-analyzer` into diagnostics agent + deal scoring skill + reporting resources
- Split `funnel-builder` into 5 focused commands per phase, orchestrating existing skills

---

### majestic-devops (12 components)

| Component | Type | Lines | Issue |
|-----------|------|-------|-------|
| `devops-verifier` | Agent | 282 | 6 dimensions bundled: best practices, platform-specific, security, simplicity, maintainability, documentation |
| `wrangler-coder` | Skill | 454 | 7+ Cloudflare products: Workers, Pages, KV, D1, R2, Queues, Durable Objects, AI |

**Recommendations:**
- Convert `devops-verifier` to true orchestrator delegating to focused skills
- Monitor `wrangler-coder` for growth; consider splitting by feature area if resources expand

---

### majestic-python (8 components)

| Component | Type | Lines | Issue |
|-----------|------|-------|-------|
| `python-db` | Agent | 411 | **Exceeds 300-line limit.** Covers SQLAlchemy, async, models, queries, CRUD, repository, Alembic, optimization, pooling, transactions |
| `python-coder` | Skill | 127 | Lists 8 unrelated capability areas without teaching specific patterns |

**Recommendations:**
- Split `python-db` into `python-db-models` + `python-db-queries` + `python-db-migrations`
- Convert `python-coder` to reference material or split into focused skills per capability

---

### Other Plugins (No Critical Issues)

| Plugin | Components | Status |
|--------|------------|--------|
| majestic-react | 6 | All well-scoped |
| majestic-llm | 7 | All well-scoped |
| majestic-experts | 3 | All well-scoped |
| majestic-founder | 4 | All well-scoped |
| majestic-ralph | 4 | All well-scoped |
| majestic-relay | 4 | All well-scoped |
| majestic-agent-sdk | 2 | All well-scoped |
| majestic-browser | 1 | All well-scoped |
| majestic-creative | 2 | All well-scoped |

---

## Line Limit Violations

### Agents > 300 lines (CRITICAL)

| Plugin | Agent | Lines | Over Limit |
|--------|-------|-------|------------|
| majestic-python | python-db | 411 | +111 |
| majestic-rails | data-integrity-reviewer | 272 | -28 (OK) |

### Skills > 500 lines (None Found)

All skills comply with the 500-line limit.

### Commands (No Limit, But Concerns)

| Plugin | Command | Lines | Concern |
|--------|---------|-------|---------|
| majestic-tools | new-skill | 443 | Should be agent + skills |
| majestic-engineer | blueprint | 425 | Should be 3-4 focused commands |

---

## Patterns Requiring Attention

### 1. Framework Soup
Skills that mix multiple frameworks without clear guidance on when to use which:
- `data-validation`: Pydantic vs Pandera vs Great Expectations
- `frontend-design`: React vs Vue vs Rails vs Hotwire
- `business-logic-coder`: ActiveInteraction vs AASM

**Fix:** Split by framework OR add explicit decision criteria.

### 2. Orchestrator Overload
Commands that do too much inline instead of delegating:
- `blueprint`: 11 phases with inline logic
- `funnel-builder`: 5 phases duplicating existing skills
- `new-skill`: Teaching philosophy + archetypes + naming + validation

**Fix:** Extract reusable logic to skills; keep commands as orchestrators.

### 3. Scope Creep via Phases
Components with numbered phases that should be separate:
- `thirty-day-launch`: 7 sections
- `pm-discovery`: 6 frameworks
- `sales-playbook`: 9 process components

**Fix:** Split into focused skills per phase/framework/component.

### 4. Duplicate Logic
Skills/agents that duplicate functionality in other components:
- `test-create` duplicates `test-reviewer` AC validation
- `google-ads-strategy` duplicates `bofu-keywords` research
- `sales-page` duplicates 4+ other marketing skills

**Fix:** Remove duplication; reference existing skills.

---

## Recommendations Priority

### Immediate (Breaking Architecture)

| Priority | Plugin | Component | Action | Status |
|----------|--------|-----------|--------|--------|
| P0 | python | python-db | Split into 3 agents (exceeds limit) | Open |
| P0 | tools | new-skill | Refactor to agent + skills (443 lines) | Open |
| ~~P0~~ | ~~engineer~~ | ~~blueprint~~ | ~~Split into 3-4 focused commands~~ | **DONE** (PR #44) |

### High (Significant Scope Creep)

| Priority | Plugin | Component | Action |
|----------|--------|-----------|--------|
| P1 | rails | data-integrity-reviewer | Split into 4 reviewers |
| P1 | marketing | traffic-magnet | Reduce to ~120 lines |
| P1 | company | pm-discovery | Split into 4 focused skills |
| P1 | sales | pipeline-analyzer | Split diagnostics from reporting |
| P1 | engineer | fix-reporter | Extract decision router |

### Medium (Improving UX)

| Priority | Plugin | Component | Action |
|----------|--------|-----------|--------|
| P2 | engineer | frontend-design | Create framework-specific skills |
| P2 | rails | business-logic-coder | Split ActiveInteraction from AASM |
| P2 | marketing | llm-optimizer | Split content from query expansion |
| P2 | data | etl-patterns | Split into 2 focused skills |
| P2 | devops | devops-verifier | Convert to orchestrator |

### Low (Cleanup)

| Priority | Plugin | Component | Action |
|----------|--------|-----------|--------|
| P3 | engineer | test-create | Remove duplicate AC validation |
| P3 | marketing | google-ads-strategy | Remove keyword research |
| P3 | tools | learn | Remove skill duplication |
| P3 | rails | dhh-coder | Narrow scope, remove overlaps |

---

## Metrics

### Components by Size

```
< 100 lines:    89 components (25%)
100-200 lines: 142 components (40%)
200-300 lines:  98 components (27%)
300-400 lines:  25 components (7%)
> 400 lines:     5 components (1%)
```

### Issues by Category

```
Scope Creep:     22 components (65% of issues)
Framework Soup:   5 components (15% of issues)
Duplication:      4 components (12% of issues)
Line Violations:  3 components (8% of issues)
```

### Plugin Health Scores

| Plugin | Score | Notes |
|--------|-------|-------|
| majestic-react | 100% | All components well-scoped |
| majestic-llm | 100% | All components well-scoped |
| majestic-experts | 100% | All components well-scoped |
| majestic-founder | 100% | All components well-scoped |
| majestic-ralph | 100% | All components well-scoped |
| majestic-relay | 100% | All components well-scoped |
| majestic-agent-sdk | 100% | All components well-scoped |
| majestic-browser | 100% | All components well-scoped |
| majestic-creative | 100% | All components well-scoped |
| majestic-devops | 83% | 2 issues |
| majestic-data | 83% | 4 issues |
| majestic-engineer | 89% | 8 issues |
| majestic-rails | 85% | 6 issues |
| majestic-marketing | 87% | 8 issues |
| majestic-company | 85% | 4 issues |
| majestic-tools | 76% | 4 issues |
| majestic-sales | 58% | 5 issues |
| majestic-python | 75% | 2 issues |

---

## Appendix: Well-Designed Components (Reference Patterns)

These components exemplify proper granularity:

### Skills (Single Concern)
- `tdd-workflow` (148 lines): Pure methodology
- `code-story` (36 lines): Pure templates
- `pandas-coder` (194 lines): One tool, comprehensive
- `parquet-coder` (269 lines): One format, comprehensive
- `devils-advocate` (102 lines): Single thinking framework

### Agents (Focused Purpose)
- `spec-reviewer` (76 lines): One review type
- `lint` (87 lines): One action
- `drift-detector` (270 lines): One detection type
- `proposal-generator` (140 lines): Clean orchestration

### Commands (Clear Delegation)
- `ship-it` (23 lines): Thin wrapper
- `worktree-cleanup` (22 lines): Single operation
- `config-reader` (29 lines): Single function
