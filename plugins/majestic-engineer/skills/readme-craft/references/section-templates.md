# Extended Section Templates

Additional README section templates for specialized documentation needs.

## Performance Section

```markdown
## Performance

| Metric | [Tool] | Alternative |
|--------|--------|-------------|
| Startup | <50ms | ~200ms |
| Query (1K items) | 5ms | 25ms |
| Memory (idle) | 10MB | 50MB |
| Binary size | 2MB | 15MB |

**Benchmarks:** Run `mytool benchmark` to reproduce locally.

### Optimization Tips

- Use `--fast` flag for speed over accuracy
- Enable caching with `--cache`
- Batch operations when possible
```

## Security Section

```markdown
## Security

**Privacy Model:**
- All processing happens locally
- No data sent to external servers
- Credentials stored in system keychain

**Data Storage:**
```
~/.mytool/
├── config.yaml     # User configuration
├── cache/          # Temporary files (auto-cleaned)
└── logs/           # Debug logs (optional)
```

**Secure Deletion:**
```bash
mytool clean --all  # Remove all local data
```

**Reporting Issues:** security@example.com (PGP key available)
```

## Data Model Section

```markdown
## Data Model

### Schema

| Field | Type | Indexed | Description |
|-------|------|---------|-------------|
| `id` | UUID | Yes | Primary key |
| `name` | string | Yes | Display name |
| `data` | JSON | No | Arbitrary metadata |
| `created_at` | timestamp | Yes | Creation time |

### Storage

- SQLite by default (~/.mytool/data.db)
- PostgreSQL for multi-user setups
- 100K records: ~50MB storage

### Queries

```sql
-- Find by name
SELECT * FROM items WHERE name LIKE '%query%';

-- Recent items
SELECT * FROM items ORDER BY created_at DESC LIMIT 10;
```
```

## API Reference Section

```markdown
## API Reference

### Client Initialization

```rust
use mytool::Client;

let client = Client::builder()
    .api_key("your-key")
    .timeout(Duration::from_secs(30))
    .build()?;
```

### Core Methods

#### `client.process(input)`

Process input data and return results.

**Parameters:**
| Name | Type | Required | Description |
|------|------|----------|-------------|
| `input` | `&str` | Yes | Input data |
| `options` | `Options` | No | Processing options |

**Returns:** `Result<Output, Error>`

**Example:**
```rust
let result = client.process("input data")?;
println!("{:?}", result);
```

### Error Handling

```rust
match client.process(input) {
    Ok(result) => println!("Success: {:?}", result),
    Err(Error::Auth(e)) => eprintln!("Auth failed: {}", e),
    Err(Error::Network(e)) => eprintln!("Network error: {}", e),
    Err(e) => eprintln!("Unknown error: {}", e),
}
```
```

## Migration/Upgrade Section

```markdown
## Upgrading

### v1.x → v2.0 (Breaking Changes)

**What changed:**
- Config format: YAML → TOML
- CLI: `--output` renamed to `-o`
- API: `process()` now async

**Migration steps:**

1. Backup existing config
   ```bash
   cp ~/.mytool/config.yaml ~/.mytool/config.yaml.bak
   ```

2. Run migration tool
   ```bash
   mytool migrate --from v1
   ```

3. Verify configuration
   ```bash
   mytool config validate
   ```

4. Update scripts (if any)
   ```bash
   # Old
   mytool run --output result.json

   # New
   mytool run -o result.json
   ```

### v2.0 → v2.1 (Non-Breaking)

```bash
# Just upgrade, no migration needed
brew upgrade mytool
```
```

## Contributing Section

```markdown
## Contributing

### Development Setup

```bash
# Clone repository
git clone https://github.com/user/mytool
cd mytool

# Install dependencies
make deps

# Run tests
make test

# Build
make build
```

### Pull Request Process

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing`)
3. Make changes with tests
4. Run `make lint test`
5. Commit with conventional format
6. Open PR against `main`

### Code Style

| Rule | Enforcement |
|------|-------------|
| Formatting | `make fmt` (auto-fix) |
| Linting | `make lint` (CI required) |
| Tests | Coverage >80% |
| Docs | Public APIs documented |

### Commit Messages

```
type(scope): description

feat(parser): add JSON support
fix(cli): handle empty input
docs(readme): update examples
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`
```

## Environment Variables

```markdown
## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `MYTOOL_API_KEY` | (required) | API authentication |
| `MYTOOL_DEBUG` | `false` | Enable debug logging |
| `MYTOOL_TIMEOUT` | `30` | Request timeout (seconds) |
| `MYTOOL_CACHE_DIR` | `~/.cache/mytool` | Cache location |

### Example

```bash
export MYTOOL_API_KEY="your-key"
export MYTOOL_DEBUG=true
mytool run input.txt
```

### Config File

`~/.mytool/config.toml`:
```toml
api_key = "your-key"
debug = false
timeout = 30

[cache]
enabled = true
dir = "~/.cache/mytool"
```

**Precedence:** CLI flags > Environment > Config file > Defaults
```

## Shell Completions

```markdown
## Shell Completions

### Bash

```bash
mytool completions bash > /etc/bash_completion.d/mytool
source /etc/bash_completion.d/mytool
```

### Zsh

```bash
mytool completions zsh > ~/.zsh/completions/_mytool
# Add to .zshrc: fpath=(~/.zsh/completions $fpath)
```

### Fish

```bash
mytool completions fish > ~/.config/fish/completions/mytool.fish
```

### PowerShell

```powershell
mytool completions powershell >> $PROFILE
```
```

## Release Notes Pattern

```markdown
## Changelog

### [2.1.0] - 2025-01-15

#### Added
- JSON output format (`-o json`)
- Shell completions for Fish

#### Changed
- Improved error messages
- 2x faster parsing

#### Fixed
- Memory leak in long-running processes
- Crash on empty input files

### [2.0.0] - 2025-01-01

#### Breaking
- Config format changed from YAML to TOML
- Minimum supported version: Python 3.10

See [CHANGELOG.md](CHANGELOG.md) for full history.
```

## Acknowledgments Section

```markdown
## Acknowledgments

**Built with:**
- [library-a](link) - Core parsing
- [library-b](link) - CLI framework

**Inspired by:**
- [project-x](link) - Architecture patterns
- [project-y](link) - API design

**Contributors:**
Thanks to all [contributors](https://github.com/user/mytool/graphs/contributors)!
```
