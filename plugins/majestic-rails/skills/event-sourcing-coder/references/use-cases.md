# Event Pattern Use Cases

## Table of Contents
- [Activity Feeds](#activity-feeds)
- [Audit Trails](#audit-trails)
- [Webhook Delivery](#webhook-delivery)
- [Automation Rules](#automation-rules)
- [Analytics & Metrics](#analytics--metrics)
- [Real-Time Updates](#real-time-updates)

## Activity Feeds

### Basic Activity Feed

```ruby
# app/components/activity_feed_component.rb
class ActivityFeedComponent < ViewComponent::Base
  def initialize(events:, show_resource: true)
    @events = events
    @show_resource = show_resource
  end

  private

  attr_reader :events, :show_resource
end
```

```erb
<%# app/components/activity_feed_component.html.erb %>
<div class="activity-feed">
  <% events.each do |event| %>
    <%= render ActivityItemComponent.new(event: event, show_resource: show_resource) %>
  <% end %>
</div>
```

### Activity Item Component

```ruby
# app/components/activity_item_component.rb
class ActivityItemComponent < ViewComponent::Base
  def initialize(event:, show_resource: true)
    @event = event
    @show_resource = show_resource
  end

  def description
    I18n.t(
      "events.#{event.eventable_type.underscore}.#{event.action}",
      actor: event.actor.name,
      resource: resource_name,
      **event.metadata.symbolize_keys
    )
  end

  def icon
    case event.action
    when "created" then "plus-circle"
    when "closed" then "check-circle"
    when "commented" then "message-circle"
    when "assigned" then "user-plus"
    else "activity"
    end
  end

  private

  attr_reader :event, :show_resource

  def resource_name
    event.eventable.try(:title) || event.eventable.try(:name) || "Item"
  end
end
```

### Localization

```yaml
# config/locales/events.en.yml
en:
  events:
    issue:
      created: "%{actor} created issue %{resource}"
      assigned: "%{actor} assigned %{resource} to %{assignee}"
      status_changed: "%{actor} changed status from %{from} to %{to}"
      commented: "%{actor} commented on %{resource}"
      closed: "%{actor} closed %{resource}"
    project:
      created: "%{actor} created project %{resource}"
      member_added: "%{actor} added %{member} to %{resource}"
      archived: "%{actor} archived %{resource}"
```

### Grouped Activity Feed

```ruby
class GroupedActivityFeed
  def initialize(events)
    @events = events
  end

  def grouped_by_day
    @events.group_by { |e| e.created_at.to_date }
           .transform_values { |events| group_similar(events) }
  end

  private

  def group_similar(events)
    events.chunk_while { |a, b| similar?(a, b) }
          .map { |group| ActivityGroup.new(group) }
  end

  def similar?(a, b)
    a.action == b.action &&
      a.actor_id == b.actor_id &&
      (b.created_at - a.created_at) < 5.minutes
  end
end

class ActivityGroup
  attr_reader :events

  def initialize(events)
    @events = events
  end

  def primary_event
    events.first
  end

  def count
    events.size
  end

  def collapsed?
    count > 1
  end
end
```

## Audit Trails

### Compliance Audit Log

```ruby
# app/models/events/inboxes/audit_log.rb
module Events::Inboxes
  class AuditLog < Base
    AUDITABLE_ACTIONS = %w[
      created updated deleted
      permission_changed access_granted access_revoked
      login logout password_changed
    ].freeze

    private

    def should_process?
      action.in?(AUDITABLE_ACTIONS)
    end

    def handle
      AuditEntry.create!(
        event: event,
        actor: actor,
        actor_email: actor.email,
        actor_ip: metadata["ip_address"],
        action: action,
        resource_type: event.eventable_type,
        resource_id: event.eventable_id,
        resource_snapshot: build_snapshot,
        occurred_at: event.created_at
      )
    end

    def build_snapshot
      {
        resource_attributes: eventable.attributes,
        metadata: metadata,
        request_id: metadata["request_id"]
      }
    end
  end
end
```

### Audit Query Interface

```ruby
class AuditQuery
  def initialize(scope = AuditEntry.all)
    @scope = scope
  end

  def by_actor(user)
    @scope = @scope.where(actor: user)
    self
  end

  def by_resource(resource)
    @scope = @scope.where(
      resource_type: resource.class.name,
      resource_id: resource.id
    )
    self
  end

  def by_action(action)
    @scope = @scope.where(action: action)
    self
  end

  def in_period(start_date, end_date)
    @scope = @scope.where(occurred_at: start_date..end_date)
    self
  end

  def results
    @scope.order(occurred_at: :desc)
  end

  def to_csv
    CSV.generate do |csv|
      csv << %w[timestamp actor action resource details]
      results.find_each do |entry|
        csv << [
          entry.occurred_at.iso8601,
          entry.actor_email,
          entry.action,
          "#{entry.resource_type}##{entry.resource_id}",
          entry.resource_snapshot.to_json
        ]
      end
    end
  end
end
```

## Webhook Delivery

### Webhook Inbox

```ruby
# app/models/events/inboxes/webhook_delivery.rb
module Events::Inboxes
  class WebhookDelivery < Base
    private

    def should_process?
      webhooks.any?
    end

    def handle
      webhooks.each do |webhook|
        WebhookDeliveryJob.perform_later(
          webhook_id: webhook.id,
          payload: build_payload
        )
      end
    end

    def webhooks
      @webhooks ||= eventable.project.webhooks.active.for_event(action)
    end

    def build_payload
      {
        event: action,
        timestamp: event.created_at.iso8601,
        resource: {
          type: event.eventable_type,
          id: event.eventable_id,
          url: resource_url
        },
        actor: {
          id: actor.id,
          name: actor.name,
          email: actor.email
        },
        data: metadata
      }
    end

    def resource_url
      Rails.application.routes.url_helpers.polymorphic_url(eventable)
    end
  end
end
```

### Webhook Delivery Job

```ruby
class WebhookDeliveryJob < ApplicationJob
  queue_as :webhooks
  retry_on Faraday::Error, wait: :polynomially_longer, attempts: 5

  def perform(webhook_id:, payload:)
    webhook = Webhook.find(webhook_id)
    delivery = webhook.deliveries.create!(payload: payload, status: "pending")

    response = deliver(webhook, payload)

    delivery.update!(
      status: "delivered",
      response_code: response.status,
      response_body: response.body.truncate(10_000),
      delivered_at: Time.current
    )
  rescue Faraday::Error => e
    delivery&.update!(
      status: "failed",
      error_message: e.message
    )
    raise
  end

  private

  def deliver(webhook, payload)
    connection.post(webhook.url) do |req|
      req.headers["Content-Type"] = "application/json"
      req.headers["X-Webhook-Signature"] = sign(payload, webhook.secret)
      req.body = payload.to_json
    end
  end

  def sign(payload, secret)
    OpenSSL::HMAC.hexdigest("SHA256", secret, payload.to_json)
  end

  def connection
    @connection ||= Faraday.new do |f|
      f.options.timeout = 30
      f.options.open_timeout = 10
    end
  end
end
```

## Automation Rules

### Rule Engine

```ruby
# app/models/automation_rule.rb
class AutomationRule < ApplicationRecord
  belongs_to :project

  serialize :conditions, coder: JSON
  serialize :actions, coder: JSON

  scope :active, -> { where(active: true) }
  scope :for_event, ->(action) { where("trigger_events @> ?", [action].to_json) }

  def matches?(event)
    conditions.all? { |condition| evaluate_condition(condition, event) }
  end

  def execute!(event)
    actions.each { |action_config| execute_action(action_config, event) }
  end

  private

  def evaluate_condition(condition, event)
    case condition["type"]
    when "metadata_equals"
      event.metadata[condition["field"]] == condition["value"]
    when "metadata_contains"
      event.metadata[condition["field"]].to_s.include?(condition["value"])
    when "actor_is"
      event.actor_id == condition["user_id"]
    when "label_present"
      event.eventable.labels.exists?(name: condition["label"])
    else
      true
    end
  end

  def execute_action(action_config, event)
    case action_config["type"]
    when "assign"
      event.eventable.update!(assignee_id: action_config["user_id"])
    when "add_label"
      event.eventable.labels << Label.find(action_config["label_id"])
    when "change_status"
      event.eventable.update!(status: action_config["status"])
    when "send_notification"
      AutomationMailer.notification(
        user_id: action_config["user_id"],
        message: action_config["message"],
        event: event
      ).deliver_later
    end
  end
end
```

### Automation Inbox

```ruby
module Events::Inboxes
  class AutomationRules < Base
    private

    def should_process?
      matching_rules.any?
    end

    def handle
      matching_rules.each do |rule|
        Rails.logger.info "[Automation] Executing rule '#{rule.name}' for event ##{event.id}"
        rule.execute!(event)

        AutomationExecution.create!(
          rule: rule,
          event: event,
          executed_at: Time.current
        )
      end
    end

    def matching_rules
      @matching_rules ||= eventable.project
        .automation_rules
        .active
        .for_event(action)
        .select { |rule| rule.matches?(event) }
    end
  end
end
```

## Analytics & Metrics

### Event Analytics Inbox

```ruby
module Events::Inboxes
  class Analytics < Base
    private

    def should_process?
      true  # Track all events
    end

    def handle
      # Send to analytics service
      AnalyticsService.track(
        event: "domain_event",
        properties: {
          action: action,
          resource_type: event.eventable_type,
          resource_id: event.eventable_id,
          actor_id: actor.id,
          project_id: eventable.try(:project_id),
          metadata: metadata
        },
        timestamp: event.created_at
      )

      # Update real-time counters
      update_counters
    end

    def update_counters
      # Increment daily counters
      key = "events:#{event.eventable_type}:#{action}:#{Date.current}"
      Redis.current.incr(key)
      Redis.current.expire(key, 90.days)

      # Update project metrics
      if eventable.respond_to?(:project_id)
        ProjectMetrics.increment(eventable.project_id, action)
      end
    end
  end
end
```

### Metrics Dashboard

```ruby
class EventMetrics
  def initialize(project:, period: 30.days)
    @project = project
    @period = period
  end

  def summary
    {
      total_events: events.count,
      events_by_action: events.group(:action).count,
      events_by_day: events.group_by_day(:created_at).count,
      most_active_users: most_active_users,
      busiest_hours: busiest_hours
    }
  end

  def events
    @events ||= Event
      .joins("INNER JOIN issues ON events.eventable_type = 'Issue' AND events.eventable_id = issues.id")
      .where(issues: { project_id: @project.id })
      .where("events.created_at > ?", @period.ago)
  end

  def most_active_users
    events.group(:actor_id)
          .order("count_all DESC")
          .limit(10)
          .count
          .map { |id, count| { user: User.find(id), count: count } }
  end

  def busiest_hours
    events.group_by_hour_of_day(:created_at, time_zone: @project.timezone)
          .count
  end
end
```

## Real-Time Updates

### Turbo Streams Integration

```ruby
module Events::Inboxes
  class TurboStreamBroadcast < Base
    private

    def should_process?
      action.in?(%w[created commented status_changed])
    end

    def handle
      broadcast_to_issue_channel
      broadcast_to_project_channel
    end

    def broadcast_to_issue_channel
      Turbo::StreamsChannel.broadcast_prepend_to(
        eventable,
        target: "activity-feed",
        partial: "events/event",
        locals: { event: event }
      )
    end

    def broadcast_to_project_channel
      Turbo::StreamsChannel.broadcast_update_to(
        eventable.project,
        target: dom_id(eventable, :card),
        partial: "issues/card",
        locals: { issue: eventable }
      )
    end
  end
end
```

### ActionCable Notifications

```ruby
module Events::Inboxes
  class RealtimeNotifications < Base
    private

    def should_process?
      recipients.any?
    end

    def handle
      recipients.each do |user|
        NotificationChannel.broadcast_to(user, {
          type: "event",
          action: action,
          resource_type: event.eventable_type,
          resource_id: event.eventable_id,
          actor: { id: actor.id, name: actor.name, avatar: actor.avatar_url },
          message: notification_message,
          url: resource_url,
          timestamp: event.created_at.iso8601
        })
      end
    end

    def recipients
      @recipients ||= begin
        users = case action
        when "assigned" then [eventable.assignee]
        when "commented", "mentioned" then eventable.subscribers
        else []
        end
        users.compact - [actor]
      end
    end

    def notification_message
      I18n.t("notifications.#{event.eventable_type.underscore}.#{action}",
        actor: actor.name,
        resource: eventable.title
      )
    end

    def resource_url
      Rails.application.routes.url_helpers.polymorphic_path(eventable)
    end
  end
end
```

### Server-Sent Events (SSE)

```ruby
class EventStreamController < ApplicationController
  include ActionController::Live

  def show
    response.headers["Content-Type"] = "text/event-stream"
    response.headers["Cache-Control"] = "no-cache"

    sse = SSE.new(response.stream, event: "event")
    listener = EventListener.new(current_user)

    listener.subscribe do |event|
      sse.write(event.as_json)
    end
  rescue IOError
    # Client disconnected
  ensure
    listener.unsubscribe
    response.stream.close
  end
end

class EventListener
  def initialize(user)
    @user = user
    @redis = Redis.new
  end

  def subscribe(&block)
    @redis.subscribe("events:user:#{@user.id}") do |on|
      on.message do |_channel, message|
        block.call(JSON.parse(message))
      end
    end
  end

  def unsubscribe
    @redis.unsubscribe
  end
end
```
