# Evidence – Commands and Outputs

This document captures key commands and outputs observed during hardening and recovery drills.

---

## System Info

```bash
uname -a
cat /etc/os-release

# Linux Server Hardening and Recovery Lab

## Overview

This project is a hands-on Linux engineering lab focused on **system hardening, failure injection, incident response, and recovery procedures**.  
It demonstrates real-world Linux operational scenarios including boot failures, disk exhaustion, service crashes, and permissions incidents.

The goal is to build practical experience with:
- Linux system internals
- systemd troubleshooting
- filesystem recovery
- permissions and ownership debugging
- operational runbook documentation

This is designed to reflect **production-style Linux engineering work**.

---

## Architecture

- **Platform:** AWS EC2
- **OS:** Ubuntu 22.04 LTS
- **Access:** SSH + AWS SSM Session Manager
- **Storage:**
  - Root EBS volume
  - Secondary EBS volume for mount/fstab drills

---

## Project Structure

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
- Simulates invalid filesystem mount entry
- System drops to emergency mode
- Recovery using SSM + remount + fstab correction

### R3 – Disk Full Incident
- Root filesystem exhaustion
- Service and command failures
- Diagnosis with `du`, `df`, `journalctl`
- Cleanup and recovery

### R4 – systemd Service Failure
- Misconfigured `ExecStart` directive
- Diagnosis with `systemctl`, `journalctl`, `systemd-analyze`
- Unit file correction and service restoration

### R5 – Permissions and Ownership Incident
- Application unable to write logs
- Diagnosis with `ls -l`, `namei`, `getfacl`
- Ownership and permission correction

---

## Chaos Engineering Scripts

Failure scenarios are injected using scripts in:

scripts/chaos/

bash
Copy code

Examples:

```bash
./scripts/chaos/break_demo_app_service.sh
./scripts/chaos/break_permissions.sh
Each script intentionally introduces a failure that is then resolved using the documented runbooks.

Evidence
Command outputs and observations are captured in:

bash
Copy code
docs/evidence/commands-and-outputs.md
This mirrors real operational incident documentation.

Automation (Ansible)
The ansible/ directory is reserved for automating:

baseline configuration

hardening controls

service deployment

audit checks

Manual steps are implemented first to ensure understanding before automation.

Skills Demonstrated
Linux system hardening

systemd internals and troubleshooting

Filesystem and boot recovery

Permissions and ownership debugging

Incident response and runbook writing

Cloud-based Linux operations (EC2 + SSM)

Disclaimer
This project intentionally breaks system components for learning purposes.
Do not run these drills on production systems.


## R6 – SSH Lockout Recovery

Injected lockout by setting:

AllowUsers root

Observed:
- New SSH sessions failed with "Permission denied"
- Existing session remained active

Recovered via AWS SSM Session Manager:
- Removed restrictive AllowUsers directive
- Validated with sshd -t
- Reloaded SSH
- Verified SSH access restored

Commands used:

sshd -t
systemctl reload ssh
ssh ares@<host>
