# Ruby Tips Reference

Practical Ruby patterns and idioms for Rails applications.

## Type Conversion

### Safe Integer Conversion with try_convert

Use `Integer.try_convert` for safe type coercion that returns nil instead of raising errors:

```ruby
string = "Hello, World!"

# to_i silently returns 0 for non-numeric strings
string.to_i  # => 0

# to_int raises NoMethodError
string.to_int  # => raises NoMethodError

# try_convert returns nil for incompatible types
Integer.try_convert(string)  # => nil
Integer.try_convert(2.5)     # => 2
Integer.try_convert(3)       # => 3

# Useful for conditional logic
if (count = Integer.try_convert(params[:count]))
  # count is definitely an integer
else
  # count was not convertible
end
```

## Hash Patterns

### Default Values with with_defaults

Use `with_defaults` instead of `reverse_merge` for clearer intent:

```ruby
# Less clear: reverse_merge
settings = {}
settings.reverse_merge(locale: :en, timezone: 'UTC')
# => { locale: :en, timezone: 'UTC' }

settings = { locale: :fr }
settings.reverse_merge(locale: :en, timezone: 'UTC')
# => { locale: :fr, timezone: 'UTC' }

# Clearer: with_defaults
settings = {}
settings.with_defaults(locale: :en, timezone: 'UTC')
# => { locale: :en, timezone: 'UTC' }

settings = { locale: :fr }
settings.with_defaults(locale: :en, timezone: 'UTC')
# => { locale: :fr, timezone: 'UTC' }
```

## Proc Composition

### Composing Procs with << Operator

Chain procs together for functional composition:

```ruby
round    = proc { |n| n.round(2) }
format   = proc { |n| sprintf("%.2f", n) }
currency = proc { |n| "$#{n}" }

# Compose procs: currency receives output of format, which receives output of round
number_to_currency = (currency << format << round)

number_to_currency.call(12.3456)  # => "$12.35"
```

## Argument Forwarding

### Forward Arguments Notation (...)

Use `...` to forward all arguments including blocks to another method:

```ruby
# Part 1: Basic forwarding
module Reporting
  # First parameter is defined, the rest are forwarded
  def self.log(message, ...)
    puts message
    before(...)
    console_logging(message, ...)
    error_reporting(...)
  end

  # Only the &block is needed so everything else is ignored
  def self.before(*_, **_, &block) = block&.call("#{self.name}##{__method__}")

  # Using all params: message, *args, **kwargs, &block
  def self.console_logging(message, object, *args, **kwargs, &block)
    puts "Message <#{message}>: #{object} with args: #{args} and kwargs: #{kwargs} with block: #{block}"
  end

  # Forward all params
  def self.error_reporting(...) = Provider.new.report(...)
end

# Part 2: Service objects that forward to other services
module User
  class CreateService
    def call(object, ...)
      Reporting.log("starting service", object, ...)

      Validate.new(object).call(...)
               .then { Converter.new(object).call(...) }
               .then { Repo.new(object).update(...) }

      Reporting.log("finished service", object, ...)
    end
  end

  class Validate
    def initialize(object) = @object = object
    def call(*args, **kwargs, &block) = block&.call("#{self.class}##{__method__}")
  end

  class Converter
    def initialize(object) = @object = object
    def call(*args, **kwargs, &block) = block&.call("#{self.class}##{__method__}")
  end

  class Repo
    def initialize(object) = @object = object
    def update(*args, **kwargs, &block) = block&.call("#{self.class}##{__method__}")
  end
end

# Usage - can be called with positional, keyword, and block arguments
User::CreateService.new.call(user, payload, config: { app: true }) do |method_name|
  puts "executed from #{method_name}"
end
```

## Refinements

### Local Monkey-Patching with Refinements

Use refinements for scoped monkey-patches that don't pollute global namespace:

```ruby
# Define a refinement module
module Pipelines
  # Refinement patches are local to where the refinement is used
  refine BasicObject do
    # Add >> operator to BasicObject
    def >>(callable)
      callable.call(self)
    end
  end
end

# Now, enabling Elixir-style pipelines is a matter of using the module
class UsersController < ApplicationController
  using Pipelines  # Refinement is only active in this class

  def confirm
    # Can use >> because the refinement is active here
    params[:login] >>
      FindUser >>
      ConfirmAccount >>
      SendConfirmationNotification[:sms]
  end
end

# Outside this class, >> is NOT available on BasicObject
```

## ActiveSupport Configuration

### Configurable Module Pattern

Use `ActiveSupport::Configurable` for gem/module configuration:

```ruby
require 'active_support/configurable'

module RailsMetrics
  class Settings
    include ActiveSupport::Configurable

    config_accessor(:enabled) { true }
    config_accessor(:endpoint) { 'https://railsmetrics/v1/events' }
    config_accessor(:tags)
  end
end

# Access configuration
RailsMetrics::Settings.config
# => <#:enabled=>true, :endpoint=>"https://railsmetrics/v1/events", :tags=>nil}>

RailsMetrics::Settings.config.enabled  # => true
RailsMetrics::Settings.config.tags     # => nil

# Set configuration
RailsMetrics::Settings.config.tags = [:production, :critical]
```

## Logging Patterns

### Method Signatures with Default Timestamps

Use keyword arguments with defaults for optional parameters:

```ruby
def log_event(message, time: Time.now.strftime("%F %T"))
  EventLogger.log("[#{time}] #{message}")
end

log_event("new subscription")  # => "[2024-04-24 04:24:24] new subscription"
log_event("new message")       # => "[2024-04-24 04:24:25] new message"

# Can override the time if needed
log_event("backdated", time: "2024-01-01 00:00:00")
```
