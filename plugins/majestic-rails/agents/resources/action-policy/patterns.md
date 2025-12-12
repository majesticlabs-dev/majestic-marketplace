# ActionPolicy Patterns Reference

## Testing with RSpec

### Setup

```ruby
# spec/rails_helper.rb
require "action_policy/rspec"
```

### Policy Specs

```ruby
# spec/policies/post_policy_spec.rb
RSpec.describe PostPolicy do
  let(:user) { create(:user) }
  let(:admin) { create(:user, :admin) }
  let(:post) { create(:post, user: user) }

  describe "#update?" do
    it "allows post owner" do
      expect(PostPolicy).to be_authorized_to(:update?, post)
        .with(user: user)
    end

    it "allows admin" do
      expect(PostPolicy).to be_authorized_to(:update?, post)
        .with(user: admin)
    end

    it "denies other users" do
      other = create(:user)
      expect(PostPolicy).not_to be_authorized_to(:update?, post)
        .with(user: other)
    end
  end

  describe "relation_scope" do
    it "returns all posts for admin" do
      expect(PostPolicy)
        .to have_authorized_scope(:relation)
        .with(user: admin)
        .that_returns(Post.all)
    end

    it "returns own and published posts for user" do
      own_post = create(:post, user: user)
      published = create(:post, :published)
      draft = create(:post)  # Someone else's draft

      scope = authorized_scope(Post.all, with: PostPolicy, user: user)
      expect(scope).to include(own_post, published)
      expect(scope).not_to include(draft)
    end
  end
end
```

### Controller Specs

```ruby
# spec/requests/posts_spec.rb
RSpec.describe "Posts", type: :request do
  describe "PUT /posts/:id" do
    let(:post) { create(:post) }

    context "as owner" do
      before { sign_in post.user }

      it "updates the post" do
        put post_path(post), params: { post: { title: "New Title" } }
        expect(response).to redirect_to(post)
      end
    end

    context "as other user" do
      before { sign_in create(:user) }

      it "denies access" do
        put post_path(post), params: { post: { title: "Hacked" } }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
```

## GraphQL Integration

### Setup with action_policy-graphql

```ruby
# Gemfile
gem "action_policy-graphql"

# app/graphql/types/base_object.rb
class Types::BaseObject < GraphQL::Schema::Object
  include ActionPolicy::GraphQL::Behaviour
end

# app/graphql/types/base_field.rb
class Types::BaseField < GraphQL::Schema::Field
  include ActionPolicy::GraphQL::AuthorizedField
end
```

### Authorize Fields

```ruby
# app/graphql/types/post_type.rb
class Types::PostType < Types::BaseObject
  field :id, ID, null: false
  field :title, String, null: false
  field :content, String, null: false

  # Field-level authorization
  field :admin_notes, String, null: true, authorize: true

  def admin_notes
    object.admin_notes
  end
end
```

### Authorize Mutations with preauthorize

```ruby
# app/graphql/types/mutation_type.rb
class Types::MutationType < Types::BaseObject
  # preauthorize checks BEFORE mutation runs (prevents side effects)
  field :update_post, mutation: Mutations::UpdatePost,
        preauthorize: { to: :update?, with: PostPolicy }

  field :publish_post, mutation: Mutations::PublishPost,
        preauthorize: { to: :publish?, with: PostPolicy }
end

# app/graphql/mutations/update_post.rb
class Mutations::UpdatePost < Mutations::BaseMutation
  argument :id, ID, required: true
  argument :title, String, required: false
  argument :content, String, required: false

  field :post, Types::PostType, null: true
  field :errors, [String], null: false

  def resolve(id:, **attrs)
    post = Post.find(id)
    # Authorization already checked by preauthorize

    if post.update(attrs.compact)
      { post: post, errors: [] }
    else
      { post: nil, errors: post.errors.full_messages }
    end
  end

  # Required: return the record for preauthorize
  def object
    Post.find(arguments[:id])
  end
end
```

## ActionCable Integration

```ruby
# app/channels/post_channel.rb
class PostChannel < ApplicationCable::Channel
  include ActionPolicy::Channel::Authorization

  def subscribed
    @post = Post.find(params[:id])

    if allowed_to?(:show?, @post, with: PostPolicy)
      stream_for @post
    else
      reject
    end
  end

  def update_title(data)
    @post = Post.find(data["id"])

    authorize! @post, to: :update?, with: PostPolicy

    @post.update!(title: data["title"])
    PostChannel.broadcast_to(@post, action: "updated", post: @post.as_json)
  rescue ActionPolicy::Unauthorized
    transmit(error: "Not authorized to update this post")
  end
end
```

## Advanced Patterns

### Context-Aware Policies

```ruby
class PostPolicy < ApplicationPolicy
  # Access additional context
  authorize :account, optional: true

  def update?
    return true if user.admin?
    return owner? unless account

    # Multi-tenant check
    owner? && record.account_id == account.id
  end
end

# In controller
authorize! @post, context: { account: Current.account }
```

### Pre-checks

```ruby
class ApplicationPolicy < ActionPolicy::Base
  pre_check :verify_user_active

  private

  def verify_user_active
    deny! unless user&.active?
  end
end
```

## External Cache Stores (Redis)

For high-traffic apps needing cross-request cache persistence:

```ruby
# config/initializers/action_policy.rb
ActionPolicy.configure do |config|
  # Redis for distributed caching across requests/servers
  config.cache_store = ActiveSupport::Cache::RedisCacheStore.new(
    url: ENV.fetch("REDIS_URL", "redis://localhost:6379/1"),
    namespace: "action_policy",
    expires_in: 1.hour
  )
end
```

When to use external cache:
- Expensive authorization checks (complex DB queries)
- Multi-server deployments needing shared cache
- Authorization rules that rarely change

### Policy Instance Memoization

Avoid redundant authorization checks on the same object within a request:

```ruby
class PostPolicy < ApplicationPolicy
  # ActionPolicy uses record.policy_cache_key by default
  # Override for custom cache keys
  def policy_cache_key
    record.cache_key_with_version
  end

  def update?
    # This check is memoized per policy instance
    cache { owner_or_collaborator? }
  end
end
```

For views checking permissions on collections:

```ruby
# app/controllers/posts_controller.rb
class PostsController < ApplicationController
  def index
    @posts = authorized_scope(Post.all).includes(:user)
    # Preload policies to avoid N+1 authorization checks
    @posts.each { |post| allowed_to?(:edit?, post) }
  end
end
```

```erb
<%# Subsequent checks reuse memoized results %>
<% @posts.each do |post| %>
  <% if allowed_to?(:edit?, post) %>
    <%= link_to "Edit", edit_post_path(post) %>
  <% end %>
<% end %>
```
