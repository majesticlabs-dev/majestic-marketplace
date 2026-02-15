---
description: Organize Gemfile with categorized sections and alphabetized gems
argument-hint: "[optional: path/to/Gemfile]"
allowed-tools: Bash, Read, Edit, Write, AskUserQuestion
disable-model-invocation: true
---

# Organize Gemfile

Reorganize a Gemfile with categorized sections, comment headers, and alphabetized gems within each section.

## Target File

$ARGUMENTS (default: `Gemfile` in current directory)

## Tasks

### 1. Read and Parse Current Gemfile

Read the Gemfile and identify:
- Source declarations (`source "..."`)
- Ruby version specification (`ruby ...`)
- Individual gem declarations with their options
- Existing groups and their contents
- Comments (preserve inline comments with gems)

### 2. Categorize Gems

Assign each gem to a category based on these mappings:

**Server**
- `puma`, `unicorn`, `thin`, `falcon`

**GraphQL**
- `graphql*`, `apollo*`, `graphiql*`

**Databases**
- `pg*`, `mysql*`, `sqlite*`, `redis*`, `mongo*`
- `activerecord*`, `active_record*`, `sequel`
- `connection_pool`, `with_advisory_lock`
- `store_model`, `attr_json`

**Background Jobs**
- `sidekiq*`, `resque*`, `delayed_job*`, `good_job`, `solid_queue`
- `activejob`, `active_job*`

**Authentication & Authorization**
- `devise*`, `omniauth*`, `doorkeeper*`, `rodauth*`
- `pundit`, `cancan*`, `action_policy`
- `jwt`, `bcrypt`

**Feature Flags**
- `flipper*`, `rollout`, `unleash`

**Caching**
- `solid_cache`, `dalli`, `redis-rails`, `bootsnap`

**Rails Extensions & Tools** (default category)
- `aasm`, `state_machines*`
- `friendly_id`, `hashid*`, `sequenced`
- `pagy`, `kaminari`, `will_paginate`
- `paranoia`, `discard`, `acts_as_paranoid`
- `audited`, `paper_trail`, `logidze`
- `rack-*`, `lograge*`
- Most `*-rails` gems

**Monitoring**
- `appsignal`, `newrelic*`, `datadog*`, `scout_apm`
- `rollbar`, `sentry*`, `bugsnag`, `honeybadger`
- `judoscale*`, `rails_autoscale*`

**Upload & Storage**
- `shrine`, `carrierwave`, `paperclip`, `active_storage*`
- `aws-sdk*`, `google-cloud-storage`, `fog*`
- `image_processing`, `mini_magick`, `ruby-vips`

**External APIs & Services**
- `stripe`, `braintree`, `paddle`
- `twilio*`, `sendgrid*`, `mailgun*`, `postmark*`
- `slack-*`, `octokit`
- `savon`, `httparty`, `faraday`, `typhoeus`
- `intacct`, `quickbooks*`, `xero*`

**Ruby Extensions**
- `amazing_print`, `awesome_print`
- `oj`, `multi_json`, `alba`, `blueprinter`
- `dry-*`, `hashie`, `hash_dot`
- `countries`, `money*`, `phonelib`
- `chronic`, `ice_cube`, `business_time`, `holidays`
- `shale`, `nokogiri`, `ox`

**PDF Generation**
- `prawn*`, `wicked_pdf`, `pdfkit`, `hexapdf`
- `ttfunk`, `matrix`

**XLSX/CSV Generation**
- `caxlsx`, `axlsx*`, `roo*`, `spreadsheet`
- `csv`, `smarter_csv`

**Frontend Dependencies**
- `turbo-rails`, `stimulus-rails`, `hotwire*`
- `importmap*`, `jsbundling*`, `cssbundling*`
- `propshaft`, `sprockets*`
- `tailwindcss*`, `bootstrap*`
- `view_component*`
- `inertia*`

**Admin & Backoffice**
- `avo*`, `activeadmin`, `rails_admin`, `administrate`
- `trestle`

**Testing** (usually in group)
- `rspec*`, `minitest*`, `capybara*`
- `factory_bot*`, `faker`, `ffaker`
- `vcr`, `webmock`, `shoulda*`
- `simplecov`, `codecov`
- `database_cleaner*`

**Development Tools** (usually in group)
- `rubocop*`, `standard`, `brakeman`
- `annotate`, `bullet`, `pry*`, `byebug`, `debug`
- `letter_opener*`, `guard*`
- `ruby-lsp*`, `solargraph`

### 3. Generate Organized Gemfile

Output format:

```ruby
source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby file: '.ruby-version'  # or specific version

gem 'rails', '~> 7.x'

# Server
#########################
gem 'puma'

# Databases
#########################
gem 'pg'
gem 'redis'

# [Continue with each non-empty category...]

# Groups at bottom
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

### 4. Preservation Rules

- Keep gem options intact: `github:`, `source:`, `require:`, `branch:`, `path:`
- Preserve version constraints: `'~> 1.0'`, `'>= 2.0'`
- Keep inline comments: `gem 'foo' # comment`
- Preserve special blocks like `git_source`
- Sort gems alphabetically within each section
- Only include category headers for sections with gems

### 5. Write Output

- Show diff of changes
- Ask for confirmation before overwriting
- Create backup as `Gemfile.backup` before modifying

## Output

After organizing, display:
1. Summary of gems by category
2. Any gems that couldn't be categorized (placed in Rails Extensions)
3. Diff of changes

```
Organized 87 gems into 15 categories:
- Server: 1 gem
- Databases: 6 gems
- Background Jobs: 4 gems
...

Uncategorized gems placed in 'Rails Extensions & Tools':
- custom_gem
- another_gem
```

Use `AskUserQuestion` to confirm before applying:
- **Show diff** - Display the proposed changes
- **Apply changes** - Write the organized Gemfile
- **Cancel** - Abort without changes
