# Testing Tips Reference

Practical patterns for testing Rails applications.

## Fixtures

### Using DEFAULTS for Common Attributes

Define fixture defaults to avoid repetition:

```yaml
# test/fixtures/users.yml
DEFAULTS: &DEFAULTS
  password_digest: <%= BCrypt::Password.create("password") %>

alex:
  email: alexandre@hey.com
  <<: *DEFAULTS

jeanne:
  email: jeanne@hey.com
  <<: *DEFAULTS
```

## Development Helpers

### Highlighting Missing Alt Attributes

Add visual debugging for accessibility issues in development:

```css
/* app/assets/stylesheets/development.css */
img:not([alt]) {
  border: 5px solid red;
}
```

This makes images without alt attributes immediately visible during development.

## Test Configuration

### Disabling Logging in Tests

Silence logs during test runs for cleaner output:

```ruby
# config/test.rb
if ENV["RAILS_LOG"].blank?
  config.logger = Logger.new(nil)
  config.log_level = :fatal
end
```

Run with logging when needed:
```bash
RAILS_LOG=1 rails test
```

## CI Configuration

### Comprehensive GitHub Actions Checks

Example of thorough CI checks for Rails projects:

```yaml
# .github/workflows/ci.yml
name: CI

on: [pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          bundler-cache: true

      # Static Analysis
      - name: CodeQL Analysis (Ruby)
        uses: github/codeql-action/analyze@v2
        with:
          languages: ruby

      - name: CodeQL Analysis (JavaScript)
        uses: github/codeql-action/analyze@v2
        with:
          languages: javascript

      - name: Cadacy Static Code Analysis
        uses: codacy/codacy-analysis-cli-action@v4

      # Security
      - name: Brakeman Security Scan
        run: bundle exec brakeman --no-pager

      - name: Bundle Audit
        run: bundle exec bundle-audit check --update

      - name: Snyk Security
        uses: snyk/actions/ruby@master

      # Code Quality
      - name: RSpec
        run: bundle exec rspec

      - name: Reek
        run: bundle exec reek

      - name: RubyCritic
        run: bundle exec rubycritic

      - name: SimpleCov
        run: bundle exec rake coverage

      - name: Standard Ruby
        run: bundle exec standardrb
```

## Git Hooks

### Overcommit Configuration

Pre-commit hooks for Rails projects:

```yaml
# .overcommit.yml
verify_signatures: false

PreCommit:
  StandardRB:
    enabled: true
    required: true
    command: [
      'bash',
      '-c',
      "git diff --name-only --diff-filter=d --cached | grep '\\.rb$' | xargs bundle exec standardrb --force-exclusion",
    ]  # Invoke within Bundler context

  ErbLint:
    enabled: true
    required: true
    command:
      [
        'erblint',
        '--lint-all',
        '--enable-linters',
        'space_around_erb_tag,extra_newline',
      ]

PrePush:
  RSpec:
    enabled: true
    required: true
    command: ['bundle', 'exec', 'rspec']
```
