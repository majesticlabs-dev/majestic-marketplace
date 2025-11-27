---
name: gem-builder
description: Comprehensive guide for building production-quality Ruby gems. Use when creating new gems, structuring gem architecture, implementing configuration patterns, setting up testing, or preparing for publishing. Covers all gem types - libraries, CLI tools, Rails engines, and API clients.
allowed-tools: Read, Write, Edit, MultiEdit, Grep, Glob, Bash, WebSearch
---

# Gem Builder

## Overview

This skill provides comprehensive guidance for building production-quality Ruby gems from concept to publishing. Apply these standards when creating new gems, structuring gem architecture, implementing configuration patterns, or preparing for RubyGems distribution.

## Core Philosophy

Prioritize:
- **Minimal dependencies**: Only add gems you truly need
- **Single responsibility**: Each class/module does one thing well
- **Semantic versioning**: Follow SemVer strictly (MAJOR.MINOR.PATCH)
- **Test coverage**: Every public method has tests
- **Documentation**: YARD docs, README, and CHANGELOG
- **Fail fast**: Validate inputs early, raise descriptive errors

## Gem Structure

### Standard Directory Layout

```
my_gem/
├── lib/
│   ├── my_gem.rb              # Main entry point
│   ├── my_gem/
│   │   ├── version.rb         # VERSION constant
│   │   ├── config.rb          # Configuration class
│   │   ├── errors.rb          # Error hierarchy
│   │   └── [feature].rb       # Feature modules
├── test/                      # Test suite
│   ├── test_helper.rb         # Test configuration
│   └── [feature]_test.rb      # Feature tests
├── my_gem.gemspec             # Gem specification
├── Gemfile                    # Development dependencies
├── Rakefile                   # Build tasks
├── README.md                  # User documentation
├── CHANGELOG.md               # Version history
├── LICENSE.txt                # License file
├── .rubocop.yml               # Code style rules
└── .yardopts                  # Documentation config
```

### Main Entry Point (`lib/my_gem.rb`)

```ruby
# frozen_string_literal: true

require_relative "my_gem/version"
require_relative "my_gem/config"
require_relative "my_gem/errors"

module MyGem
  class << self
    def config
      @config ||= Config.new
    end

    def configure
      yield(config)
    end

    # Test helper - reset between tests
    def reset_configuration!
      @config = nil
    end
  end
end
```

## Gemspec Best Practices

### Essential Metadata

```ruby
# my_gem.gemspec
require_relative "lib/my_gem/version"

Gem::Specification.new do |spec|
  spec.name          = "my_gem"
  spec.version       = MyGem::VERSION
  spec.authors       = ["Your Name"]
  spec.email         = ["you@example.com"]

  spec.summary       = "One-line description"
  spec.description   = "Longer description of what the gem does"
  spec.homepage      = "https://github.com/username/my_gem"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  # Discoverability metadata
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["documentation_uri"] = "https://rubydoc.info/gems/my_gem"
  spec.metadata["rubygems_mfa_required"] = "true"
end
```

### Clean File Inclusion

```ruby
# Exclude test files, CI config, development files
spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
  ls.readlines("\x0", chomp: true).reject do |f|
    f.start_with?(*%w[bin/ test/ spec/ .github/ .rubocop])
  end
end

spec.require_paths = ["lib"]
```

### Dependencies

```ruby
# Runtime dependencies - be conservative
spec.add_dependency "faraday", "~> 2.9"

# Development dependencies go in Gemfile, not gemspec
```

## Gem Types

### Library Gem (Utility/Helper)

Pure Ruby functionality, no external services:

```ruby
module StringUtils
  def self.titleize(str)
    str.split.map(&:capitalize).join(" ")
  end
end
```

### API Client Gem

Wrap external HTTP APIs with resource pattern:

```ruby
class Client
  def initialize(api_key: nil)
    @api_key = api_key || MyGem.config.api_key
    raise ArgumentError, "API key required" if @api_key.to_s.empty?
  end

  # Lazy resource initialization
  def users
    @users ||= Resources::Users.new(self)
  end

  def posts
    @posts ||= Resources::Posts.new(self)
  end

  def request(method, path, body: nil)
    # HTTP implementation
  end
end
```

### CLI Tool Gem

Command-line applications:

