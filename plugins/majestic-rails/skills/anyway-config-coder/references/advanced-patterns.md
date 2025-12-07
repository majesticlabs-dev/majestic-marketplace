# Advanced Anyway Config Patterns

## Dynamic Configuration

### Runtime Overrides

```ruby
class FeatureConfig < Anyway::Config
  attr_config :dark_mode,
              :beta_access

  # Override for specific context
  def with_user(user)
    self.class.new(
      dark_mode: user.prefers_dark_mode? || dark_mode,
      beta_access: user.beta_tester? || beta_access
    )
  end
end
```

### Configuration Inheritance

```ruby
class BaseApiConfig < Anyway::Config
  attr_config timeout: 30,
              retries: 3,
              base_url: nil

  required :base_url
end

class GeminiConfig < BaseApiConfig
  config_name :gemini

  attr_config model: "gemini-pro"

  def base_url
    "https://generativelanguage.googleapis.com/v1beta"
  end
end

class OpenAIConfig < BaseApiConfig
  config_name :openai

  attr_config model: "gpt-4"

  def base_url
    "https://api.openai.com/v1"
  end
end
```

## Callbacks & Lifecycle

### On Load Callback

```ruby
class AppConfig < Anyway::Config
  attr_config :debug_mode,
              :log_level

  on_load do
    Rails.logger.level = log_level_constant if log_level.present?
  end

  private

  def log_level_constant
    Logger.const_get(log_level.upcase)
  rescue NameError
    Logger::INFO
  end
end
```

### Reloading Configuration

```ruby
class DynamicConfig < Anyway::Config
  attr_config :feature_flags

  def reload!
    @values = nil
    load
  end
end

# In controller or job
DynamicConfig.new.reload!
```

## Environment-Specific Behavior

```ruby
class DatabaseConfig < Anyway::Config
  attr_config pool: 5,
              timeout: 5000,
              prepared_statements: true

  def pool
    # Increase pool in production
    Rails.env.production? ? super * 2 : super
  end

  def connection_options
    base = { pool:, timeout: }

    if Rails.env.production?
      base.merge(prepared_statements:, checkout_timeout: 10)
    else
      base
    end
  end
end
```

## Configuration Sources Priority

Anyway Config loads from multiple sources (highest priority first):

1. **Environment variables** - `MY_CONFIG_KEY=value`
2. **YAML files** - `config/settings/my_config.yml`
3. **Secrets** - Rails credentials (if using `secrets: true`)
4. **Defaults** - Values in `attr_config`

```ruby
class MultiSourceConfig < Anyway::Config
  # Enable all sources
  config_name :app

  # Explicit source control
  env_prefix :MY_APP  # Use MY_APP_* instead of APP_*
end
```

## Complex Type Coercion

### Custom Type

```ruby
class ApiConfig < Anyway::Config
  # Define custom type
  coerce_types endpoint: ->(value) {
    URI.parse(value)
  }

  # Hash coercion
  coerce_types headers: {
    type: ->(val) { JSON.parse(val) rescue {} },
    array: false
  }

  attr_config endpoint: nil,
              headers: {}
end
```

### Boolean Coercion

```ruby
class FeatureConfig < Anyway::Config
  # Handles "true", "1", "yes", "on" as true
  coerce_types enabled: :boolean,
               debug: :boolean

  attr_config enabled: false,
              debug: false
end
```

## Namespaced Configurations

```ruby
# For modular Rails apps
module Billing
  class Config < Anyway::Config
    config_name :billing

    attr_config stripe_key: nil,
                webhook_secret: nil,
                currency: "usd"
  end
end

module Notifications
  class Config < Anyway::Config
    config_name :notifications

    attr_config provider: "sendgrid",
                from_email: "noreply@example.com"
  end
end
```

## Testing Strategies

### Stub Configuration

```ruby
RSpec.describe "with stubbed config" do
  let(:config) { instance_double(GeminiConfig, api_key: "test", timeout: 5) }

  before do
    allow(GeminiConfig).to receive(:new).and_return(config)
  end

  it "uses stubbed values" do
    expect(GeminiConfig.new.api_key).to eq("test")
  end
end
```

### Factory Pattern for Tests

```ruby
# spec/support/config_helpers.rb
module ConfigHelpers
  def with_config(config_class, **overrides)
    original = config_class.new
    stubbed = config_class.new(**original.to_h.merge(overrides))

    allow(config_class).to receive(:new).and_return(stubbed)
    yield stubbed
  end
end

# Usage
with_config(GeminiConfig, api_key: "test-key") do |config|
  expect(config.api_key).to eq("test-key")
end
```

## Rails Integration

### Initializer Pattern

```ruby
# config/initializers/gemini.rb
Rails.application.config.gemini = GeminiConfig.new

# Access anywhere
Rails.application.config.gemini.api_key
```

### Lazy Loading

```ruby
# config/initializers/configs.rb
Rails.application.config.to_prepare do
  Rails.application.config.gemini = GeminiConfig.new
  Rails.application.config.storage = StorageConfig.new
end
```

## Migration from ENV

Before (scattered ENV access):

```ruby
class GeminiClient
  def initialize
    @api_key = ENV["GEMINI_API_KEY"]
    @timeout = ENV.fetch("GEMINI_TIMEOUT", 30).to_i
    @model = ENV.fetch("GEMINI_MODEL", "gemini-pro")
  end
end
```

After (typed configuration):

```ruby
class GeminiConfig < Anyway::Config
  attr_config :api_key,
              timeout: 30,
              model: "gemini-pro"

  required :api_key
end

class GeminiClient
  def initialize(config: GeminiConfig.new)
    @config = config
  end

  def generate(prompt)
    # @config.api_key, @config.timeout, etc.
  end
end
```
