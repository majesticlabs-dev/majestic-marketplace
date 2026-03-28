# Docker Patterns for Kamal

## Production Dockerfile (Multi-Stage)

```dockerfile
# syntax=docker/dockerfile:1
ARG RUBY_VERSION=3.3.0
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

WORKDIR /rails
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test"

# ---------- Build stage ----------
FROM base AS build

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential git pkg-config libyaml-dev

COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

COPY . .

RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile
RUN bundle exec bootsnap precompile app/ lib/

# ---------- Final stage ----------
FROM base

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    curl libjemalloc2 libvips sqlite3 && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

ENV LD_PRELOAD="libjemalloc.so.2"

COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp

USER 1000:1000

ENTRYPOINT ["./docker-entrypoint.sh"]

EXPOSE 3000
CMD ["./bin/rails", "server"]
```

### Key Patterns

| Pattern | Purpose |
|---------|---------|
| `libjemalloc2` + `LD_PRELOAD` | 20-30% memory reduction |
| `libvips` | ActiveStorage image processing |
| `SECRET_KEY_BASE_DUMMY=1` | Asset compilation without real secrets |
| `bootsnap precompile` | Faster boot times |
| Non-root user (UID 1000) | Security best practice |
| Multi-stage build | Final image has no build tools |

### SQLite Dependencies

For Rails 8 SQLite apps, ensure the final stage includes:

```dockerfile
RUN apt-get install --no-install-recommends -y sqlite3 libsqlite3-0
```

## Docker Entrypoint

Selective migration — only runs `db:prepare` for the web container, not job workers:

```bash
#!/bin/bash -e

# Only run migrations for the Rails server process
if [ "${@: -2:1}" == "./bin/rails" ] && [ "${@: -1:1}" == "server" ]; then
  ./bin/rails db:prepare
fi

exec "${@}"
```

Make executable: `chmod +x docker-entrypoint.sh`

**Why this matters:**
- Web container runs migrations on deploy
- Job container (`bin/jobs start`) skips migrations — avoids race conditions
- `db:prepare` is idempotent — creates DB if missing, migrates if exists

## Volume Patterns

### SQLite + ActiveStorage

```yaml
# config/deploy.yml
servers:
  web:
    hosts:
      - 203.0.113.10
    volumes:
      - myapp_storage:/rails/storage
  job:
    hosts:
      - 203.0.113.10
    cmd: bin/jobs start
    volumes:
      - myapp_storage:/rails/storage
```

Both roles mount the same named volume. SQLite databases and uploaded files persist across deploys.

### Backup Labels

Add labels for docker-volume-backup integration:

```yaml
servers:
  web:
    hosts:
      - 203.0.113.10
    volumes:
      - myapp_storage:/rails/storage
    labels:
      docker-volume-backup.stop-during-backup: "true"
```

Pauses the container before tar.gz snapshot for data consistency.

## .dockerignore

```
.git
.github
.kamal
log/*
tmp/*
storage/*
node_modules
.env*
```

Keep image small. Never include `.kamal/secrets` in the image.
