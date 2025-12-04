# Majestic Engineer

Language-agnostic engineering workflows. Includes 19 specialized agents, 18 commands, and 13 skills.

## Installation

```bash
claude /plugin install majestic-engineer
```

## Recommended Workflows

### PRD-First (New Products/Features)

```mermaid
graph LR
    A0(/majestic:guided-prd) --> A(/majestic:prd)
    A --> B{{architect}}
    B --> C{{plan-review}}
    C --> D[Build]
    D --> E{{test-create}}
    E --> F{{ship}}
```

| Step | Tool | Purpose |
|------|------|---------|
| 1 | `/majestic:guided-prd` | Discover and refine product idea |
| 2 | `/majestic:prd` | Generate Product Requirements Document |
| 3 | `agent mj:architect` | Design implementation (HOW) |
| 4 | `agent mj:plan-review` | Validate before coding |
| 5 | Implementation | Write the code |
| 6 | `agent mj:test-create` | Write tests |
| 7 | `/git:commit` + `/git:create-pr` | Ship it |

### Plan-First (Features/Bugs/Improvements)

```mermaid
graph LR
    A(/majestic:plan) --> B{{plan-review}}
    B --> C[Build]
    C --> D{{test-create}}
    D --> E{{ship}}
```

| Step | Tool | Purpose |
|------|------|---------|
| 1 | `/majestic:plan` | Create structured implementation plan |
| 2 | `agent mj:plan-review` | Validate before coding |
| 3 | Implementation | Write the code |
| 4 | `agent mj:test-create` | Write tests |
| 5 | `agent mj:security-review` | Security audit |
| 6 | `/git:commit` + `/git:create-pr` | Ship it |

> **Note:** For Rails projects, use `/majestic-rails:workflows:build` for implementation.

## Quick Reference

| I want to... | Use this |
|--------------|----------|
| Plan a feature or bug fix | `/majestic:plan` |
| Analyze a spec for gaps | `agent mj:spec-reviewer` |
| Define what to build (requirements) | `/majestic:prd` |
| Design how to build it (architecture) | `agent mj:architect` |
| Plan a refactoring effort | `agent mj:refactor-plan` |
| Review a plan before implementing | `agent mj:plan-review` |

## Agents

Invoke with: `agent mj:<name>`

### design

| Agent | Description |
|-------|-------------|
| `mj:ui-ux-designer` | Iterative UI/UX refinement through screenshots and progressive improvements |

### plan

| Agent | Description |
|-------|-------------|
| `mj:architect` | Design non-trivial features, system architecture planning |
| `mj:plan-review` | Thorough review of development plans before implementation |
| `mj:refactor-plan` | Analyze code structure and create comprehensive refactoring plans |
| `mj:spec-reviewer` | Analyze specs and plans for user flows, gaps, and missing requirements |

### qa

| Agent | Description |
|-------|-------------|
| `mj:security-review` | OWASP Top 10 vulnerability scanning, secrets detection |
| `mj:test-create` | Automated test creation across frameworks (RSpec, Minitest, Jest) |
| `mj:test-reviewer` | Review test quality, coverage, edge cases, and assertion quality |
| `mj:visual-validator` | Verify UI changes achieved their goals through skeptical visual analysis |

### research

| Agent | Description |
|-------|-------------|
| `mj:best-practices-researcher` | Research external best practices and documentation with structured citations |
| `mj:docs-architect` | Create comprehensive technical documentation from codebases |
| `mj:docs-researcher` | Fetch and summarize library documentation |
| `mj:git-researcher` | Analyze git history, trace code evolution, and identify contributor expertise |
| `mj:repo-analyst` | Repository onboarding - analyze structure, conventions, templates, and patterns |
| `mj:web-research` | Internet research for debugging, finding solutions, and technical problems |

### workflow

| Agent | Description |
|-------|-------------|
| `mj:always-works-verifier` | Verify implementations actually work before declaring completion |
| `workflow:github-resolver` | Resolve CI failures and PR review comments (auto-detects project type) |
| `mj:ship` | Complete shipping workflow: lint, commit, PR |

## Commands

