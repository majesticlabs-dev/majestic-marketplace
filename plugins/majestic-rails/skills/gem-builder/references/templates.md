# Gem Builder Templates

Copy-paste ready templates for common gem files.

## GitHub Actions CI

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [main, master]
  pull_request:
    branches: [main, master]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        ruby: ['3.2', '3.3', '3.4']

    steps:
      - uses: actions/checkout@v4

      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: ${{ matrix.ruby }}
          bundler-cache: true

      - name: Run tests
        run: bundle exec rake

      - name: Run linter
        run: bundle exec rubocop
```

## GitHub Actions CI (Multi-Version)

For gems supporting multiple Rails/ActiveRecord versions:

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [main, master]
  pull_request:
    branches: [main, master]

jobs:
  test:
    runs-on: ubuntu-latest
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

      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: ${{ matrix.ruby }}
          bundler-cache: true

      - name: Run tests
        run: bundle exec rake test
```

### Test Gemfile Structure

```
test/gemfiles/
├── activerecord70.gemfile
├── activerecord71.gemfile
└── activerecord72.gemfile
```

```ruby
# test/gemfiles/activerecord71.gemfile
source "https://rubygems.org"

gemspec path: "../.."

gem "activerecord", "~> 7.1.0"
gem "sqlite3"
```

## GitHub Actions Release

```yaml
# .github/workflows/release.yml
name: Release

on:
  push:
    tags:
      - 'v*'

jobs:
  release:
    runs-on: ubuntu-latest
    permissions:
      contents: write
      id-token: write

    steps:
      - uses: actions/checkout@v4

      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.3'
          bundler-cache: true

      - name: Build gem
        run: gem build *.gemspec

      - name: Push to RubyGems
        run: |
          mkdir -p ~/.gem
          echo -e "---\n:rubygems_api_key: ${{ secrets.RUBYGEMS_API_KEY }}" > ~/.gem/credentials
          chmod 0600 ~/.gem/credentials
          gem push *.gem
```

## README.md

```markdown
# MyGem

[![Gem Version](https://badge.fury.io/rb/my_gem.svg)](https://badge.fury.io/rb/my_gem)
[![CI](https://github.com/username/my_gem/actions/workflows/ci.yml/badge.svg)](https://github.com/username/my_gem/actions/workflows/ci.yml)

Brief description of what the gem does.

## Installation

Add to your Gemfile:

```ruby
gem "my_gem"
```

## Quick Start

```ruby
require "my_gem"

# Configure (optional - uses ENV vars by default)
MyGem.configure do |config|
  config.api_key = 'your-api-key'
end

# Use
client = MyGem::Client.new
result = client.do_something
```

## Configuration

| Option | ENV Variable | Default | Description |
|--------|-------------|---------|-------------|
| `api_key` | `MY_GEM_API_KEY` | `nil` | API authentication key |
| `base_url` | `MY_GEM_BASE_URL` | `https://api.example.com` | API base URL |
| `timeout` | `MY_GEM_TIMEOUT` | `30` | Request timeout in seconds |

### Rails Configuration

```ruby
# config/initializers/my_gem.rb
MyGem.configure do |config|
  config.api_key = Rails.application.credentials.dig(:my_gem, :api_key)
  config.logger = Rails.logger
end
```

## Features

### Feature 1

Description and example.

### Feature 2

Description and example.

## Error Handling

```ruby
begin
  client.do_something
rescue MyGem::AuthenticationError => e
  # Handle 401 errors
rescue MyGem::ClientError => e
  # Handle 4xx errors
  puts "Status: #{e.status}, Body: #{e.body}"
rescue MyGem::ServerError => e
  # Handle 5xx errors
rescue MyGem::NetworkError => e
  # Handle connection/timeout errors
end
```

## Development

```bash
# Install dependencies
bundle install

# Run tests
bundle exec rake test

# Run linter
bundle exec rubocop

# Generate docs
bundle exec yard

# Start console
bin/console
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b feature/my-feature`)
3. Commit your changes (`git commit -am 'Add my feature'`)
4. Push to the branch (`git push origin feature/my-feature`)
5. Create a Pull Request

## License

MIT License - see [LICENSE.txt](LICENSE.txt)
```

## Gemspec

```ruby
# my_gem.gemspec
# frozen_string_literal: true

