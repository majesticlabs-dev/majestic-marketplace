# Ansible Integration for Hetzner

## Post-Provisioning with Ansible

Cloud-init runs at first boot. For ongoing configuration or re-running setup, use Ansible.

```hcl
# outputs.tf
output "server_ip" {
  value       = hcloud_server.app.ipv4_address
  description = "Server IP for Ansible inventory"
}

output "ansible_inventory" {
  value = <<-EOT
    [web]
    ${hcloud_server.app.ipv4_address} ansible_user=root
  EOT
  description = "Ansible inventory content"
}
```

## Provision Script (Terraform > Ansible > Kamal)

```bash
#!/usr/bin/env bash
# infra/bin/provision
set -euo pipefail

INFRA_DIR="$(dirname "$0")/.."

# 1. Terraform
cd "$INFRA_DIR"
tofu apply

# 2. Wait for SSH
SERVER_IP=$(tofu output -raw server_ip)
until ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=accept-new root@$SERVER_IP true 2>/dev/null; do
  echo "Waiting for server..."
  sleep 5
done

# 3. Ansible
cd ansible
tofu output -raw ansible_inventory > hosts.ini
ansible-galaxy install -r requirements.yml --force
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i hosts.ini playbook.yml

# 4. Kamal bootstrap
cd ../..
bundle exec kamal server bootstrap
```

## Kamal-Ready Server Playbook

Based on [kamal-ansible-manager](https://github.com/guillaumebriday/kamal-ansible-manager):

```yaml
# infra/ansible/playbook.yml
---
- name: Configure Hetzner server for Kamal
  hosts: web
  become: true

  vars:
    swap_file_size_mb: "2048"
    timezone: "UTC"

  roles:
    - role: geerlingguy.swap
      when: ansible_swaptotal_mb < 1

  tasks:
    - name: Install Docker
      ansible.builtin.shell: curl -fsSL https://get.docker.com | sh
      args:
        creates: /usr/bin/docker

    - name: Enable Docker
      ansible.builtin.systemd:
        name: docker
        state: started
        enabled: true

    - name: Install security packages
      ansible.builtin.apt:
        name: [fail2ban, ufw]
        state: present
        update_cache: true

    - name: Configure fail2ban
      ansible.builtin.copy:
        dest: /etc/fail2ban/jail.local
        content: |
          [sshd]
          enabled = true
          maxretry = 5
          bantime = 3600
        mode: "0644"

    - name: Configure UFW
      community.general.ufw:
        rule: allow
        port: "{{ item }}"
        proto: tcp
      loop: [22, 80, 443]

    - name: Enable UFW
      community.general.ufw:
        state: enabled
        policy: deny
        direction: incoming

    - name: Harden SSH
      ansible.builtin.lineinfile:
        path: /etc/ssh/sshd_config
        regexp: "^#?PasswordAuthentication"
        line: "PasswordAuthentication no"
      notify: Restart ssh

  handlers:
    - name: Restart ssh
      ansible.builtin.systemd:
        name: ssh
        state: restarted
```

## Requirements

```yaml
# infra/ansible/requirements.yml
---
roles:
  - name: geerlingguy.swap
    version: 2.0.0
```

## When to Use Each Approach

| Approach | Use Case |
|----------|----------|
| Cloud-init only | Immutable infra, destroy/recreate pattern |
| Ansible only | Existing servers, complex multi-step config |
| Cloud-init + Ansible | First boot basics, then Ansible for hardening |
