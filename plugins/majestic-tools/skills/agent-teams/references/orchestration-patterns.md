# Agent Teams Orchestration Patterns

## Pattern 1: Parallel Review

**Use when:** Reviewing code, PRs, or designs from multiple perspectives simultaneously.

**Structure:**
- Lead creates team + spawns 3-4 specialist reviewers
- Each reviewer gets a distinct lens (security, performance, test coverage, architecture)
- Reviewers work independently, no inter-agent messaging needed
- Lead synthesizes findings after all reviewers finish

**Prompt template:**
```
Create an agent team to review [target]. Spawn [N] reviewers:
- One focused on [lens-1]
- One checking [lens-2]
- One validating [lens-3]
Have them each review and report findings.
```

**Task structure:** Independent tasks, no dependencies. One task per reviewer.

**Model selection:** Use Sonnet for reviewers (cost-effective). Lead can use Opus or Sonnet.

---

## Pattern 2: Competing Hypotheses

**Use when:** Root cause is unclear, debugging complex issues, or exploring design alternatives.

**Structure:**
- Lead spawns 3-5 investigators, each assigned a different hypothesis
- Investigators explicitly challenge each other's findings
- Adversarial debate structure prevents anchoring bias
- Lead synthesizes consensus or identifies winning hypothesis

**Prompt template:**
```
[Problem description]. Spawn [N] teammates to investigate different hypotheses.
Have them talk to each other to try to disprove each other's theories.
Update findings with whatever consensus emerges.
```

**Task structure:** Independent investigation tasks + shared "findings" document.

**Key advantage:** Sequential investigation anchors on first theory found. Parallel adversarial investigation surfaces the strongest explanation.

---

## Pattern 3: Multi-Module Feature

**Use when:** Building a feature that spans multiple modules or layers (frontend, backend, tests).

**Structure:**
- Lead breaks feature into independent modules
- Each teammate owns a different set of files
- Dependencies expressed via task `blockedBy` — auto-unblock when predecessors complete
- Lead coordinates integration after all modules ready

**Prompt template:**
```
Create a team with [N] teammates to implement [feature].
- [teammate-1]: owns [module-1] files
- [teammate-2]: owns [module-2] files
- [teammate-3]: writes tests after implementation
Use Sonnet for each teammate.
```

**Task structure:**
```
Task 1: Implement backend API (teammate-1)
Task 2: Implement frontend UI (teammate-2)
Task 3: Write integration tests (teammate-3, blockedBy: [1, 2])
Task 4: Update documentation (teammate-1, blockedBy: [3])
```

**Critical rule:** No two teammates should edit the same file. Break work by file ownership.

---

## Pattern 4: Research Pipeline

**Use when:** Research feeds into implementation — explore first, then build.

**Structure:**
- Phase 1: Multiple researchers explore different aspects in parallel
- Phase 2: Lead synthesizes research into implementation plan
- Phase 3: Implementers build based on synthesized plan
- Plan approval workflow ensures quality gate between phases

**Prompt template:**
```
Phase 1: Spawn 3 researchers to investigate [topic] from different angles.
Require plan approval before any implementation.
Phase 2: After research, create implementation tasks based on findings.
```

**Task structure:**
```
Tasks 1-3: Research tasks (parallel, no dependencies)
Task 4: Synthesize findings (lead, blockedBy: [1, 2, 3])
Tasks 5-7: Implementation tasks (blockedBy: [4])
```

**Plan approval:** Spawn implementers with `planModeRequired: true`. Lead reviews and approves/rejects plans before implementation begins.

---

## Sizing Guidelines

| Team Size | Best For | Token Cost |
|-----------|----------|------------|
| 2-3 teammates | Focused parallel work | ~3-4x single session |
| 4-5 teammates | Multi-module features | ~5-6x single session |
| 5+ teammates | Large research efforts | ~7x+ single session |

**Task sizing:**
- Too small: coordination overhead exceeds benefit
- Too large: teammates work too long without check-ins
- Right size: self-contained unit producing a clear deliverable (function, test file, review)
- Aim for 5-6 tasks per teammate for steady throughput
