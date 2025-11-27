# Majestic Engineer

Language-agnostic engineering workflows. Includes 13 specialized agents, 7 commands, and 12 skills.

## Installation

```bash
claude /plugin install majestic-engineer
```

## Agents

| Agent | Description |
|-------|-------------|
| `plan/architect` | Design non-trivial features, system architecture planning |
| `plan/plan-review` | Thorough review of development plans before implementation |
| `plan/refactor-plan` | Analyze code structure and create comprehensive refactoring plans |
| `plan/spec-reviewer` | Analyze specs and plans for user flows, gaps, and missing requirements |
| `qa/security-review` | OWASP Top 10 vulnerability scanning, secrets detection |
| `qa/test-create` | Automated test creation across frameworks (RSpec, Minitest, Jest) |
| `qa/test-reviewer` | Review test quality, coverage, edge cases, and assertion quality |
| `workflow/ship` | Complete shipping workflow: lint, commit, PR |
| `research/docs-researcher` | Fetch and summarize library documentation |
| `research/git-researcher` | Analyze git history, trace code evolution, and identify contributor expertise |
| `research/web-research` | Internet research for debugging, finding solutions, and technical problems |
| `research/best-practices-researcher` | Research external best practices and documentation with structured citations |
| `design/design-iterator` | Iterative UI/UX refinement through screenshots and progressive improvements |

## Commands

### git/
| Command | Description |
|---------|-------------|
| `/git/commit` | Create git commit with proper message formatting |
| `/git/create-pr` | Create a pull request for the current feature branch |
| `/git/pr-review` | Review and address Pull Request comments from GitHub |
| `/git/changelog` | Create engaging changelogs from recent merges |

### workflows/
| Command | Description |
|---------|-------------|
| `/workflows/question` | Answer questions about project structure without coding |

### session/
| Command | Description |
|---------|-------------|
| `/session/handoff` | Create a detailed handoff plan for continuing work |
| `/session/pickup` | Resume work from a previous handoff session |

## Skills

| Skill | Description |
|-------|-------------|
| `ast-grep-searching` | Structural code search and AST-based pattern matching for safe refactoring |
| `backlog-manager` | Manage project backlogs and task prioritization |
| `check-ci` | Monitor PR CI checks by polling GitHub status |
| `create-adr` | Create Architecture Decision Records for significant technical decisions |
| `fix-reporter` | Capture solved problems as categorized documentation with YAML frontmatter |
| `frontend-design` | Create distinctive, production-grade frontend interfaces for Tailwind, React, Vue, and Rails/Hotwire |
| `git-worktree` | Manage git worktrees for parallel development |
| `mermaid-builder` | Create syntactically correct Mermaid diagrams |
| `ripgrep-search` | Fast, intelligent code and text searching with ripgrep |
| `subagent-driven-development` | Execute plans with fresh subagent per task and code review between tasks |
| `tdd-workflow` | Test-driven development using red-green-refactor cycle |
| `web-browser` | Browser automation via Chrome DevTools Protocol |

## Usage Examples

```bash
# Design a new feature
claude agent plan/architect "Design user authentication system"

# Create commit and PR
claude /git/commit
claude /git/create-pr

# Monitor CI (using skill)
claude skill check-ci

# Use git-worktree skill for parallel development
claude skill git-worktree
```
