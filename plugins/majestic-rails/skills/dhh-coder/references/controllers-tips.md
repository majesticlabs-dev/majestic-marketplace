# Rails Controllers Tips Reference

Practical patterns for Rails controllers, routing, and request handling.

## Routing Patterns

### Authenticated Route Constraints

Create route constraints to serve different roots based on authentication:

```ruby
# config/initializers/routing_helpers.rb
class AuthenticatedConstraint
  def matches?(request)
    cookies = ActionDispatch::Cookies::CookieJar.build(request, request.cookies)
    if (session_token = cookies.signed[:session_token])
      return true if ::Session.find_by(id: session_token)
    end

    false
  rescue => _
    false
  end
end

module RoutingHelpers
  def authenticated(options = {}, &block)
    constraint = AuthenticatedConstraint.new
    constraints(constraint, &block)
  end
end

ActionDispatch::Routing::Mapper.include(RoutingHelpers)

# config/routes.rb
authenticated do
  root to: "workspaces#index", as: :workspace_root
end

root to: "pages#home"
```

### Direct Routes for External URLs

Define named routes for external URLs:

```ruby
# config/routes.rb
Rails.application.routes.draw do
  direct(:partner_website) { "https://www.rubycademy.com" }
end

# Usage
partner_website_url  # => "https://www.rubycademy.com"
```

## Controller Patterns

### Rate Limiting (Rails 8+)

Implement rate limiting with custom handlers:

```ruby
# app/controllers/api_controller.rb
class ApiController < ApplicationController
  rate_limit to: 5, within: 1.minute, by: :ip, with: -> { handle_rate_limit }

  private

  # Centralized rate-limit handler
  def handle_rate_limit(message: "Server is busy. Please try again later.")
    redirect_to busy_path(error: message)
  end
end

# app/controllers/users_controller.rb
class UsersController < ApiController
  rate_limit to: 1000, within: 10.seconds,
    by: -> { request.domain },
    with: -> { handle_rate_limit(message: "Too many signups on your domain.") },
    only: :create

  def create
    # ...
  end
end

# app/controllers/busy_controller.rb
class BusyController < ApplicationController
  def index
    render json: { error: params[:error] }, status: :too_many_requests
  end
end
```

### Strong Parameters with expect (Rails 8+)

Use `expect` instead of `require` + `permit`:

```ruby
# Rails < 8: Using require and permit
class PeopleController < ApplicationController
  def create
    Person.create(person_params)
  end

  private

  def person_params
    params.require(:person).permit(:name, :age)
  end
end

# Rails 8+: Using expect
class PeopleController < ApplicationController
  def create
    Person.create(person_params)
  end

  private

  def person_params
    params.expect(person: [:name, :age])
  end
end
```

### Custom Form Builders

Create domain-specific form helpers:

```ruby
# app/form_builders/support_ticket_form_builder.rb
class SupportTicketFormBuilder < ActionView::Helpers::FormBuilder
  PRIORITY_VALUES = [
    ["Low", 1],
    ["Medium", 2],
    ["High", 3]
  ].freeze

  def priority_field(name, options = {})
    @template.select(@object_name, name, PRIORITY_VALUES, options)
  end
end

# app/controllers/support_tickets_controller.rb
class SupportTicketsController < ApplicationController
  default_form_builder SupportTicketFormBuilder
end

# app/views/admin/support_tickets/edit.html.erb
<%= form_for(@support_ticket) do |builder| %>
  <%= builder.priority_field(:priority) %>
<% end %>
```

### Turbo Frame Request Variants

Detect Turbo Frame requests and serve appropriate templates:

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  before_action :turbo_frame_request_variant

  private

  def turbo_frame_request_variant
    request.variant = :turbo_frame if turbo_frame_request?
  end
end