require_relative "lib/my_gem/version"

Gem::Specification.new do |spec|
  spec.name = "my_gem"
  spec.version = MyGem::VERSION
  spec.authors = ["Your Name"]
  spec.email = ["you@example.com"]

  spec.summary = "One-line summary of the gem"
  spec.description = "Longer description explaining what the gem does and why it's useful"
  spec.homepage = "https://github.com/username/my_gem"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["documentation_uri"] = "https://rubydoc.info/gems/my_gem"
  spec.metadata["bug_tracker_uri"] = "#{spec.homepage}/issues"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Include only necessary files
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ .git .github .rubocop Gemfile])
    end
  end

  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Runtime dependencies
  spec.add_dependency "faraday", "~> 2.9"
  spec.add_dependency "faraday-multipart", "~> 1.0"
end
```

## Gemfile

```ruby
# frozen_string_literal: true

source "https://rubygems.org"

gemspec

group :development do
  gem "irb"
  gem "rake"
  gem "rubocop", require: false
  gem "rubocop-minitest", require: false
  gem "rubocop-rake", require: false
  gem "yard"
end

group :test do
  gem "minitest"
  gem "webmock"
end
```

## Rakefile

```ruby
# frozen_string_literal: true

require "bundler/gem_tasks"
require "minitest/test_task"

Minitest::TestTask.create

require "rubocop/rake_task"
RuboCop::RakeTask.new

require "yard"
YARD::Rake::YardocTask.new

task default: %i[test rubocop]
```

## .rubocop.yml

```yaml
require:
  - rubocop-minitest
  - rubocop-rake

AllCops:
  TargetRubyVersion: 3.2
  NewCops: enable
  Exclude:
    - 'vendor/**/*'
    - 'tmp/**/*'

Style/StringLiterals:
  EnforcedStyle: double_quotes

Style/StringLiteralsInInterpolation:
  EnforcedStyle: double_quotes

Layout/LineLength:
  Max: 120

Metrics/BlockLength:
  Exclude:
    - 'test/**/*'
    - '*.gemspec'

Metrics/ClassLength:
  Max: 150

Metrics/MethodLength:
  Max: 15
```

## .yardopts

```
--markup markdown
--no-private
--output-dir doc
lib/**/*.rb
- README.md
- CHANGELOG.md
- LICENSE.txt
```

## CHANGELOG.md

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - YYYY-MM-DD

### Added

- Initial release
- Core functionality description
- Configuration via environment variables
- Rails integration support

### Security

- MFA required for gem publishing
```

## LICENSE.txt (MIT)

```
The MIT License (MIT)

Copyright (c) YYYY Your Name

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
```

## bin/console

```ruby
#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/setup"
require "my_gem"

# Configure for development
MyGem.configure do |config|
  config.api_key = ENV.fetch("MY_GEM_API_KEY", "dev-key")
end

require "irb"
IRB.start(__FILE__)
```

## bin/setup

```bash
#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

bundle install
```

## .gitignore

```
/.bundle/
/.yardoc
/_yardoc/
/coverage/
/doc/
/pkg/
/spec/reports/
/tmp/
*.gem
Gemfile.lock
```

## Test Helper (Minitest)

```ruby
# test/test_helper.rb
# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "my_gem"
require "minitest/autorun"
require "webmock/minitest"

module TestConfig
  def setup_config
    WebMock.reset!
    MyGem.reset_configuration!
    MyGem.configure do |config|
      config.api_key = "test-api-key"
      config.base_url = "https://api.test.com"
      config.logger = Logger.new(File::NULL)
    end
  end

  def teardown_config
    WebMock.reset!
    MyGem.reset_configuration!
  end
end

# Include in all tests
class Minitest::Test
  include TestConfig

  def setup
    setup_config
  end

  def teardown
    teardown_config
  end
end
```

## Test Helper (RSpec)

```ruby
# spec/spec_helper.rb
# frozen_string_literal: true

require "my_gem"
require "webmock/rspec"

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.before do
    MyGem.reset_configuration!
    MyGem.configure do |c|
      c.api_key = "test-api-key"
      c.base_url = "https://api.test.com"
      c.logger = Logger.new(File::NULL)
    end
  end

  config.after do
    MyGem.reset_configuration!
  end
end
```
