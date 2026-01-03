# Palkan Rails Patterns

Patterns that complement DHH's philosophy with practical architectural guidance.

## Namespaced Model Classes (NOT Service Objects)

**Core principle:** Complex operations belong in namespaced model classes, not `app/services/`.

```ruby
# WRONG - Service object pattern
# app/services/cloud_card_generator_service.rb
class CloudCardGeneratorService
  def call(cloud)
    # ...
  end
end

# RIGHT - Namespaced under model
# app/models/cloud/card_generator.rb
class Cloud::CardGenerator
  def initialize(cloud)
    @cloud = cloud
  end

  def generate
    analyze_image
    generate_cards
    update_state
  end

  private

  def analyze_image
    # Complex logic here
  end
end

# Usage (reads naturally)
Cloud::CardGenerator.new(cloud).generate
```

### Directory Structure

```
app/models/
├── cloud.rb                    # Main model
├── cloud/
│   ├── card_generator.rb       # Complex operation
│   ├── image_analyzer.rb       # Another operation
│   └── state_machine.rb        # State management
├── participant.rb
└── participant/
    └── onboarding.rb
```

### When to Extract

Extract to namespaced class when:
- Operation exceeds 15 lines
- Logic is reusable across controllers
- Operation involves external APIs
- Complex business rules

Keep in model when:
- Simple query or check
- Less than 10 lines
- Only used in one place

## Counter Cache Mandate

**Every `has_many` should have a counter cache** to prevent N+1 queries.

```ruby
# Migration
add_column :rooms, :messages_count, :integer, default: 0, null: false

# Update existing counts
Room.find_each do |room|
  Room.reset_counters(room.id, :messages)
end

# Model
class Message < ApplicationRecord
  belongs_to :room, counter_cache: true
end

class Room < ApplicationRecord
  has_many :messages

  # Now this is O(1) instead of O(n)
  def message_count
    messages_count  # Single column read
  end
end
```

### Benefits

| Without Counter Cache | With Counter Cache |
|-----------------------|---------------------|
| `messages.count` → SQL query | `messages_count` → column read |
| N+1 in listings | Single query |
| Expensive at scale | O(1) always |

## Model Organization Order

Organize model internals in this specific order:

```ruby
class Cloud < ApplicationRecord
  # 1. Gems/DSL extensions
  include Turbo::Broadcastable
  has_paper_trail

  # 2. Associations
  belongs_to :participant
  has_many :cards, dependent: :destroy
  has_one_attached :image

  # 3. Enums (for state)
  enum :state, {
    uploaded: "uploaded",
    analyzing: "analyzing",
    analyzed: "analyzed",
    generating: "generating",
    generated: "generated",
    failed: "failed"
  }

  # 4. Normalizations (Rails 7.1+)
  normalizes :email, with: ->(e) { e.strip.downcase }
  normalizes :name, with: ->(n) { n.squish }

  # 5. Validations
  validates :title, presence: true, length: { maximum: 100 }
  validates :state, presence: true

  # 6. Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :pending, -> { where(state: %i[uploaded analyzing]) }
  scope :by_participant, ->(p) { where(participant: p) }

  # 7. Callbacks
  before_create :generate_slug
  after_commit :broadcast_update, on: :update

  # 8. Delegated methods
  delegate :email, to: :participant, prefix: true

  # 9. Public instance methods
  def ready?
    generated? && cards.any?
  end

  def process!
    Cloud::CardGenerator.new(self).generate
  end

  # 10. Private methods
  private

  def generate_slug
    self.slug ||= title.parameterize
  end

  def broadcast_update
    broadcast_replace_to participant, :clouds
  end
end
```

## PostgreSQL-Level Enums

Define enums at the database level for type safety:

```ruby
# Migration
class AddCloudStateEnum < ActiveRecord::Migration[7.1]
  def up
    create_enum :cloud_state, %w[
      uploaded
      analyzing
      analyzed
      generating
      generated
      failed
    ]

    add_column :clouds, :state, :cloud_state, default: "uploaded", null: false
    add_index :clouds, :state
  end

  def down
    remove_column :clouds, :state
    drop_enum :cloud_state
  end
end

# Model
class Cloud < ApplicationRecord
  # PostgreSQL enum - validates at DB level
  enum :state, {
    uploaded: "uploaded",
    analyzing: "analyzing",
    analyzed: "analyzed",
    generating: "generating",
    generated: "generated",
    failed: "failed"
  }, validate: true
end
```

