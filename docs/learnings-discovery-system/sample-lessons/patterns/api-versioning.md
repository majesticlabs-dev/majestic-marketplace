---
module: System
date: 2025-11-15
problem_type: best_practice
component: api
symptoms:
  - "Breaking API changes affecting mobile clients"
  - "No clear upgrade path for consumers"
root_cause: inadequate_documentation
resolution_type: documentation_update
severity: medium
tags: [api, versioning, rest, backwards-compatibility]

# Discovery fields
lesson_type: pattern
workflow_phase: [planning]
tech_stack: [generic]
impact: major_time_sink
keywords: [api, version, v1, v2, endpoint, breaking_change, deprecation, backwards]
---

# Pattern: API Versioning Strategy

## When to Apply

Use this pattern when:
- Designing new REST APIs
- Planning breaking changes to existing APIs
- Building APIs consumed by mobile apps or third parties

## Pattern Overview

Use URL-based versioning with explicit deprecation periods:

```
/api/v1/users     # Original version
/api/v2/users     # New version with breaking changes
```

## Implementation

### Rails

```ruby
# config/routes.rb
Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :users
    end
    namespace :v2 do
      resources :users
    end
  end
end

# app/controllers/api/v1/users_controller.rb
module Api::V1
  class UsersController < ApplicationController
    def index
      @users = User.all
      render json: UserSerializerV1.new(@users)
    end
  end
end
```

### Node.js (Express)

```javascript
const v1Router = require('./routes/v1');
const v2Router = require('./routes/v2');

app.use('/api/v1', v1Router);
app.use('/api/v2', v2Router);

// Add deprecation header for v1
app.use('/api/v1', (req, res, next) => {
  res.setHeader('Deprecation', 'true');
  res.setHeader('Sunset', '2026-06-01');
  next();
});
```

### Python (FastAPI)

```python
from fastapi import APIRouter

v1_router = APIRouter(prefix="/api/v1")
v2_router = APIRouter(prefix="/api/v2")

app.include_router(v1_router)
app.include_router(v2_router)
```

## Versioning Guidelines

### What Requires a New Version

- Removing fields from responses
- Changing field types (string to integer)
- Changing authentication mechanisms
- Removing endpoints
- Changing required parameters

### What Does NOT Require a New Version

- Adding new optional fields
- Adding new endpoints
- Adding new optional query parameters
- Performance improvements
- Bug fixes

## Deprecation Timeline

1. **Announce deprecation** - Add headers, update docs
2. **Monitor usage** - Track v1 vs v2 adoption
3. **Sunset warning** - 6 months before removal
4. **Remove** - After sunset date passes

## Response Headers

```
Deprecation: true
Sunset: Sat, 01 Jun 2026 00:00:00 GMT
Link: </api/v2/users>; rel="successor-version"
```

## Why This Matters

- Mobile apps can't force users to update
- Third-party integrations need upgrade time
- Breaking changes without versioning cause production incidents
- Clear deprecation periods build trust with API consumers

## Anti-Patterns to Avoid

- **Header-based versioning** (`Accept: application/vnd.api.v2+json`)
  - Hard to test in browser
  - Easy to forget in client code

- **Query param versioning** (`/api/users?version=2`)
  - Leaks into caching layers
  - Not idempotent for same URL

- **No versioning at all**
  - Impossible to make breaking changes safely

## Related Issues

No related issues documented yet.
