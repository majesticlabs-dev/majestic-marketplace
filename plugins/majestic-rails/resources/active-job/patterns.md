# Active Job Patterns Reference

## Multi-Step Workflows (Continuable Pattern)

For complex jobs with multiple sequential steps, use the Continuable pattern. Each step updates model state, allowing jobs to resume from failures.

### Basic Continuable Job

```ruby
class ProcessCloudJob < ApplicationJob
  queue_as :default

  # Define steps as isolated units
  STEPS = %i[
    analyze_image
    generate_cards
    notify_participant
  ].freeze

  def perform(cloud_id)
    @cloud = Cloud.find(cloud_id)

    STEPS.each do |step|
      next if step_completed?(step)

      send(step)
      mark_step_completed(step)
    end
  rescue => err
    handle_failure(err)
    raise
  end

  private

  def analyze_image
    return if @cloud.analyzed?

    result = Cloud::ImageAnalyzer.new(@cloud).analyze
    @cloud.update!(
      state: :analyzed,
      analysis_data: result
    )
  end

  def generate_cards
    return if @cloud.generated?

    Cloud::CardGenerator.new(@cloud).generate
    @cloud.update!(state: :generated)
  end

  def notify_participant
    return if @cloud.notification_sent?

    CloudMailer.ready(@cloud).deliver_later
    @cloud.update!(notification_sent_at: Time.current)
  end

  def step_completed?(step)
    case step
    when :analyze_image then @cloud.analyzed? || @cloud.generated?
    when :generate_cards then @cloud.generated?
    when :notify_participant then @cloud.notification_sent?
    else false
    end
  end

  def mark_step_completed(step)
    Rails.logger.info("[#{self.class}] Completed step: #{step}")
  end

  def handle_failure(error)
    Rails.error.report(error, handled: true)
    @cloud.update!(
      state: :failed,
      failure_reason: error.message
    )
  end
end
```

### State-Driven Steps

Use model state to determine which steps to run:

```ruby
class ImportDataJob < ApplicationJob
  def perform(import_id)
    @import = DataImport.find(import_id)

    case @import.state
    when "pending"
      validate_and_continue
    when "validated"
      process_and_continue
    when "processed"
      finalize
    end
  end

  private

  def validate_and_continue
    if @import.validate_data!
      @import.update!(state: :validated)
      ImportDataJob.perform_later(@import.id)  # Re-enqueue for next step
    else
      @import.update!(state: :validation_failed)
    end
  end

  def process_and_continue
    @import.process_rows!
    @import.update!(state: :processed)
    ImportDataJob.perform_later(@import.id)
  end

  def finalize
    @import.update!(state: :completed, completed_at: Time.current)
    ImportMailer.completed(@import).deliver_later
  end
end
```

### With Progress Tracking

```ruby
class BulkProcessJob < ApplicationJob
  def perform(batch_id)
    @batch = Batch.find(batch_id)
    @batch.update!(state: :processing)

    @batch.items.pending.find_each do |item|
      process_item(item)
      update_progress
    end

    @batch.update!(state: :completed, completed_at: Time.current)
  rescue => err
    @batch.update!(state: :failed, error_message: err.message)
    raise
  end

  private

  def process_item(item)
    item.process!
    item.update!(state: :processed)
  rescue => err
    item.update!(state: :failed, error_message: err.message)
    # Continue with next item
  end

  def update_progress
    processed = @batch.items.processed.count
    total = @batch.items.count
    @batch.update!(progress: (processed.to_f / total * 100).round)

    # Broadcast progress for live updates
    @batch.broadcast_replace_to(
      @batch.user,
      :batches,
      partial: "batches/progress"
    )
  end
end
```

### Continuable with Checkpoints

For very long jobs, checkpoint progress to database:

```ruby
class LongRunningJob < ApplicationJob
  CHECKPOINT_INTERVAL = 100

  def perform(task_id)
    @task = Task.find(task_id)
    @processed = @task.checkpoint_data["processed"] || 0

    items_to_process.each_with_index do |item, index|
      process_item(item)
      @processed += 1

      checkpoint! if (index + 1) % CHECKPOINT_INTERVAL == 0
    end

    @task.update!(state: :completed)
  end

  private

  def items_to_process
    # Resume from where we left off
    @task.items.offset(@processed)
  end

  def checkpoint!
    @task.update!(
      checkpoint_data: { processed: @processed },
      checkpoint_at: Time.current
    )
    Rails.logger.info("[#{self.class}] Checkpoint: #{@processed} items processed")
  end
end
```

## Testing Jobs

### Unit Testing (Minitest)

```ruby
# test/jobs/send_welcome_email_job_test.rb
class SendWelcomeEmailJobTest < ActiveJob::TestCase
  test "sends welcome email" do
    user = users(:new_user)

    assert_enqueued_with(job: SendWelcomeEmailJob, args: [user]) do
      SendWelcomeEmailJob.perform_later(user)
    end
  end

  test "performs job successfully" do
    user = users(:new_user)

    assert_emails 1 do
      SendWelcomeEmailJob.perform_now(user)
    end
  end
end
```

### Testing with RSpec

```ruby
# spec/jobs/send_welcome_email_job_spec.rb
RSpec.describe SendWelcomeEmailJob, type: :job do
  include ActiveJob::TestHelper

  let(:user) { create(:user) }

  it "enqueues the job" do
    expect {
      described_class.perform_later(user.id)
    }.to have_enqueued_job(described_class).with(user.id)
  end

  it "sends welcome email" do
    expect {
      described_class.perform_now(user.id)
    }.to change { ActionMailer::Base.deliveries.count }.by(1)
  end

  it "retries on network errors" do
    allow(ExternalApi).to receive(:call).and_raise(Net::OpenTimeout)

    expect {
      described_class.perform_now(user.id)
    }.to have_been_enqueued.at_least(:once)
  end
end
```

## Job Logging Pattern

```ruby
module JobLogging
  extend ActiveSupport::Concern

  included do
    around_perform :log_job_execution
  end

  private

  def log_job_execution
    start_time = Time.current
    Rails.logger.info("[#{self.class.name}] Starting job #{job_id}")

    yield

    duration = Time.current - start_time
    Rails.logger.info("[#{self.class.name}] Completed in #{duration.round(2)}s")
  rescue StandardError => e
    Rails.logger.error("[#{self.class.name}] Failed: #{e.message}")
    raise
  end
end

class ApplicationJob < ActiveJob::Base
  include JobLogging
end
```

## Idempotent Job Design

Jobs should be safe to run multiple times:

```ruby
class SyncUserToExternalJob < ApplicationJob
  def perform(user_id)
    user = User.find(user_id)

    # Idempotent: Check before creating
    return if ExternalService.exists?(user.external_id)

    ExternalService.create(user.attributes)
  end
end

class ProcessPaymentJob < ApplicationJob
  def perform(payment_id)
    payment = Payment.find(payment_id)

    # Use database constraints for idempotency
    payment.with_lock do
      return if payment.processed?

      PaymentProcessor.charge(payment)
      payment.update!(processed_at: Time.current)
    end
  end
end
```
