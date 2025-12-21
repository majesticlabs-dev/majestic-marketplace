# Advanced Rails Testing Patterns

Production-tested patterns from 37signals' Fizzy test suite for building maintainable, efficient Rails tests.

## Multi-Tenancy Testing

Handle URL-based tenant isolation elegantly with `Current.account` fixtures:

```ruby
# test/test_helper.rb
class ActiveSupport::TestCase
  setup do
    Current.account = accounts(:default)
  end
end

# Set script_name for proper tenant URL generation
class ActionDispatch::IntegrationTest
  def default_url_options
    { script_name: "/#{Current.account.subdomain}" }
  end
end
```

```ruby
# test/integration/dashboard_test.rb
class DashboardTest < ActionDispatch::IntegrationTest
  test "shows account-specific dashboard" do
    Current.account = accounts(:acme)
    get dashboard_path
    assert_response :success
    assert_select "h1", "Acme Dashboard"
  end
end
```

---

## Authentication Helper with Assertions

Build `sign_in_as` helper that validates assertions within the helper to fail early:

```ruby
# test/test_helper.rb
class ActionDispatch::IntegrationTest
  def sign_in_as(user)
    post magic_link_path, params: { email: user.email }
    assert_response :redirect, "Magic link request failed"

    token = user.reload.magic_link_token
    assert token.present?, "Magic link token not generated"

    get magic_link_verify_path(token:)
    assert_response :redirect, "Magic link verification failed"

    follow_redirect!
    assert_response :success, "Post-login redirect failed"
  end
end
```

**Why assertions inside helpers?**
- Fails fast with clear error message
- Doesn't mask issues downstream
- Each step verified before proceeding

---

## Deterministic UUID Fixtures

Generate UUIDv7 that sorts by fixture ID for predictable `.first`/`.last`:

```ruby
# test/test_helper.rb
module FixtureHelpers
  def deterministic_uuid(fixture_name)
    # UUIDv7 timestamp prefix + fixture-based suffix
    timestamp = Time.current.to_i
    fixture_hash = Digest::MD5.hexdigest(fixture_name.to_s)[0..11]

    format(
      "%08x-%04x-7%03x-%04x-%012s",
      timestamp,
      rand(0xffff),
      rand(0x0fff),
      rand(0x3fff) | 0x8000,
      fixture_hash
    )
  end
end
```

```yaml
# test/fixtures/users.yml
alice:
  id: <%= deterministic_uuid(:alice) %>
  name: Alice
  created_at: <%= 2.days.ago %>

bob:
  id: <%= deterministic_uuid(:bob) %>
  name: Bob
  created_at: <%= 1.day.ago %>
```

**Benefits:**
- `User.first` and `User.last` work predictably
- Consistent ordering across SQLite and MySQL
- Fixtures can reference each other reliably

---

## VCR Cassette Management

Filter timestamps so cassettes remain reusable across test runs:

```ruby
# test/support/vcr_setup.rb
VCR.configure do |config|
  config.cassette_library_dir = "test/cassettes"
  config.hook_into :webmock

  # Filter dynamic timestamps
  config.filter_sensitive_data("<TIMESTAMP>") do |interaction|
    if interaction.request.body
      JSON.parse(interaction.request.body)["timestamp"] rescue nil
    end
  end

  # Custom matcher ignoring timing variations
  config.register_request_matcher :body_without_timestamp do |r1, r2|
    normalize_body(r1.body) == normalize_body(r2.body)
  end

  def normalize_body(body)
    return body unless body
    parsed = JSON.parse(body) rescue body
    parsed.except("timestamp", "nonce", "request_id").to_json
  end
end
```

```ruby
# Usage in tests
test "syncs with external API" do
  VCR.use_cassette("external_api_sync", match_requests_on: [:method, :uri, :body_without_timestamp]) do
    result = ExternalSync.new.perform
    assert result.success?
  end
end
```

---

## Concurrency Testing

Detect race conditions with thread-based testing and dedicated connection pooling:

```ruby
# test/support/concurrency_helpers.rb
module ConcurrencyHelpers
  def with_concurrent_threads(count: 2, &block)
    threads = count.times.map do
      Thread.new do
        ActiveRecord::Base.connection_pool.with_connection do
          yield
        end
      end
    end

    threads.each(&:join)
  end
end

class ActiveSupport::TestCase
  include ConcurrencyHelpers
end
```

```ruby
# test/models/activity_tracker_test.rb
class ActivityTrackerTest < ActiveSupport::TestCase
  test "handles concurrent activity spikes without duplicates" do
    user = users(:alice)
    initial_count = user.activities.count

    with_concurrent_threads(count: 5) do
      ActivityTracker.record(user:, action: "page_view")
    end

    # Should handle race condition gracefully
    assert_equal initial_count + 5, user.activities.count
  end
end
```

---

## Database-Agnostic Helpers

Create adapter-aware utilities for SQLite/MySQL compatibility:

```ruby
# test/support/database_helpers.rb
module DatabaseHelpers
  def clear_search_index(model_class)
    case ActiveRecord::Base.connection.adapter_name
    when "SQLite"
      # SQLite FTS cleanup
      model_class.connection.execute("DELETE FROM #{model_class.table_name}_fts")
    when "Mysql2"
      # MySQL fulltext index rebuild
      model_class.connection.execute("OPTIMIZE TABLE #{model_class.table_name}")
    end
  end

  def with_advisory_lock(name, &block)
    case ActiveRecord::Base.connection.adapter_name
    when "SQLite"
      # SQLite doesn't support advisory locks - use file lock
      File.open("/tmp/#{name}.lock", File::RDWR | File::CREAT) do |f|
        f.flock(File::LOCK_EX)
        yield
      end
    when "Mysql2"
      ActiveRecord::Base.connection.execute("SELECT GET_LOCK('#{name}', 10)")
      yield
    ensure
      ActiveRecord::Base.connection.execute("SELECT RELEASE_LOCK('#{name}')") if ActiveRecord::Base.connection.adapter_name == "Mysql2"
    end
  end
end

class ActiveSupport::TestCase
  include DatabaseHelpers
end
```

---

## Key Takeaways

| Pattern | Problem Solved |
|---------|----------------|
| Current.account fixtures | Multi-tenant URL isolation in tests |
| Assertion-validating helpers | Early failure with clear messages |
| Deterministic UUIDs | Predictable fixture ordering |
| VCR timestamp filtering | Reusable API cassettes |
| Thread-based concurrency | Race condition detection |
| Adapter-aware helpers | SQLite/MySQL compatibility |

**Philosophy:** Stay with Rails conventions—minitest, fixtures, standard patterns—to produce elegant, maintainable tests without exotic frameworks.
