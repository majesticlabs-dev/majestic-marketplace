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

## N+1 Query Prevention

Each attachment display triggers two queries (join table + blob). Always eager load:

```ruby
# Preferred — built-in scope
@companies = Company.all.with_attached_logo

# Equivalent manual includes
@companies = Company.all.includes(:logo_attachment, :logo_blob)

# has_many_attached with variants
@products = Product.all.includes(photos_attachments: :blob)
```

## Serving Modes

Three modes available since Rails 6.1:

| Mode | Behavior | Use When |
|------|----------|----------|
| Redirect | 302 to signed storage URL | Default. CDN-friendly |
| Proxy | Streams through Puma | Need auth checks per request |
| Public | Direct storage URL (no signing) | Public assets, max CDN performance |

**Proxy mode warning:** Streaming holds Puma workers and AR connections. Increase connection pool beyond thread count when using proxy mode.

## Direct Uploads & Slow Client Defense

File uploads hold Puma workers hostage. On small deployments (2 dynos, 2 workers each), two slow uploads halve capacity.

```erb
<%# Always use direct uploads for user-facing forms %>
<%= form.file_field :avatar, direct_upload: true %>
```

If using proxy mode for serving, buffer with nginx:

```nginx
# Strip session cookies from cached responses
# Without this: User A's session cookie gets cached and served to User B
proxy_hide_header Set-Cookie;
proxy_ignore_header Set-Cookie;
```

## Variant Optimization

### Use libvips Over ImageMagick

libvips is faster, lower memory, fewer CVEs. For HEIC/AVIF/JPEGXL support, compile from source with dev packages. Replace `libjpeg-turbo` with `mozjpeg` for 20-35% smaller JPEGs.

### Optimal Saver Options

```ruby
# JPEG (mozjpeg linked)
variant(saver: { strip: true, quality: 80, interlace: true,
  optimize_coding: true, trellis_quant: true, quant_table: 3 }, format: "jpg")

# PNG
variant(saver: { strip: true, compression: 9 }, format: "png")

# WebP
variant(saver: { strip: true, quality: 75, lossless: false, alpha_q: 85,
  reduction_effort: 6, smart_subsample: true }, format: "webp")
```

**Always specify `format:`** — some Android devices send `.jfif` files (valid JPEGs) that libvips mishandles without explicit format.

### JPEG vs WebP Trade-off

WebP lacks interlacing — images only display after full download. JPEG with interlacing shows progressive preview, *feeling* faster. With mozjpeg, the size gap narrows substantially.

### Resize Strategy

Resize to **2x display size** (not 1x, not higher). Larger than 2x provides no perceptual benefit. Share the same variant between thumbnail and full view so the browser cache serves it instantly on click.

### On-Demand Variant Generation Risks

A user uploads 10 images, then views their gallery. All 10 variants generate simultaneously, competing for CPU/memory, causing swap and slowing all requests.

Mitigations:
1. Use libvips (not ImageMagick)
2. Scale vertically — add RAM to avoid swap (`c6i` → `m6i`)
3. Pre-generate variants via background jobs

## CDN Gotchas

**Cache propagation storms:** Without premium CDN plans, each PoP independently cache-misses. A single image can trigger 90+ requests to your app (46 US PoPs x 2 misses each).

**TTL vs retention:** TTL controls *freshness*, not *retention*. Infrequently requested images get evicted despite long TTLs.

## `has_many_attached` Anti-Pattern

Once you use `has_many_attached`, you can't add per-file metadata (ordering, flags, roles). You'll eventually need to migrate to a full model.

```ruby
# Start with this pattern instead
class Product < ApplicationRecord
  has_many :photos
end

class Photo < ApplicationRecord
  has_one_attached :file
  validates :position, presence: true
end
```

## Content Type Configuration

Two key configs to know:

| Config | Purpose | Default |
|--------|---------|---------|
| `web_image_content_types` | Formats served as-is | png, jpeg, gif |
| `variable_content_types` | Formats AST will convert | (broad list) |

- Add `webp` to `web_image_content_types` if serving WebP
- Remove unsupported formats from `variable_content_types` or error trackers flood with conversion failures
- If a file isn't in `web_image_content_types` but is in `variable_content_types`, AST converts it to PNG automatically

## Storage Service Quirks

| Service | Gotcha |
|---------|--------|
| S3 | Default 60s timeout + auto-retry = minutes holding a worker per failed upload |
| GCS | Concurrent metadata updates fail (e.g., simultaneous `.analyze` calls) |
| R2 | Intermittent connection failures in production |

**Migration cost:** AST stores originals and variants in the same flat structure (no folders). Migrating providers means paying egress for *all* files including regeneratable variants.

## Custom Analyzer

Extend the default analyzer for rotation-aware dimensions and opacity detection:

```ruby
class MyAnalyzer < Analyzer::ImageAnalyzer::Vips
  def metadata
    read_image do |image|
      dims = rotated_image?(image) ?
        { width: image.height, height: image.width } :
        { width: image.width, height: image.height }
      dims.merge(opaque: opaque?(image)).compact
    end
  end

  private
    def opaque?(image)
      return true unless image.has_alpha?
      image[image.bands - 1].min == 255
    rescue ::Vips::Error
      false
    end
end

# config/initializers/active_storage.rb
Rails.application.config.to_prepare do
  Rails.application.config.active_storage.analyzers.prepend MyAnalyzer
end
```
