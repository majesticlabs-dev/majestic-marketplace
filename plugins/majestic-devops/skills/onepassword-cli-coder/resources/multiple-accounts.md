# Multiple 1Password Accounts

Many users have separate personal and work 1Password accounts. The CLI supports switching between them.

## List Configured Accounts

```bash
op account list
```

Output:
```
USER ID                          URL
-----------------------------    --------------------------
A3BCDEFGHIJKLMNOPQRSTUVWX       my.1password.com
B4CDEFGHIJKLMNOPQRSTUVWXY       acme.1password.com
```

## Specify Account per Command

Use `--account` with either the sign-in address or account ID:

```bash
# Using sign-in address
op vault list --account my.1password.com
op item get "AWS" --account acme.1password.com

# Using account ID
op vault list --account A3BCDEFGHIJKLMNOPQRSTUVWX
```

## Set Default Account (Environment Variable)

Set `OP_ACCOUNT` to choose default for all commands in that shell:

```bash
export OP_ACCOUNT=acme.1password.com
op vault list            # Uses acme.1password.com
op item get "API Key"    # Uses acme.1password.com
```

`--account` flag **overrides** `OP_ACCOUNT` for a single command.

## Multiple Accounts with op run

```bash
# Specify account explicitly
op run --account acme.1password.com --env-file=.op.env.work -- ./deploy.sh

# Or set environment variable first
export OP_ACCOUNT=my.1password.com
op run --env-file=.op.env.personal -- ./start-local-dev.sh
```

## Cross-Account Workflows

When scripts need secrets from different accounts:

```bash
# Script using work account
export OP_ACCOUNT=acme.1password.com
WORK_DB=$(op read "op://Production/Database/url")

# Switch to personal for specific command
PERSONAL_KEY=$(op read "op://Personal/GitHub/token" --account my.1password.com)
```

## Makefile with Account Selection

```makefile
# Default to work account
OP_ACCOUNT ?= acme.1password.com
OP ?= op
OP_ENV_FILE ?= .op.env

CMD = OP_ACCOUNT=$(OP_ACCOUNT) $(OP) run --env-file=$(OP_ENV_FILE) --

deploy:
	$(CMD) kamal deploy

# Personal account for local dev
dev:
	OP_ACCOUNT=my.1password.com $(OP) run --env-file=.op.env.personal -- rails server

# Usage:
# make deploy                           # Uses work account
# make deploy OP_ACCOUNT=my.1password.com  # Override account
# make dev                              # Uses personal account
```

## Best Practices for Multiple Accounts

**DO:**
- Always use `--account` or `OP_ACCOUNT` in scripts (don't rely on "last signed in")
- Use work accounts for CI/CD, personal for local dev
- Create separate `.op.env` files per account context

**DON'T:**
- Rely on "last signed in" account in automation (brittle)
- Mix account contexts in single env file

## Account-Specific Env Files

```bash
# .op.env.work (uses work account vaults)
AWS_ACCESS_KEY_ID=op://Work-Infrastructure/AWS/access_key_id
DATABASE_URL=op://Work-Production/Database/url

# .op.env.personal (uses personal account vaults)
GITHUB_TOKEN=op://Personal/GitHub/token
OPENAI_API_KEY=op://Personal/OpenAI/api_key
```

```makefile
# Makefile with account + env file pairing
work-deploy:
	op run --account acme.1password.com --env-file=.op.env.work -- ./deploy.sh

personal-dev:
	op run --account my.1password.com --env-file=.op.env.personal -- ./dev.sh
```
