# Configuration & Operations Tips Reference

Practical patterns for Rails configuration, logging, and deployment.

## Custom Configuration with config_for

Use `config_for` to load environment-specific YAML configuration:

```ruby
# config/application.rb
module Railsdevs
  class Application < Rails::Application
    config.emails = config_for(:emails)
  end
end
```

```yaml
# config/emails.yml
shared:
  support: joe@railsdevs.com
  marketing: hi@railsdevs.com

development:
  support: joe@example.com
  marketing: hi@example.com
```

```ruby
# Access configuration with bang methods (raises KeyError if missing)
Rails.configuration.emails.support!  # => joe@railsdevs.com
Rails.configuration.emails.missing!  # => raises KeyError
```

## Logging Configuration

### Log Rotation (Rails 7.1+)

Rails 7.1+ includes automatic log rotation:

```ruby
# Default: rotates when file reaches 100MB
Rails.application.config.log_file_size  # => 104857600 (100MB)

# Configure in development.rb or test.rb
Rails.application.configure do
  # ...
  config.log_file_size = 100.megabytes
end

# For older Rails versions, clear logs manually:
# $ rake log:clear  # Truncate all *.log files in log/ to zero bytes
```

## Bundler Tips

### Check Outdated Gems

View which gems have newer versions available:

```bash
bundle outdated

# Gem        Current   Latest    Requested   Groups
# puma       5.6.5     6.0.0     ~> 5.0      default
# rack       2.2.4     3.0.0
```

### Create New Gems with Testing and Linting

Generate a new gem with RSpec and RuboCop pre-configured:

```bash
bundle gem pipeline --test=rspec --linter=rubocop
```

## Deployment Scripts

### Safe Deployment with Confirmation

A deployment script that shows commits and requires confirmation:

```bash
#!/bin/sh

set -e

base_branch=main
current_branch="$(git branch --show-current)"
production=git@production.com/app.git

if [ "$current_branch" != "$base_branch" ]
then
  echo "[bin/deploy] Please checkout main first."
  exit 1
fi

# Set up the production remote
if [ "$(git config remote.production.url)" != "$production" ]
then
  echo "[bin/deploy] Configuring production remote..."
  git remote | grep production > /dev/null && git remote remove production
  git remote add production $production
fi

git fetch origin
git fetch production
diff="$(git log origin/main...production/master)"

if [ -n "$diff" ]
then
  # Print out what commits will be deployed, and confirm
  echo "[bin/deploy] The following commits will be deployed:"
  echo
  echo "$diff"
  echo
  echo "[bin/deploy] Would you like to deploy these commits? [y/N]"
  read -r response
  response="${response:-n}"

  if [ "$response" = y ]
  then
    # Run linters, unit tests, and system tests
    bin/ci
    git push production main
  else
    echo "[bin/deploy] Exiting."
    exit 0
  fi
else
  echo "[bin/deploy] There are no new commits to deploy."
  exit 1
fi
```

## PostgreSQL Patterns

### Year-over-Year Comparison with LAG

Compare metrics to previous year using window functions:

```sql
WITH counts AS (
  SELECT
    DATE_TRUNC('month', orgs.created_at) AS month,
    COUNT(*) AS signups,
    SUM(
      CASE WHEN subscriptions.id IS NOT NULL
        THEN 1
        ELSE 0
      END
    ) AS subscribers
  FROM orgs
  LEFT JOIN subscriptions ON orgs.id = subscriptions.org_id
  GROUP BY 1
  ORDER BY 1 DESC
),

previous_counts AS (
  SELECT
    month::date,
    signups,
    LAG(signups, 12) OVER (ORDER BY month) AS prev_signups,
    subscribers,
    LAG(subscribers, 12) OVER (ORDER BY month) AS prev_subscribers
  FROM counts
  ORDER BY month DESC
)

SELECT month, signups, prev_signups, subscribers, prev_subscribers
FROM previous_counts
```

### COUNT with FILTER

Count multiple conditions in a single query:

```sql
SELECT
  COUNT(*) AS "All Users",
  COUNT(*) FILTER (WHERE u.verified) AS "Verified Users",
  COUNT(*) FILTER (WHERE NOT u.verified) AS "Unverified Users"
FROM users AS u;
```

## ActiveJob Patterns

### Priority-Based Job Queuing

Implement priority queues based on business logic:

```ruby
class PrioritizedJob < ApplicationJob
  queue_as do
    # Jobs should override #for_paid_account? and implement logic for
    # determining whether the job is being performed on behalf of a paid
    # account.
    if for_paid_account?
      :priority
    else
      :default
    end
  end

  def perform(invoice)
    # Generate the invoice.
  end

  private

  # There are several options when it comes to implementing #for_paid_account?.
  # Which is best depends on your business circumstances. Some examples:
  #
  #   1. Don't implement it in the base class and let jobs crash when missing.
  #   2. Same as above but add a test case to verify all subclasses of
  #      PrioritizedJob implement the method.
  #   3. Default to false, i.e. treat paid customers as free in case you forget
  #      to override it.
  #   4. Default to true, i.e. treat free customers as paid in case you forget
  #      to override it.
  def for_paid_account?
    true
  end
end
```

## Recommended Gems

### Production-Ready Gem Stack

```ruby
# Gemfile

# Database
gem "pg"

# Cache, queue, cable backend
gem "hiredis"
gem "redis"

# Job queue
gem "sidekiq"

# Full text search
gem "meilisearch-rails"

# Performance monitoring
gem "rails_performance"
```

### Model Extension Gems

```ruby
# Extending concepts in app/models
gem "conventional_extensions"    # app/models/post/extensions/*.rb
gem "active_record-ingress"       # app/models/post/ingressed/*.rb
gem "active_record-associated_object"  # app/models/post/*.rb
gem "active_job-performs"

gem "hercule-poro"  # Plain Old Ruby Objects
```

## Export Patterns

### Configurable Export Actions

Pattern for flexible data exports:

```ruby
# app/models/projects/export_action.rb
class Projects::ExportAction < ApplicationRecord
  include Actions::PerformsExport
  include Actions::ProcessesAsync
  include Actions::TracksCreator

  belongs_to :team, class_name: "Team"

  def valid_targets
    team.projects
  end

  AVAILABLE_FIELDS = {
    id: true,
    team_id: false,
    name: true,
    description: true,
    created_at: false,
    updated_at: false,
  }
end
```
