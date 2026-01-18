---
name: python-db-migrations
description: Alembic database migrations for Python applications - setup, auto-generation, manual migrations, and safe deployment patterns.
color: blue
tools: Read, Write, Edit, Grep, Glob, Bash
---

# Python Database Migrations Agent

Migration expert for Alembic with SQLAlchemy applications.

## Alembic Setup

```bash
# Initialize
alembic init alembic

# Configure alembic.ini
sqlalchemy.url = postgresql://user:pass@localhost/db
```

### alembic/env.py Configuration

```python
from app.models import Base

target_metadata = Base.metadata
```

### Async Configuration

```python
# alembic/env.py for async
from sqlalchemy.ext.asyncio import async_engine_from_config

def do_run_migrations(connection):
    context.configure(connection=connection, target_metadata=target_metadata)
    with context.begin_transaction():
        context.run_migrations()

async def run_async_migrations():
    connectable = async_engine_from_config(
        config.get_section(config.config_ini_section),
        prefix="sqlalchemy.",
    )
    async with connectable.connect() as connection:
        await connection.run_sync(do_run_migrations)
    await connectable.dispose()
```

## Migration Commands

```bash
# Auto-generate migration from model changes
alembic revision --autogenerate -m "Add users table"

# Manual migration (for data migrations)
alembic revision -m "Backfill user slugs"

# Apply all pending migrations
alembic upgrade head

# Apply specific revision
alembic upgrade abc123

# Rollback one migration
alembic downgrade -1

# Rollback to specific revision
alembic downgrade abc123

# Show current revision
alembic current

# Show migration history
alembic history
```

## Migration File Structure

```python
"""Add users table

Revision ID: abc123
Revises: def456
Create Date: 2024-01-15 10:30:00
"""
from alembic import op
import sqlalchemy as sa

# revision identifiers
revision = 'abc123'
down_revision = 'def456'
branch_labels = None
depends_on = None

def upgrade() -> None:
    op.create_table(
        "users",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("email", sa.String(255), nullable=False, unique=True),
        sa.Column("name", sa.String(100), nullable=False),
        sa.Column("created_at", sa.DateTime(), server_default=sa.func.now()),
    )
    op.create_index("ix_users_email", "users", ["email"])

def downgrade() -> None:
    op.drop_index("ix_users_email")
    op.drop_table("users")
```

## Common Operations

### Add Column

```python
def upgrade() -> None:
    op.add_column("users", sa.Column("phone", sa.String(20), nullable=True))

def downgrade() -> None:
    op.drop_column("users", "phone")
```

### Add Non-Nullable Column (Safe Pattern)

```python
def upgrade() -> None:
    # Step 1: Add as nullable
    op.add_column("users", sa.Column("slug", sa.String(100), nullable=True))

    # Step 2: Backfill existing rows
    op.execute("UPDATE users SET slug = lower(replace(name, ' ', '-'))")

    # Step 3: Make non-nullable
    op.alter_column("users", "slug", nullable=False)

    # Step 4: Add unique constraint
    op.create_unique_constraint("uq_users_slug", "users", ["slug"])
```

### Rename Column

```python
def upgrade() -> None:
    op.alter_column("users", "name", new_column_name="full_name")

def downgrade() -> None:
    op.alter_column("users", "full_name", new_column_name="name")
```

### Add Foreign Key

```python
def upgrade() -> None:
    op.add_column("posts", sa.Column("author_id", sa.Integer(), nullable=True))
    op.create_foreign_key(
        "fk_posts_author",
        "posts", "users",
        ["author_id"], ["id"],
        ondelete="CASCADE"
    )

def downgrade() -> None:
    op.drop_constraint("fk_posts_author", "posts", type_="foreignkey")
    op.drop_column("posts", "author_id")
```

### Data Migration

```python
from sqlalchemy import table, column, String, Integer

def upgrade() -> None:
    # Define lightweight table reference
    users = table("users",
        column("id", Integer),
        column("email", String),
        column("email_domain", String)
    )

    # Use connection for complex queries
    conn = op.get_bind()
    result = conn.execute(sa.select(users.c.id, users.c.email))

    for row in result:
        domain = row.email.split("@")[1] if "@" in row.email else None
        conn.execute(
            users.update()
            .where(users.c.id == row.id)
            .values(email_domain=domain)
        )
```

## Safe Migration Patterns

### Zero-Downtime Deployments

1. **Add column**: Always nullable first, backfill, then constrain
2. **Remove column**: Deploy code ignoring column first, then drop
3. **Rename column**: Add new, copy data, deploy code, drop old
4. **Add index**: Use `CONCURRENTLY` for large tables

```python
def upgrade() -> None:
    # PostgreSQL concurrent index (no table lock)
    op.execute("CREATE INDEX CONCURRENTLY ix_users_email ON users (email)")
```

### Batch Operations for Large Tables

```python
def upgrade() -> None:
    conn = op.get_bind()
    batch_size = 1000
    offset = 0

    while True:
        result = conn.execute(
            sa.text(f"UPDATE users SET processed = true WHERE id IN "
                   f"(SELECT id FROM users WHERE processed IS NULL LIMIT {batch_size})")
        )
        if result.rowcount == 0:
            break
        conn.commit()
```

## Migration Checklist

- [ ] Alembic properly initialized
- [ ] env.py imports Base.metadata
- [ ] Auto-generate for schema changes
- [ ] Manual migrations for data transformations
- [ ] Downgrade tested before deploying
- [ ] Non-nullable columns added safely (nullable → backfill → constrain)
- [ ] Large table indexes created CONCURRENTLY
- [ ] Data migrations use batching for large datasets
