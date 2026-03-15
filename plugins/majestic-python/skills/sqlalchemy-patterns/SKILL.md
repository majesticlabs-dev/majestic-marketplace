---
name: sqlalchemy-patterns
description: SQLAlchemy 2.0 patterns - model definition, engine setup, async patterns, relationships, query optimization, repository pattern, and transactions.
allowed-tools: Read Write Edit Grep Glob Bash
---

# SQLAlchemy 2.0 Patterns

**Audience:** Python developers building database-backed applications
**Goal:** Comprehensive SQLAlchemy 2.0 reference for models, queries, and data access

## Engine Setup

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

## Query Patterns

### Select Queries

```python
from sqlalchemy import select

# Simple select
stmt = select(User).where(User.email == "test@example.com")
result = session.execute(stmt)
user = result.scalar_one_or_none()

# Multiple results
stmt = select(User).where(User.is_active == True).order_by(User.created_at.desc())
result = session.execute(stmt)
users = result.scalars().all()

# Select specific columns
stmt = select(User.id, User.email).where(User.is_active == True)
result = session.execute(stmt)
rows = result.all()  # List of tuples
```

### Async Queries

```python
async def get_user_by_email(db: AsyncSession, email: str) -> User | None:
    stmt = select(User).where(User.email == email)
    result = await db.execute(stmt)
    return result.scalar_one_or_none()

async def get_active_users(db: AsyncSession) -> list[User]:
    stmt = select(User).where(User.is_active == True)
    result = await db.execute(stmt)
    return list(result.scalars().all())
```

### Joins and Eager Loading

```python
from sqlalchemy.orm import selectinload, joinedload

# Eager load relationships (N+1 prevention)
stmt = (
    select(User)
    .options(selectinload(User.posts))
    .where(User.is_active == True)
)

# Join
stmt = (
    select(User, Post)
    .join(Post, User.id == Post.author_id)
    .where(Post.published_at.isnot(None))
)

# Outer join
stmt = (
    select(User)
    .outerjoin(Post)
    .where(User.is_active == True)
)
```

### Aggregations

```python
from sqlalchemy import func

# Count
stmt = select(func.count(User.id)).where(User.is_active == True)
count = session.execute(stmt).scalar()

# Group by
stmt = (
    select(User.id, func.count(Post.id).label("post_count"))
    .outerjoin(Post)
    .group_by(User.id)
    .having(func.count(Post.id) > 5)
)
```

## Repository Pattern

```python
from typing import TypeVar, Generic
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

T = TypeVar("T", bound=Base)

class BaseRepository(Generic[T]):
    def __init__(self, db: AsyncSession, model: type[T]):
        self.db = db
        self.model = model

    async def get_by_id(self, id: int) -> T | None:
        return await self.db.get(self.model, id)

    async def get_all(self, skip: int = 0, limit: int = 100) -> list[T]:
        stmt = select(self.model).offset(skip).limit(limit)
        result = await self.db.execute(stmt)
        return list(result.scalars().all())

    async def create(self, **kwargs) -> T:
        obj = self.model(**kwargs)
        self.db.add(obj)
        await self.db.commit()
        await self.db.refresh(obj)
        return obj

    async def update(self, obj: T, **kwargs) -> T:
        for key, value in kwargs.items():
            setattr(obj, key, value)
        await self.db.commit()
        await self.db.refresh(obj)
        return obj

    async def delete(self, obj: T) -> None:
        await self.db.delete(obj)
        await self.db.commit()

class UserRepository(BaseRepository[User]):
    def __init__(self, db: AsyncSession):
        super().__init__(db, User)

    async def get_by_email(self, email: str) -> User | None:
        stmt = select(User).where(User.email == email)
        result = await self.db.execute(stmt)
        return result.scalar_one_or_none()
```

## Query Optimization

### N+1 Problem

```python
# BAD: N+1 queries
users = session.execute(select(User)).scalars().all()
for user in users:
    print(user.posts)  # Each access triggers a query!

# GOOD: Eager loading
stmt = select(User).options(selectinload(User.posts))
users = session.execute(stmt).scalars().all()
for user in users:
    print(user.posts)  # No additional queries
```

### Bulk Operations

```python
from sqlalchemy import insert, update

# Bulk insert
stmt = insert(User).values([
    {"email": "user1@example.com", "name": "User 1"},
    {"email": "user2@example.com", "name": "User 2"},
])
await db.execute(stmt)

# Bulk update
stmt = (
    update(User)
    .where(User.is_active == False)
    .values(is_active=True)
)
await db.execute(stmt)
await db.commit()
```

## Connection Pooling

```python
engine = create_engine(
    DATABASE_URL,
    pool_size=5,           # Maintained connections
    max_overflow=10,       # Extra connections when needed
    pool_timeout=30,       # Seconds to wait for connection
    pool_recycle=1800,     # Recycle connections after 30 min
    pool_pre_ping=True,    # Test connections before use
)
```

### FastAPI Integration

```python
from fastapi import Depends
from sqlalchemy.ext.asyncio import AsyncSession

async def get_db() -> AsyncGenerator[AsyncSession, None]:
    async with AsyncSessionLocal() as session:
        try:
            yield session
        finally:
            await session.close()

@app.get("/users/{user_id}")
async def get_user(user_id: int, db: AsyncSession = Depends(get_db)):
    user = await db.get(User, user_id)
    if not user:
        raise HTTPException(status_code=404)
    return user
```

## Transactions

```python
from sqlalchemy import exc

async def transfer_funds(db: AsyncSession, from_id: int, to_id: int, amount: float):
    async with db.begin():  # Transaction context
        from_account = await db.get(Account, from_id, with_for_update=True)
        to_account = await db.get(Account, to_id, with_for_update=True)

        if from_account.balance < amount:
            raise ValueError("Insufficient funds")

        from_account.balance -= amount
        to_account.balance += amount
        # Commits automatically on exit, rollback on exception
```

## Checklist

- [ ] Using SQLAlchemy 2.0 style (Mapped, mapped_column)
- [ ] Proper relationship definitions with back_populates
- [ ] Cascade rules defined for deletions
- [ ] Indexes on frequently queried columns
- [ ] Async for I/O bound applications
- [ ] Eager loading to prevent N+1
- [ ] Proper connection pooling configured
- [ ] Repository pattern for data access
- [ ] Transactions for multi-step operations
- [ ] Bulk operations for batch writes