### Benefits

- Invalid states rejected at database level
- Faster queries (enum stored as integer internally)
- Self-documenting schema
- Works with `enum :state, ...` in Rails 7+

## Data Normalization Pattern

Use `normalizes` for automatic data cleanup:

```ruby
class User < ApplicationRecord
  # Automatic normalization before validation
  normalizes :email, with: ->(e) { e.strip.downcase }
  normalizes :phone, with: ->(p) { p.gsub(/\D/, "") }
  normalizes :name, with: ->(n) { n.squish.titleize }
  normalizes :url, with: ->(u) { u.strip.downcase.delete_suffix("/") }
end

# Before: email = "  USER@Example.COM  "
# After:  email = "user@example.com"
```

## Form Objects (Multi-Model Operations)

Use form objects only for operations spanning multiple models:

```ruby
# app/forms/application_form.rb
class ApplicationForm
  include ActiveModel::API
  include ActiveModel::Attributes
  include ActiveModel::Validations::Callbacks

  def submit!
    return false unless valid?

    ActiveRecord::Base.transaction do
      persist!
    end

    true
  rescue ActiveRecord::RecordInvalid => e
    errors.merge!(e.record.errors)
    false
  end

  private

  def persist!
    raise NotImplementedError
  end
end

# app/forms/registration_form.rb
class RegistrationForm < ApplicationForm
  attribute :email, :string
  attribute :name, :string
  attribute :company_name, :string

  validates :email, :name, :company_name, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }

  attr_reader :user, :company

  private

  def persist!
    @company = Company.create!(name: company_name)
    @user = User.create!(
      email:,
      name:,
      company: @company
    )
  end
end

# Controller
def create
  @form = RegistrationForm.new(form_params)

  if @form.submit!
    redirect_to @form.user, notice: "Welcome!"
  else
    render :new, status: :unprocessable_entity
  end
end
```

## Query Objects

For complex, reusable queries:

```ruby
# app/queries/application_query.rb
class ApplicationQuery
  def initialize(relation = default_relation)
    @relation = relation
  end

  def call
    raise NotImplementedError
  end

  private

  attr_reader :relation

  def default_relation
    raise NotImplementedError
  end
end

# app/queries/clouds/search_query.rb
module Clouds
  class SearchQuery < ApplicationQuery
    def initialize(relation = Cloud.all, params: {})
      super(relation)
      @params = params
    end

    def call
      relation
        .then { |r| filter_by_state(r) }
        .then { |r| filter_by_date(r) }
        .then { |r| search_by_title(r) }
        .order(created_at: :desc)
    end

    private

    attr_reader :params

    def filter_by_state(relation)
      return relation if params[:state].blank?

      relation.where(state: params[:state])
    end

    def filter_by_date(relation)
      return relation if params[:from_date].blank?

      relation.where(created_at: Date.parse(params[:from_date])..)
    end

    def search_by_title(relation)
      return relation if params[:q].blank?

      relation.where("title ILIKE ?", "%#{params[:q]}%")
    end

    def default_relation
      Cloud.all
    end
  end
end

# Usage
Clouds::SearchQuery.new(params: search_params).call
```

## Controller Namespacing for Auth

Namespace controllers by authentication scope:

```ruby
# app/controllers/participant/application_controller.rb
module Participant
  class ApplicationController < ::ApplicationController
    before_action :set_participant

    private

    def set_participant
      @participant = Current.participant
    end
  end
end

# app/controllers/participant/clouds_controller.rb
module Participant
  class CloudsController < ApplicationController
    def index
      @clouds = @participant.clouds.recent
    end

    def show
      @cloud = @participant.clouds.find(params[:id])
    end
  end
end

# Routes
namespace :participant do
  resources :clouds
end
```

### Benefits

- Automatic scoping to current participant
- No accidental data leakage
- Cleaner authorization
- Inheritance handles auth

## Model Size Target

**Target: Under 100 lines per model**

When exceeding:
1. Extract complex operations to namespaced classes
2. Move shared behavior to concerns
3. Split into multiple focused models (if domain supports it)

```ruby
# Too large? Extract:
# - Cloud::CardGenerator for generation logic
# - Cloud::ImageAnalyzer for analysis logic
# - Concerns::Broadcastable for Turbo broadcasts
```
