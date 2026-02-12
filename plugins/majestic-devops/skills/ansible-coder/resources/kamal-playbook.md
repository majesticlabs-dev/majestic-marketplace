# Kamal Server Preparation

Complete playbook for Kamal deployment servers (based on [kamal-ansible-manager](https://github.com/guillaumebriday/kamal-ansible-manager)):

```yaml
---
- name: Prepare server for Kamal deployment
  hosts: web
  become: true

  vars:
    swap_file_size_mb: "2048"
    timezone: "UTC"
    ufw_allowed_ports: [22, 80, 443]

  roles:
    - role: geerlingguy.swap
      when: ansible_swaptotal_mb < 1

  tasks:
    # System updates
    - name: Update and upgrade packages
      ansible.builtin.apt:
        update_cache: true
        upgrade: dist

    # Remove bloat
    - name: Remove snapd
      ansible.builtin.apt:
        name: snapd
        state: absent
        purge: true
      ignore_errors: true

    # Essential packages
    - name: Install required packages
      ansible.builtin.apt:
        name: [curl, ca-certificates, fail2ban, ufw, ntp]
        state: present

    # Docker
    - name: Install Docker
      ansible.builtin.shell: curl -fsSL https://get.docker.com | sh
      args:
        creates: /usr/bin/docker

    - name: Enable Docker
      ansible.builtin.systemd:
        name: docker
        state: started
        enabled: true

    # Security
    - name: Configure fail2ban
      ansible.builtin.copy:
        dest: /etc/fail2ban/jail.local
        content: |
          [sshd]
          enabled = true
          maxretry = 5
          bantime = 3600
        mode: "0644"
      notify: Restart fail2ban

    - name: Configure UFW
      community.general.ufw:
        rule: allow
        port: "{{ item }}"
        proto: tcp
      loop: "{{ ufw_allowed_ports }}"

    - name: Enable UFW
      community.general.ufw:
        state: enabled
        policy: deny
        direction: incoming

    # SSH hardening
    - name: Harden SSH
      ansible.builtin.lineinfile:
        path: /etc/ssh/sshd_config
        regexp: "{{ item.regexp }}"
        line: "{{ item.line }}"
      loop:
        - { regexp: "^#?PasswordAuthentication", line: "PasswordAuthentication no" }
        - { regexp: "^#?PermitRootLogin", line: "PermitRootLogin prohibit-password" }
      notify: Restart ssh

    # Performance
    - name: Tune kernel
      ansible.posix.sysctl:
        name: "{{ item.name }}"
        value: "{{ item.value }}"
        reload: true
      loop:
        - { name: vm.swappiness, value: "10" }
        - { name: net.core.somaxconn, value: "65535" }

    - name: Set timezone
      community.general.timezone:
        name: "{{ timezone }}"

  handlers:
    - name: Restart fail2ban
      ansible.builtin.systemd:
        name: fail2ban
        state: restarted

    - name: Restart ssh
      ansible.builtin.systemd:
        name: ssh
        state: restarted
```
