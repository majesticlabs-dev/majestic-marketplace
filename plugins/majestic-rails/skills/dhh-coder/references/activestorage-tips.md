# ActiveStorage Tips Reference

Practical patterns for file uploads and attachments in Rails.

## Attachment Management

### Removing Attachments via Checkbox

Allow users to remove attachments through a form checkbox:

```ruby
# app/models/account.rb
class Account < ApplicationRecord
  attribute :remove_logo, :boolean
  has_one_attached :logo
  before_save :unassign_logo, if: :remove_logo

  private

  def unassign_logo
    self.logo = nil
  end
end

# app/controllers/accounts_controller.rb
class AccountsController < ApplicationController
  private

  def account_params
    params.require(:account).permit(:logo, :remove_logo)
  end
end
```

```erb
<%# app/views/accounts/_form.html.erb %>
<% if form.object.logo.present? %>
  <%= image_tag form.object.logo %>
  <%= form.check_box :remove_logo %>
<% end %>

<%= form.label :logo %>
<%= form.file_field :logo %>
```

### Custom Storage Keys

Use custom keys for cleaner, predictable URLs:

```ruby
# Instead of random blob keys like:
# https://your_app.io/b4g9ac7lk70urbjgkb2dluntaerd

# Use custom keys for human-readable URLs:
user.avatar.attach(
  io: File.open('/path/to/file'),
  filename: 'avatar.png',
  key: "custom/folder/path/avatar.png"
)

# Result: https://your_app.io/custom/folder/path/avatar.png
```

### Replacing vs Adding Attachments

By default, attaching files to a `has_many_attached` replaces existing attachments:

```erb
<%# To keep existing attachments, use hidden fields with signed_ids %>
<% @message.images.each do |image| %>
  <%= form.hidden_field :images, multiple: true, value: image.signed_id %>
<% end %>

<%= form.file_field :images, multiple: true %>
```

This allows JavaScript to selectively remove existing attachments while adding new ones.

### Preserving Attachments on Validation Failure

Use direct uploads to retain uploads when form validation fails:

```erb
<%# Preserve existing attachment on validation failure %>
<%= form.hidden_field :avatar, value: @user.avatar.signed_id if @user.avatar.attached? %>
<%= form.file_field :avatar, direct_upload: true %>
```

With direct uploads, files are uploaded directly to storage before form submission, so they persist even if validation fails.

## Displaying Attachments

### Handling Various Blob Types

Display different attachment types appropriately:

```erb
<% @record.blobs.each do |blob| %>
  <% if blob.previewable? %>
    <%# PDFs, videos - generate preview image %>
    <%= image_tag blob.preview(resize_to_limit: [100, 100]).processed.url %>
  <% elsif blob.variable? %>
    <%# Images - create variant %>
    <%= image_tag blob.variant(resize_to_fill: [120, 120]) %>
  <% else %>
    <%# Other files - show icon or content type %>
    <!-- show a file icon instead -->
    <span>Cannot show: <%= blob.content_type %></span>
  <% end %>
<% end %>
```

## Email Attachments

### Previewing Stored Email Files

Store and preview email (.eml) files:

```ruby
# app/models/email.rb
class Email < ApplicationRecord
  has_one_attached :eml
end

# app/controllers/emails_controller.rb
class EmailsController < ApplicationController
  def show
    email = Email.find(params[:id])

    @email_file = Mail.new(email.eml.download)
    @preview = ActionMailer::InlinePreviewInterceptor
                 .previewing_email(@email_file)
                 .html_part.decoded

    render layout: false
  end
end
```

```erb
<%# app/views/emails/show.html.erb %>
<%= @preview.html_safe %>
```
