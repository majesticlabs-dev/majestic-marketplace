---
name: skill-linter
description: Validate skills against agentskills.io specification. Use when adding new skills to the marketplace, reviewing skill PRs, checking skill compliance, or running quality gates on skills. Validates frontmatter fields (name, description, license, compatibility, metadata, allowed-tools), directory naming, line limits, and structure.
allowed-tools: Bash Read Glob Grep
---

# Skill Linter

## When to Use

- Adding new skills to the marketplace
- Reviewing skill PRs
- Running quality gates before merge
- Checking existing skills for compliance

## Validation Rules

### Required Frontmatter

| Field | Constraints |
|-------|-------------|
| `name` | 1-64 chars, lowercase alphanumeric + hyphens, no leading/trailing/consecutive hyphens, must match parent directory name |
| `description` | 1-1024 chars, non-empty, should include keywords for discoverability |

### Optional Frontmatter

| Field | Constraints |
|-------|-------------|
| `license` | Short license name or file reference |
| `compatibility` | 1-500 chars, environment requirements |
| `metadata` | Key-value pairs (string values only) |
| `allowed-tools` | Space-delimited tool list |

### Structure Requirements

| Rule | Requirement |
|------|-------------|
| Directory name | Must match `name` field exactly |
| SKILL.md | Required, must exist |
| Line limit | Max 500 lines in SKILL.md |
| Subdirectories | Only `scripts/`, `references/`, `assets/` allowed |

### Content Quality Rules

| Rule | Requirement |
|------|-------------|
| No ASCII art | Box-drawing characters (─│┌┐└┘├┤┬┴┼), arrows (↑↓←→↔), and decorative diagrams waste tokens. LLMs tokenize character-by-character, not visually. Use plain lists or tables instead. |
| No decorative quotes | Inspirational quotes or attributions ("As X said...") have no functional value for LLM execution. |
| Functional content only | Every line should improve LLM behavior. Ask: "Does this help Claude execute better?" |

**ASCII Art Detection Pattern:**
```regex
[─│┌┐└┘├┤┬┴┼╭╮╯╰═║╔╗╚╝╠╣╦╩╬↑↓←→↔⇒⇐⇔▲▼◄►]{3,}
```

Files matching this pattern should be flagged for review.

### Name Pattern

```regex
^[a-z][a-z0-9]*(-[a-z0-9]+)*$
```

**Valid:** `my-skill`, `skill1`, `api-v2-handler`
**Invalid:** `-skill`, `skill-`, `my--skill`, `MySkill`, `my_skill`

## Usage

### Validate Single Skill

```bash
./scripts/validate-skill.sh path/to/skill-name
```

### Validate All Marketplace Skills

```bash
for skill in plugins/*/skills/*/; do
  ./scripts/validate-skill.sh "$skill"
done
```

### CI Integration

Add to pre-commit hook or CI pipeline:

```yaml
- name: Lint Skills
  run: |
    for skill in plugins/*/skills/*/; do
      .claude/skills/skill-linter/scripts/validate-skill.sh "$skill" || exit 1
    done
```

## Validation Script

The linter script at `scripts/validate-skill.sh` performs these checks:

1. **Directory exists** with SKILL.md file
2. **Frontmatter present** with YAML delimiters
3. **Name field valid** - pattern, length, matches directory
4. **Description field valid** - present, length constraints
5. **Optional fields valid** - if present, match constraints
6. **Line count** - under 500 lines
7. **Subdirectory names** - only allowed directories
8. **No ASCII art** - detects box-drawing characters and decorative diagrams

## Error Codes

| Code | Meaning |
|------|---------|
| 0 | All validations passed |
| 1 | Missing SKILL.md |
| 2 | Invalid frontmatter |
| 3 | Name validation failed |
| 4 | Description validation failed |
| 5 | Optional field validation failed |
| 6 | Line limit exceeded |
| 7 | Invalid subdirectory |
| 8 | ASCII art detected (warning) |

## Example Output

```
Validating: plugins/majestic-tools/skills/brainstorming

[PASS] SKILL.md exists
[PASS] Frontmatter present
[PASS] Name 'brainstorming' valid (12 chars)
[PASS] Name matches directory
[PASS] Description valid (156 chars)
[PASS] Line count: 87/500
[PASS] Subdirectories valid

Result: ALL CHECKS PASSED
```

## Spec Reference

Based on [agentskills.io/specification](https://agentskills.io/specification):

- **Progressive disclosure** - Metadata ~100 tokens at startup, full content <5000 tokens when activated
- **Reference files** - Keep one level deep from SKILL.md
- **Token budget** - Main SKILL.md recommended under 500 lines
