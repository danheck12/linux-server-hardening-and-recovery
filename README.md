# Linux Server Hardening, Recovery, and Automation Lab

## Overview

This project is a hands-on Linux engineering lab focused on **system hardening, failure injection, incident response, recovery procedures, and automation**.  
It demonstrates real-world Linux operational scenarios including boot failures, disk exhaustion, systemd service crashes, permissions incidents, and SSH lockouts — all recovered using production-grade methods.

The project is intentionally designed to simulate **real production incidents**, recover from them safely, and document each scenario with detailed operational runbooks.

This repository showcases **practical Linux engineering and SRE skills**, not just theoretical knowledge.

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

- **Platform:** AWS EC2
- **Operating System:** Ubuntu 24.04 LTS
- **Access Methods:**
  - SSH (key-based)
  - AWS SSM Session Manager (break-glass recovery)
- **Storage:**
  - Root EBS volume
  - Secondary EBS volume for filesystem and fstab recovery drills

---

## Repository Structure

.
├── README.md
├── docs
│ ├── runbooks
│ │ ├── R2-broken-fstab.md
│ │ ├── R3-disk-full.md
│ │ ├── R4-systemd-service-failure.md
│ │ ├── R5-permissions-ownership-incident.md
│ │ └── R6-ssh-lockout-recovery.md
│ └── evidence
│ └── commands-and-outputs.md
├── scripts
│ └── chaos
│ ├── break_demo_app_service.sh
│ ├── break_permissions.sh
│ └── ssh_lockout_allowusers.sh
└── ansible
├── ansible.cfg
├── inventory
│ └── hosts.ini
├── group_vars
│ └── all.yml
├── playbooks
│ ├── site.yml
│ └── audit.yml
└── roles
├── baseline
├── ssh_hardening
├── ufw
├── fail2ban
├── demo_app
└── audit

markdown
Copy code

---

## Implemented Recovery Scenarios

### R2 – Broken `/etc/fstab` Boot Failure
- Invalid filesystem mount entry injected
- System drops to emergency mode during boot
- Recovery using SSM, root remount, and fstab correction

### R3 – Disk Full Incident
- Root filesystem exhaustion
- Services and commands fail due to lack of space
- Diagnosis using `df`, `du`, and `journalctl`
- Cleanup and recovery procedures documented

### R4 – systemd Service Failure
- Misconfigured `ExecStart` directive
- Service fails to start and enters failed state
- Diagnosis using `systemctl`, `journalctl`, and `systemd-analyze`
- Unit file correction and service restoration

### R5 – Permissions and Ownership Incident
- Application unable to write to log directory
- Diagnosis using `ls -l`, `namei`, and `getfacl`
- Ownership and permission correction
- Service recovery verified

### R6 – SSH Lockout Recovery
- Accidental access restriction via `sshd_config`
- New SSH sessions blocked
- Recovery performed using AWS SSM Session Manager
- SSH access safely restored

---

## Chaos Engineering Scripts

Failure scenarios are injected using scripts located in:

scripts/chaos/

bash
Copy code

Examples:

``bash
./scripts/chaos/break_demo_app_service.sh
./scripts/chaos/break_permissions.sh
./scripts/chaos/ssh_lockout_allowusers.sh
Each script introduces a controlled failure that is then resolved using the documented runbooks.

Ansible Automation
This project includes full Ansible automation to enforce baseline configuration, hardening, service deployment, and auditing.

Automated Components
Baseline Role

Common troubleshooting tools (tmux, jq, sysstat, iotop, tcpdump, etc.)

System utilities and observability tooling

SSH Hardening Role

Disable root login

Disable password authentication

Enforce AllowUsers

Validate configuration with sshd -t before reload

UFW Firewall Role

Default deny incoming

Allow SSH only from approved CIDRs

fail2ban Role

sshd jail configuration

Brute-force protection

demo-app Role

Deploys a sample systemd service

Used for service failure drills (R4)

Audit Role

Verifies:

SSH effective settings

UFW firewall state

fail2ban status

demo-app service health

Main Playbook
bash
Copy code
ansible-playbook playbooks/site.yml --private-key ~/.ssh/linux-lab.pem
Audit Playbook
bash
Copy code
ansible-playbook playbooks/audit.yml --private-key ~/.ssh/linux-lab.pem
This ensures the system is both configured and continuously verifiable.

Evidence Collection
Command outputs, observations, and recovery steps are captured in:

bash
Copy code
docs/evidence/commands-and-outputs.md
This mirrors real operational incident documentation practices.

Skills Demonstrated
Linux system hardening

systemd internals and troubleshooting

Filesystem and boot recovery

Disk usage analysis and cleanup

Permissions and ownership debugging

SSH access recovery and break-glass procedures

AWS SSM Session Manager usage

Ansible automation and role design

Audit and compliance mindset

Incident response and runbook documentation

Cloud-based Linux operations (AWS EC2)

How to Use This Repository
Review the runbooks in docs/runbooks/

Use chaos scripts in scripts/chaos/ to inject failures

Follow runbook procedures to recover the system

Capture evidence in docs/evidence/commands-and-outputs.md

Apply automation using Ansible playbooks

Verify system state using the audit playbook

Disclaimer
This project intentionally breaks system components for learning purposes.
Do not run these drills on production systems.

Author
Built and maintained as part of a Linux engineering learning and portfolio project.


