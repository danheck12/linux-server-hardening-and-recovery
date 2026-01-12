# Linux Server Hardening and Recovery Lab

## Overview

This project is a hands-on Linux engineering lab focused on **system hardening, failure injection, incident response, and recovery procedures**.  
It demonstrates real-world Linux operational scenarios including boot failures, disk exhaustion, systemd service crashes, and permissions incidents.

The goal of this project is to simulate **production-style Linux incidents**, recover from them using proper tooling and methodology, and document the process with operational runbooks.

This repository is designed to showcase **practical Linux engineering skills**, not just theoretical knowledge.

---

## Objectives

- Harden a Linux server using best practices
- Simulate common production failures
- Diagnose issues using standard Linux tooling
- Recover systems safely and methodically
- Document recovery procedures in runbooks
- Prepare for automation using Ansible

---

## Architecture

- **Platform:** AWS EC2
- **Operating System:** Ubuntu 22.04 LTS
- **Access Methods:**
  - SSH (key-based)
  - AWS SSM Session Manager (for recovery scenarios)
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
│ │ └── R5-permissions-ownership-incident.md
│ └── evidence
│ └── commands-and-outputs.md
├── scripts
│ └── chaos
│ ├── break_demo_app_service.sh
│ └── break_permissions.sh
└── ansible
├── playbooks
├── roles
└── inventory

markdown
Copy code

---

## Implemented Scenarios

### R2 – Broken `/etc/fstab` Boot Failure
- Invalid filesystem mount entry added
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

---

## Chaos Engineering Scripts

Failure scenarios are injected using scripts located in:

scripts/chaos/

bash
Copy code

Examples:

```bash
./scripts/chaos/break_demo_app_service.sh
./scripts/chaos/break_permissions.sh
Each script introduces a controlled failure that is then resolved using the documented runbooks.

Evidence Collection
Command outputs, observations, and recovery steps are captured in:

bash
Copy code
docs/evidence/commands-and-outputs.md
This mirrors real operational incident documentation practices.

Automation (Ansible)
The ansible/ directory is reserved for automating:

Baseline system configuration

Hardening controls

Service deployment

Audit and compliance checks

Manual implementation is completed first to ensure full understanding before automation.

Skills Demonstrated
Linux system hardening

systemd internals and troubleshooting

Filesystem and boot recovery

Disk usage analysis and cleanup

Permissions and ownership debugging

Incident response and runbook documentation

Cloud-based Linux operations (AWS EC2 + SSM)

How to Use This Repository
Review the runbooks in docs/runbooks/

Use chaos scripts in scripts/chaos/ to inject failures

Follow runbook procedures to recover the system

Capture evidence in docs/evidence/commands-and-outputs.md

(Optional) Implement automation using Ansible

Disclaimer
This project intentionally breaks system components for learning purposes.
Do not run these drills on production systems.

Author
Built and maintained as part of a Linux engineering learning and portfolio project.

yaml
Copy code
