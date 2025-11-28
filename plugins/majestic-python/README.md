# Majestic Python

Python development tools. Includes 2 specialized agents.

## Installation

```bash
claude /plugin install majestic-python
```

## Agents

Invoke with: `agent majestic-python:<name>`

| Agent | Description |
|-------|-------------|
| `python-coder` | Modern Python 3.12+ development with uv, ruff, FastAPI, async patterns |
| `python-reviewer` | Code review with high quality bar for type hints, Pythonic patterns |

## Usage Examples

```bash
# Set up a modern Python project
agent majestic-python:python-coder "Set up a FastAPI project with uv, ruff, and pytest"

# Optimize async code
agent majestic-python:python-coder "Optimize this async code for better performance"

# Review Python code
agent majestic-python:python-reviewer "Review the changes in src/services/"

# Create a data pipeline
agent majestic-python:python-coder "Design a high-performance ETL pipeline with pandas"
```

## Python-Coder Capabilities

### Modern Tooling
- Package management with **uv** (fastest Python package manager)
- Code formatting/linting with **ruff** (replaces black, isort, flake8)
- Type checking with mypy and pyright
- Project configuration with pyproject.toml

### Web Development
- **FastAPI** for high-performance APIs
- **Django** for full-featured web applications
- **Flask** for lightweight services
- **Pydantic** for data validation

### Testing & Quality
- pytest with fixtures and mocks
- Property-based testing with Hypothesis
- Coverage analysis with pytest-cov
- CI/CD with GitHub Actions

### Performance
- Async programming with asyncio
- Profiling with cProfile, py-spy
- Memory optimization techniques
- Database optimization with SQLAlchemy 2.0+

## Python-Reviewer Focus Areas

### Code Quality Checks
- Type hints for all function parameters and return values
- Modern Python 3.10+ syntax (`list[str]` not `List[str]`)
- PEP 8 compliance and import organization
- Pythonic patterns (comprehensions, context managers)

### Review Philosophy
- **Strict on existing code** - Question added complexity
- **Pragmatic on new code** - If isolated and works, acceptable
- **Testability focus** - Hard to test = needs refactoring
- **5-second naming rule** - Names should be self-documenting

## Important Notes

- Targets **Python 3.12+** with latest ecosystem tools
- Emphasizes **production-ready** code with proper error handling
- Follows **PEP 8** and the Zen of Python
- Prefers **explicit over implicit**, readability over cleverness
