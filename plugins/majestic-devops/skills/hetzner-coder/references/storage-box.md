# Hetzner Storage Box

Hetzner Storage Boxes are external network storage (not Cloud API). Provisioned via Robot panel or API, mounted via CIFS/SMB, SFTP, or SCP. Common use: off-server backup destination for Litestream and docker-volume-backup.

**Not manageable via OpenTofu** — the hcloud provider only covers Hetzner Cloud. Storage Boxes are a separate Hetzner product ordered through Robot.

## CIFS Mount via Ansible

### Playbook

```yaml
- name: Mount Hetzner Storage Box
  hosts: all
  become: true
  vars:
    storage_box_user: "u123456"
    storage_box_host: "u123456.your-storagebox.de"
    mount_point: "/mnt/storage_box"

  tasks:
    - name: Install CIFS utilities
      apt:
        name: cifs-utils
        state: present

    - name: Create credentials file
      copy:
        dest: /etc/storage-box-credentials
        content: |
          username={{ storage_box_user }}
          password={{ storage_box_password }}
        mode: "0600"
        owner: root
        group: root
      no_log: true

    - name: Create mount point
      file:
        path: "{{ mount_point }}"
        state: directory
        mode: "0755"

    - name: Add fstab entry
      mount:
        path: "{{ mount_point }}"
        src: "//{{ storage_box_host }}/backup"
        fstype: cifs
        opts: "iocharset=utf8,rw,credentials=/etc/storage-box-credentials,uid=1000,gid=1000,file_mode=0660,dir_mode=0770"
        state: mounted
```

### Encrypted Password with Ansible Vault

```bash
# Encrypt the password
ansible-vault encrypt_string 'your-storage-box-password' --name 'storage_box_password'

# Run with vault
ansible-playbook -i hosts.ini playbook.yml --ask-vault-pass
```

## Backup Directory Structure

Organize mount point by service and backup type:

```
/mnt/storage_box/
├── backups/
│   ├── sqlite3/
│   │   └── myapp/           # Litestream WAL replicas
│   └── volumes/
│       └── myapp/           # docker-volume-backup tarballs
└── exports/                 # Manual data exports
```

## Integration with Kamal Accessories

### Litestream to Storage Box

```yaml
# config/deploy.yml
accessories:
  litestream:
    image: litestream/litestream:0.3
    host: 203.0.113.10
    cmd: replicate
    volumes:
      - /mnt/storage_box/backups/sqlite3/myapp:/backup
      - myapp_storage:/rails/storage:ro
    files:
      - config/litestream.yml:/etc/litestream.yml
    env:
      secret:
        - LITESTREAM_ACCESS_KEY_ID
        - LITESTREAM_SECRET_ACCESS_KEY
```

Litestream config uses local path replica instead of S3:

```yaml
# config/litestream.yml (local replica variant)
dbs:
  - path: /rails/storage/production.sqlite3
    replicas:
      - type: file
        path: /backup/production
        retention: 720h
        sync-interval: 5s
```

### docker-volume-backup to Storage Box

```yaml
# config/deploy.yml
accessories:
  backup:
    image: offen/docker-volume-backup:v2
    host: 203.0.113.10
    volumes:
      - myapp_storage:/backup/myapp_storage:ro
      - /mnt/storage_box/backups/volumes/myapp:/archive
      - /var/run/docker.sock:/var/run/docker.sock:ro
    env:
      clear:
        BACKUP_CRON_EXPRESSION: "0 3 * * *"
        BACKUP_FILENAME: "myapp-%Y-%m-%dT%H-%M-%S.tar.gz"
        BACKUP_PRUNING_PREFIX: "myapp-"
        BACKUP_RETENTION_DAYS: "30"
```

## Storage Box Tiers

| Size | Price/mo | Use Case |
|------|----------|----------|
| 1 TB | ~3.81 EUR | Single app backups |
| 5 TB | ~12.35 EUR | Multiple apps or long retention |
| 10 TB | ~18.52 EUR | Large datasets + backups |
| 20 TB | ~30.89 EUR | Full archive storage |

Prices approximate — check Hetzner Robot for current pricing.

## Mount Options Reference

| Option | Purpose |
|--------|---------|
| `credentials=/etc/storage-box-credentials` | Separate file for username/password |
| `uid=1000,gid=1000` | Match container user (rails) |
| `file_mode=0660,dir_mode=0770` | Restrictive permissions |
| `iocharset=utf8` | UTF-8 filename support |
| `_netdev` | Wait for network before mount (add for boot reliability) |
| `vers=3.0` | Force SMB3 if default negotiation fails |
