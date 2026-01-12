# R6 – SSH Lockout Recovery

## Incident Summary
SSH access was unintentionally blocked after modifying `/etc/ssh/sshd_config`. New SSH sessions failed, requiring recovery using AWS SSM Session Manager.

---

## Impact
- New SSH sessions failed with "Permission denied"
- Risk of complete administrative lockout
- Existing SSH sessions remained active
- Break-glass access via SSM was required

---

## Root Cause
A restrictive `AllowUsers` directive was added, allowing only the `root` user and preventing the `ares` user from authenticating.

Misconfiguration example:

```text
AllowUsers root
Detection
From a new terminal:

bash
Copy code
ssh -i linux-lab.pem ares@<ec2-host>
Observed:

java
Copy code
Permission denied (publickey).
Recovery Procedure
1. Access host via AWS SSM Session Manager
Used AWS Systems Manager Session Manager to gain shell access when SSH was unavailable.

2. Edit sshd configuration
bash
Copy code
sudo nano /etc/ssh/sshd_config
Removed the restrictive line:

text
Copy code
AllowUsers root
3. Validate configuration
bash
Copy code
sudo sshd -t
No output indicates a valid configuration.

4. Reload SSH service safely
bash
Copy code
sudo systemctl reload ssh
Post-Recovery Validation
From local machine:

bash
Copy code
ssh -i linux-lab.pem ares@<ec2-host>
Access restored successfully.

Verified effective SSH settings:

bash
Copy code
sudo sshd -T | egrep 'allowusers|passwordauthentication|permitrootlogin'
Lessons Learned
Always keep a break-glass access method (SSM) before modifying SSH configuration.

Prefer systemctl reload ssh over restart to reduce risk.

Always validate configuration with sshd -t before applying changes.

Keep at least one active admin session open during access changes.

Prevention
Manage SSH configuration via Ansible.

Implement peer review for access control changes.

Use CI checks where possible.

Maintain versioned backups of critical configuration files.

Evidence
bash
Copy code
sshd -t
systemctl reload ssh
ssh -i linux-lab.pem ares@<ec2-host>
SSH access was successfully restored.

