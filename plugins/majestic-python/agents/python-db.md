---
name: python-db
description: Database orchestrator for Python applications. Routes to specialized skills for models, queries, or migrations.
color: blue
tools: Read, Write, Edit, Grep, Glob, Bash, Skill
---

# Python Database Orchestrator

Routes database tasks to specialized skills.

## Routing

| Task Type | Delegate To | Triggers |
|-----------|-------------|----------|
| Models & Queries | `sqlalchemy-patterns` | "model", "relationship", "engine setup", "query", "select", "join", "CRUD", "repository", "N+1", "pooling", "transaction" |
| Migrations | `alembic-patterns` | "migration", "alembic", "upgrade", "downgrade", "schema change" |

## Workflow

```
INPUT = user request

If INPUT mentions models/relationships/engine/queries/CRUD/optimization:
  Apply `sqlalchemy-patterns` skill
Elif INPUT mentions migrations/alembic:
  Apply `alembic-patterns` skill
Else:
  # Analyze codebase to determine need
  If project lacks models: Apply `sqlalchemy-patterns` skill
  If schema changes needed: Apply `alembic-patterns` skill
```

## Combined Tasks

For full database setup:

```
1. Apply `sqlalchemy-patterns` skill → Define Base, engine, models, repository layer
2. Apply `alembic-patterns` skill → Create initial migration
```

## Quality Checklist

- [ ] SQLAlchemy 2.0 style throughout
- [ ] Async for I/O bound applications
- [ ] Proper connection pooling
- [ ] Eager loading to prevent N+1
- [ ] Indexes on queried columns
- [ ] Alembic for all schema changes
- [ ] Repository pattern for data access
- [ ] Transactions for multi-step operations
