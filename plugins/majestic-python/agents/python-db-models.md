---
name: python-db-models
description: SQLAlchemy 2.0 model definition, engine setup, async patterns, and relationship configuration for Python applications.
color: blue
tools: Read, Write, Edit, Grep, Glob, Bash
---

# Python Database Models Agent

Database model expert for SQLAlchemy 2.0 applications.

## SQLAlchemy 2.0 Engine Setup

### Sync Engine

```python
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, DeclarativeBase

engine = create_engine(
    "postgresql://user:pass@localhost/db",
    pool_size=5,
    max_overflow=10,
    pool_pre_ping=True,  # Verify connections before use
    echo=True,  # SQL logging (disable in production)
)

Session = sessionmaker(bind=engine)

class Base(DeclarativeBase):
    pass
```

### Async Engine (PostgreSQL + asyncpg)

```python
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, async_sessionmaker

async_engine = create_async_engine(
    "postgresql+asyncpg://user:pass@localhost/db",
    pool_size=5,
    max_overflow=10,
    echo=True,
)

AsyncSessionLocal = async_sessionmaker(
    async_engine,
    class_=AsyncSession,
    expire_on_commit=False,
)

async def get_db() -> AsyncGenerator[AsyncSession, None]:
    async with AsyncSessionLocal() as session:
        yield session
```

## Model Definition (2.0 Style)

```python
from datetime import datetime
from typing import Optional
from sqlalchemy import String, ForeignKey, func
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship

class Base(DeclarativeBase):
    pass

class User(Base):
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(primary_key=True)
    email: Mapped[str] = mapped_column(String(255), unique=True, index=True)
    name: Mapped[str] = mapped_column(String(100))
    is_active: Mapped[bool] = mapped_column(default=True)
    created_at: Mapped[datetime] = mapped_column(server_default=func.now())

    # Relationships
    posts: Mapped[list["Post"]] = relationship(back_populates="author", cascade="all, delete-orphan")

    def __repr__(self) -> str:
        return f"<User(id={self.id}, email={self.email})>"

class Post(Base):
    __tablename__ = "posts"

    id: Mapped[int] = mapped_column(primary_key=True)
    title: Mapped[str] = mapped_column(String(200))
    content: Mapped[str]
    author_id: Mapped[int] = mapped_column(ForeignKey("users.id"))
    views: Mapped[int] = mapped_column(default=0)
    published_at: Mapped[Optional[datetime]] = mapped_column(nullable=True)

    author: Mapped["User"] = relationship(back_populates="posts")
```

## Relationship Patterns

### One-to-Many

```python
class Author(Base):
    books: Mapped[list["Book"]] = relationship(back_populates="author", cascade="all, delete-orphan")

class Book(Base):
    author_id: Mapped[int] = mapped_column(ForeignKey("authors.id"))
    author: Mapped["Author"] = relationship(back_populates="books")
```

### Many-to-Many

```python
from sqlalchemy import Table, Column, ForeignKey

book_tags = Table(
    "book_tags",
    Base.metadata,
    Column("book_id", ForeignKey("books.id"), primary_key=True),
    Column("tag_id", ForeignKey("tags.id"), primary_key=True),
)

class Book(Base):
    tags: Mapped[list["Tag"]] = relationship(secondary=book_tags, back_populates="books")

class Tag(Base):
    books: Mapped[list["Book"]] = relationship(secondary=book_tags, back_populates="tags")
```

### Self-Referential

```python
class Category(Base):
    parent_id: Mapped[Optional[int]] = mapped_column(ForeignKey("categories.id"))
    children: Mapped[list["Category"]] = relationship(back_populates="parent")
    parent: Mapped[Optional["Category"]] = relationship(back_populates="children", remote_side="Category.id")
```

## Indexing Strategy

```python
from sqlalchemy import Index

class User(Base):
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(primary_key=True)
    email: Mapped[str] = mapped_column(String(255), index=True)  # Single column

    __table_args__ = (
        Index("ix_user_active_created", "is_active", "created_at"),  # Composite
    )
```

## Model Checklist

- [ ] Using SQLAlchemy 2.0 style (Mapped, mapped_column)
- [ ] Proper relationship definitions with back_populates
- [ ] Cascade rules defined for deletions
- [ ] Indexes on frequently queried columns
- [ ] Composite indexes for common query patterns
- [ ] Optional fields use `Mapped[Optional[T]]`
