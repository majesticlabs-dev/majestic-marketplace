# Advanced Ripgrep Patterns and Techniques

## Table of Contents

- [Multiline Search](#multiline-search)
- [Security Auditing](#security-auditing)
- [Complex Pattern Matching](#complex-pattern-matching)
- [Integration with Other Tools](#integration-with-other-tools)
- [Configuration Files](#configuration-files)
- [PCRE2 Advanced Features](#pcre2-advanced-features)
- [Advanced Use Cases](#advanced-use-cases)


## Multiline Search

Enable with `-U` flag. Use `.*?` (non-greedy) for better performance.

```bash
# Find method definitions with bodies
rg -U "def \w+.*?end" -t ruby
rg -U "function \w+\(.*?\)\s*\{.*?\}" -t js

# Find try-catch blocks
rg -U "try\s*\{.*?\}\s*catch" -t js

# Find HTML tags with content
rg -U "<div[^>]*>.*?</div>" -t html

# Find comment blocks
rg -U "/\*.*?\*/" -t js
```

**Best Practices:**
- Be specific with patterns to avoid matching too much
- Test on small subsets first
- Use `--max-filesize` to avoid very large files


## Security Auditing

### Hardcoded Secrets

```bash
# Find passwords, API keys, secrets
rg "password\s*=\s*['\"][\w!@#$%^&*]+['\"]" -i
rg "api[_-]?key\s*=\s*['\"][\w-]+['\"]" -i
rg "secret\s*=\s*['\"][\w-]+['\"]" -i
rg "aws_access_key_id|aws_secret_access_key" -i
rg "BEGIN.*PRIVATE KEY" --hidden
```

### Injection Vulnerabilities

```bash
# SQL injection (string concatenation)
rg "execute.*\+|query.*\+" -t ruby
rg "execute.*#\{|query.*#\{" -t ruby

# Code injection
rg "\beval\(" -w
rg "innerHTML\s*=" -t js -t ts
rg "\b(eval|instance_eval|class_eval|send)\(" -t ruby

# Command injection
rg "system\(|exec\(|spawn\(|\`" -t ruby
rg "subprocess\.|os\.system|os\.popen" -t py

# Path traversal
rg "File\.open\(|FileUtils\.|Dir\[" -t ruby | rg "params|request"
```


## Complex Pattern Matching

### PCRE2 Lookahead/Lookbehind

```bash
# Find method names (lookbehind for 'def')
rg --pcre2 "(?<=def )\w+(?=\()" -t ruby

# Find variable assignments (exclude const)
rg --pcre2 "(?<!const )\w+\s*=" -t js

# Combined lookaround
rg --pcre2 "(?<!def )(?<=^)\w+(?=\()"
```

### Conditional Patterns

```bash
# Match either pattern A or B
rg "error|warning|critical"

# Match multiple patterns (all required)
rg -l "class User" | xargs rg -l "def initialize"

# Match pattern A but not B
rg "authenticate" | grep -v "test"
```

### Capturing Groups

```bash
# Preview replacements (doesn't modify files)
rg "old_method_name" -r "new_method_name"

# Replace with captured groups
rg "(\w+)_id" -r "id_for_$1" app/models/
rg "def (test_\w+)" -r "def $1_new" spec/
```


## Integration with Other Tools

### Piping and Aggregation

```bash
# Count total matches across all files
rg "pattern" -c | awk -F: '{sum += $2} END {print sum}'

# List files sorted by match count
rg "pattern" -c | sort -t: -k2 -n -r

# Count lines in matching files
rg "pattern" -l | xargs wc -l

# Get unique matched strings
rg "pattern" -o --no-filename | sort -u

# Extract URLs
rg "https?://[^\s]+" -o | sort -u

# Extract email addresses
rg "\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b" -o --no-filename | sort -u
```

### With find

```bash
# Find .log files and search them
find . -name "*.log" -exec rg "error" {} +

# Search recently modified files
find . -mtime -1 -type f -exec rg "pattern" {} +
```

### With jq/yq

```bash
# Find JSON files with specific structure
rg -l "\"version\":" -t json | xargs -I {} jq '.version' {}

# Search YAML files
rg "database:" -t yaml | awk -F: '{print $1}' | xargs -I {} yq '.database' {}
```


## Configuration Files

### Global Configuration (~/.ripgreprc)

```bash
# Always use smart case
--smart-case

# Show context by default
--context=2

# Limit column width
--max-columns=150
--max-columns-preview

# Search hidden files by default
--hidden

# Always ignore specific directories
--glob=!.git/*
--glob=!node_modules/*
--glob=!dist/*
--glob=!build/*

# Custom file types
--type-add=log:*.log
--type-add=config:*.{conf,config,ini}
```

Set environment variable:
```bash
export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"
```

### Project-Specific (.ripgreprc)

```bash
# Project-specific ignores
--glob=!vendor/*
--glob=!coverage/*
--glob=!tmp/*

# Project-specific types
--type-add=rails:*.{rb,rake,erb}
--type-add=web:*.{html,css,js,ts}
```

### Using in Scripts

```bash
# Use project config
RIPGREP_CONFIG_PATH="./.ripgreprc" rg "pattern"

# Temporarily disable config
RIPGREP_CONFIG_PATH="" rg "pattern"
```


## PCRE2 Advanced Features

### Named Capture Groups

```bash
# Extract structured data
rg --pcre2 "(?P<method>GET|POST) (?P<path>/\S+)" access.log

# Match email components
rg --pcre2 "(?P<user>\w+)@(?P<domain>\S+)" -o
```

### Recursive and Atomic Patterns

```bash
# Match nested structures
rg --pcre2 "\{(?:[^{}]|(?R))*\}" -U

# Match balanced parentheses
rg --pcre2 "\((?:[^()]|(?R))*\)"

# Atomic group (no backtracking)
rg --pcre2 "(?>pattern)"

# Possessive quantifier
rg --pcre2 "\w++\s+pattern"
```


## Advanced Use Cases

### Code Refactoring

```bash
# Find all usages of a function
rg "\busage_function\b" -w

# Find method definitions and calls
rg "def method_name|method_name\(" -t ruby

# Find class instantiations
rg "new ClassName|ClassName\.new" -t ruby
```

### Dependency Analysis

```bash
# Find all imports of a module
rg "^import.*module_name|from module_name" -t py

# Find all requires of a gem
rg "require ['\"]gem_name" -t ruby

# Find all package imports
rg "import.*from ['\"]package" -t js
```

### API Usage Patterns

```bash
# Find all HTTP endpoints
rg "^\s*(get|post|put|delete|patch)\s+['\"]" -t ruby

# Find all API calls
rg "fetch\(|axios\.|http\." -t js -t ts

# Find GraphQL queries
rg "query\s+\w+|mutation\s+\w+" -t js -t ts
```

### Log Analysis

```bash
# Find errors in logs
rg "ERROR|FATAL" --type-add 'log:*.log' -t log

# Find slow queries (> 500ms)
rg "duration: [5-9]\d\d\d|duration: \d{5,}" -t log

# Find specific time range
rg "2024-01-15.*ERROR" -t log
```


## Performance Optimization

### Speed

```bash
# Use file types to reduce scope
rg "pattern" -t ruby -t python  # Much faster

# Limit search depth
rg "pattern" --max-depth 3

# Skip large files
rg "pattern" --max-filesize 1M

# Limit columns (for files with long lines)
rg "pattern" --max-columns 150

# Adjust threads
rg "pattern" -j 8  # Use 8 threads
rg "pattern" -j 1  # Single threaded
```

### Memory

```bash
# Enable/disable memory mapping
rg "pattern" --mmap         # Default
rg "pattern" --no-mmap      # If issues
```

### Benchmarking

```bash
# Compare approaches
time rg "pattern" -t ruby
time rg "pattern" -g "*.rb"
```


## Tips and Tricks

### Exclude Tests

```bash
rg "pattern" -g "!*test*" -g "!*spec*"
rg "pattern" -g "!**/{test,spec}/**"
```

### Search Git

```bash
# Search in specific branch
git show branch-name:path/to/file | rg "pattern"

# Search git history
git log -p | rg "pattern"
```

### Case Control

```bash
rg "Pattern"        # Case sensitive (uppercase present)
rg -i "pattern"     # Case insensitive
rg -S "pattern"     # Smart case
```

### File Lists

```bash
# Create file list
rg "pattern" -l > files_to_process.txt

# Use file list
cat files_to_process.txt | xargs -I {} echo "Processing: {}"
```

### Common Combinations

```bash
# Find and replace (preview only)
rg "old" -r "new" --passthru

# Multiple patterns (OR)
rg -e "error" -e "warning" -e "critical"

# Multiple patterns (AND)
rg -l "pattern1" | xargs rg -l "pattern2"

# Search only git-tracked files
git ls-files | xargs rg "pattern"
```


## Shell Aliases

Add to `~/.bashrc` or `~/.zshrc`:

```bash
# Shortcuts
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

# Tasks
alias rgtodo='rg "TODO|FIXME|HACK|XXX" -i'
alias rgurl='rg "https?://[^\s]+" -o'
```


**Reference Status**: Complete - Advanced patterns and techniques ✅
**Use with**: Main SKILL.md for comprehensive ripgrep mastery