# app/views/index.html+turbo_frame.erb
<%= turbo_frame_tag "page_handler" do %>
  <%= turbo_stream_action_tag(
    "append",
    target: "widgets",
    template: %(#{render @widgets})
  ) %>
  <%= turbo_stream_action_tag(
    "replace",
    target: "pager",
    template: %(#{render "pager", pagy: @pagy})
  ) %>
<% end %>

# app/views/index.turbo_stream.erb (standalone Turbo Stream)
<%= turbo_stream_action_tag(
  "append",
  target: "widgets",
  template: %(#{render @widgets})
) %>
<%= turbo_stream_action_tag(
  "replace",
  target: "pager",
  template: %(#{render "pager", pagy: @pagy})
) %>
```

## Form Object Pattern

Use form objects for complex multi-model forms:

```ruby
class JobPostForm
  include ActiveModel::Model

  attr_accessor :job_post

  delegate :title, :title=,
           :description, :description=,
           :commitment, :commitment=,
           :company, :company=,
           :user, :user=,
           :job_category_id, :job_category,
           to: :job_post

  validates :title, :company, :user, :job_category, presence: true
  validate :company_must_be_valid
  validate :user_must_be_valid

  def initialize(job_post = JobPost.new)
    @job_post = job_post
  end

  def company_name
    job_post.company&.name
  end

  def company_name=(name)
    job_post.company = Company.find_or_initialize_by(name: name)
  end

  def user_email
    job_post.user&.email
  end

  def user_email=(email)
    job_post.user = User.find_or_initialize_by(email: email)
  end

  def job_category_id=(id)
    job_post.job_category = JobCategory.find_by(id: id)
    if job_post.job_category.nil?
      errors.add(:job_category, "is not valid")
    end
  end

  def save
    return false unless valid?

    ActiveRecord::Base.transaction do
      job_post.company.save! if job_post.company&.changed?
      job_post.user.save! if job_post.user&.changed?
      job_post.save!
    end
    true
  rescue ActiveRecord::RecordInvalid => e
    e.record.errors.each do |attr, message|
      errors.add(attr, message)
    end
    false
  end

  def persisted?
    job_post.persisted?
  end

  def model_name
    job_post.model_name
  end
end
```

## User Deactivation Pattern

Properly deactivate users while preserving data integrity:

```ruby
class User < ApplicationRecord
  def deactivate
    transaction do
      memberships.without_direct_rooms.delete_all
      push_subscriptions.delete_all
      searches.delete_all

      update!(
        active: false,
        email_address: deactivated_email_address
      )
    end
  end

  private

  def deactivated_email_address
    # Preserve email format but make it unique and unusable
    email_address.gsub(/@/, "-deactivated-#{SecureRandom.uuid}@")
  end
end
```

## Force WWW Redirect

Redirect non-www requests to www subdomain:

```ruby
# config/routes.rb
# Force www redirect
# Start server with: rails s -p 3000 -b lvh.me
# Then go to http://www.lvh.me:3000

constraints(host: /^(?!www\.)/i) do
  match '(*any)' => redirect { |params, request|
    URI.parse(request.url).tap { |uri| uri.host = "www.#{uri.host}" }.to_s
  }
end
```

## Timezone Detection Pattern

Automatically detect and set user timezone from browser:

```ruby
# app/views/layouts/application.html.erb
<script type="module">
  import Cookies from "https://cdn.jsdelivr.net/npm/js-cookie@3.0.1/dist/js.cookie.min.mjs"
  const { timeZone } = new Intl.DateTimeFormat().resolvedOptions()
  Cookies.set("time_zone", timeZone, { expires: 365 })
</script>

# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  around_action :set_time_zone

  def set_time_zone
    Time.use_zone(cookies[:time_zone]) { yield }
  end
end
```

## Resource Scoping Concerns

37signals uses composable concerns to establish nested resource context.

### CardScoped

Establishes `@card` and `@board` context for card sub-resource controllers:

```ruby
# app/controllers/concerns/card_scoped.rb
module CardScoped
  extend ActiveSupport::Concern

  included do
    before_action :set_card
    before_action :set_board
  end

  private
    def set_card
      @card = Current.account.cards.find(params[:card_id])
    end

    def set_board
      @board = @card.board
    end

    def render_card_replacement
      render turbo_stream: turbo_stream.replace(@card)
    end
end

# Usage in sub-resource controller
class Cards::ClosuresController < ApplicationController
  include CardScoped

  def create
    @card.close(by: Current.user)
    render_card_replacement
  end
end
```

### BoardScoped

Sets up `@board` context and authorization:

```ruby
# app/controllers/concerns/board_scoped.rb
module BoardScoped
  extend ActiveSupport::Concern

  included do
    before_action :set_board
    before_action :ensure_board_access
  end

  private
    def set_board
      @board = Current.account.boards.find(params[:board_id])
    end

    def ensure_board_access
      head :forbidden unless Current.user.can_access?(@board)
    end
end
```

## Request Context Concerns

### CurrentRequest

Populates `Current` with HTTP metadata for use in models and jobs:

```ruby
# app/controllers/concerns/current_request.rb
module CurrentRequest
  extend ActiveSupport::Concern

  included do
    before_action :set_current_request_details
  end

  private
    def set_current_request_details
      Current.request_id = request.request_id
      Current.user_agent = request.user_agent
      Current.ip_address = request.remote_ip
      Current.request_method = request.method
      Current.referrer = request.referrer
    end
end

# app/models/current.rb
class Current < ActiveSupport::CurrentAttributes
  attribute :user, :session, :account
  attribute :request_id, :user_agent, :ip_address, :request_method, :referrer
end
```

### CurrentTimezone

Wraps requests in user's timezone and includes in ETags:

```ruby
# app/controllers/concerns/current_timezone.rb
module CurrentTimezone
  extend ActiveSupport::Concern

  included do
    around_action :set_time_zone
    etag { cookies[:time_zone] }
  end

  private
    def set_time_zone
      Time.use_zone(cookies[:time_zone] || "UTC") { yield }
    end
end
```

## Security Concerns

### Sec-Fetch-Site CSRF Protection (Rails 8+)

Modern CSRF protection using browser headers instead of tokens:

```ruby
# app/controllers/concerns/request_forgery_protection.rb
module RequestForgeryProtection
  extend ActiveSupport::Concern

  included do
    before_action :verify_request_origin, unless: :safe_request?
  end

  private
    def verify_request_origin
      return if request.headers["Sec-Fetch-Site"].in?(%w[same-origin same-site none])

      head :unprocessable_entity
    end

    def safe_request?
      request.get? || request.head?
    end
end
```

### BlockSearchEngineIndexing

Prevents crawlers from indexing private app content:

```ruby
# app/controllers/concerns/block_search_engine_indexing.rb
module BlockSearchEngineIndexing
  extend ActiveSupport::Concern

  included do
    after_action :set_robots_header
  end

  private
    def set_robots_header
      response.headers["X-Robots-Tag"] = "noindex, nofollow"
    end
end
```

## FilterScoped Pattern

Composable concern for complex query filtering with saved filters:

```ruby
# app/controllers/concerns/filter_scoped.rb
module FilterScoped
  extend ActiveSupport::Concern

  private
    def apply_filters(scope)
      scope = apply_status_filter(scope)
      scope = apply_assignee_filter(scope)
      scope = apply_label_filter(scope)
      scope
    end

    def apply_status_filter(scope)
      return scope unless params[:status].present?
      scope.where(status: params[:status])
    end

    def apply_assignee_filter(scope)
      return scope unless params[:assignee_id].present?
      scope.where(assignee_id: params[:assignee_id])
    end

    def apply_label_filter(scope)
      return scope unless params[:label_ids].present?
      scope.joins(:labels).where(labels: { id: params[:label_ids] })
    end

    def current_filter
      @current_filter ||= if params[:filter_id]
        Current.user.saved_filters.find(params[:filter_id])
      end
    end
end

# Usage
class CardsController < ApplicationController
  include FilterScoped

  def index
    @cards = apply_filters(@board.cards)
  end
end
```
