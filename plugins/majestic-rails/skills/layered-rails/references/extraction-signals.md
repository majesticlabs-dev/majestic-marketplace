# Extraction Signals

Methodology for identifying when and what to extract from existing code.

## The Specification Test

Step-by-step diagnostic for misplaced responsibilities.

### How to Apply

1. **Pick a class** (model, controller, service)
2. **List every responsibility** it handles — one line per responsibility
3. **Label each** with its natural layer: Presentation, Application, Domain, Infrastructure
4. **Compare** each label to the class's actual layer
5. **Mismatches are extraction candidates**

### Worked Example: `User` Model (Domain Layer)

| # | Responsibility | Natural Layer | Match? |
|---|---------------|---------------|--------|
| 1 | Validates email format | Domain | Yes |
| 2 | Authenticates password | Domain | Yes |
| 3 | Processes avatar upload | Infrastructure | NO — extract |
| 4 | Sends welcome email | Infrastructure | NO — extract |
| 5 | Formats display name | Presentation | NO — extract or keep if trivial |
| 6 | Tracks login count | Domain | Yes |
| 7 | Generates API token | Domain | Yes |
| 8 | Logs activity to audit trail | Infrastructure | NO — extract |

**Extraction plan:**
- #3 → `Users::ProcessAvatar` service or ActiveStorage callback
- #4 → `after_create_commit` job or Active Delivery
- #5 → Keep if simple (`def display_name = "#{first} #{last}"`), else Presenter
- #8 → Event handler or `event-sourcing-coder` pattern

### Worked Example: `OrdersController` (Presentation Layer)

| # | Responsibility | Natural Layer | Match? |
|---|---------------|---------------|--------|
| 1 | Parse params | Presentation | Yes |
| 2 | Authorize user | Application | NO — extract to policy |
| 3 | Calculate discount | Domain | NO — extract to model/service |
| 4 | Create order + line items | Application | NO — extract to service |
| 5 | Send confirmation email | Infrastructure | NO — extract to service |
| 6 | Render response | Presentation | Yes |

**Extraction plan:**
- #2 → `OrderPolicy` via `action-policy-coder`
- #3 → `Order#apply_discount` or `Discounts::Calculate` interaction
- #4 + #5 → `Orders::Create` interaction via `active-interaction-coder`

## Callback Scoring Rubric

Score each model callback 1-5. Extract anything scoring 1-2.

### Score 5: Transformer

Computes derived values from the model's own attributes. Essential for data integrity.

```ruby
# Score 5 — Keep
before_validation :normalize_email
before_save :compute_slug_from_title
before_save :set_published_at, if: :publishing?

private

def normalize_email
  self.email = email&.strip&.downcase
end

def compute_slug_from_title
  self.slug = title&.parameterize
end
```

### Score 4: Normalizer / Utility

Sanitizes input or maintains internal counters. Safe to keep.

```ruby
# Score 4 — Keep
before_save :strip_whitespace_from_bio
after_create :increment_author_posts_count
after_destroy :decrement_author_posts_count

private

def strip_whitespace_from_bio
  self.bio = bio&.strip
end
```

### Score 2: Observer

Triggers side-effects that don't affect the model's own data.

```ruby
# Score 2 — Consider extracting
after_save :notify_admin_of_changes
after_update :sync_to_search_index
after_update :invalidate_cache

# Better: Use after_commit for async side-effects
after_commit :notify_admin_of_changes, on: :update
```

**Extraction options:**
- Move to `after_commit` + background job (minimum fix)
- Extract to Active Delivery notification (see `event-sourcing-coder`)
- Use pub/sub if multiple observers exist

### Score 1: Operation

Business workflow steps disguised as callbacks. Always extract.

```ruby
# Score 1 — Extract immediately
after_create :send_welcome_email
after_create :provision_account
after_create :create_default_project
after_create :enqueue_onboarding_sequence

# These are an entire workflow hiding in callbacks.
# Extract to: Users::Onboard interaction (active-interaction-coder)
```

**Why extract:** These callbacks couple the model to orchestration logic. Creating a User in tests/console triggers the entire onboarding workflow. The model shouldn't know about business processes.

## God Object Detection

### Churn x Complexity

God objects have both high change frequency AND high complexity.

**Measuring churn** (change frequency):
```bash
# Files changed most in last 6 months
git log --since="6 months ago" --name-only --pretty=format: | \
  sort | uniq -c | sort -rn | head -20
```

**Measuring complexity** (rough proxy):
```bash
# Line count per model
wc -l app/models/*.rb | sort -rn | head -20
```

**God object indicators:**
- Model > 300 lines
- Changed > 20 times in 6 months
- Has > 5 concerns included
- Spec file > 500 lines
- Multiple developers frequently conflict on same file

### Decomposition Strategies

| Strategy | When to Use | Example |
|----------|-------------|---------|
| Extract concern | Cohesive behavior subset | `User` → `Authenticatable` concern |
| Extract value object | Attributes that travel together | `User` → `Address` value object |
| Extract service | Multi-step operations | `User#provision!` → `Users::Provision` |
| Delegate to new model | Separate entity hiding inside | `User` → `UserProfile` (1:1) |
| Extract query object | Complex query logic | `User.active_with_stats` → `ActiveUsersQuery` |

## Current Attribute Anti-Pattern

### The Problem

`Current` attributes create invisible dependencies between layers.

```ruby
# BAD: Model depends on presentation-layer context
class Post < ApplicationRecord
  before_create :set_author

  def set_author
    self.author = Current.user  # Invisible dependency!
  end
end

# Breaks in: console, background jobs, tests, seeds
```

### The Fix

Pass explicitly at the call site.

```ruby
# GOOD: Explicit parameter
class Post < ApplicationRecord
  belongs_to :author, class_name: "User"
  validates :author, presence: true
end

# Controller (presentation layer owns Current)
def create
  @post = Post.new(post_params.merge(author: Current.user))
end
```

### When Current Is Acceptable

- **Audit logging** via middleware (infrastructure concern, not domain)
- **Request tracking** (request_id, IP) for observability
- **Timezone/locale** for presentation formatting

**Rule:** `Current` is for infrastructure concerns that span the entire request. Never for domain logic.

## Extraction Triggers Checklist

Extract when any of these are true:

- [ ] Method exceeds 15 lines
- [ ] Class exceeds 300 lines
- [ ] Model has 5+ included concerns
- [ ] External API call inside a model
- [ ] `Current.*` used in domain layer
- [ ] Callback scores 1-2 on the rubric
- [ ] Same logic duplicated in 2+ locations
- [ ] Spec file tests concerns outside the class's layer
- [ ] Multiple developers frequently conflict on the file
- [ ] Method name starts with `process_`, `handle_`, `perform_` in a model (smells like orchestration)
