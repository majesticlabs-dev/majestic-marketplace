# DHH Ruby Style Resources

Links to source material, documentation, and further reading.

## Primary Source Code

### Campfire (Once)
The main codebase this style guide is derived from.

- **Repository**: https://github.com/basecamp/once-campfire
- **Messages Controller**: https://github.com/basecamp/once-campfire/blob/main/app/controllers/messages_controller.rb

### 37signals Open Source
- **Solid Queue**: https://github.com/rails/solid_queue - Database-backed Active Job backend
- **Solid Cache**: https://github.com/rails/solid_cache - Database-backed Rails cache
- **Solid Cable**: https://github.com/rails/solid_cable - Database-backed Action Cable adapter
- **Kamal**: https://github.com/basecamp/kamal - Zero-downtime deployment tool
- **Turbo**: https://github.com/hotwired/turbo-rails - Hotwire's SPA-like page accelerator
- **Stimulus**: https://github.com/hotwired/stimulus - Modest JavaScript framework

## Articles & Blog Posts

### Controller Organization
- **How DHH Organizes His Rails Controllers**: https://jeromedalbert.com/how-dhh-organizes-his-rails-controllers/
  - Definitive article on REST-pure controller design
  - Documents the "only 7 actions" philosophy

### Testing Philosophy
- **37signals Dev - Pending Tests**: https://dev.37signals.com/pending-tests/
- **37signals Dev - All About QA**: https://dev.37signals.com/all-about-qa/

## Official Documentation

### Rails Guides
- **Rails Doctrine**: https://rubyonrails.org/doctrine
  - The philosophical foundation
  - Convention over configuration explained

### Hotwire
- **Hotwire**: https://hotwired.dev/
- **Turbo Handbook**: https://turbo.hotwired.dev/handbook/introduction
- **Stimulus Handbook**: https://stimulus.hotwired.dev/handbook/introduction

### Current Attributes
- **Rails API - CurrentAttributes**: https://api.rubyonrails.org/classes/ActiveSupport/CurrentAttributes.html

## Gems & Tools

### Core Stack
```ruby
gem "rails", "~> 8.1"
gem "sqlite3"
gem "propshaft"        # Asset pipeline
gem "importmap-rails"  # JavaScript imports
gem "turbo-rails"      # Hotwire Turbo
gem "stimulus-rails"   # Hotwire Stimulus
gem "solid_queue"      # Job backend
gem "solid_cache"      # Cache backend
gem "solid_cable"      # WebSocket backend
gem "kamal"            # Deployment
```

### RuboCop Configuration

37signals publishes their RuboCop rules:
- **rubocop-rails-omakase**: https://github.com/rails/rubocop-rails-omakase

```yaml
# .rubocop.yml
inherit_gem:
  rubocop-rails-omakase: rubocop.yml
```

## Rails Doctrine Pillars

1. Optimize for programmer happiness
2. Convention over Configuration
3. The menu is omakase
4. No one paradigm
5. Exalt beautiful code
6. Provide sharp knives
7. Value integrated systems
8. Progress over stability
9. Push up a big tent

## DHH Quotes

> "The vast majority of Rails controllers can use the same seven actions."

> "If you're adding a custom action, you're probably missing a controller."

> "Clear code is better than clever code."

> "SQLite is enough for most applications."
