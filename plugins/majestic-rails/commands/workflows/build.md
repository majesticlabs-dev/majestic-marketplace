---
name: rails:build
description: Execute work plans efficiently while maintaining quality and finishing Rails features
argument-hint: "[plan file] [optional: branch-name]"
allowed-tools: Read, Write, Edit, Bash, Grep, Glob, Task, Skill, TodoWrite, AskUserQuestion
---

# Work Plan Execution Command

Execute a work plan efficiently while maintaining quality and finishing features.

## Introduction

This command takes a work document (plan, specification, or todo file) and executes it systematically. The focus is on **shipping complete features** by understanding requirements quickly, following existing patterns, and maintaining quality throughout.

## Arguments

Parse the arguments to extract:
- **Plan file**: The path to the work document (required)
- **Branch name**: Optional branch name for the feature (if not provided, derive from plan title)

<input_arguments> $ARGUMENTS </input_arguments>

## Execution Workflow

### Phase 1: Quick Start

1. **Read Plan and Clarify**

   - Read the work document completely
   - Review any references or links provided in the plan
   - If anything is unclear or ambiguous, ask clarifying questions now
   - Get user approval to proceed
   - **Do not skip this** - better to ask questions now than build the wrong thing

2. **Setup Environment**

   Determine branch name:
   - **If branch name provided**: Use it exactly as-is (e.g., `my-branch`)
   - **If NOT provided**: Derive from plan title with `feature/` prefix (e.g., `feature/user-auth`)

   Use `AskUserQuestion` to determine environment setup:

   **Options:**
   - **Live work on current branch** - Standard checkout workflow
   - **Parallel work with worktree** - Recommended for parallel development

   **If live work:**
   ```bash
   git checkout master && git pull origin master
   git checkout -b <branch-name>
   ```

   **If worktree:**
   ```bash
   skill: git-worktree
   # Pass the branch name to the skill
   ```

   **Recommendation**: Use worktree if:
   - You want to work on multiple features simultaneously
   - You want to keep main clean while experimenting
   - You plan to switch between branches frequently

   Use live branch if:
   - You're working on a single feature
   - You prefer staying in the main repository

3. **Create Todo List**
   - Use TodoWrite to break plan into actionable tasks
   - Include dependencies between tasks
   - Prioritize based on what needs to be done first
   - Include testing and quality check tasks
   - Keep tasks specific and completable

### Phase 2: Execute

1. **Task Execution Loop**

   For each task in priority order:

   ```
   while (tasks remain):
     - Mark task as in_progress in TodoWrite
     - Read any referenced files from the plan
     - Look for similar patterns in codebase
     - Implement following existing conventions
     - Write tests for new functionality
     - Run tests after changes
     - Mark task as completed
   ```

2. **Follow Existing Patterns**

   - The plan should reference similar code - read those files first
   - Match naming conventions exactly
   - Reuse existing components where possible
   - Follow project coding standards (see CLAUDE.md)
   - When in doubt, grep for similar implementations

3. **Test Continuously**

   - Run relevant tests after each significant change
   - Don't wait until the end to test
   - Fix failures immediately
   - Add new tests for new functionality

4. **UI Iteration** (if applicable)

   For UI work:

   - Implement components following design specs or mockups
   - Use `ui-ux-designer` agent to iteratively refine the UI
   - Take screenshots and compare against requirements
   - Repeat until implementation meets expectations

5. **Track Progress**
   - Keep TodoWrite updated as you complete tasks
   - Note any blockers or unexpected discoveries
   - Create new tasks if scope expands
   - Keep user informed of major milestones

### Phase 3: Quality Check

1. **Run Core Quality Checks**

   Always run before submitting:

   ```bash
   # Run full test suite
   bin/rails test

   # Run linting
   # Use `lint` agent before pushing to origin
   ```

2. **Consider Reviewer Agents** (Optional)

   Use for complex, risky, or large changes:

   - **simplicity-reviewer**: Check for unnecessary complexity
   - **pragmatic-rails-reviewer**: Verify Rails conventions
   - **performance-reviewer**: Check for performance issues
   - **security-review**: Scan for security vulnerabilities
   - **test-reviewer**: Review test quality and coverage

   Run reviewers in parallel:

   ```
   agent simplicity-reviewer "Review changes for simplicity"
   agent pragmatic-rails-reviewer "Check Rails conventions"
   ```

   Present findings to user and address critical issues.

3. **Final Validation**
   - All TodoWrite tasks marked completed
   - All tests pass
   - Linting passes
   - Code follows existing patterns
   - UI matches design requirements (if applicable)
   - No console errors or warnings

### Phase 4: Ship It

Use the `ship` agent to handle linting, commit, and PR creation:

```
agent ship
```

The ship agent will:
- Run linters and auto-fix issues
- Create a commit with proper conventional format
- Push and create a pull request
- Return the PR URL

After shipping, notify the user:
- Summarize what was completed
- Link to PR
- Note any follow-up work needed

## Key Principles

### Start Fast, Execute Faster

- Get clarification once at the start, then execute
- Don't wait for perfect understanding - ask questions and move
- The goal is to **finish the feature**, not create perfect process

### The Plan is Your Guide

- Work documents should reference similar code and patterns
- Load those references and follow them
- Don't reinvent - match what exists

### Test As You Go

- Run tests after each change, not at the end
- Fix failures immediately
- Continuous testing prevents big surprises

### Quality is Built In

- Follow existing patterns
- Write tests for new code
- Run linting before pushing
- Use reviewer agents for complex/risky changes only

### Ship Complete Features

- Mark all tasks completed before moving on
- Don't leave features 80% done
- A finished feature that ships beats a perfect feature that doesn't

## Quality Checklist

Before creating PR, verify:

- [ ] All clarifying questions asked and answered
- [ ] All TodoWrite tasks marked completed
- [ ] Tests pass (run `bin/rails test`)
- [ ] Linting passes (use `lint` agent)
- [ ] Code follows existing patterns
- [ ] UI matches design requirements (if applicable)
- [ ] Commit messages follow conventional format
- [ ] PR description includes summary and testing notes

## When to Use Reviewer Agents

**Don't use by default.** Use reviewer agents only when:

- Large refactor affecting many files (10+)
- Security-sensitive changes (authentication, permissions, data access)
- Performance-critical code paths
- Complex algorithms or business logic
- User explicitly requests thorough review

For most features: tests + linting + following patterns is sufficient.

## Common Pitfalls to Avoid

- **Analysis paralysis** - Don't overthink, read the plan and execute
- **Skipping clarifying questions** - Ask now, not after building wrong thing
- **Ignoring plan references** - The plan has links for a reason
- **Testing at the end** - Test continuously or suffer later
- **Forgetting TodoWrite** - Track progress or lose track of what's done
- **80% done syndrome** - Finish the feature, don't move on early
- **Over-reviewing simple changes** - Save reviewer agents for complex work
