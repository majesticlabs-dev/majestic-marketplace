---
name: majestic:run-blueprint
description: Execute all tasks in a blueprint using build-task workflow
argument-hint: "<blueprint-file.md>"
---

Run these steps in order. Do not do anything else.

1. `/majestic-ralph:ralph-loop "complete all blueprint tasks" --completion-promise "RUN_BLUEPRINT_COMPLETE"`
2. Load blueprint from $ARGUMENTS (required)
3. Find next task with status ⏳ (skip if dependencies not ✅)
4. `/majestic:build-task "<task-id>" --no-ship`
5. Update task status in blueprint: ✅ if passed, 🔴 if failed
6. If all tasks ✅ or 🔴: `/majestic:ship-it`
7. Output `<promise>RUN_BLUEPRINT_COMPLETE</promise>` when shipped

Start with step 1 now.
