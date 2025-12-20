# DHH Ruby/Rails Patterns Reference

Comprehensive code patterns extracted from 37signals' Campfire codebase and DHH's public teachings.

## Controller Patterns

### REST-Pure Controller Design

Every controller maps to a resource with only 7 standard actions.

```ruby
# CORRECT: Standard REST actions only
class MessagesController < ApplicationController
  def index; end
  def show; end
  def new; end
  def create; end
  def edit; end
  def update; end
  def destroy; end
end

# WRONG: Custom actions
class MessagesController < ApplicationController
  def archive    # NO
  def unarchive  # NO
  def search     # NO
  def drafts     # NO
end

# CORRECT: New controllers for custom behavior
class Messages::ArchivesController < ApplicationController
  def create  # archives a message
  def destroy # unarchives a message
end

class Messages::SearchesController < ApplicationController
  def show    # shows search results
end
```

### Complete Controller Example

```ruby
class MessagesController < ApplicationController
  include ActiveStorage::SetCurrent, RoomScoped

  before_action :set_room, except: :create
  before_action :set_message, only: %i[ show edit update destroy ]
  before_action :ensure_can_administer, only: %i[ edit update destroy ]

  layout false, only: :index

  def index
    @messages = find_paged_messages
    if @messages.any?
      fresh_when @messages
    else
      head :no_content
    end
  end

  def create
    set_room
    @message = @room.messages.create_with_attachment!(message_params)
    @message.broadcast_create
  rescue ActiveRecord::RecordNotFound
    render action: :room_not_found
  end

  def show
  end

  def edit
  end

  def update
    @message.update!(message_params)
    @message.broadcast_replace_to @room, :messages,
      target: [ @message, :presentation ],
      partial: "messages/presentation",
      attributes: { maintain_scroll: true }
    redirect_to room_message_url(@room, @message)
  end

  def destroy
    @message.destroy
    @message.broadcast_remove_to @room, :messages
  end

  private
    def set_message
      @message = @room.messages.find(params[:id])
    end

    def ensure_can_administer
      head :forbidden unless Current.user.can_administer?(@message)
    end

    def find_paged_messages
      case
      when params[:before].present?
        @room.messages.with_creator.page_before(@room.messages.find(params[:before]))
      when params[:after].present?
        @room.messages.with_creator.page_after(@room.messages.find(params[:after]))
      else
        @room.messages.with_creator.last_page
      end
    end

    def message_params
      params.require(:message).permit(:body, :attachment, :client_message_id)
    end
end
```

### Private Method Indentation

Indent private methods one level under `private` keyword:

```ruby
  private
    def set_message
      @message = Message.find(params[:id])
    end

    def message_params
      params.require(:message).permit(:body)
    end
```

### Controller Concerns

```ruby
# app/controllers/concerns/room_scoped.rb
module RoomScoped
  extend ActiveSupport::Concern

  included do
    before_action :set_room
  end

  private
    def set_room
      @room = Current.user.rooms.find(params[:room_id])
    end
end
```

## Model Patterns

### Semantic Association Naming

```ruby
class Message < ApplicationRecord
  # Semantic names that express domain concepts
  belongs_to :creator, class_name: "User"
  belongs_to :room
  has_many :mentions
  has_many :mentionees, through: :mentions, source: :user

  # NOT: belongs_to :user (too generic)
end
```

### Scope Design

```ruby
class Message < ApplicationRecord
  # Eager loading scopes (preloaded_*)
  scope :with_creator, -> { includes(:creator) }
  scope :with_attachments, -> { includes(attachment_attachment: :blob) }
  scope :preloaded, -> { includes(:creator, :mentions, attachment_attachment: :blob) }

  # Ordering scopes
  scope :chronologically, -> { order(created_at: :asc) }
  scope :reverse_chronologically, -> { order(created_at: :desc) }
  scope :latest, -> { order(created_at: :desc).limit(1) }
  scope :recently_updated, -> { order(updated_at: :desc) }

  # Cursor-based pagination scopes
  scope :page_before, ->(cursor) {
    where("id < ?", cursor.id).order(id: :desc).limit(50)
  }
  scope :page_after, ->(cursor) {
    where("id > ?", cursor.id).order(id: :asc).limit(50)
  }
  scope :last_page, -> { order(id: :desc).limit(50) }

  # Indexed lookups (indexed_by_*)
  scope :indexed_by_room, -> { group(:room_id).index_by(&:room_id) }
  scope :indexed_by_creator, -> { group(:creator_id).index_by(&:creator_id) }
end
```

#### Scope Naming Conventions

| Pattern | Purpose | Example |
|---------|---------|---------|
| `with_*` | Eager load associations | `with_creator`, `with_attachments` |
| `preloaded` | Full eager load for views | `preloaded` (all associations) |
| `chronologically` | Oldest first ordering | `chronologically` |
| `reverse_chronologically` | Newest first ordering | `reverse_chronologically` |
| `latest` | Single most recent | `latest` |
| `page_*` | Cursor pagination | `page_before`, `page_after` |
| `indexed_by_*` | Hash lookup by key | `indexed_by_room` |
| `excluding` | Filter out records | `excluding(user)` |

### Authorization on Models

```ruby
class User < ApplicationRecord
  def can_administer?(message)
    message.creator == self || admin?
  end

  def can_access?(room)
    rooms.include?(room) || admin?
  end

  def can_invite_to?(room)
    room.creator == self || admin?
  end
end

# Usage in controller
def ensure_can_administer
  head :forbidden unless Current.user.can_administer?(@message)
end
```

