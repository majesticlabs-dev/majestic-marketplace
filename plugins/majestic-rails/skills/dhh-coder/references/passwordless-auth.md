# Passwordless Authentication

37signals magic link authentication: no passwords to store, reset, or manage.

## Identity Model

Global identity separate from per-account users (one person, many accounts):

```ruby
class Identity < ApplicationRecord
  has_many :sessions
  has_many :magic_links
  has_many :users

  normalizes :email, with: ->(e) { e.strip.downcase }
  validates :email, presence: true, uniqueness: true,
    format: { with: URI::MailTo::EMAIL_REGEXP }
end
```

## Magic Link Model

```ruby
class MagicLink < ApplicationRecord
  CODE_LENGTH = 6
  EXPIRATION_TIME = 15.minutes

  belongs_to :identity

  enum :purpose, { sign_in: 0, sign_up: 1 }

  before_create :generate_code

  scope :stale, -> { where("created_at < ?", EXPIRATION_TIME.ago) }
  scope :valid, -> { where("created_at >= ?", EXPIRATION_TIME.ago) }

  def expired?
    created_at < EXPIRATION_TIME.ago
  end

  private
    def generate_code
      loop do
        self.code = SecureRandom.random_number(10**CODE_LENGTH).to_s.rjust(CODE_LENGTH, "0")
        break unless MagicLink.exists?(code: code, purpose: purpose)
      end
    end
end
```

## Session Model

```ruby
class Session < ApplicationRecord
  belongs_to :identity

  before_create { self.token = SecureRandom.urlsafe_base64(32) }

  def self.authenticate(token)
    find_by(token: token)
  end
end
```

## Authentication Concern

```ruby
module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    helper_method :authenticated?, :current_user
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
    end
  end

  private
    def authenticated?
      current_session.present?
    end

    def current_user
      Current.user
    end

    def current_session
      @current_session ||= find_session_from_cookie || find_session_from_bearer
    end

    def find_session_from_cookie
      token = cookies.signed[:session_token]
      Session.authenticate(token)&.tap { |s| set_current_from_session(s) }
    end

    def find_session_from_bearer
      token = request.authorization&.delete_prefix("Bearer ")
      Session.authenticate(token)&.tap { |s| set_current_from_session(s) }
    end

    def set_current_from_session(session)
      Current.session = session
      Current.identity = session.identity
      Current.user = session.identity.users.find_by(account: Current.account)
    end

    def require_authentication
      redirect_to new_session_path unless authenticated?
    end

    def start_session(identity)
      session = identity.sessions.create!(
        user_agent: request.user_agent,
        ip_address: request.remote_ip
      )

      cookies.signed.permanent[:session_token] = {
        value: session.token,
        httponly: true,
        secure: Rails.env.production?
      }

      session
    end
end
```

## Sessions Controller

```ruby
class SessionsController < ApplicationController
  allow_unauthenticated_access

  rate_limit to: 10, within: 3.minutes, only: :create

  def new
  end

  def create
    identity = Identity.find_by(email: params[:email])

    if identity
      magic_link = identity.magic_links.create!(purpose: :sign_in)
      MagicLinkMailer.sign_in(magic_link).deliver_later
      redirect_to verify_magic_link_path, notice: "Check your email for a sign-in code"
    else
      redirect_to new_registration_path(email: params[:email])
    end
  end

  def destroy
    current_session&.destroy
    cookies.delete(:session_token)
    redirect_to root_path, notice: "Signed out"
  end
end
```

## Magic Links Controller

```ruby
class MagicLinksController < ApplicationController
  allow_unauthenticated_access

  rate_limit to: 10, within: 15.minutes, only: :verify

  def verify
    @email = session[:pending_email]
  end

  def confirm
    email = session[:pending_email]
    magic_link = MagicLink.valid.find_by!(
      code: params[:code],
      identity: Identity.find_by!(email: email)
    )

    start_session(magic_link.identity)
    magic_link.destroy!
    session.delete(:pending_email)

    redirect_to after_sign_in_path
  rescue ActiveRecord::RecordNotFound
    redirect_to verify_magic_link_path, alert: "Invalid or expired code"
  end

  private
    def after_sign_in_path
      stored_location || root_path
    end
end
```

## Magic Link Mailer

Include code in subject for cross-device authentication:

```ruby
class MagicLinkMailer < ApplicationMailer
  def sign_in(magic_link)
    @magic_link = magic_link
    @code = magic_link.code

    mail(
      to: magic_link.identity.email,
      subject: "Your sign-in code is #{@code}"
    )
  end
end
```

```erb
<%# app/views/magic_link_mailer/sign_in.html.erb %>
<p>Your sign-in code is:</p>
<p style="font-size: 32px; font-weight: bold; letter-spacing: 4px;">
  <%= @code %>
</p>
<p>This code expires in 15 minutes.</p>
```

## Cleanup Job

```ruby
class MagicLink::CleanupJob < ApplicationJob
  def perform
    MagicLink.stale.delete_all
  end
end

# config/recurring.yml
cleanup_magic_links:
  class: MagicLink::CleanupJob
  schedule: every hour
```

## Routes

```ruby
Rails.application.routes.draw do
  resource :session, only: %i[new create destroy]
  resource :registration, only: %i[new create]

  resources :magic_links, only: [] do
    collection do
      get :verify
      post :confirm
    end
  end
end
```
