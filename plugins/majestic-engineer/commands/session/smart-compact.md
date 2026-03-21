---
name: session:smart-compact
description: Analyze conversation and generate optimized /compact command
model: haiku
---

# Smart Compact

Analyze the current conversation and generate an optimized `/compact` command that preserves valuable context while discarding stale information.

## Analysis Framework

Review the conversation and categorize content:

### High Value (KEEP)
- Current task/goal being worked on
- Recent file changes (last 2-3 edits)
- Active errors or failing tests
- Decisions made and their rationale
- Current branch/PR context
- Uncommitted work state
- User preferences expressed this session

### Medium Value (SUMMARIZE)
- Exploration that led to current approach
- Research findings still relevant
- File structure understanding
- Dependencies/relationships discovered

### Low Value (DISCARD)
- Old grep/glob searches superseded by newer ones
- Abandoned approaches explicitly rejected
- Verbose tool outputs already acted upon
- Redundant file reads (same file read multiple times)
- Exploratory dead ends
- Old error messages that were fixed

## Output Format

Generate a ready-to-run command:

```
/compact [specific instructions]
```

### Instruction Template

```
/compact
KEEP: [specific items - current task, recent changes, active errors]
SUMMARIZE: [items worth condensing - exploration results, research]
DISCARD: [specific stale items - old searches, abandoned approaches, fixed errors]
```

## Example Outputs

### After Feature Implementation
```
/compact
KEEP: PR #45 authentication refactor, User model changes in app/models/user.rb,
test failure at spec/models/user_spec.rb:45 (validates :email uniqueness).
SUMMARIZE: Session token research, existing auth patterns found.
DISCARD: Initial file exploration, old grep for "password", abandoned JWT approach.
```

### After Debugging Session
```
/compact
KEEP: Root cause identified (N+1 in OrdersController#index), fix applied in commit abc123,
pending: add eager loading test.
SUMMARIZE: Performance investigation steps.
DISCARD: All EXPLAIN ANALYZE outputs, old log searches, initial wrong hypotheses.
```

### After Research/Planning
```
/compact
KEEP: Chosen approach (Hotwire + Turbo Streams), implementation plan in docs/plan.md,
key files to modify: app/views/messages/, app/controllers/messages_controller.rb.
SUMMARIZE: Alternative approaches evaluated (React, LiveView).
DISCARD: Documentation fetches, gem comparison searches, abandoned SPA approach.
```

## Instructions

1. Analyze the full conversation history
2. Categorize content using the framework above
3. Be specific - name files, line numbers, PR numbers, error messages
4. Output ONLY the `/compact` command block - no explanation needed
5. Make the command copy-paste ready

Generate the smart compact command now.