Invoke with: `/majestic-engineer:<category>:<name>`

### git

| Command | Description |
|---------|-------------|
| `git:changelog` | Create engaging changelogs from recent merges |
| `git:code-story` | Generate documentary-style narrative of repository development history |
| `git:commit` | Create git commit with proper message formatting |
| `git:create-pr` | Create a pull request for the current feature branch |
| `git:pr-review` | Review and address Pull Request comments from GitHub |

### session

| Command | Description |
|---------|-------------|
| `session:handoff` | Create a detailed handoff plan for continuing work |
| `session:pickup` | Resume work from a previous handoff session |

### tasks

| Command | Description |
|---------|-------------|
| `tasks:backlog` | Manage backlog items across files, GitHub Issues, Linear, or Beads |

### workflows

| Command | Description |
|---------|-------------|
| `workflows:build-task` | Autonomous task implementation from GitHub Issues - research, plan, build, review, fix, ship |
| `workflows:debug` | Debug errors, test failures, or unexpected behavior (auto-detects project type) |
| `workflows:guided-prd` | Discover and refine a product idea through guided questioning, then generate a PRD |
| `workflows:init-agents-md` | Initialize AGENTS.md with hierarchical structure and create CLAUDE.md symlink |
| `workflows:plan` | Transform feature descriptions into well-structured project plans |
| `workflows:prd` | Create a Product Requirements Document (PRD) for a new product or feature |
| `workflows:question` | Answer questions about project structure without coding |
| `workflows:ship-it` | Complete checkout workflow - runs linting, creates commit, and opens PR |

## Skills

Invoke with: `skill majestic-engineer:<name>`

| Skill | Description |
|-------|-------------|
| `ast-grep-searching` | Structural code search and AST-based pattern matching for safe refactoring |
| `backlog-manager` | Manage project backlogs and task prioritization |
| `check-ci` | Monitor PR CI checks by polling GitHub status |
| `create-adr` | Create Architecture Decision Records for significant technical decisions |
| `fix-reporter` | Capture solved problems as categorized documentation with YAML frontmatter |
| `frontend-design` | Create distinctive, production-grade frontend interfaces for Tailwind, React, Vue, and Rails/Hotwire |
| `git-worktree` | Manage git worktrees for parallel development |
| `hierarchical-agents` | Generate hierarchical AGENTS.md structure for codebases |
| `mermaid-builder` | Create syntactically correct Mermaid diagrams |
| `ripgrep-search` | Fast, intelligent code and text searching with ripgrep |
| `subagent-driven-development` | Execute plans with fresh subagent per task and code review between tasks |
| `tdd-workflow` | Test-driven development using red-green-refactor cycle |
| `web-browser` | Browser automation via Chrome DevTools Protocol |

## Configuration

### Task Management

The `backlog-manager` skill supports multiple backends:

| Backend | Choose When |
|---------|-------------|
| **Files** | Solo/small projects, want git-tracked todos, no external dependencies |
| **GitHub** | Already using GitHub Issues, team collaboration, want PR/issue linking |
| **Linear** | Already using Linear, sprint planning, need project management features |
| **Beads** | Dependency-aware workflows, AI agent coordination, need blocking/ready tracking |

Configure in your project's CLAUDE.md:

```markdown
## Task Management
backend: github  # Options: files, github, linear, beads
```

### External Dependencies

| Tool | Required For | Installation |
|------|--------------|--------------|
| [beads](https://github.com/steveyegge/beads) | `backlog-manager` beads backend | `curl -fsSL https://raw.githubusercontent.com/steveyegge/beads/main/install.sh \| bash` |

## Usage Examples

```bash
# Create a PRD for a new feature
/majestic-engineer:workflows:prd "Mobile app for tracking fitness goals"

# Design implementation based on PRD
agent majestic-engineer:plan:architect "Design user authentication system"

# Create commit and PR
/majestic-engineer:git:commit
/majestic-engineer:git:create-pr

# Monitor CI (using skill)
skill majestic-engineer:check-ci

# Use git-worktree skill for parallel development
skill majestic-engineer:git-worktree
```
