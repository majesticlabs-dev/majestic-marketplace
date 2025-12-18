# Path-Based Multi-Tenancy

37signals approach: path-based tenancy with shared database. URLs follow `/1234567/boards/123` pattern.

## Why Path-Based (Not Subdomains)

- No wildcard DNS/SSL setup
- Simpler local development
- No `/etc/hosts` hacking

## Middleware Tenant Extraction

```ruby
# lib/account_slug/extractor.rb
class AccountSlug::Extractor
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)

    if match = request.path_info.match(%r{^/(\d+)(.*)})
      account_id, remaining_path = match.captures
      env["fizzy.external_account_id"] = account_id
      env["SCRIPT_NAME"] = "/#{account_id}"
      env["PATH_INFO"] = remaining_path.presence || "/"
    end

    @app.call(env)
  end
end
```

## Current Attributes

```ruby
class Current < ActiveSupport::CurrentAttributes
  attribute :session, :user, :identity, :account
end

# Set in ApplicationController
class ApplicationController < ActionController::Base
  before_action :set_current_account

  private
    def set_current_account
      if account_id = request.env["fizzy.external_account_id"]
        Current.account = Account.find(account_id)
      end
    end
end
```

## Defense-in-Depth Scoping

Never use `Model.find(id)` directly. Always scope through tenant:

```ruby
# CORRECT: Scoped through account
Current.account.comments.find(params[:id])
Current.account.boards.find(params[:board_id])

# WRONG: Global lookup
Comment.find(params[:id])
```

## Multi-Tenant Cookie Scoping

Scope cookies to account path to prevent cross-tenant token collisions:

```ruby
cookies.signed[:session_token] = {
  value: session.token,
  path: "/#{Current.account.id}",
  httponly: true,
  secure: Rails.env.production?
}
```

## Background Job Tenant Preservation

```ruby
module TenantAwareJob
  extend ActiveSupport::Concern

  included do
    attr_accessor :account_gid

    before_enqueue { self.account_gid = Current.account&.to_global_id }
    before_perform { Current.account = GlobalID::Locator.locate(account_gid) }
  end
end

class NotificationJob < ApplicationJob
  include TenantAwareJob

  def perform(comment)
    # Current.account is restored
    comment.notify_subscribers
  end
end
```

## Routes with Account Scope

```ruby
# config/routes.rb
Rails.application.routes.draw do
  scope "/:account_id" do
    resources :boards do
      resources :cards
    end
    resources :comments
  end

  # Non-tenanted routes
  resource :session
  resources :magic_links
end
```

## Development Default Tenant

```ruby
# config/environments/development.rb
config.after_initialize do
  Current.account ||= Account.first if Account.table_exists?
end
```