```ruby
# Add to gemspec
spec.executables = ["my_cli"]
spec.bindir = "exe"

# exe/my_cli
#!/usr/bin/env ruby
require "my_gem/cli"
MyCli::CLI.start(ARGV)
```

### Rails Integration Gem

**Never require Rails gems directly.** Use `ActiveSupport.on_load` for lazy loading:

```ruby
# lib/my_gem/railtie.rb
module MyGem
  class Railtie < Rails::Railtie
    initializer "my_gem.configure" do
      ActiveSupport.on_load(:active_record) do
        extend MyGem::Model  # Add class methods
      end
    end
  end
end

# lib/my_gem.rb (entry point)
require_relative "my_gem/railtie" if defined?(Rails)
```

For mountable web interfaces, use Engine with `isolate_namespace`.

## Class Macro DSL Pattern

The signature pattern for Rails gems (`searchkick`, `lockbox`, `has_encrypted`):

```ruby
# Usage in model
class Product < ApplicationRecord
  mygemname word_start: [:name]
end

# Implementation
module MyGem
  module Model
    def mygemname(**options)
      # Validate options
      unknown = options.keys - KNOWN_OPTIONS
      raise ArgumentError, "Unknown options: #{unknown.join(", ")}" if unknown.any?

      # Create module with instance methods
      mod = Module.new
      mod.module_eval do
        define_method(:some_method) { options[:key] }
      end
      include mod

      # Store options in class variable
      class_variable_set(:@@mygemname_options, options.dup)
    end
  end
end

# Rails integration
ActiveSupport.on_load(:active_record) do
  extend MyGem::Model
end
```

## Configuration Pattern

### Environment-First Configuration

```ruby
# lib/my_gem/config.rb
module MyGem
  class Config
    attr_accessor :api_key, :base_url, :timeout
    attr_writer :logger

    def initialize
      @api_key = ENV.fetch("MY_GEM_API_KEY", nil)
      @base_url = ENV.fetch("MY_GEM_BASE_URL", "https://api.example.com")
      @timeout = integer_or_default("MY_GEM_TIMEOUT", 30)
    end

    def logger
      @logger ||= default_logger
    end

    private

    def integer_or_default(key, default)
      Integer(ENV.fetch(key, default))
    rescue StandardError
      default
    end

    def default_logger
      if defined?(Rails) && Rails.respond_to?(:logger)
        Rails.logger
      else
        Logger.new($stderr)
      end
    end
  end
end
```

### Usage Pattern

```ruby
# Block-based configuration
MyGem.configure do |config|
  config.api_key = "secret"
  config.timeout = 60
end

# Or per-instance override
client = MyGem::Client.new(api_key: "different_key")
```

## Error Handling

### Custom Exception Hierarchy

```ruby
# lib/my_gem/errors.rb
module MyGem
  class Error < StandardError
    attr_reader :status, :body

    def initialize(message = nil, status: nil, body: nil)
      super(message)
      @status = status
      @body = body
    end
  end

  # Specific error types
  class ConfigurationError < Error; end
  class AuthenticationError < Error; end  # 401
  class ClientError < Error; end          # 4xx
  class ServerError < Error; end          # 5xx
  class NetworkError < Error; end         # Connection failures
end
```

### Error Handling in Client

```ruby
def handle_response(response)
  case response.status
  when 200..299
    JSON.parse(response.body)
  when 401
    raise AuthenticationError.new("Invalid API key", status: 401)
  when 400..499
    raise ClientError.new(response.body, status: response.status)
  when 500..599
    raise ServerError.new("Server error", status: response.status)
  end
rescue Faraday::TimeoutError => e
  raise NetworkError, "Request timed out: #{e.message}"
end
```

## Testing Setup

### Minitest Configuration

```ruby
# test/test_helper.rb
$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "my_gem"
require "minitest/autorun"
require "webmock/minitest"

module TestConfig
  def setup_config
    WebMock.reset!
    MyGem.reset_configuration!
    MyGem.configure do |config|
      config.api_key = "test-key"
      config.base_url = "https://api.example.com"
    end
  end

  def teardown_config
    WebMock.reset!
    MyGem.reset_configuration!
  end
end
```

### Test Example

```ruby
class ClientTest < Minitest::Test
  include TestConfig

  def setup = setup_config
  def teardown = teardown_config

  def test_requires_api_key
    MyGem.config.api_key = nil
    error = assert_raises(ArgumentError) { MyGem::Client.new }
    assert_equal "API key required", error.message
  end

  def test_fetches_users
    stub_request(:get, "https://api.example.com/users")
      .to_return(status: 200, body: '[{"id": 1}]')
    assert_equal 1, @client.users.list.first["id"]
  end
end
```