### Model Broadcasting

```ruby
class Message < ApplicationRecord
  after_create_commit :broadcast_create
  after_update_commit :broadcast_update
  after_destroy_commit :broadcast_destroy

  def broadcast_create
    broadcast_append_to room, :messages,
      target: "messages",
      partial: "messages/message"
  end

  def broadcast_update
    broadcast_replace_to room, :messages,
      target: dom_id(self, :presentation),
      partial: "messages/presentation"
  end

  def broadcast_destroy
    broadcast_remove_to room, :messages
  end
end
```

## Current Attributes Pattern

### Definition

```ruby
# app/models/current.rb
class Current < ActiveSupport::CurrentAttributes
  attribute :user
  attribute :session
  attribute :request_id
  attribute :user_agent

  resets { Time.zone = nil }

  def user=(user)
    super
    Time.zone = user&.time_zone
  end
end
```

### Setting in Controller

```ruby
class ApplicationController < ActionController::Base
  before_action :set_current_attributes

  private
    def set_current_attributes
      Current.user = authenticate_user
      Current.session = session
      Current.request_id = request.request_id
    end
end
```

### Usage Throughout App

```ruby
# In models
class Message < ApplicationRecord
  before_create :set_creator

  private
    def set_creator
      self.creator ||= Current.user
    end
end

# In views
<%= Current.user.name %>

# In jobs - Current is reset, pass what you need
class NotificationJob < ApplicationJob
  def perform(message)
    message.room.users.each { |user| notify(user, message) }
  end
end
```

## Ruby Idioms

### Guard Clauses Over Nested Conditionals

```ruby
# CORRECT: Guard clauses
def process_message
  return unless message.valid?
  return if message.spam?
  return unless Current.user.can_access?(message.room)

  message.deliver
end

# WRONG: Nested conditionals
def process_message
  if message.valid?
    unless message.spam?
      if Current.user.can_access?(message.room)
        message.deliver
      end
    end
  end
end
```

### Expression-less Case Statements

```ruby
def status_class
  case
  when urgent? then "bg-red"
  when pending? then "bg-yellow"
  when completed? then "bg-green"
  else "bg-gray"
  end
end

def find_paged_messages
  case
  when params[:before].present?
    messages.page_before(params[:before])
  when params[:after].present?
    messages.page_after(params[:after])
  else
    messages.last_page
  end
end
```

### Method Chaining

```ruby
@room.messages
     .with_creator
     .with_attachments
     .excluding(@message.creator)
     .page_before(cursor)
```

### Implicit Returns

```ruby
# CORRECT: Implicit return
def full_name
  "#{first_name} #{last_name}"
end

def can_administer?(message)
  message.creator == self || admin?
end

# WRONG: Unnecessary explicit return
def full_name
  return "#{first_name} #{last_name}"
end
```

## Testing Patterns

### System Tests First

```ruby
class MessagesTest < ApplicationSystemTestCase
  test "sending a message" do
    sign_in users(:david)
    visit room_path(rooms(:watercooler))

    fill_in "Message", with: "Hello, world!"
    click_button "Send"

    assert_text "Hello, world!"
  end
end
```

### Fixtures Over Factories

```yaml
# test/fixtures/users.yml
david:
  name: David
  email: david@example.com
  admin: true

# test/fixtures/messages.yml
greeting:
  body: Hello everyone!
  room: watercooler
  creator: david
```

### Integration Tests for API

```ruby
class MessagesApiTest < ActionDispatch::IntegrationTest
  test "creating a message via API" do
    post room_messages_url(rooms(:watercooler)),
      params: { message: { body: "API message" } },
      headers: auth_headers(users(:david))

    assert_response :success
    assert Message.exists?(body: "API message")
  end
end
```

## Anti-Patterns to Avoid

### Don't Add Service Objects for Simple Cases

```ruby
# WRONG: Over-abstraction
class MessageCreationService
  def initialize(room, params, user)
    @room = room
    @params = params
    @user = user
  end

  def call
    message = @room.messages.build(@params)
    message.creator = @user
    message.save!
    BroadcastService.new(message).call
    message
  end
end

# CORRECT: Keep it in the model
class Message < ApplicationRecord
  def self.create_with_broadcast!(params)
    create!(params).tap(&:broadcast_create)
  end
end
```

### Don't Use Policy Objects for Simple Auth

```ruby
# WRONG: Separate policy class
class MessagePolicy
  def initialize(user, message)
    @user = user
    @message = message
  end

  def update?
    @message.creator == @user || @user.admin?
  end
end

# CORRECT: Method on User model
class User < ApplicationRecord
  def can_administer?(message)
    message.creator == self || admin?
  end
end
```

### Don't Mock Everything

```ruby
# WRONG: Over-mocked test
test "sending message" do
  room = mock("room")
  user = mock("user")
  message = mock("message")

  room.expects(:messages).returns(stub(create!: message))
  message.expects(:broadcast_create)

  MessagesController.new.create
end

# CORRECT: Test the real thing
test "sending message" do
  sign_in users(:david)
  post room_messages_url(rooms(:watercooler)),
    params: { message: { body: "Hello" } }

  assert_response :success
  assert Message.exists?(body: "Hello")
end
```
