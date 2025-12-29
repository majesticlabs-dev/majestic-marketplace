---
name: majestic-guide
description: HOW TO - Guide to the right skill, command, or agent for any task
allowed-tools: Read, Glob, Grep
argument-hint: "[what you want to do]"
---

# Majestic Guide

Guide users to the most appropriate skill, command, or agent for their task.

## Input

`$ARGUMENTS` - Description of what the user wants to accomplish

## Instructions

1. **Analyze the Request**
   - Parse what the user is trying to accomplish
   - Identify key domain areas: engineering, rails, python, marketing, sales, company ops, or meta/tools

2. **Search Available Components**

   Search across all installed Majestic plugins for matching components:

   ```
   Agents: plugins/*/agents/*.md
   Commands: plugins/*/commands/**/*.md
   Skills: plugins/*/skills/*/SKILL.md
   ```

3. **Match by Domain and Intent**

   **Engineering (majestic-engineer)**
   - Git workflows → `/majestic-engineer:git:*` commands
   - Planning/architecture → `plan:architect` agent, `/majestic:plan` command
   - Build single task → `/majestic:build-task` command
   - Build entire plan → `/majestic:build-plan` command (with ralph-wiggum for autonomy)
   - Testing/TDD → `tdd-workflow` skill, `test-create` agent
   - Security review → `security-review` agent
   - CI/CD issues → `github-resolver` agent, `check-ci` skill
   - Code search → `ripgrep-search`, `ast-grep-searching` skills
   - Documentation → `docs-architect`, `docs-researcher` agents

   **Rails (majestic-rails)**
   - Ruby code → `ruby-coder`, `dhh-coder` skills
   - Tests → `rspec-coder`, `minitest-coder` skills
   - Debugging → `rails-debugger` agent
   - Refactoring → `rails-refactorer` agent
   - Linting → `lint` agent, `rubocop-fixer` agent
   - Database → `database-admin`, `database-optimizer` agents
   - Background jobs → `active-job-coder`, `solid-queue-coder` agents
   - Frontend → `hotwire-coder`, `stimulus-coder`, `tailwind-coder` agents
   - GraphQL → `graphql-architect` agent
   - Components → `viewcomponent-coder` skill

   **Python (majestic-python)**
   - Python code → `python-coder` agent
   - Code review → `python-reviewer` agent

   **Marketing (majestic-marketing)**
   - SEO → various `seo:*` agents, `seo-audit` skill
   - Content → `content-writer`, `content-optimizer` skills
   - Branding → `namer` agent
   - Landing pages → `landing-page-builder` skill
   - Market research → `market-research` skill

   **Sales (majestic-sales)**
   - Funnels → `/funnel-builder` command
   - ICP → `icp-discovery` skill
   - Proposals → `proposal-writer` skill
   - Outbound → `outbound-sequences` skill
   - Playbooks → `sales-playbook` skill

   **Company (majestic-company)**
   - Idea validation → `idea-validator` agent
   - Strategy → `first-principles` agent
   - HR/People → `people-ops` agent
   - Customer discovery → various research skills

   **Tools/Meta (majestic-tools)**
   - Create skills → `new-skill` skill
   - Create commands → `/new-command` command
   - Create agents → `/new-agent` command
   - Create hooks → `/new-hook` command
   - Brainstorming → `brainstorming` skill
   - Deep thinking → `/ultrathink-task`, `/ultra-options` commands

4. **Present Recommendation**

   Format the response as:

   ```
   ## 🎯 Recommended: [Component Type] - [Name]

   **Plugin:** majestic-[plugin]
   **Type:** Agent | Command | Skill
   **Invocation:** `[how to use it]`

   ### Why This Fits
   [Brief explanation of why this matches the request]

   ### Quick Start
   [Example usage]

   ---

   ### 🔄 Alternatives
   - **[Alternative 1]** - [when to use instead]
   - **[Alternative 2]** - [when to use instead]
   ```

5. **Handle Ambiguity**

   If the request could match multiple domains:
   - List top 2-3 options with clear distinctions
   - Ask a clarifying question if truly ambiguous

## Examples

**Input:** "write tests for my Rails model"
**Output:** Recommend `rspec-coder` skill or `test-create` agent

**Input:** "optimize my database queries"
**Output:** Recommend `database-optimizer` agent

**Input:** "create a landing page"
**Output:** Recommend `landing-page-builder` skill

**Input:** "review my PR"
**Output:** Recommend `/majestic-rails:workflows:code-review` command

**Input:** "plan a new feature"
**Output:** Recommend `/majestic-engineer:workflows:plan` command or `plan:architect` agent

**Input:** "implement all tasks in my plan"
**Output:** Recommend `/majestic:build-plan` command, mention ralph-wiggum for autonomous execution

---

Now analyze: `$ARGUMENTS`
