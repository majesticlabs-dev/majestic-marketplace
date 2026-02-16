# B2 CLI Installation & Authentication

## Installation

```bash
# macOS
brew install b2-tools

# Linux (Debian/Ubuntu)
sudo apt install backblaze-b2

# Linux (via pip)
pip install b2

# Verify
b2 version
```

## CLI Authentication

```bash
# Authorize with application key (preferred)
b2 authorize-account <applicationKeyId> <applicationKey>

# Or with 1Password
b2 authorize-account $(op read "op://Infrastructure/Backblaze/key_id") \
                     $(op read "op://Infrastructure/Backblaze/application_key")

# Credentials stored in ~/.b2_account_info (SQLite)
# Override with B2_ACCOUNT_INFO env var
```

## Terraform Authentication

```bash
export B2_APPLICATION_KEY_ID="your-key-id"
export B2_APPLICATION_KEY="your-application-key"

# Or with 1Password
B2_APPLICATION_KEY_ID=op://Infrastructure/Backblaze/key_id
B2_APPLICATION_KEY=op://Infrastructure/Backblaze/application_key
```
