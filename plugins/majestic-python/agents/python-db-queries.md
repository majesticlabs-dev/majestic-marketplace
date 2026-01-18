---
name: python-db-queries
description: SQLAlchemy query patterns, CRUD operations, repository pattern, query optimization, connection pooling, and transactions for Python applications.
color: blue
tools: Read, Write, Edit, Grep, Glob, Bash
---

# Python Database Queries Agent

Query expert for SQLAlchemy 2.0 applications.

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

## Query Checklist

- [ ] Async for I/O bound applications
- [ ] Eager loading to prevent N+1
- [ ] Proper connection pooling configured
- [ ] Repository pattern for data access
- [ ] Transactions for multi-step operations
- [ ] Connection health checks (pool_pre_ping)
- [ ] Bulk operations for batch writes
