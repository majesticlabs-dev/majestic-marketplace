---
name: layered-rails
description: Design Rails applications using layered architecture. Use when analyzing codebases for architecture violations, planning feature implementations, deciding where code belongs, or extracting abstractions from fat models/controllers. Complements dhh-coder (which keeps things simple) with guidance for when complexity demands structure.
---

# Layered Rails Architecture

**Audience:** Rails developers working on applications that have outgrown single-file patterns.
**Goal:** Know which layer code belongs in, when to extract, and which existing skill handles the implementation.

## Four-Layer Architecture

```
Presentation  →  Application  →  Domain  →  Infrastructure
(HTTP/UI)        (Orchestration)  (Business)   (Persistence/APIs)
```

**Core rule:** Lower layers MUST NOT depend on higher layers. Data flows top-to-bottom only.

### Layer Responsibilities

| Layer | Owns | Does NOT Own |
|-------|------|-------------|
| **Presentation** | HTTP concerns, params, rendering, channels, mailers | Business logic, direct DB queries |
| **Application** | Orchestration across models, authorization, form validation | Persistence details, rendering |
| **Domain** | Business rules, validations, associations, value objects | HTTP context, request objects, `Current.*` |
| **Infrastructure** | ActiveRecord, external APIs, file storage, caching | Business rules, presentation |

### Common Layer Violations

| Violation | Why It's Wrong | Fix |
|-----------|---------------|-----|
| `Current.user` in model | Domain depends on presentation context | Pass user as explicit parameter |
| `request` param in service | Application depends on presentation | Extract needed values before calling service |
| Pricing calc in controller | Business logic in presentation | Move to model method or service |
| All logic in services, anemic models | Domain layer is hollow | Keep domain logic in models; services orchestrate |
| Model sends emails directly | Domain depends on infrastructure side-effects | Use callbacks only for data transforms; extract delivery |

## The Specification Test

Diagnostic for misplaced code:

1. List every responsibility the object handles
2. For each, ask: "Does this belong to this layer's primary concern?"
3. If NO → extract to the appropriate layer

**Example:** A `User` model that handles authentication, avatar processing, notification preferences, and activity logging.
- Authentication → Domain (keep)
- Avatar processing → Infrastructure (extract to service/job)
- Notification preferences → Domain (keep as concern)
- Activity logging → Infrastructure (extract to observer/event)

See [references/extraction-signals.md](references/extraction-signals.md) for the full methodology.

## Callback Scoring

Rate each callback 1-5. Extract anything scoring 1-2.

| Score | Type | Example | Action |
|-------|------|---------|--------|
| 5 | Transformer | `before_validation :normalize_email` | Keep |
| 4 | Normalizer | `before_save :strip_whitespace` | Keep |
| 4 | Utility | `after_create :update_counter_cache` | Keep |
| 2 | Observer | `after_save :notify_admin` | Consider extracting |
| 1 | Operation | `after_create :send_welcome_email, :provision_account` | Extract |

**Rule of thumb:** If removing the callback would break the model's own data integrity → keep. If it triggers external side-effects → extract.

## Pattern Selection

**"Where should this code go?"**

| Situation | Pattern | Layer | Skill |
|-----------|---------|-------|-------|
| Complex multi-model form | Form Object | Presentation | — |
| Request param filtering | Filter Object | Presentation | — |
| View-specific formatting | Presenter / ViewComponent | Presentation | `viewcomponent-coder` |
| Authorization rules | Policy Object | Application | `action-policy-coder` |
| Business operation (one-time) | Service / Interaction | Application | `active-interaction-coder` |
| Multi-model orchestration | Service Object | Application | `active-interaction-coder` |
| State lifecycle management | State Machine | Domain | `aasm-coder` |
| Complex reusable query | Query Object | Domain | — |
| Immutable concept (Money, DateRange) | Value Object | Domain | — |
| Shared model behavior | Concern | Domain | — |
| Typed configuration | Config Object | Infrastructure | `anyway-config-coder` |
| Domain events / audit trail | Event Sourcing | Infrastructure | `event-sourcing-coder` |
| JSON-backed attributes | Store Model | Domain | `store-model-coder` |

### Decision Tree

