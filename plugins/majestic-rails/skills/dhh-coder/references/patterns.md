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

## DHH Code Review Patterns

Patterns extracted from DHH's actual code review comments on 37signals PRs.

### Earn Your Abstractions

Only create abstractions when supporting 3+ variations. Ask: *"Is this abstraction earning its keep?"*

```ruby
# WRONG: Premature abstraction for 2 cases
class NotificationStrategy
  def self.for(type)
    case type
    when :email then EmailStrategy.new
    when :push then PushStrategy.new
    end
  end
end

# CORRECT: Simple conditional until 3+ variations exist
def notify(user)
  if user.prefers_email?
    send_email(user)
  else
    send_push(user)
  end
end
```

### Inline Anemic Code

Methods without additional logic or explanation should be inlined. *"Don't think this method is carrying its weight."*

```ruby
# WRONG: Anemic wrapper
def user_name
  user.name
end

# CORRECT: Just use it directly
user.name

# EXCEPTION: When method adds semantic meaning
def author_name
  creator.display_name  # Semantic alias is valuable
end
```

### Prefer Database Constraints

Use DB constraints over ActiveRecord validations for data integrity. Reserve validations for user-facing error messages.

```ruby
# WRONG: Validation-only uniqueness
validates :email, uniqueness: true

# CORRECT: Database constraint + validation for messages
validates :email, uniqueness: true
# + migration: add_index :users, :email, unique: true

# WRONG: Application-level null check only
validates :account_id, presence: true

# CORRECT: Database enforces, validation provides message
validates :account_id, presence: true
# + migration: null: false on column
```

### Positive Naming

Use affirmative terms rather than negations.

```ruby
# WRONG: Negative naming
scope :not_deleted, -> { where(deleted_at: nil) }
scope :not_popped, -> { where(popped: false) }

# CORRECT: Positive naming
scope :active, -> { where(deleted_at: nil) }
scope :visible, -> { where(popped: false) }
```

### Method Names Reflect Return Values

Method names should indicate what they return.

```ruby
# WRONG: collect implies returning array, but ignores result
mentions.collect { |m| m.notify }

# CORRECT: Use each when ignoring return, or name appropriately
mentions.each { |m| m.notify }

# CORRECT: When you need the result
notified_users = mentions.map(&:notify_and_return_user)
```

### Consistent Domain Language

Maintain terminology throughout codebase. Don't mix synonyms.

```ruby
# WRONG: Inconsistent terminology
class Card
  belongs_to :container  # Sometimes "container"
  belongs_to :source     # Sometimes "source"
  belongs_to :resource   # Sometimes "resource"
end

# CORRECT: Pick one term and use it everywhere
class Card
  belongs_to :bucket  # Always "bucket"
end
```

### Touch Chains for Cache Busting

Use `touch: true` on associations instead of complex cache key dependencies.

```ruby
# WRONG: Complex cache dependencies
cache [@card, @card.comments.maximum(:updated_at), @card.attachments.count]

# CORRECT: Touch chains
class Comment < ApplicationRecord
  belongs_to :card, touch: true
end

class Attachment < ApplicationRecord
  belongs_to :card, touch: true
end

# Simple cache key
cache @card
```

### Logic in Helpers, Not Partials

Partials with minimal HTML should become helper methods.

```ruby
# WRONG: Partial with mostly logic
# _status_badge.html.erb
<% if card.closed? %>
  <span class="badge-closed">Closed</span>
<% elsif card.urgent? %>
  <span class="badge-urgent">Urgent</span>
<% else %>
  <span class="badge-open">Open</span>
<% end %>

# CORRECT: Helper method
def status_badge(card)
  case
  when card.closed? then tag.span("Closed", class: "badge-closed")
  when card.urgent? then tag.span("Urgent", class: "badge-urgent")
  else tag.span("Open", class: "badge-open")
  end
end
```

### Explicit Helper Parameters

Avoid magical instance variables in helpers. Pass dependencies explicitly.

```ruby
# WRONG: Relies on instance variable
def card_actions
  if @current_user.can_edit?(@card)
    # ...
  end
end

# CORRECT: Explicit parameters
def card_actions(card, user)
  if user.can_edit?(card)
    # ...
  end
end
```

### Avoid Test-Induced Design Damage

Never modify production code solely for testability.

```ruby
# WRONG: Exposing internals for tests
class Order
  attr_accessor :payment_processor  # Added just for testing

  def process_payment
    @payment_processor ||= StripeProcessor.new
    @payment_processor.charge(total)
  end
end

# CORRECT: Use fixtures/mocks without changing production code
test "processes payment" do
  order = orders(:pending)

  Stripe::Charge.stub(:create, successful_charge) do
    order.process_payment
  end

  assert order.paid?
end
```

### Migrations Can Reference Models

Direct model interaction in migrations is acceptable for data transformations.

```ruby
# CORRECT: Using models in migrations
class BackfillDisplayNames < ActiveRecord::Migration[7.1]
  def up
    User.find_each do |user|
      user.update_column(:display_name, "#{user.first_name} #{user.last_name}")
    end
  end
end

# Avoid raw SQL only when model behavior is needed
```

### Use update_all for Bulk Updates

Perform mass updates with `update_all` when no callbacks are needed.

```ruby
# WRONG: Loading all records for simple update
Card.where(board: old_board).each { |c| c.update!(board: new_board) }

# CORRECT: Direct SQL update
Card.where(board: old_board).update_all(board_id: new_board.id)
```

### Avoid Introspection Magic

For 2-3 cases, use explicit conditionals instead of metaprogramming.

```ruby
# WRONG: Clever metaprogramming for 3 states
STATES = %i[pending active completed]
STATES.each do |state|
  define_method("#{state}?") { status == state.to_s }
end

# CORRECT: Explicit methods
def pending?
  status == "pending"
end

def active?
  status == "active"
end

def completed?
  status == "completed"
end
```

### Use created_at for Initial Timestamps

Don't add extra timestamp columns when `created_at` suffices.

```ruby
# WRONG: Redundant timestamp
class Card < ApplicationRecord
  # started_at, created_at columns
end

# CORRECT: Use created_at for initial timestamp
class Card < ApplicationRecord
  alias_attribute :started_at, :created_at
end
```

### Implicit Format Responding

Template files automatically imply format support. Explicit `respond_to` is often unnecessary.

```ruby
# WRONG: Unnecessary respond_to
def show
  @card = Card.find(params[:id])
  respond_to do |format|
    format.html
    format.json
  end
end

# CORRECT: Templates handle it
def show
  @card = Card.find(params[:id])
end
# show.html.erb and show.json.jbuilder exist
