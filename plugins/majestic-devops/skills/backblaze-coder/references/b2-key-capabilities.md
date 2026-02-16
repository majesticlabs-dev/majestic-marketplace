# B2 Application Key Capabilities

| Capability | Operations |
|------------|------------|
| `listBuckets` | List buckets (minimum required) |
| `listFiles` | List files in bucket |
| `readFiles` | Download files |
| `writeFiles` | Upload files |
| `deleteFiles` | Delete files |
| `writeBucketRetentions` | Modify retention settings |
| `readBucketEncryption` | Read encryption settings |
| `writeBucketEncryption` | Modify encryption settings |

## Key Management

```bash
# List keys
b2 key list

# Create key with specific capabilities
b2 key create my-app-key listBuckets,listFiles,readFiles,writeFiles

# Create key restricted to bucket and prefix
b2 key create my-app-key listBuckets,listFiles,readFiles \
  --bucket my-bucket \
  --name-prefix "uploads/"

# Delete key
b2 key delete <applicationKeyId>
```

## Sync Flags

| Flag | Description |
|------|-------------|
| `--threads N` | Parallel threads (default 10, max 99) |
| `--delete` | Delete files not in source |
| `--keep-days N` | Keep old versions for N days |
| `--replace-newer` | Replace if source is newer |
| `--skip-newer` | Skip if dest is newer |
| `--exclude-regex` | Exclude matching files |
| `--include-regex` | Include only matching files |
| `--no-progress` | Disable progress (for scripts) |
