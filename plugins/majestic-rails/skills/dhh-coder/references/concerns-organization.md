# Concerns Organization Patterns

How 37signals organizes concerns in large Rails applications like Basecamp, HEY, and Fizzy.

## Two Types of Concerns

### Model-Specific Concerns

Place in `app/models/<model_name>/` with implicit namespacing:

```ruby
# app/models/recording.rb
class Recording < ApplicationRecord
  include Completable
  include Copyable
  include Incineratable
end

# app/models/recording/completable.rb
module Recording::Completable
  extend ActiveSupport::Concern

  included do
    scope :completed, -> { where.not(completed_at: nil) }
    scope :incomplete, -> { where(completed_at: nil) }
  end

  def complete!
    update!(completed_at: Time.current)
  end

  def completed?
    completed_at.present?
  end
end

# app/models/recording/copyable.rb
module Recording::Copyable
  extend ActiveSupport::Concern

  included do
    has_many :copies, foreign_key: :source_recording_id
  end

  def copy_to(bucket, parent: nil)
    copies.create! destination_bucket: bucket, destination_parent: parent
  end
end

# app/models/recording/incineratable.rb
module Recording::Incineratable
  extend ActiveSupport::Concern

  def incinerate
    Incineration.create!(recording: self)
  end

  def incinerate_later
    IncinerationJob.perform_later(self)
  end
end
```

### Common/Shared Concerns

Place in `app/models/concerns/` for cross-cutting functionality:

```ruby
# app/models/concerns/tracked.rb
module Tracked
  extend ActiveSupport::Concern

  included do
    has_many :events, as: :trackable, dependent: :destroy
    after_create :track_creation
  end

  private
    def track_creation
      events.create!(action: "created", actor: Current.user)
    end
end

# app/models/concerns/mentionable.rb
module Mentionable
  extend ActiveSupport::Concern

  included do
    has_many :mentions, as: :mentionable, dependent: :destroy
    after_save :extract_mentions, if: :mentionable_content_changed?
  end

  def mentionees
    mentions.includes(:user).map(&:user)
  end

  private
    def extract_mentions
      MentionExtractor.new(self).extract!
    end

    def mentionable_content_changed?
      saved_change_to_body?
    end
end
```

## Naming Convention

Each concern should represent a **cohesive trait** with genuine "has trait" or "acts as" semantics:

```ruby
# GOOD: Clear domain concepts
class Topic < ApplicationRecord
  include Accessible      # has access controls
  include Deletable       # can be deleted/restored
  include Incineratable   # can be permanently destroyed
  include Indexed         # is searchable
  include Mergeable       # can merge with other topics
  include Notifiable      # triggers notifications
  include Publishable     # has publish/unpublish states
  include Recyclable      # moves to/from trash
  include Sortable        # has ordering
end

# BAD: Arbitrary code groupings
class Topic < ApplicationRecord
  include TopicHelpers      # unclear purpose
  include TopicCallbacks    # technical, not domain
  include TopicValidations  # should be inline
end
```

## Concerns as Facades

Concerns expose simple APIs while hiding complex implementations:

```ruby
# Simple interface
module Recording::Copyable
  def copy_to(bucket, parent: nil)
    copies.create! destination_bucket: bucket, destination_parent: parent
  end
end

# Behind the scenes: Copy model triggers background jobs
class Copy < ApplicationRecord
  after_create_commit :perform_copy

  private
    def perform_copy
      CopyJob.perform_later(self)
    end
end

# CopyJob instantiates Recording::Copier for the actual work
class CopyJob < ApplicationJob
  def perform(copy)
    Recording::Copier.new(copy).process
  end
end
```

This layering follows **Single Responsibility Principle at implementation level** while maintaining a large, convenient API surface.

## Directory Structure

```
app/models/
├── concerns/              # Shared across models
│   ├── mentionable.rb
│   ├── tracked.rb
│   └── searchable.rb
├── recording/             # Recording-specific
│   ├── completable.rb
│   ├── copyable.rb
│   ├── incineratable.rb
│   └── copier.rb          # POROs can live here too
├── topic/                 # Topic-specific
│   ├── accessible.rb
│   ├── entries.rb
│   └── mergeable.rb
├── recording.rb
└── topic.rb
```

## Rich Model Example

The HEY `Topic` model showcases concerns enabling rich functionality:

```ruby
class Topic < ApplicationRecord
  include Accessible, Breakoutable, Deletable, Entries, Incineratable,
          Indexed, Involvable, Journal, Mergeable, Named, Nettable,
          Notifiable, Postable, Publishable, Preapproved, Collectionable,
          Recycled, Redeliverable, Replyable, Restorable, Sortable,
          Spam, Spanning
end
```

Each concern name clearly communicates a domain concept, making the model's capabilities immediately apparent.

## Key Principles

1. **Cohesive traits** - Each concern represents one domain concept
2. **Natural inclusion** - `include Copyable` reads like English
3. **No namespace repetition** - `Recording::Completable` included as `Completable`
4. **Facade pattern** - Simple API, complex implementation hidden
5. **Model-specific by default** - Only extract to `concerns/` when truly shared
