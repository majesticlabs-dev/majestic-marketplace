# Inbox Pattern

## Table of Contents
- [Inbox Architecture](#inbox-architecture)
- [Inbox Registry](#inbox-registry)
- [Error Handling](#error-handling)
- [Conditional Processing](#conditional-processing)
- [Testing Inboxes](#testing-inboxes)

## Inbox Architecture

### Base Inbox Class

```ruby
# app/models/events/inboxes/base.rb
module Events::Inboxes
  class Base
    attr_reader :event

    delegate :eventable, :actor, :action, :metadata, to: :event

    def initialize(event)
      @event = event
    end

    def process
      return unless should_process?

      Rails.logger.info "[#{self.class.name}] Processing #{event.action} event ##{event.id}"
      handle
    rescue StandardError => e
      handle_error(e)
    end

    private

    def should_process?
      raise NotImplementedError, "#{self.class} must implement #should_process?"
    end

    def handle
      raise NotImplementedError, "#{self.class} must implement #handle"
    end

    def handle_error(error)
      Rails.logger.error "[#{self.class.name}] Error processing event ##{event.id}: #{error.message}"
      Sentry.capture_exception(error, extra: { event_id: event.id })
    end
  end
end
```

### Specialized Inbox Types

```ruby
# Inbox that processes specific actions
module Events::Inboxes
  class ActionFilteredBase < Base
    class << self
      attr_accessor :processable_actions
    end

    def self.processes(*actions)
      self.processable_actions = actions.map(&:to_s)
    end

    private

    def should_process?
      self.class.processable_actions.include?(action)
    end
  end
end

# Usage
module Events::Inboxes
  class EmailNotifications < ActionFilteredBase
    processes :assigned, :commented, :mentioned

    private

    def handle
      # Only called for assigned, commented, or mentioned events
    end
  end
end
```

### Inbox with Configuration

```ruby
module Events::Inboxes
  class WebhookDelivery < Base
    def initialize(event, config: nil)
      super(event)
      @config = config || default_config
    end

    private

    def should_process?
      @config[:enabled] && webhook_url.present?
    end

    def handle
      WebhookDeliveryJob.perform_later(
        url: webhook_url,
        payload: build_payload,
        event_id: event.id
      )
    end

    def webhook_url
      eventable.project.webhook_url
    end

    def build_payload
      {
        event: action,
        resource_type: event.eventable_type,
        resource_id: event.eventable_id,
        actor: { id: actor.id, name: actor.name },
        timestamp: event.created_at.iso8601,
        data: metadata
      }
    end

    def default_config
      { enabled: true }
    end
  end
end
```

## Inbox Registry

### Dynamic Inbox Discovery

```ruby
# app/models/events/inbox_registry.rb
module Events
  class InboxRegistry
    class << self
      def inboxes
        @inboxes ||= []
      end

      def register(inbox_class, priority: 10)
        inboxes << { class: inbox_class, priority: priority }
        inboxes.sort_by! { |i| i[:priority] }
      end

      def for_event(event)
        inboxes
          .map { |i| i[:class] }
          .select { |klass| klass.handles?(event) }
      end
    end
  end
end

# Base class with registration
module Events::Inboxes
  class Base
    class << self
      def inherited(subclass)
        super
        Events::InboxRegistry.register(subclass) unless subclass.abstract?
      end

      def abstract?
        false
      end

      def handles?(event)
        true  # Override in subclasses
      end

      def priority
        10
      end
    end
  end
end
```

### Event-Type Specific Inboxes

```ruby
# Inbox that only handles Issue events
module Events::Inboxes
  class IssueSlackNotifier < Base
    class << self
      def handles?(event)
        event.eventable_type == "Issue"
      end
    end

    private

    def issue
      eventable
    end

    def should_process?
      action.in?(%w[created closed]) && issue.project.slack_enabled?
    end

    def handle
      SlackNotifier.notify(
        channel: issue.project.slack_channel,
        message: slack_message
      )
    end

    def slack_message
      case action
      when "created"
        "New issue: #{issue.title} by #{actor.name}"
      when "closed"
        "Issue closed: #{issue.title} by #{actor.name}"
      end
    end
  end
end
```

## Error Handling

### Retry with Exponential Backoff

```ruby
# app/jobs/event/broadcast_job.rb
class Event::BroadcastJob < ApplicationJob
  queue_as :events
  retry_on StandardError, wait: :polynomially_longer, attempts: 5

  def perform(event)
    Events::InboxRegistry.for_event(event).each do |inbox_class|
      process_inbox(event, inbox_class)
    end
  end

  private

  def process_inbox(event, inbox_class)
    inbox_class.new(event).process
  rescue StandardError => e
    # Log but don't fail the whole job
    Rails.logger.error "[BroadcastJob] #{inbox_class} failed: #{e.message}"
    track_failure(event, inbox_class, e)
  end

  def track_failure(event, inbox_class, error)
    EventInboxFailure.create!(
      event: event,
      inbox_class: inbox_class.name,
      error_message: error.message,
      error_backtrace: error.backtrace&.first(10)
    )
  end
end
```

### Inbox-Specific Job Isolation

```ruby
# Each inbox runs in its own job for isolation
class Event::BroadcastJob < ApplicationJob
  def perform(event)
    Events::InboxRegistry.for_event(event).each do |inbox_class|
      Event::ProcessInboxJob.perform_later(event, inbox_class.name)
    end
  end
end

class Event::ProcessInboxJob < ApplicationJob
  queue_as :events
  retry_on StandardError, wait: :polynomially_longer, attempts: 3

  def perform(event, inbox_class_name)
    inbox_class = inbox_class_name.constantize
    inbox_class.new(event).process
  end
end
```

### Dead Letter Queue

```ruby
class Event::ProcessInboxJob < ApplicationJob
  discard_on ActiveJob::DeserializationError

  retry_on StandardError, wait: :polynomially_longer, attempts: 3 do |job, error|
    # After all retries exhausted, move to dead letter queue
    DeadLetterQueue.add(
      job_class: job.class.name,
      arguments: job.arguments,
      error: error.message,
      failed_at: Time.current
    )
  end
end
```

## Conditional Processing

### Feature Flags

```ruby
module Events::Inboxes
  class BetaFeatureNotifier < Base
    private

    def should_process?
      Flipper.enabled?(:beta_notifications, actor) &&
        action.in?(%w[new_feature_available])
    end
  end
end
```

### User Preferences

```ruby
module Events::Inboxes
  class EmailNotifications < Base
    private

    def should_process?
      action.in?(notifiable_actions) &&
        recipients.any?
    end

    def recipients
      @recipients ||= potential_recipients.select do |user|
        user.notification_preferences.email_enabled_for?(action)
      end
    end

    def potential_recipients
      case action
      when "assigned"
        [eventable.assignee].compact
      when "commented"
        eventable.subscribers - [actor]
      when "mentioned"
        mentioned_users
      else
        []
      end
    end
  end
end
```

### Rate Limiting

```ruby
module Events::Inboxes
  class SlackNotifications < Base
    RATE_LIMIT = 10.per(1.minute)

    private

    def should_process?
      action.in?(notifiable_actions) && within_rate_limit?
    end

    def within_rate_limit?
      key = "slack_notifications:#{eventable.project_id}"
      Kredis.counter(key, expires_in: 1.minute).increment < RATE_LIMIT
    end
  end
end
```

### Quiet Hours

```ruby
module Events::Inboxes
  class PushNotifications < Base
    private

    def should_process?
      action.in?(urgent_actions) || !in_quiet_hours?
    end

    def in_quiet_hours?
      # Check each recipient's timezone
      recipients.all? do |user|
        hour = Time.current.in_time_zone(user.timezone).hour
        hour >= 22 || hour < 8
      end
    end

    def urgent_actions
      %w[security_alert system_down]
    end
  end
end
```

## Testing Inboxes

### Unit Testing

```ruby
RSpec.describe Events::Inboxes::EmailNotifications do
  let(:event) { create(:event, action: "assigned") }
  let(:inbox) { described_class.new(event) }

  describe "#should_process?" do
    context "when action is notifiable" do
      it "returns true" do
        expect(inbox.send(:should_process?)).to be true
      end
    end

    context "when action is not notifiable" do
      let(:event) { create(:event, action: "viewed") }

      it "returns false" do
        expect(inbox.send(:should_process?)).to be false
      end
    end
  end

  describe "#process" do
    context "when should process" do
      before do
        allow(inbox).to receive(:should_process?).and_return(true)
      end

      it "calls handle" do
        expect(inbox).to receive(:handle)
        inbox.process
      end
    end

    context "when should not process" do
      before do
        allow(inbox).to receive(:should_process?).and_return(false)
      end

      it "does not call handle" do
        expect(inbox).not_to receive(:handle)
        inbox.process
      end
    end
  end
end
```

### Integration Testing

```ruby
RSpec.describe "Event Broadcasting" do
  let(:issue) { create(:issue) }
  let(:user) { create(:user) }

  it "processes event through all inboxes" do
    expect(Events::Inboxes::EmailNotifications).to receive(:new).and_call_original
    expect(Events::Inboxes::SlackNotifications).to receive(:new).and_call_original

    perform_enqueued_jobs do
      issue.record_event!(action: "created", actor: user)
    end
  end

  it "sends email notification for assignment" do
    assignee = create(:user)
    issue.update!(assignee: assignee)

    expect {
      perform_enqueued_jobs do
        issue.record_event!(action: "assigned", actor: user)
      end
    }.to have_enqueued_mail(IssueMailer, :assigned)
      .with(a_hash_including(user: assignee))
  end
end
```

### Testing Error Handling

```ruby
RSpec.describe Events::Inboxes::WebhookDelivery do
  let(:event) { create(:event) }
  let(:inbox) { described_class.new(event) }

  describe "error handling" do
    before do
      allow(inbox).to receive(:should_process?).and_return(true)
      allow(inbox).to receive(:handle).and_raise(StandardError, "API timeout")
    end

    it "logs the error" do
      expect(Rails.logger).to receive(:error).with(/API timeout/)
      inbox.process
    end

    it "reports to Sentry" do
      expect(Sentry).to receive(:capture_exception)
      inbox.process
    end

    it "does not re-raise" do
      expect { inbox.process }.not_to raise_error
    end
  end
end
```
