---
name: upgrade
description: Upgrade a gem safely with changelog review and testing
argument-hint: "[gem_name | --outdated]"
---

# Upgrade Gem

Safely upgrade a Ruby gem with changelog review, breaking changes analysis, and automated testing.

## Arguments

`$ARGUMENTS`

- `gem_name` - Upgrade a specific gem (e.g., `rails`, `sidekiq`)
- `--outdated` - Review all outdated gems and select which to upgrade

## Tasks

### 1. Check Current Status

```bash
# For specific gem
bundle outdated [gem_name] --strict

# For all outdated
bundle outdated --strict
```

Parse output to get:
- Current version installed
- Latest version available
- Whether it's a major, minor, or patch update

### 2. Fetch Changelog Information

For the gem being upgraded:

1. **Find GitHub repository**
   ```bash
   bundle info [gem_name] --path
   # Check gemspec for homepage/source_code_uri
   ```

2. **Fetch changelog** using WebFetch:
   - `https://github.com/[owner]/[repo]/releases` - GitHub releases
   - `https://github.com/[owner]/[repo]/blob/main/CHANGELOG.md` - Changelog file
   - `https://github.com/[owner]/[repo]/blob/main/HISTORY.md` - History file
   - `https://github.com/[owner]/[repo]/blob/main/NEWS.md` - News file

3. **Extract relevant changes** between current and target version

### 3. Analyze Breaking Changes

Look for:
- **Major version bumps** (1.x → 2.x) - likely breaking
- **Deprecation warnings** in changelog
- Keywords: "BREAKING", "removed", "renamed", "changed behavior"
- **Migration guides** or upgrade instructions
- **Ruby/Rails version requirements**

Present summary:

```
## Upgrade Analysis: sidekiq 6.5.12 → 7.2.0

### Version Jump: MAJOR (6.x → 7.x)

### Breaking Changes:
- Removed support for Redis < 6.2
- Changed default concurrency from 25 to 10
- Renamed `Sidekiq::Worker` to `Sidekiq::Job`

### Migration Required:
1. Update Redis to 6.2+
2. Replace `include Sidekiq::Worker` with `include Sidekiq::Job`
3. Review concurrency settings

### Deprecations:
- `Sidekiq.options` deprecated, use `Sidekiq.configure_*`

### New Features:
- Capsules for isolated configurations
- Improved metrics dashboard

### Compatibility:
- Requires Ruby 2.7+
- Requires Rails 6.0+
```

### 4. Present Options to User

```
Current: sidekiq 6.5.12
Latest:  sidekiq 7.2.0

Options:
1. Upgrade to latest (7.2.0) - MAJOR update, review changes above
2. Upgrade to latest minor (6.5.latest) - Safer, bug fixes only
3. Upgrade to specific version
4. Skip this gem

Choice [1/2/3/4]:
```

### 5. Update Gemfile

Based on user choice:

```ruby
# Before
gem 'sidekiq', '~> 6.5.12'

# After (option 1 - latest)
gem 'sidekiq', '~> 7.2'

# After (option 2 - minor)
gem 'sidekiq', '~> 6.5'
```

### 6. Run Bundle Update

```bash
bundle update [gem_name] --conservative
```

If update fails:
- Show dependency conflicts
- Suggest solutions (update dependent gems)
- Offer to rollback

### 7. Run Test Suite

```bash
# Detect test framework
if [ -f "spec/spec_helper.rb" ]; then
  bundle exec rspec
elif [ -f "test/test_helper.rb" ]; then
  bundle exec rails test
fi
```

Report results:
- Tests passed: proceed to commit
- Tests failed: show failures, offer to rollback

### 8. Create Commit

If tests pass:

```bash
git add Gemfile Gemfile.lock
git commit -m "$(cat <<'EOF'
chore(deps): upgrade [gem_name] from X.X.X to Y.Y.Y

Breaking changes:
- [list any breaking changes]

Migration notes:
- [list any migration steps taken]

Changelog: [URL to changelog]
EOF
)"
```

## Rollback

If something goes wrong at any step:

```bash
git checkout -- Gemfile Gemfile.lock
bundle install
```

## Batch Mode (--outdated)

When using `--outdated`:

1. Run `bundle outdated --strict`
2. Group by update type:
   - **Patch updates** (1.0.0 → 1.0.1): Usually safe
   - **Minor updates** (1.0.0 → 1.1.0): Review recommended
   - **Major updates** (1.0.0 → 2.0.0): Careful review required

3. Present interactive selection:

```
Outdated gems found:

PATCH updates (safe):
  [ ] rack 3.0.8 → 3.0.9
  [ ] puma 6.4.0 → 6.4.2

MINOR updates (review recommended):
  [ ] devise 4.9.2 → 4.9.4
  [ ] sidekiq 6.5.10 → 6.5.12

MAJOR updates (breaking changes likely):
  [ ] rails 7.1.3 → 7.2.0
  [ ] graphql 2.2.0 → 2.3.0

Select gems to upgrade (space to toggle, enter to proceed):
```

4. Process selected gems one at a time with full workflow

## Safety Features

- Always show diff before applying
- Create Gemfile.backup before modifications
- Run tests before committing
- Easy rollback at any step
- Conservative updates by default
- Warn about major version jumps
