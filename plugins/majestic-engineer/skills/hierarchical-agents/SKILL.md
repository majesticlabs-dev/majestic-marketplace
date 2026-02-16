---
name: hierarchical-agents
description: Generate hierarchical AGENTS.md structure for codebases to optimize AI agent token usage. Use when creating AGENTS.md files, documenting codebase structure, setting up agent guidance, organizing project documentation for AI tools, implementing JIT indexing, or working with monorepos that need lightweight root guidance with detailed sub-folder documentation. Covers repository analysis, root AGENTS.md generation, sub-folder AGENTS.md creation, and token-efficient documentation patterns.
disable-model-invocation: true
---

# Hierarchical Agents Documentation Generator

## Purpose

Create a **hierarchical AGENTS.md system** for codebases that enables AI coding agents to work efficiently with minimal token usage. Generates lightweight root documentation with detailed sub-folder guidance following the "nearest-wins" principle.

## When to Use

- Creating AGENTS.md documentation for a new project
- Setting up AI agent guidance for a monorepo
- Optimizing existing documentation for token efficiency
- Implementing JIT (Just-In-Time) indexing patterns

## Core Principles

### 1. Root AGENTS.md is LIGHTWEIGHT
- Only universal guidance and links to sub-files
- ~100-200 lines maximum
- Acts as index and navigation hub

### 2. Nearest-Wins Hierarchy
- Agents read the closest AGENTS.md to the file being edited
- Sub-folder AGENTS.md files override root guidance

### 3. JIT (Just-In-Time) Indexing
- Provide paths, globs, and search commands — NOT full file content
- Enable discovery, not copy-paste

### 4. Token Efficiency
- Reference files by path, not content
- Examples point to actual files in codebase
- Single-line commands that can be executed

### 5. Sub-Folder Detail
- Sub-folder AGENTS.md files have MORE detail
- Specific patterns with file examples
- Technology-specific conventions

## Process Overview

Follow these phases in order. See [references/generation-process.md](references/generation-process.md) for complete details.

### Phase 1: Repository Analysis

Analyze the codebase:
1. Repository type (monorepo, multi-package, simple)
2. Technology stack (languages, frameworks, tools)
3. Major directories (apps, services, packages)
4. Build system and testing setup
5. Key patterns, conventions, anti-patterns

**Output**: Structured map of the repository before generating any files.

### Phase 2: Generate Root AGENTS.md

Create lightweight root file with these sections:

1. **Project Snapshot** (3-5 lines)
   - Repo type
   - Primary tech stack
   - Note about sub-package AGENTS.md files
2. **Root Setup Commands** (5-10 lines)
   - Install dependencies, build all, typecheck all, test all
3. **Universal Conventions** (5-10 lines)
   - Code style (TypeScript strict? Prettier? ESLint?)
   - Commit format (Conventional Commits?)
   - Branch strategy
   - PR requirements
4. **Implementation Rules** (2-3 lines)
   - Version verification for external dependencies
   - Never trust training data for version numbers
5. **Development Workflow** (5-7 lines)
   - Plan before code: describe approach, wait for approval
   - Ambiguous requirements? Ask before coding
   - >3 files affected? Decompose into smaller tasks
   - After coding: list breakage risks, suggest tests
   - Bug fix: write failing test first, fix until green
   - When corrected: add lesson to .agents/lessons/
6. **Security & Secrets** (3-5 lines)
   - Never commit tokens
   - Where secrets go (.env patterns)
   - PII handling
7. **JIT Index - Directory Map** (10-20 lines)
   - Links to sub-AGENTS.md files
   - Quick find commands
8. **Acceptance Criteria** (3-5 lines)
   - Pre-PR checklist
   - What must pass

**Example Implementation Rules**:
```markdown
## Implementation Rules

Before adding ANY external dependency (gems, npm packages, GitHub Actions, Docker images, APIs, CDN links):
- Use WebSearch to verify the latest stable version BEFORE implementation
- Never trust training data for version numbers
```

**Example JIT Index**:
```markdown
## JIT Index (what to open, not what to paste)

### Package Structure
- Web UI: `apps/web/` -> [see apps/web/AGENTS.md](apps/web/AGENTS.md)
- API: `apps/api/` -> [see apps/api/AGENTS.md](apps/api/AGENTS.md)
- Shared packages: `packages/**/` -> [see packages/README.md]

### Quick Find Commands
- Search function: `rg -n "functionName" apps/** packages/**`
- Find component: `rg -n "export.*ComponentName" apps/web/src`
- Find API routes: `rg -n "export const (GET|POST)" apps/api`
```

**Example Development Workflow**:
```markdown
## Development Workflow

- Before coding -> describe approach -> wait for approval
- Ambiguous requirements -> ask first
- If task touches >3 files -> decompose first
- After coding -> list breakage risks + suggest tests
- Bug fix -> write failing test -> fix until green
- When corrected -> add lesson to .agents/lessons/
```

### Phase 3: Generate Sub-Folder AGENTS.md Files

For EACH major package/directory, create detailed AGENTS.md:

1. **Package Identity** (2-3 lines)
2. **Setup & Run** (5-10 lines)
3. **Patterns & Conventions** (10-20 lines) - MOST IMPORTANT
4. **Touch Points / Key Files** (5-10 lines)
5. **JIT Index Hints** (5-10 lines)
6. **Common Gotchas** (3-5 lines)
7. **Pre-PR Checks** (2-3 lines)

**Key**: Patterns & Conventions must include real file paths with DO/DON'T examples.

### Phase 4: Special Considerations

Adapt templates for specific package types (Design System, Database, API, Testing).
See [references/generation-process.md](references/generation-process.md) for specialized templates.

## Quality Checklist

- [ ] Root AGENTS.md is under 200 lines
- [ ] Root links to all sub-AGENTS.md files
- [ ] Each sub-file has concrete examples (actual file paths)
- [ ] Commands are copy-paste ready
- [ ] No duplication between root and sub-files
- [ ] Every DO has a real file example
- [ ] Every DON'T references real anti-pattern
- [ ] All paths are relative and correct

## Common Patterns and Workflow

### Monorepo Structure
```
AGENTS.md                    # Root (lightweight)
apps/
  web/AGENTS.md             # Frontend details
  api/AGENTS.md             # Backend details
packages/
  ui/AGENTS.md              # Design system details
  shared/AGENTS.md          # Shared code details
```

### Simple Project Structure
```
AGENTS.md                    # Root (can be more detailed)
src/
  components/AGENTS.md      # Component patterns
  services/AGENTS.md        # Service patterns
```

## Anti-Patterns

- Don't include full file content in AGENTS.md -> Reference file paths and provide search commands
- Don't duplicate guidance in root and sub-files -> Keep root minimal, detail in sub-files
- Don't write vague examples ("use best practices") -> Point to specific files
- Don't create AGENTS.md for every directory -> Only for major packages/domains
- Don't use placeholder paths -> Verify all paths exist in codebase

## Maintenance

Update AGENTS.md when:
- Adding new packages or major directories
- Changing build/test commands
- Establishing new conventions
- Refactoring project structure

## Related Resources

- [references/generation-process.md](references/generation-process.md) - Complete step-by-step generation process with templates
