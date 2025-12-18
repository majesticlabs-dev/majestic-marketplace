# Webhook Patterns

Secure webhook delivery with SSRF protection, state machine lifecycle, and intelligent retry.

## SSRF Protection

Prevent Server-Side Request Forgery with upfront DNS resolution and IP blocking:

```ruby
class Webhook::SafeResolver
  BLOCKED_RANGES = [
    IPAddr.new("10.0.0.0/8"),
    IPAddr.new("172.16.0.0/12"),
    IPAddr.new("192.168.0.0/16"),
    IPAddr.new("127.0.0.0/8"),
    IPAddr.new("169.254.0.0/16"),
    IPAddr.new("::1/128"),
    IPAddr.new("fc00::/7")
  ].freeze

  def self.resolve(url)
    uri = URI.parse(url)
    addresses = Resolv.getaddresses(uri.host)

    addresses.each do |addr|
      ip = IPAddr.new(addr)
      raise SecurityError, "Blocked IP range" if BLOCKED_RANGES.any? { |range| range.include?(ip) }
    end

    { uri: uri, resolved_ip: addresses.first }
  end
end
```

## Webhook Model with State Machine

```ruby
class Webhook < ApplicationRecord
  belongs_to :account
  has_many :deliveries, class_name: "Webhook::Delivery"

  encrypts :secret

  before_create { self.secret = SecureRandom.hex(32) }

  enum :status, { active: 0, disabled: 1 }

  def signature_for(payload)
    OpenSSL::HMAC.hexdigest("SHA256", secret, payload)
  end
end
```

## Delivery Lifecycle

```ruby
class Webhook::Delivery < ApplicationRecord
  belongs_to :webhook

  enum :status, { pending: 0, in_progress: 1, completed: 2, errored: 3 }

  def execute!
    in_progress!

    resolved = Webhook::SafeResolver.resolve(webhook.url)
    payload = event_payload.to_json

    response = HTTP
      .headers(
        "Content-Type" => "application/json",
        "X-Webhook-Signature" => webhook.signature_for(payload)
      )
      .timeout(connect: 5, write: 5, read: 10)
      .post(resolved[:uri], body: payload)

    update!(
      status: response.status.success? ? :completed : :errored,
      response_code: response.status.code,
      response_body: response.body.to_s.truncate(10_000)
    )
  rescue => e
    update!(status: :errored, error_message: e.message)
  end
end
```

## Delinquency Tracking

Auto-disable webhooks after repeated failures:

```ruby
class Webhook < ApplicationRecord
  FAILURE_THRESHOLD = 10
  FAILURE_WINDOW = 1.hour

  def record_failure!
    increment!(:consecutive_failures)
    update!(last_failure_at: Time.current)

    if consecutive_failures >= FAILURE_THRESHOLD &&
       last_failure_at > FAILURE_WINDOW.ago
      disabled!
    end
  end

  def record_success!
    update!(consecutive_failures: 0) if consecutive_failures > 0
  end
end
```

## Two-Stage Dispatch

Separate event dispatch from delivery execution:

```ruby
class Webhook::DispatchJob < ApplicationJob
  def perform(event_type, payload)
    Current.account.webhooks.active.each do |webhook|
      delivery = webhook.deliveries.create!(
        event_type: event_type,
        event_payload: payload
      )
      Webhook::DeliveryJob.perform_later(delivery)
    end
  end
end

class Webhook::DeliveryJob < ApplicationJob
  retry_on HTTP::TimeoutError, wait: :polynomially_longer, attempts: 3

  def perform(delivery)
    delivery.execute!
    delivery.webhook.record_success!
  rescue => e
    delivery.webhook.record_failure!
    raise
  end
end
```

## Signature Verification (Recipient Side)

```ruby
class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def receive
    payload = request.raw_post
    signature = request.headers["X-Webhook-Signature"]

    unless secure_compare(expected_signature(payload), signature)
      head :unauthorized
      return
    end

    process_event(JSON.parse(payload))
    head :ok
  end

  private
    def expected_signature(payload)
      OpenSSL::HMAC.hexdigest("SHA256", ENV["WEBHOOK_SECRET"], payload)
    end

    def secure_compare(a, b)
      ActiveSupport::SecurityUtils.secure_compare(a.to_s, b.to_s)
    end
end
```

## Automatic Cleanup

```ruby
class Webhook::CleanupJob < ApplicationJob
  def perform
    Webhook::Delivery
      .where("created_at < ?", 7.days.ago)
      .in_batches
      .delete_all
  end
end

# config/recurring.yml
cleanup_webhook_deliveries:
  class: Webhook::CleanupJob
  schedule: every 4 hours
```
