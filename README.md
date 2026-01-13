# Linux Server Hardening, Recovery, and Automation Lab

![ShellCheck](https://github.com/danheck12/linux-server-hardening-and-recovery/actions/workflows/lint.yml/badge.svg)
![Ansible Lint](https://github.com/danheck12/linux-server-hardening-and-recovery/actions/workflows/ansible-lint.yml/badge.svg)
![Last Commit](https://img.shields.io/github/last-commit/danheck12/linux-server-hardening-and-recovery)
![Repo Size](https://img.shields.io/github/repo-size/danheck12/linux-server-hardening-and-recovery)
![Stars](https://img.shields.io/github/stars/danheck12/linux-server-hardening-and-recovery?style=social)


Hands-on Linux engineering lab focused on **system hardening, failure injection, incident response, recovery procedures, and automation**.
Designed to simulate common production incidents (boot failures, disk exhaustion, systemd crashes, permissions incidents, SSH lockouts) and recover using production-grade methods and documented runbooks.

> ⚠️ Safety: This project intentionally breaks system components for learning. Do **not** run these drills on production systems.

---

## Table of Contents
- [Objectives](#objectives)
- [Architecture](#architecture)
- [Repository Structure](#repository-structure)
- [Getting Started](#getting-started)
- [Recovery Scenarios](#recovery-scenarios)
- [Chaos Scripts](#chaos-scripts)
- [Ansible Automation](#ansible-automation)
- [Evidence Collection](#evidence-collection)
- [Skills Demonstrated](#skills-demonstrated)

---

## Objectives
- Harden a Linux server using best practices
- Simulate common production failures
- Diagnose issues using standard Linux tooling
- Recover systems safely and methodically
- Document recovery procedures in runbooks
- Automate configuration and hardening using Ansible
- Validate system state with audit playbooks

---

## Architecture
- Platform: AWS EC2
- OS: Ubuntu 22.04 LTS
- Access:
  - SSH (key-based)
  - AWS SSM Session Manager (break-glass recovery)
- Storage:
  - Root EBS volume
  - Secondary EBS volume for filesystem + `/etc/fstab` recovery drills

---

## Repository Structure
.
├── README.md
├── docs/
│ ├── runbooks/
│ │ ├── R2-broken-fstab.md
│ │ ├── R3-disk-full.md
│ │ ├── R4-systemd-service-failure.md
│ │ ├── R5-permissions-ownership-incident.md
│ │ └── R6-ssh-lockout-recovery.md
│ └── evidence/
│ └── commands-and-outputs.md
├── scripts/
│ └── chaos/
│ ├── break_demo_app_service.sh
│ ├── break_permissions.sh
│ └── ssh_lockout_allowusers.sh
└── ansible/
├── ansible.cfg
├── inventory/hosts.ini
├── group_vars/all.yml
├── playbooks/
│ ├── site.yml
│ └── audit.yml
└── roles/
├── baseline/
├── ssh_hardening/
├── ufw/
├── fail2ban/
├── demo_app/
└── audit/

yaml
Copy code

---

## Getting Started

### Prerequisites
- AWS account access to create/manage EC2 + IAM/SSM components
- AWS CLI configured (`aws sts get-caller-identity` works)
- Ansible installed locally
- SSH keypair available
- Recommended: create the instance with SSM access (Session Manager) for break-glass recovery

### 1) Provision an EC2 instance
Minimum suggestions (you can tighten later):
- Ubuntu 24.04 LTS
- Instance type: t3.small (or similar)
- Security group:
  - SSH (22) from your IP (optional if you rely on SSM)
- Attach an IAM role with:
  - `AmazonSSMManagedInstanceCore`

Ensure SSM is working:
- AWS Console → Systems Manager → Fleet Manager → Managed nodes
- or use Session Manager to open a shell.

### 2) Configure Ansible inventory
Edit:
`ansible/inventory/hosts.ini`

Example:
```ini
[linux_lab]
<EC2_PUBLIC_IP_OR_DNS> ansible_user=ubuntu
3) Run the hardening + baseline playbook
From repo root:

bash
Copy code
cd ansible
ansible-playbook playbooks/site.yml --private-key ~/.ssh/<your-key>.pem
4) Run the audit playbook (verification)
bash
Copy code
ansible-playbook playbooks/audit.yml --private-key ~/.ssh/<your-key>.pem
5) Inject a failure and recover using a runbook
From repo root:

bash
Copy code
./scripts/chaos/break_demo_app_service.sh
# then follow:
# docs/runbooks/R4-systemd-service-failure.md
Recovery Scenarios
R2 – Broken /etc/fstab Boot Failure
Inject invalid mount entry

System drops to emergency mode

Recover using SSM, remount root, correct fstab

R3 – Disk Full Incident
Exhaust root filesystem

Diagnose via df, du, journalctl

Cleanup + recovery

R4 – systemd Service Failure
Break ExecStart

Diagnose via systemctl, journalctl, systemd-analyze

Fix unit file + restore service

R5 – Permissions / Ownership Incident
App cannot write logs

Diagnose via ls -l, namei, getfacl

Correct perms/ownership and validate

R6 – SSH Lockout Recovery
Restrict access in sshd_config

New sessions blocked

Recover via SSM Session Manager and restore safe SSH access

Chaos Scripts
Scripts live in:
scripts/chaos/

Examples:

bash
Copy code
./scripts/chaos/break_demo_app_service.sh
./scripts/chaos/break_permissions.sh
./scripts/chaos/ssh_lockout_allowusers.sh
Each script introduces a controlled failure intended to be recovered via the corresponding runbook.

Ansible Automation
Roles included:

baseline: troubleshooting tools + utilities

ssh_hardening: disable root, disable password auth, validate config (sshd -t)

ufw: default deny inbound, allow SSH from approved CIDRs

fail2ban: sshd jail

demo_app: deploy sample systemd service for drills

audit: verify effective config + service health

Run:

bash
Copy code
cd ansible
ansible-playbook playbooks/site.yml --private-key ~/.ssh/<your-key>.pem
ansible-playbook playbooks/audit.yml --private-key ~/.ssh/<your-key>.pem
Evidence Collection
Capture command outputs and observations in:
docs/evidence/commands-and-outputs.md

This mirrors real incident documentation practices.

Skills Demonstrated
Linux system hardening

systemd internals + troubleshooting

Boot + filesystem recovery

Disk usage analysis

Permissions debugging

SSH recovery + break-glass access

AWS SSM Session Manager operations

Ansible role design + auditing mindset

Runbook-driven incident response

yaml
Copy code