```
Is it about HTTP/params/rendering?
  YES → Presentation layer
    Multi-model form? → Form Object
    Filtering params? → Filter Object
    Formatting for view? → Presenter or ViewComponent
  NO ↓

Is it authorization?
  YES → Policy Object (action-policy-coder)
  NO ↓

Does it orchestrate multiple models/services?
  YES → Application layer
    One-time operation? → Service/Interaction (active-interaction-coder)
    Needs typed inputs? → ActiveInteraction (active-interaction-coder)
  NO ↓

Is it a business rule about a single model?
  YES → Domain layer (keep in model or concern)
    Has state transitions? → AASM (aasm-coder)
    Reusable query? → Query Object
    Immutable value? → Value Object
  NO ↓

Is it about persistence/external APIs/caching?
  YES → Infrastructure layer
```

## Services as Waiting Rooms

`app/services/` is a **temporary staging area**, not a permanent home.

- Services that survive should eventually reveal the real abstraction they represent
- If a service wraps a single model operation → it probably belongs in the model
- If a service coordinates 3+ models → it's a legitimate orchestrator
- If a service grows complex → look for Form Object, Policy, or Query Object hiding inside

**Smell test:** If `app/services/` has 50+ files and no subdirectories, the waiting room has become permanent storage.

## Extraction Signals

When to extract code from existing locations:

| Signal | Threshold | Action |
|--------|-----------|--------|
| Method length | > 15 lines | Extract method or object |
| External API call in model | Any | Extract to service/gateway |
| God object | High churn × high complexity | Decompose (see [references/extraction-signals.md](references/extraction-signals.md)) |
| Spec exceeds layer concern | Specification test fails | Extract to appropriate layer |
| Callback score | 1-2/5 | Extract to service or event handler |
| Duplicated query logic | 2+ locations | Extract Query Object |
| `Current.*` in model | Any usage | Pass as explicit parameter |

See [references/extraction-signals.md](references/extraction-signals.md) for the complete methodology.

## Model Organization

Recommended ordering within model files:

```ruby
class Order < ApplicationRecord
  # 1. Extensions/DSL (has_secure_password, acts_as_*)
  # 2. Associations
  # 3. Enums
  # 4. Normalizations
  # 5. Validations
  # 6. Scopes
  # 7. Callbacks (transformers/normalizers only — score 4-5)
  # 8. Delegations
  # 9. Public methods
  # 10. Private methods
end
```

## When Layered vs DHH Style

This skill complements `dhh-coder`, not replaces it.

| Situation | Use |
|-----------|-----|
| Small/medium app, standard CRUD | `dhh-coder` — keep it simple |
| Complex domain, multiple bounded contexts | `layered-rails` — add structure |
| Authorization beyond simple checks | `action-policy-coder` via layered guidance |
| Fat model with 500+ lines | `layered-rails` extraction signals |
| Standard controller actions | `dhh-coder` — 7 REST actions |
| Multi-step business operation | `active-interaction-coder` via layered guidance |

**Default to simplicity.** Reach for layered patterns only when complexity demands it.

## Success Checklist

- [ ] No reverse dependencies (lower layers don't reference higher)
- [ ] Models don't access `Current` attributes
- [ ] Services don't accept request/controller objects
- [ ] Controllers contain only HTTP concerns
- [ ] Domain logic lives in models, not leaked into services
- [ ] All callbacks score 4+ (or extracted)
- [ ] Concerns group by behavior, not by artifact type
- [ ] Each abstraction belongs to exactly one layer

## Cross-References

| Need | Skill |
|------|-------|
| Authorization policies | `action-policy-coder` |
| Typed business operations | `active-interaction-coder` |
| State machines | `aasm-coder` |
| Operations + state routing | `business-logic-coder` |
| ViewComponents | `viewcomponent-coder` |
| Typed configuration | `anyway-config-coder` |
| Event sourcing / audit | `event-sourcing-coder` |
| JSON attributes | `store-model-coder` |
| Refactoring execution | `rails-refactorer` |
| DHH-style simplicity | `dhh-coder` |
| Pattern catalog details | [references/pattern-catalog.md](references/pattern-catalog.md) |
| Extraction methodology | [references/extraction-signals.md](references/extraction-signals.md) |
