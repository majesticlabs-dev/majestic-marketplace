---
name: gemfile-upgrade
description: Safely upgrade a Ruby gem with changelog review, breaking changes analysis, bundle update, test run, and commit. Use when the user asks to upgrade, bump, or update a gem, or to review outdated gems.
allowed-tools: Bash Read Edit WebFetch AskUserQuestion
---

# Gemfile Upgrade

## Input

- ARG = `gem_name` (single gem) | `--outdated` (batch mode)

## Workflow (single gem)

1. Check status:
   ```bash
   bundle outdated GEM --strict
   ```
   Parse: current, latest, jump type (patch/minor/major)

2. Locate repo:
   ```bash
   bundle info GEM --path   # check gemspec for homepage / source_code_uri
   ```

3. Fetch changelog via WebFetch (try in order, stop on first hit):
   - `https://github.com/OWNER/REPO/releases`
   - `https://github.com/OWNER/REPO/blob/main/CHANGELOG.md`
   - `https://github.com/OWNER/REPO/blob/main/HISTORY.md`
   - `https://github.com/OWNER/REPO/blob/main/NEWS.md`

4. Extract changes between current → target. Flag:
   - Major bumps (X.x → Y.x)
   - Keywords: `BREAKING`, `removed`, `renamed`, `changed behavior`
   - Migration guides
   - Ruby/Rails version requirements
   - Deprecations

5. Present analysis:
   ```
   ## Upgrade Analysis: GEM CURRENT → TARGET

   ### Version Jump: PATCH | MINOR | MAJOR
   ### Breaking Changes: [list]
   ### Migration Required: [steps]
   ### Deprecations: [list]
   ### New Features: [list]
   ### Compatibility: [Ruby/Rails reqs]
   ```

6. AskUserQuestion → options:
   - `Upgrade to latest minor (recommended)` — safer, bug fixes
   - `Upgrade to latest (TARGET)` — review breaking changes
   - `Upgrade to specific version` — prompt for version
   - `Skip`

7. Update Gemfile (Edit):
   ```ruby
   # latest
   gem 'GEM', '~> MAJOR.MINOR'
   # minor only
   gem 'GEM', '~> CURRENT_MAJOR.CURRENT_MINOR'
   ```

8. Run update:
   ```bash
   bundle update GEM --conservative
   ```
   On failure → show conflicts, suggest dependent updates, offer rollback.

9. Run tests (auto-detect):
   ```bash
   if [ -f spec/spec_helper.rb ]; then bundle exec rspec
   elif [ -f test/test_helper.rb ]; then bundle exec rails test
   fi
   ```
   - Pass → step 10
   - Fail → show failures, AskUserQuestion: `Rollback` | `Investigate`

10. Commit:
    ```bash
    git add Gemfile Gemfile.lock
    git commit -m "$(cat <<'EOF'
    chore(deps): upgrade GEM from CURRENT to TARGET

    Breaking changes:
    - [list]

    Migration notes:
    - [steps taken]

    Changelog: URL
    EOF
    )"
    ```

## Workflow (--outdated batch mode)

1. `bundle outdated --strict`
2. Group by jump type:
   - **PATCH** (X.Y.Z → X.Y.Z+1) — usually safe
   - **MINOR** (X.Y → X.Y+1) — review recommended
   - **MAJOR** (X → X+1) — careful review required
3. AskUserQuestion (multi-select) presenting all gems grouped by risk
4. For each selected gem → run single-gem workflow (steps 1-10)

## Rollback

At any failure step:
```bash
git checkout -- Gemfile Gemfile.lock
bundle install
```

## Safety Rules

- Always show diff before applying
- Create backup of Gemfile before edit (Edit tool preserves prior content via git)
- Never commit if tests fail
- Default to `--conservative` to avoid cascading updates
- Flag major version jumps explicitly in analysis
