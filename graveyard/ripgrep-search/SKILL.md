---
name: ripgrep-search
description: Use ripgrep (rg) for fast, intelligent code and text searching across projects. Triggers on search, ripgrep, rg, grep, find patterns, locate code, code search, find functions, find classes, search files, locate definitions, analyze codebase, investigate issues, find imports, search documentation, audit code, find configuration.
---

# Ripgrep Search Skill

## Purpose

Master efficient code search using ripgrep (`rg`), the fastest and smartest search tool available. Ripgrep respects `.gitignore` by default, intelligently filters files, and provides powerful regex matching.

## When to Use This Skill

Use ripgrep when you need to:
- Find function/class definitions
- Search for patterns across the codebase
- Locate configuration values
- Analyze code structure
- Debug by finding error messages or log patterns
- Audit code for security issues or deprecated APIs
- Understand how a library/module is used
- Find TODO/FIXME comments
- Search documentation or text files

## Core Principles

1. **Default to ripgrep** - It's faster and smarter than grep
2. **Let ripgrep filter** - Automatically ignores binary files, hidden files, and gitignored files
3. **Use file types** - Leverage built-in file types instead of writing globs
4. **Consider regex first** - Ripgrep's regex is powerful and well-optimized

## Table of Contents

- [Basic Usage](#basic-usage)
- [File Type Filtering](#file-type-filtering)
- [Pattern Matching](#pattern-matching)
- [Context and Output Control](#context-and-output-control)
- [Directory and Path Control](#directory-and-path-control)
- [Common Use Cases](#common-use-cases)
- [Best Practices](#best-practices)
- [Quick Reference](#quick-reference)
- [Reference Files](#reference-files)

## Basic Usage

### Simple Text Search

```bash
# Search for exact text
rg "function_name"

# Case-insensitive search
rg -i "error"

# Smart case (case-sensitive if uppercase present)
rg -S "DatabaseError"
```

### Most Common Flags

```bash
rg "pattern"              # Basic search
rg "pattern" -i           # Case insensitive
rg "pattern" -t py        # Only Python files
rg "pattern" -l           # List matching files
rg "pattern" -c           # Count matches
rg "pattern" -C 3         # Show 3 lines context
rg "pattern" -w           # Match whole words
rg "pattern" -F           # Literal search (no regex)
```

## File Type Filtering

### Using Built-in Types

```bash
# Search only Python files
rg "import requests" -t py

# Search only JavaScript/TypeScript
rg "async function" -t js -t ts

# Search Ruby files
rg "def initialize" -t ruby

# Exclude specific file types
rg "config" -T json -T yaml

# List all available types
rg --type-list
```

### Common File Types

| Language   | Flag       | Extensions                    |
|------------|------------|-------------------------------|
| Ruby       | `-t ruby`  | *.rb, *.rake, Gemfile         |
| Python     | `-t py`    | *.py, *.pyi, *.pyw            |
| JavaScript | `-t js`    | *.js, *.jsx, *.mjs            |
| TypeScript | `-t ts`    | *.ts, *.tsx                   |
| JSON       | `-t json`  | *.json                        |
| YAML       | `-t yaml`  | *.yaml, *.yml                 |
| Markdown   | `-t md`    | *.md, *.markdown              |
| HTML       | `-t html`  | *.html, *.htm                 |
| CSS        | `-t css`   | *.css                         |
| SQL        | `-t sql`   | *.sql                         |

## Pattern Matching

### Language-Specific Patterns

```bash
# Find function definitions
rg "^\s*def \w+"              # Ruby/Python functions
rg "^\s*function \w+"         # JavaScript functions
rg "^\s*const \w+ = "         # JS/TS arrow functions

# Find class definitions
rg "^class \w+"

# Find import/require statements
rg "^import|^require|^from .* import"

# Match word boundaries (exact word match)
rg -w "user"

# Literal string search (disable regex)
rg -F "function()"
```

### Advanced Pattern Examples

```bash
# Find URLs
rg "https?://\S+"

# Find email addresses
rg "\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b"

# Find hex colors
rg "#[0-9a-fA-F]{6}"

# Find function calls with arguments
rg "\w+\([^)]+\)"
```

## Context and Output Control

```bash
# Show 3 lines before and after match
rg "error" -C 3

# Show only 2 lines after
rg "TODO" -A 2

# Show only 2 lines before
rg "FIXME" -B 2

# Show only filenames with matches
rg "database" -l

# Count matches per file
rg "test" -c

# Show only the matched text
rg "https://\S+" -o

# Disable line numbers
rg "pattern" -N
```

## Directory and Path Control

```bash
# Search specific directory
rg "pattern" src/

# Search multiple directories
rg "pattern" src/ lib/ config/

# Use glob patterns
rg "pattern" -g "*.{rb,py,js}"

# Exclude paths
rg "pattern" -g "!test/*" -g "!spec/*"

# Search hidden files
rg "pattern" --hidden

# Search including ignored files
rg "pattern" --no-ignore
```

## Common Use Cases

### Finding Code Definitions

```bash
# Find all API endpoints (Rails example)
rg "^\s*(get|post|put|delete|patch)\s+" app/controllers/ -t ruby

# Find database queries
rg "SELECT.*FROM" -i -t sql -t ruby -t py

# Find all imports of a module
rg "from mymodule import|require.*mymodule"

# Find deprecated code patterns
rg "@deprecated|DEPRECATED" --ignore-case
```

### Configuration and Environment

```bash
# Find environment variable usage
rg "ENV\[|process\.env\.|os\.environ"

# Find configuration files
rg "database_url|api_endpoint" -t yaml -t json

# Search only in config directory
rg "redis" config/
```

### Documentation and Comments

```bash
# Find TODOs
rg "TODO|FIXME|HACK|XXX" --ignore-case -A 1

# Search markdown files
rg "getting started" -t md

# Search comments only (approximation)
rg "^\s*#.*pattern" -t py        # Python
rg "^\s*//.*pattern" -t js       # JavaScript
```

## Best Practices

### 1. Start Broad, Then Narrow

Begin with simple patterns, add filters as needed:

```bash
# Step 1: Find all matches
rg "authenticate"

# Step 2: Add file type filter
rg "authenticate" -t ruby

# Step 3: Add directory filter
rg "authenticate" -t ruby app/controllers/
```

### 2. Use File Types Over Globs

```bash
# ✅ Preferred - clear and fast
rg "pattern" -t ruby

# ❌ Avoid - verbose and error-prone
rg "pattern" -g "*.rb" -g "*.rake" -g "Gemfile*"
```

### 3. Check Files First with -l

When searching large codebases:

```bash
# List files first to see scope
rg "pattern" -l -t python

# Then examine matches
rg "pattern" -t python
```

### 4. Use Context Wisely

```bash
# ✅ Good - enough context to understand
rg "error" -C 2

# ❌ Too much - overwhelming
rg "error" -C 10
```

### 5. Leverage Smart Defaults

Ripgrep automatically:
- Respects `.gitignore` (usually what you want)
- Skips binary files (use `-a` to include)
- Skips hidden files (use `--hidden` to include)
- Uses regex by default (use `-F` for literal)

## Performance Optimization

### When Searching Large Codebases

```bash
# Limit search depth
rg "pattern" --max-depth 3

# Skip large files
rg "pattern" --max-filesize 1M

# Use file types to reduce scope
rg "pattern" -t ruby -t js

# Limit columns shown
rg "pattern" --max-columns 150

# Adjust threads
rg "pattern" -j 4  # Use 4 threads
```

### Debug Why Files Are Skipped

```bash
# Show debug information
rg "pattern" --debug

# Force search all files (override all filtering)
rg "pattern" -uuu
# -u: don't respect .gitignore
# -uu: also search hidden files
# -uuu: also search binary files
```

## Troubleshooting

### Pattern Not Found?

1. Check if files are being filtered: `rg pattern --debug`
2. Try with no filtering: `rg pattern -uuu`
3. Verify pattern syntax: use `-F` for literal search
4. Check case sensitivity: use `-i` for case-insensitive

### Too Many/Wrong Results?

1. Use file type filtering: `-t python`
2. Add more specific patterns: Use `\b` for word boundaries
3. Exclude directories: `-g '!test/*'`
4. Use context to verify matches: `-C 2`

### Slow Performance?

1. Use file type filters to reduce scope
2. Search specific directories instead of root
3. Use `--max-filesize` to skip large files
4. Consider using `--max-depth` to limit recursion

## Quick Reference

### Essential Commands

```bash
# Basic search
rg "pattern"

# Case insensitive
rg -i "pattern"

# Specific file type
rg "pattern" -t py

# List files only
rg "pattern" -l

# With context
rg "pattern" -C 3

# Word boundary
rg -w "word"

# Literal (no regex)
rg -F "literal.text"

# Count matches
rg "pattern" -c

# Search hidden files
rg "pattern" --hidden

# Include gitignored
rg "pattern" --no-ignore

# Multiline search
rg -U "pattern.*across.*lines"
```

### Combining Searches

```bash
# OR search
rg "error|warning|critical"
rg -e "pattern1" -e "pattern2"

# AND search (files matching both)
rg -l "pattern1" | xargs rg -l "pattern2"

# NOT search (exclude pattern)
rg "include" -g "!*test*"
```

## When NOT to Use Ripgrep

- **Structured data**: Use `jq` for JSON, `yq` for YAML
- **Syntax-aware refactoring**: Use `ast-grep` or language-specific tools
- **File name search**: Use `fd` or `find`
- **Large binary files**: Ripgrep skips them by default
- **Cross-file dependencies**: Use language servers or IDE features

## Integration with Tools

```bash
# Pipe to other commands
rg "error" -l | xargs wc -l

# Count total matches
rg "pattern" -c | awk -F: '{sum += $2} END {print sum}'

# Process each matching file
rg "pattern" -l | xargs -I {} echo "Processing: {}"
```

## Reference Files

For more detailed information, see:

### [advanced-patterns.md](references/advanced-patterns.md)
- Multiline search techniques
- Security auditing patterns
- Complex regex examples
- Integration with other tools
- Configuration file setup

### [quick-reference.md](references/quick-reference.md)
- Complete flag reference
- All file type mappings
- Common pattern library
- Troubleshooting checklist
- Performance tuning guide

## Key Reminders

✅ **Ripgrep respects `.gitignore` by default** - Usually what you want
✅ **Binary files are skipped** - Use `-a` to include
✅ **Hidden files are skipped** - Use `--hidden` to include
✅ **Regex is enabled by default** - Use `-F` for literal
✅ **Searches current directory recursively** - Specify path to limit scope
✅ **Results are colored** - For better readability in terminals

**Skill Status**: Complete - Following Anthropic best practices ✅
**Line Count**: < 500 lines (following 500-line rule) ✅
**Progressive Disclosure**: Reference files for advanced content ✅
