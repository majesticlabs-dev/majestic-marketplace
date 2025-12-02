# Caching Strategies

How 37signals approaches caching in Basecamp, HEY, and production Rails applications.

## Russian Doll Caching

Nest cached fragments to maximize cache reuse. When one item changes, only that fragment re-renders.

### Basic Pattern

```erb
<%# app/views/projects/show.html.erb %>
<% cache @project do %>
  <h1><%= @project.name %></h1>

  <% @project.todolists.each do |todolist| %>
    <% cache todolist do %>
      <h2><%= todolist.name %></h2>

      <% todolist.todos.each do |todo| %>
        <% cache todo do %>
          <%= render todo %>
        <% end %>
      <% end %>
    <% end %>
  <% end %>
<% end %>
```

### Touch for Cache Invalidation

```ruby
class Todo < ApplicationRecord
  belongs_to :todolist, touch: true
end

class Todolist < ApplicationRecord
  belongs_to :project, touch: true
  has_many :todos, dependent: :destroy
end

class Project < ApplicationRecord
  has_many :todolists, dependent: :destroy
end
```

When a todo updates:
1. Todo's cache key changes (its `updated_at` changed)
2. Todolist's `updated_at` is touched, invalidating its cache
3. Project's `updated_at` is touched, invalidating the outer cache
4. Only the changed todo's fragment re-renders from scratch

## Cache Performance Analysis

**Not all fragments benefit equally from caching.** 37signals uses this formula:

```
Weighted Benefit = Hit Rate × (Miss Render Time - Hit Render Time) - (1 - Hit Rate) × Cache Overhead
```

### Real Examples from Basecamp

| Fragment | Hit Rate | Benefit |
|----------|----------|---------|
| Project card faces | 98.5% | +87ms |
| Message thread | 94.2% | +45ms |
| Todo filters | 0.5% | -12ms |

**Key insight:** Fragments with low hit rates that render quickly may perform *worse* when cached due to cache lookup overhead.

### When to Cache

**Cache when:**
- Hit rate > 80%
- Render time is significant (> 10ms)
- Content changes infrequently relative to reads

**Skip caching when:**
- Content is highly personalized (low hit rate)
- Fragment renders quickly (< 5ms)
- Content changes frequently

## Solid Cache: Database-Backed Caching

37signals uses Solid Cache instead of Redis/Memcached for caching.

### Configuration

```ruby
# config/environments/production.rb
config.cache_store = :solid_cache_store

# config/cache.yml
production:
  database: cache
  max_age: <%= 60.days.to_i %>
  max_size: <%= 256.megabytes %>
```

### Why Database Over Redis?

| Aspect | Redis | Solid Cache |
|--------|-------|-------------|
| Read/write speed | 0.8ms | 1.2ms |
| Retention period | Hours (memory limited) | Months (disk is cheap) |
| Infrastructure | Additional service | Just PostgreSQL/SQLite |
| Debugging | Separate tooling | ActiveRecord, standard SQL |

**The 0.4ms difference is insignificant** relative to total request time. The benefit is massive cache retention - keeping keys for months enables much higher hit rates.

## Fragment Caching Best Practices

### Cache Key Design

```erb
<%# Include all dependencies in cache key %>
<% cache [current_user, @project, @project.updated_at] do %>
  <%= render @project %>
<% end %>

<%# Or use cache_key_with_version %>
<% cache @project do %>
  <%# Rails automatically uses project.cache_key_with_version %>
<% end %>
```

### Collection Caching

```erb
<%# Efficient collection caching %>
<%= render partial: "todos/todo", collection: @todos, cached: true %>

<%# This generates one multi-get instead of N cache lookups %>
```

### Conditional Caching

```ruby
# Skip caching for admins who see extra info
<% cache_if !current_user.admin?, @project do %>
  <%= render @project %>
<% end %>
```

## HTTP Caching

### Fresh When

```ruby
class ProjectsController < ApplicationController
  def show
    @project = Project.find(params[:id])
    fresh_when @project
  end

  def index
    @projects = current_account.projects.recent
    fresh_when @projects
  end
end
```

### Stale?

```ruby
def show
  @project = Project.find(params[:id])

  if stale?(@project)
    respond_to do |format|
      format.html
      format.json { render json: @project }
    end
  end
end
```

## Counter Caches

Avoid N+1 counts with counter caches:

```ruby
class Todo < ApplicationRecord
  belongs_to :todolist, counter_cache: true
end

class Todolist < ApplicationRecord
  # Has todos_count column updated automatically
end

# In views - no query needed
<%= todolist.todos_count %> todos
```

## Query Caching

Rails automatically caches identical queries within a request:

```ruby
# Only one query executed
user = User.find(1)
user = User.find(1)  # Cached
user = User.find(1)  # Cached
```

For cross-request caching, use low-level caching:

```ruby
class User < ApplicationRecord
  def expensive_calculation
    Rails.cache.fetch("user/#{id}/expensive", expires_in: 1.hour) do
      # Complex calculation
    end
  end
end
```

## Key Principles

1. **Russian Doll by default** - Nest caches, use `touch: true`
2. **Measure before caching** - Not everything benefits from caching
3. **Solid Cache for retention** - Months > hours for hit rates
4. **HTTP caching first** - `fresh_when` prevents rendering entirely
5. **Counter caches for counts** - Denormalize what you read frequently
