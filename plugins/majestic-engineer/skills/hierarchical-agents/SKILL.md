---
name: hierarchical-agents
description: Generate hierarchical AGENTS.md structure for codebases to optimize AI agent token usage. Use when creating AGENTS.md files, documenting codebase structure, setting up agent guidance, organizing project documentation for AI tools, implementing JIT indexing, or working with monorepos that need lightweight root guidance with detailed sub-folder documentation. Covers repository analysis, root AGENTS.md generation, sub-folder AGENTS.md creation, and token-efficient documentation patterns.
---

# Hierarchical Agents Documentation Generator

## Purpose

Create a **hierarchical AGENTS.md system** for codebases that enables AI coding agents to work efficiently with minimal token usage. This skill generates lightweight root documentation with detailed sub-folder guidance following the "nearest-wins" principle.

## When to Use This Skill

Use this skill when:
- Creating AGENTS.md documentation for a new project
- Setting up AI agent guidance for a monorepo
- Optimizing existing documentation for token efficiency
- Restructuring codebase documentation hierarchically
- Implementing JIT (Just-In-Time) indexing patterns
- Need to document complex multi-package repositories

## Core Principles

### 1. Root AGENTS.md is LIGHTWEIGHT
- Only universal guidance and links to sub-files
- ~100-200 lines maximum
- No detailed patterns or examples
- Acts as index and navigation hub

### 2. Nearest-Wins Hierarchy
- Agents read the closest AGENTS.md to the file being edited
- Sub-folder AGENTS.md files override root guidance
- Specific beats general

### 3. JIT (Just-In-Time) Indexing
- Provide paths, globs, and search commands
- NOT full file content
- Enable discovery, not copy-paste
- Commands that agents can execute

### 4. Token Efficiency
- Small, actionable guidance over encyclopedic docs
- Reference files by path, not content
- Examples point to actual files in codebase
- Single-line commands that can be executed

**Why this matters:** Claude Code's system prompt includes ~50 instructions, leaving ~100 usable slots from Claude's ~150 instruction capacity. The system also tells Claude that AGENTS.md context "may or may not be relevant" - so non-universal instructions get ignored uniformly. Manual crafting beats auto-generation for leverage.

### 5. Sub-Folder Detail
- Sub-folder AGENTS.md files have MORE detail
- Specific patterns with file examples
- Technology-specific conventions
- Package-specific commands and gotchas

## Process Overview

Follow these phases in order. See [GENERATION_PROCESS.md](GENERATION_PROCESS.md) for complete details.

### Phase 1: Repository Analysis

Analyze the codebase structure:

1. **Repository type**: Monorepo, multi-package, or simple?
2. **Technology stack**: Languages, frameworks, tools
3. **Major directories**: Apps, services, packages, workers
4. **Build system**: pnpm/npm/yarn workspaces? Turborepo?
5. **Testing setup**: Jest, Vitest, Playwright, pytest?
6. **Key patterns**: Organization, conventions, examples, anti-patterns

**Output**: Structured map of the repository before generating any files.

**Tools to Use**:
```bash
# Get directory structure
find . -type d -maxdepth 3 -not -path '*/node_modules/*' -not -path '*/.git/*'

# Find package.json files
find . -name "package.json" -not -path '*/node_modules/*'

# Identify technology
rg -l "react|vue|angular|svelte" --type ts --type tsx --type js
rg -l "prisma|drizzle|typeorm" --type ts
rg -l "jest|vitest|playwright" --type json
```

### Phase 2: Generate Root AGENTS.md

Create lightweight root file with these sections:

1. **Project Snapshot** (3-5 lines)
   - Repo type
   - Primary tech stack
   - Note about sub-package AGENTS.md files

2. **Root Setup Commands** (5-10 lines)
   - Install dependencies
   - Build all
   - Typecheck all
   - Test all

3. **Universal Conventions** (5-10 lines)
   - Code style (TypeScript strict? Prettier? ESLint?)
   - Commit format (Conventional Commits?)
   - Branch strategy
   - PR requirements

4. **Implementation Rules** (2-3 lines)
   - Version verification for external dependencies (see example below)
   - Never trust training data for version numbers

5. **Security & Secrets** (3-5 lines)
   - Never commit tokens
   - Where secrets go (.env patterns)
   - PII handling

6. **JIT Index - Directory Map** (10-20 lines)
   - Links to sub-AGENTS.md files
   - Quick find commands

7. **Acceptance Criteria** (3-5 lines)
   - Pre-PR checklist
   - What must pass

