# Advanced Gem Patterns

Battle-tested patterns from Andrew Kane's 100+ gems with 374M+ downloads.

## Module Organization

### Simple Gem Layout

```
lib/
├── gemname.rb          # Entry point, config, errors
└── gemname/
    ├── model.rb        # Core functionality
    ├── railtie.rb      # Rails integration
    └── version.rb      # VERSION constant only
```

### Complex Gem Layout (PgHero pattern)

For large gems, decompose by feature:

```
lib/
├── gemname.rb
└── gemname/
    ├── database.rb     # Main class
    ├── engine.rb       # Rails engine
    └── methods/        # Functional decomposition
        ├── basic.rb
        ├── connections.rb
        ├── indexes.rb
        └── queries.rb
```

### Method Decomposition Pattern

Break large classes into includable modules:

```ruby
# lib/gemname/database.rb
module GemName
  class Database
    include Methods::Basic
    include Methods::Connections
    include Methods::Indexes
  end
end

# lib/gemname/methods/indexes.rb
module GemName
  module Methods
    module Indexes
      def index_hit_rate
        # implementation
      end
    end
  end
end
```

### Require Order in Entry Point

```ruby
# lib/gemname.rb

# 1. Standard library
require "forwardable"
require "json"

# 2. External dependencies (minimal)
require "active_support"

# 3. Internal files via require_relative
require_relative "gemname/model"
require_relative "gemname/version"

# 4. Conditional Rails loading (LAST)
require_relative "gemname/railtie" if defined?(Rails)
```

**Always use `require_relative`, not autoload.**

## ActiveSupport.on_load Hooks

**The Golden Rule:** Never require Rails gems directly.

```ruby
# WRONG - causes premature loading
require "active_record"
ActiveRecord::Base.include(MyGem::Model)

# CORRECT - lazy loading
ActiveSupport.on_load(:active_record) do
  extend MyGem::Model
end
```

### Common Hooks

```ruby
# Models - add class methods (searchkick, lockbox)
ActiveSupport.on_load(:active_record) do
  extend GemName::Model
end

# Controllers
ActiveSupport.on_load(:action_controller) do
  include GemName::Controller
end

# Jobs
ActiveSupport.on_load(:active_job) do
  include GemName::JobExtensions
end

# Mailers
ActiveSupport.on_load(:action_mailer) do
  include GemName::MailerExtensions
end
```

### Prepend for Behavior Modification

When overriding existing Rails methods:

```ruby
ActiveSupport.on_load(:active_record) do
  ActiveRecord::Migration.prepend(GemName::Migration)
end
```

### Minimal Railtie

```ruby
# lib/gemname/railtie.rb
module GemName
  class Railtie < Rails::Railtie
    initializer "gemname.configure" do
      ActiveSupport.on_load(:active_record) do
        extend GemName::Model
      end
    end

    rake_tasks do
      load "tasks/gemname.rake"
    end
  end
end
```

## Database Adapter Pattern

For gems supporting multiple databases:

```ruby
# lib/gemname/adapters/abstract_adapter.rb
module GemName
  module Adapters
    class AbstractAdapter
      def initialize(checker)
        @checker = checker
      end

      def min_version
        nil
      end

      def set_timeout(timeout)
        # no-op by default
      end

      private

      def connection
        @checker.send(:connection)
      end
    end
  end
end

# lib/gemname/adapters/postgresql_adapter.rb
module GemName
  module Adapters
    class PostgreSQLAdapter < AbstractAdapter
      def min_version
        "12"
      end

      def set_timeout(timeout)
        connection.execute("SET statement_timeout = #{timeout.to_i * 1000}")
      end
    end
  end
end
```

### Adapter Detection

```ruby
def adapter
  @adapter ||= case connection.adapter_name
  when /postg/i
    Adapters::PostgreSQLAdapter.new(self)
  when /mysql|trilogy/i
    connection.try(:mariadb?) ? Adapters::MariaDBAdapter.new(self) : Adapters::MySQLAdapter.new(self)
  else
    Adapters::AbstractAdapter.new(self)
  end
end
```

## Multi-Version Testing

### Directory Structure

```
test/
├── test_helper.rb
├── gemfiles/
│   ├── activerecord70.gemfile
│   ├── activerecord71.gemfile
│   └── activerecord72.gemfile
└── model_test.rb
```

### Gemfile Template

```ruby
# test/gemfiles/activerecord71.gemfile
source "https://rubygems.org"

gemspec path: "../.."

gem "activerecord", "~> 7.1.0"
gem "sqlite3"
```

### Running Tests

```bash
BUNDLE_GEMFILE=test/gemfiles/activerecord71.gemfile bundle install
BUNDLE_GEMFILE=test/gemfiles/activerecord71.gemfile bundle exec rake test
```

### GitHub Actions Matrix

```yaml
jobs:
  test:
    strategy:
      fail-fast: false
      matrix:
        ruby: ['3.2', '3.3']
        gemfile:
          - activerecord70
          - activerecord71
          - activerecord72
    env:
      BUNDLE_GEMFILE: test/gemfiles/${{ matrix.gemfile }}.gemfile
    steps:
      - uses: actions/checkout@v4
      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: ${{ matrix.ruby }}
          bundler-cache: true
      - run: bundle exec rake test
```

## Exemplary Gems to Study

### Entry Points
- [searchkick/lib/searchkick.rb](https://github.com/ankane/searchkick/blob/master/lib/searchkick.rb)
- [lockbox/lib/lockbox.rb](https://github.com/ankane/lockbox/blob/master/lib/lockbox.rb)
- [strong_migrations/lib/strong_migrations.rb](https://github.com/ankane/strong_migrations/blob/master/lib/strong_migrations.rb)

### Class Macro DSL
- [searchkick/lib/searchkick/model.rb](https://github.com/ankane/searchkick/blob/master/lib/searchkick/model.rb)
- [lockbox/lib/lockbox/model.rb](https://github.com/ankane/lockbox/blob/master/lib/lockbox/model.rb)

### Rails Integration
- [pghero/lib/pghero/engine.rb](https://github.com/ankane/pghero/blob/master/lib/pghero/engine.rb)
- [ahoy/lib/ahoy/engine.rb](https://github.com/ankane/ahoy/blob/master/lib/ahoy/engine.rb)

### Database Adapters
- [strong_migrations/lib/strong_migrations/adapters](https://github.com/ankane/strong_migrations/tree/master/lib/strong_migrations/adapters)

### Key Articles
- [Gem Patterns](https://ankane.org/gem-patterns) - Kane's own documentation
- [GitHub Profile](https://github.com/ankane) - 100+ gems to explore
