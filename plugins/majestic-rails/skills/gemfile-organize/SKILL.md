---
name: gemfile-organize
description: Reorganize a Rails Gemfile with categorized sections, comment headers, and alphabetized gems within each section. Use when the user asks to organize, sort, group, clean up, or restructure a Gemfile.
allowed-tools: Bash Read Edit Write AskUserQuestion
---

# Gemfile Organize

## Input

- TARGET = first arg or `Gemfile` in cwd
- Read TARGET, parse: `source`, `ruby`, `gem` declarations, groups, inline comments

## Categories (assignment table)

| Category | Gem patterns |
|----------|--------------|
| Server | `puma`, `unicorn`, `thin`, `falcon` |
| GraphQL | `graphql*`, `apollo*`, `graphiql*` |
| Databases | `pg*`, `mysql*`, `sqlite*`, `redis*`, `mongo*`, `activerecord*`, `active_record*`, `sequel`, `connection_pool`, `with_advisory_lock`, `store_model`, `attr_json` |
| Background Jobs | `sidekiq*`, `resque*`, `delayed_job*`, `good_job`, `solid_queue`, `activejob`, `active_job*` |
| Authentication & Authorization | `devise*`, `omniauth*`, `doorkeeper*`, `rodauth*`, `pundit`, `cancan*`, `action_policy`, `jwt`, `bcrypt` |
| Feature Flags | `flipper*`, `rollout`, `unleash` |
| Caching | `solid_cache`, `dalli`, `redis-rails`, `bootsnap` |
| Monitoring | `appsignal`, `newrelic*`, `datadog*`, `scout_apm`, `rollbar`, `sentry*`, `bugsnag`, `honeybadger`, `judoscale*`, `rails_autoscale*` |
| Upload & Storage | `shrine`, `carrierwave`, `paperclip`, `active_storage*`, `aws-sdk*`, `google-cloud-storage`, `fog*`, `image_processing`, `mini_magick`, `ruby-vips` |
| External APIs & Services | `stripe`, `braintree`, `paddle`, `twilio*`, `sendgrid*`, `mailgun*`, `postmark*`, `slack-*`, `octokit`, `savon`, `httparty`, `faraday`, `typhoeus`, `intacct`, `quickbooks*`, `xero*` |
| Ruby Extensions | `amazing_print`, `awesome_print`, `oj`, `multi_json`, `alba`, `blueprinter`, `dry-*`, `hashie`, `hash_dot`, `countries`, `money*`, `phonelib`, `chronic`, `ice_cube`, `business_time`, `holidays`, `shale`, `nokogiri`, `ox` |
| PDF Generation | `prawn*`, `wicked_pdf`, `pdfkit`, `hexapdf`, `ttfunk`, `matrix` |
| XLSX/CSV Generation | `caxlsx`, `axlsx*`, `roo*`, `spreadsheet`, `csv`, `smarter_csv` |
| Frontend Dependencies | `turbo-rails`, `stimulus-rails`, `hotwire*`, `importmap*`, `jsbundling*`, `cssbundling*`, `propshaft`, `sprockets*`, `tailwindcss*`, `bootstrap*`, `view_component*`, `inertia*` |
| Admin & Backoffice | `avo*`, `activeadmin`, `rails_admin`, `administrate`, `trestle` |
| Rails Extensions & Tools (default) | `aasm`, `state_machines*`, `friendly_id`, `hashid*`, `sequenced`, `pagy`, `kaminari`, `will_paginate`, `paranoia`, `discard`, `acts_as_paranoid`, `audited`, `paper_trail`, `logidze`, `rack-*`, `lograge*`, most `*-rails` gems, anything uncategorized |

Group-only categories (kept inside `group` blocks, not top-level):

| Category | Gem patterns |
|----------|--------------|
| Testing | `rspec*`, `minitest*`, `capybara*`, `factory_bot*`, `faker`, `ffaker`, `vcr`, `webmock`, `shoulda*`, `simplecov`, `codecov`, `database_cleaner*` |
| Development Tools | `rubocop*`, `standard`, `brakeman`, `annotate`, `bullet`, `pry*`, `byebug`, `debug`, `letter_opener*`, `guard*`, `ruby-lsp*`, `solargraph` |

## Output Format

```ruby
source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby file: '.ruby-version'

gem 'rails', '~> 7.x'

# Server
#########################
gem 'puma'

# Databases
#########################
gem 'pg'
gem 'redis'

# [Continue for each non-empty category, in table order]

group :production do
  # ...
end

group :development, :test do
  # ...
end

group :development do
  # ...
end

group :test do
  # ...
end

group :tools do
  # ...
end
```

## Preservation Rules

- Keep gem options intact: `github:`, `source:`, `require:`, `branch:`, `path:`
- Preserve version constraints: `'~> 1.0'`, `'>= 2.0'`
- Keep inline comments: `gem 'foo' # comment`
- Preserve special blocks like `git_source`
- Sort gems alphabetically within each section
- Only emit category headers for non-empty sections
- Uncategorized gems → "Rails Extensions & Tools"

## Workflow

1. Read TARGET → parse declarations
2. For each gem: assign to category by pattern match (first match wins, table order)
3. Build organized output (top-level categories, then groups)
4. Compute diff vs current TARGET
5. Show summary:
   ```
   Organized N gems into M categories:
   - Category: K gems
   ...
   Uncategorized → Rails Extensions & Tools:
   - gem_a
   - gem_b
   ```
6. AskUserQuestion → options: `Show diff` | `Apply changes` | `Cancel`
7. If Apply → write `TARGET.backup`, then overwrite TARGET