## Documentation

### YARD Setup (`.yardopts`)

```yaml
--markup markdown
--no-private
lib/**/*.rb
- README.md
- CHANGELOG.md
```

### YARD Markup Example

```ruby
# @param input [String, Hash] Document to parse
# @return [Hash] Parsed result
# @raise [ArgumentError] if input is nil
def parse(input:)
end
```

### README Sections

Essential sections: Installation, Quick Start, Configuration, Features, Development, License.

### CHANGELOG Format (Keep a Changelog)

```markdown
## [1.0.0] - 2025-01-15
### Added
- Initial release
### Fixed
- Bug fix description
```

## Build & Release

### Rakefile

```ruby
require "bundler/gem_tasks"
require "minitest/test_task"

Minitest::TestTask.create

require "rubocop/rake_task"
RuboCop::RakeTask.new

task default: %i[test rubocop]
```

### Version Management

```ruby
# lib/my_gem/version.rb
module MyGem
  VERSION = "1.0.0"
end
```

Single source of truth - gemspec reads from version.rb.

### Release Workflow

```bash
# 1. Update version in lib/my_gem/version.rb
# 2. Update CHANGELOG.md
# 3. Commit changes
git commit -am "Release v1.0.0"

# 4. Build and release
bundle exec rake release
# Creates git tag, builds gem, pushes to RubyGems
```

### GitHub Actions CI

```yaml
# .github/workflows/ci.yml
name: CI
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        ruby: ['3.2', '3.3']
    steps:
      - uses: actions/checkout@v4
      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: ${{ matrix.ruby }}
          bundler-cache: true
      - run: bundle exec rake
```

## Anti-Patterns

Avoid these common mistakes:

- **`method_missing`** - Use `define_method` instead for explicit behavior
- **Configuration objects** - Use `class << self` with `attr_accessor`
- **`@@class_variables`** - Use `class << self` with instance variables
- **Requiring Rails directly** - Use `ActiveSupport.on_load` hooks
- **Many runtime dependencies** - Prefer stdlib, minimize deps
- **Committing Gemfile.lock** - Only lock in apps, not gems
- **Heavy DSLs** - Prefer explicit Ruby over magic
- **Autoload** - Use explicit `require_relative`

## Best Practices Checklist

When building a gem, ensure:

**Structure:**
- [ ] Standard directory layout (lib/, test/, gemspec)
- [ ] Version in single location (`lib/my_gem/version.rb`)
- [ ] Main entry point requires all components
- [ ] Frozen string literals on all files

**Gemspec:**
- [ ] All metadata fields populated
- [ ] `rubygems_mfa_required` set to true
- [ ] Clean file inclusion (excludes test/CI files)
- [ ] Minimal runtime dependencies

**Configuration:**
- [ ] Environment variable fallbacks
- [ ] Block-based configuration DSL
- [ ] Test-friendly reset method
- [ ] Safe integer parsing for env vars

**Error Handling:**
- [ ] Custom error hierarchy
- [ ] Descriptive error messages
- [ ] Status and body preserved in errors

**Testing:**
- [ ] Test helper with isolation
- [ ] WebMock for HTTP stubbing
- [ ] Configuration reset between tests
- [ ] Both success and failure cases

**Documentation:**
- [ ] YARD comments on public methods
- [ ] README with quick start
- [ ] CHANGELOG following Keep a Changelog
- [ ] License file

**Build:**
- [ ] Rakefile with test + rubocop default
- [ ] CI workflow for multiple Ruby versions
- [ ] Semantic versioning

**Rails (if applicable):**
- [ ] Optional Engine with `if defined?(Rails)`
- [ ] Isolated namespace
- [ ] Initializer for setup

## References

**`references/templates.md`** - Copy-paste ready templates:
- GitHub Actions CI/CD workflows
- README.md, Gemspec, Gemfile, Rakefile
- RuboCop configuration, Test helpers

**`references/advanced-patterns.md`** - Battle-tested patterns:
- Module organization (simple vs complex layouts)
- Database adapter pattern for multi-DB support
- Multi-version testing with gemfiles
- Links to exemplary gems (Searchkick, PgHero, Lockbox)
