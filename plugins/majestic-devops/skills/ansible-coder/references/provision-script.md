# Integration with Terraform

## Provision Script Pattern

```bash
#!/usr/bin/env bash
# infra/bin/provision

# 1. Terraform creates server
cd infra && tofu apply
SERVER_IP=$(tofu output -raw server_ip)

# 2. Wait for SSH
until ssh -o ConnectTimeout=5 root@$SERVER_IP true 2>/dev/null; do
  sleep 5
done

# 3. Generate inventory
echo "[web]\n$SERVER_IP ansible_user=root" > ansible/hosts.ini

# 4. Run Ansible
cd ansible
ansible-galaxy install -r requirements.yml
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i hosts.ini playbook.yml

# 5. Kamal bootstrap
cd ../..
bundle exec kamal server bootstrap
```