**Example JIT Index**:
```markdown
## JIT Index (what to open, not what to paste)

### Package Structure
- Web UI: `apps/web/` → [see apps/web/AGENTS.md](apps/web/AGENTS.md)
- API: `apps/api/` → [see apps/api/AGENTS.md](apps/api/AGENTS.md)
- Shared packages: `packages/**/` → [see packages/README.md]

### Quick Find Commands
- Search function: `rg -n "functionName" apps/** packages/**`
- Find component: `rg -n "export.*ComponentName" apps/web/src`
- Find API routes: `rg -n "export const (GET|POST)" apps/api`
```

**Example Implementation Rules**:
```markdown
## Implementation Rules

Before adding ANY external dependency (gems, npm packages, GitHub Actions, Docker images, APIs, CDN links):
- Use WebSearch to verify the latest stable version BEFORE implementation
- Never trust training data for version numbers
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

**Key**: Section 3 (Patterns & Conventions) must include:
- ✅ DO: Pattern with file example
- ❌ DON'T: Anti-pattern with legacy file example
- Real file paths from the codebase

### Phase 4: Special Considerations

Adapt templates for specific package types:
- Design System / UI Package
- Database / Data Layer
- API / Backend Service
- Testing Package

See [GENERATION_PROCESS.md](GENERATION_PROCESS.md) for specialized templates.

## Quality Checklist

Before finalizing, verify:

- [ ] Root AGENTS.md is under 200 lines
- [ ] Root links to all sub-AGENTS.md files
- [ ] Each sub-file has concrete examples (actual file paths)
- [ ] Commands are copy-paste ready
- [ ] No duplication between root and sub-files
- [ ] JIT hints use actual codebase patterns
- [ ] Every "✅ DO" has a real file example
- [ ] Every "❌ DON'T" references real anti-pattern
- [ ] Pre-PR checks are single copy-paste commands
- [ ] All paths are relative and correct
- [ ] Search commands tested and working

## Output Format

Present files in this order:

1. **Analysis Summary** (Phase 1 findings)
2. **Root AGENTS.md** (complete, ready to copy)
3. **Each Sub-Folder AGENTS.md** (one per package)

Format each file:
```
---
File: `AGENTS.md` (root)
---
[full content]

---
File: `apps/web/AGENTS.md`
---
[full content]
```

## Common Patterns

### Monorepo Structure
```
AGENTS.md                    # Root (lightweight)
apps/
  web/AGENTS.md             # Frontend details
  api/AGENTS.md             # Backend details
  mobile/AGENTS.md          # Mobile details
packages/
  ui/AGENTS.md              # Design system details
  shared/AGENTS.md          # Shared code details
services/
  auth/AGENTS.md            # Auth service details
```

### Simple Project Structure
```
AGENTS.md                    # Root (can be more detailed)
src/
  components/AGENTS.md      # Component patterns
  services/AGENTS.md        # Service patterns
  utils/AGENTS.md           # Utility patterns
```

## Anti-Patterns to Avoid

❌ **Don't**: Include full file content in AGENTS.md
✅ **Do**: Reference file paths and provide search commands

❌ **Don't**: Duplicate guidance in root and sub-files
✅ **Do**: Keep root minimal, detail in sub-files

❌ **Don't**: Write vague examples ("use best practices")
✅ **Do**: Point to specific files ("copy pattern from `src/components/Button.tsx`")

❌ **Don't**: Create AGENTS.md for every directory
✅ **Do**: Only create for major packages/domains

❌ **Don't**: Use placeholder paths
✅ **Do**: Verify all paths exist in codebase

## Example Workflow

```bash
# 1. Start analysis
rg -l "package.json" --max-depth 3

# 2. Identify structure
tree -L 2 -d

# 3. Check for existing patterns
rg -n "export.*Component" apps/web/src --max-count 5

# 4. Generate root AGENTS.md
# (Use Phase 2 template)

# 5. Generate sub-folder AGENTS.md
# (Use Phase 3 template for each major package)

# 6. Verify all paths
find . -name "AGENTS.md"
```

## Testing the Documentation

After generation, validate:

1. **Path accuracy**: All referenced files exist
   ```bash
   # Extract file paths from AGENTS.md and verify
   rg -o '\`[^`]+\.(ts|tsx|js|jsx|md)\`' AGENTS.md | while read path; do
     [[ -f $path ]] || echo "Missing: $path"
   done
   ```

2. **Command validity**: All search commands work
   ```bash
   # Test each rg/find command from AGENTS.md
   ```

3. **Link validity**: All AGENTS.md links resolve
   ```bash
   find . -name "AGENTS.md" -type f
   ```

## Integration with AI Agents

AI agents should:
1. Read AGENTS.md in current working directory first
2. Traverse up to find root AGENTS.md if not found
3. Follow JIT commands to discover files
4. Use referenced file paths as examples
5. Execute search commands when needed

## Maintenance

Update AGENTS.md when:
- Adding new packages or major directories
- Changing build/test commands
- Establishing new conventions
- Discovering new patterns or anti-patterns
- Refactoring project structure

Keep documentation synchronized with codebase evolution.

## Related Resources

- [generation-process.md](references/generation-process.md) - Complete step-by-step generation process with templates
- Anthropic's Claude Code documentation on project context
- Token optimization best practices

**Skill Status**: ACTIVE ✅
**Line Count**: < 500 (following 500-line rule) ✅
**Progressive Disclosure**: Reference file for detailed process ✅
