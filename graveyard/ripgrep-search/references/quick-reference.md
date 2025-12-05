# Ripgrep Quick Reference

Complete command-line reference for ripgrep (`rg`).

## Table of Contents

- [Essential Flags](#essential-flags)
- [Search Options](#search-options)
- [File Filtering](#file-filtering)
- [Output Control](#output-control)
- [Common Patterns Library](#common-patterns-library)
- [File Type Reference](#file-type-reference)
- [Exit Codes](#exit-codes)
- [Troubleshooting Checklist](#troubleshooting-checklist)


## Essential Flags

### Most Common Commands

```bash
rg "pattern"              # Basic search
rg -i "pattern"           # Case insensitive
rg -w "word"              # Match whole word
rg -F "literal"           # Literal string (no regex)
rg -v "pattern"           # Invert match (show non-matching lines)
rg -l "pattern"           # List files with matches
rg -c "pattern"           # Count matches per file
rg -C 3 "pattern"         # Show 3 lines of context
rg -A 2 "pattern"         # Show 2 lines after match
rg -B 2 "pattern"         # Show 2 lines before match
```

### Case Sensitivity

```bash
-i, --ignore-case         # Case insensitive search
-s, --case-sensitive      # Case sensitive search
-S, --smart-case          # Smart case (insensitive unless uppercase in pattern)
```

### Pattern Matching

```bash
-e "pattern"              # Specify pattern (can use multiple times)
-F, --fixed-strings       # Treat pattern as literal string
-w, --word-regexp         # Match whole words only
-x, --line-regexp         # Match whole lines only
-U, --multiline           # Enable multiline mode
--pcre2                   # Use PCRE2 regex engine
```


## Search Options

### Context Control

```bash
-A NUM, --after-context NUM       # Show NUM lines after match
-B NUM, --before-context NUM      # Show NUM lines before match
-C NUM, --context NUM             # Show NUM lines before and after match
-m NUM, --max-count NUM           # Stop after NUM matches per file
--max-columns NUM                 # Show at most NUM columns
--max-columns-preview             # Show preview when line exceeds max-columns
```

### Match Output

```bash
-o, --only-matching       # Show only matched part of line
-r, --replace TEXT        # Replace matches with TEXT (display only)
-N, --no-line-number      # Don't show line numbers
-n, --line-number         # Show line numbers (default)
-H, --with-filename       # Show filename (default when multiple files)
-I, --no-filename         # Don't show filename
--trim                    # Trim leading whitespace
```

### Search Behavior

```bash
-v, --invert-match        # Show lines that don't match
--count-matches           # Show count of individual matches, not lines
-q, --quiet               # Don't output matches, just exit status
--max-depth NUM           # Limit depth of directory recursion
-f FILE, --file FILE      # Read patterns from FILE
-L, --follow              # Follow symbolic links
```


## File Filtering

### File Type Selection

```bash
-t TYPE, --type TYPE      # Search only TYPE files
-T TYPE, --type-not TYPE  # Don't search TYPE files
--type-list               # List all available file types
--type-add SPEC           # Add custom file type (e.g., 'web:*.{html,css,js}')
--type-clear TYPE         # Clear file type definition
```

### Path Filtering

```bash
-g GLOB, --glob GLOB      # Include/exclude files matching GLOB
                          # Use ! to exclude: -g '!*.min.js'
-g !GLOB                  # Exclude files matching GLOB
--iglob GLOB              # Case insensitive glob
--hidden                  # Search hidden files and directories
-L, --follow              # Follow symbolic links
-M, --max-filesize SIZE   # Ignore files larger than SIZE
```

### Ignore Files

```bash
--no-ignore               # Don't respect ignore files (.gitignore, etc.)
--no-ignore-dot           # Don't respect .ignore, .rgignore
--no-ignore-global        # Don't respect global ignore files
--no-ignore-parent        # Don't respect ignore files in parent directories
--no-ignore-vcs           # Don't respect VCS ignore files (.gitignore)
-u                        # Reduce filtering (same as --no-ignore)
-uu                       # -u + search hidden files
-uuu                      # -u + -uu + search binary files
```


## Output Control

### Display Format

```bash
--color WHEN              # When to use colors (never, auto, always)
--colors SPEC             # Configure color settings
-p, --pretty              # Alias for --color always --heading -n
-H, --with-filename       # Print filename with matches
--heading                 # Print filename above matches
--no-heading              # Don't group matches by file
--vimgrep                 # Format for Vim's quickfix
--json                    # Output results as JSON
--stats                   # Show statistics at end
```

### Progress and Debugging

```bash
--debug                   # Show debug information
--trace                   # Show trace information
--stats                   # Print statistics about search
--files                   # Show files that would be searched
--type-list               # Show all available file types
```


## Common Patterns Library

### Finding Code Elements

```bash
# Function definitions
rg "^\s*def \w+"                    # Ruby/Python
rg "^\s*function \w+"               # JavaScript
rg "^\s*const \w+ = \("             # JavaScript arrow functions
rg "^\s*public \w+ \w+\("           # Java methods

# Class definitions
rg "^class \w+"                     # Most languages
rg "^interface \w+"                 # TypeScript/Java

# Imports
rg "^import|^require|^from .* import"

# Variable assignments
rg "^\s*(const|let|var) \w+ ="      # JavaScript
rg "^\s*\w+ = "                     # Python
```

### Finding Patterns

```bash
# URLs
rg "https?://[^\s]+"

# Email addresses
rg "\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b"

# IP addresses
rg "\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b"

# Hex colors
rg "#[0-9a-fA-F]{6}"

# UUIDs
rg "[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"

# File paths
rg "/[a-zA-Z0-9/_.-]+"

# Semantic versions
rg "\d+\.\d+\.\d+"
```

### Finding Comments and Documentation

```bash
# TODOs
rg "TODO|FIXME|HACK|XXX" -i

# Single-line comments
rg "^\s*#" -t py                    # Python
rg "^\s*//" -t js                   # JavaScript
rg "^\s*//" -t cpp                  # C++

# Multi-line comments
rg -U "/\*.*?\*/" -t js             # JavaScript
rg -U "=begin.*?=end" -t ruby       # Ruby
```


## File Type Reference

### Complete List

```bash
# Show all available types
rg --type-list
```

### Most Common Types

| Type       | Extensions                                  |
|------------|---------------------------------------------|
| `ruby`     | `*.rb`, `*.rake`, `Gemfile`, `Rakefile`     |
| `python`   | `*.py`, `*.pyi`, `*.pyw`                    |
| `js`       | `*.js`, `*.jsx`, `*.mjs`, `*.cjs`           |
| `ts`       | `*.ts`, `*.tsx`                             |
| `go`       | `*.go`                                      |
| `rust`     | `*.rs`                                      |
| `c`        | `*.c`, `*.h`                                |
| `cpp`      | `*.cpp`, `*.cc`, `*.cxx`, `*.hpp`           |
| `java`     | `*.java`, `*.jsp`                           |
| `php`      | `*.php`, `*.php3`, `*.php4`, `*.php5`       |
| `html`     | `*.html`, `*.htm`                           |
| `css`      | `*.css`, `*.scss`, `*.sass`                 |
| `json`     | `*.json`                                    |
| `yaml`     | `*.yaml`, `*.yml`                           |
| `xml`      | `*.xml`                                     |
| `sql`      | `*.sql`                                     |
| `sh`       | `*.sh`, `*.bash`                            |
| `md`       | `*.md`, `*.markdown`                        |
| `make`     | `Makefile`, `*.mk`                          |
| `docker`   | `Dockerfile`, `*.dockerfile`                |

### Custom File Types

```bash
# Add temporary custom type
rg "pattern" --type-add 'web:*.{html,css,js}'

# Add to config file (~/.ripgreprc)
--type-add=log:*.log
--type-add=config:*.{conf,config,ini}
```


## Exit Codes

```
0   - Match found
1   - No matches found
2   - Error occurred
```

### Using Exit Codes

```bash
# Check if pattern exists
if rg -q "pattern"; then
    echo "Found!"
fi

# Exit on first match
rg "pattern" -q && echo "Pattern exists"
```


## Troubleshooting Checklist

### Pattern Not Found

- [ ] Files being filtered? Try `rg pattern --debug`
- [ ] Check with no filtering: `rg pattern -uuu`
- [ ] Verify pattern syntax: `rg -F "literal string"`
- [ ] Check case sensitivity: `rg -i pattern`
- [ ] Search hidden files: `rg pattern --hidden`
- [ ] Include gitignored: `rg pattern --no-ignore`

### Too Many Results

- [ ] Use file type filter: `rg pattern -t python`
- [ ] Add word boundaries: `rg -w word`
- [ ] Exclude directories: `rg pattern -g '!test/*'`
- [ ] Narrow directory: `rg pattern src/`
- [ ] Use more specific pattern: Add context to regex

### Wrong Results

- [ ] Check if regex is matching more than intended
- [ ] Use word boundaries: `rg -w exact_word`
- [ ] Use literal search: `rg -F "literal.string"`
- [ ] Add context to verify: `rg pattern -C 2`
- [ ] Test pattern in isolation first

### Performance Issues

- [ ] Use file type filters: `rg pattern -t ruby -t python`
- [ ] Search specific directory: `rg pattern src/`
- [ ] Limit depth: `rg pattern --max-depth 3`
- [ ] Skip large files: `rg pattern --max-filesize 1M`
- [ ] Reduce threads if memory-constrained: `rg pattern -j 2`

### Files Being Skipped

- [ ] Check if in `.gitignore`: `rg pattern --no-ignore`
- [ ] Check if hidden: `rg pattern --hidden`
- [ ] Check if binary: `rg pattern -uuu`
- [ ] Use debug mode: `rg pattern --debug`
- [ ] List files that would be searched: `rg --files`


## Performance Tips

### Speed Optimization

```bash
# Fast: Use file types
rg "pattern" -t ruby -t python

# Faster: Search specific directory
rg "pattern" src/

# Fastest: Combine both
rg "pattern" -t ruby src/controllers/

# Skip large files
rg "pattern" --max-filesize 1M

# Limit search depth
rg "pattern" --max-depth 2
```

### Memory Optimization

```bash
# Reduce thread count
rg "pattern" -j 2

# Limit column display
rg "pattern" --max-columns 150

# Disable memory mapping if issues
rg "pattern" --no-mmap
```


## Common Command Combinations

```bash
# Find and count total occurrences
rg "pattern" -c | awk -F: '{sum += $2} END {print sum}'

# Find files and process them
rg "pattern" -l | xargs command

# Find with context and page through results
rg "pattern" -C 3 | less

# Search only in git-tracked files
git ls-files | xargs rg "pattern"

# Find and replace (preview)
rg "old" -r "new" --passthru

# Multiple patterns (OR)
rg -e "error" -e "warning" -e "critical"

# Multiple patterns (AND) - files matching both
rg -l "pattern1" | xargs rg -l "pattern2"
```


## Aliases and Shortcuts

Add to your shell config (`~/.bashrc`, `~/.zshrc`):

```bash
# Common shortcuts
alias rgi='rg -i'                    # Case insensitive
alias rgl='rg -l'                    # List files
alias rgc='rg -C 3'                  # With context
alias rgf='rg -F'                    # Literal search
alias rgw='rg -w'                    # Word match
alias rgh='rg --hidden'              # Include hidden
alias rgall='rg -uuu'                # Search everything

# Language-specific
alias rgpy='rg -t py'
alias rgrb='rg -t ruby'
alias rgjs='rg -t js -t ts'
alias rggo='rg -t go'
alias rgrs='rg -t rust'

# Common tasks
alias rgtodo='rg "TODO|FIXME|HACK|XXX" -i'
alias rgurl='rg "https?://[^\s]+" -o'
alias rgemail='rg "\b[A-Za-z0-9._%+-]+@" -o'
```


**Reference Status**: Complete - Comprehensive quick reference ✅
**Use with**: Main SKILL.md for complete ripgrep documentation
