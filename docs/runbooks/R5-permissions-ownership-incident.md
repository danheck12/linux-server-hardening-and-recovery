# R5 – Permissions and Ownership Incident Recovery

## Incident Summary
An application failed to write to its log directory due to incorrect ownership and permissions. This runbook documents the detection, diagnosis, and recovery process for a permissions-related production incident.

---

## Impact
- Application unable to write logs
- Potential service failure or degraded functionality
- Error messages such as "Permission denied"
- Operational visibility lost due to missing logs

---

## Root Cause
The log directory `/var/log/demo-app` was owned by `root:root` with restrictive permissions, preventing the application user from writing to it.

---

## Detection

Symptoms observed:
- Application errors indicating permission denied
- Log files not being created or updated
- Service may fail to start or function correctly

Initial check:

```bash
ls -ld /var/log/demo-app
Example output:

bash
Copy code
drwx------ 2 root root 4096 Jan 11 10:42 /var/log/demo-app
Diagnosis
1. Check ownership and permissions
bash
Copy code
ls -ld /var/log/demo-app
2. Inspect full path permissions
bash
Copy code
namei -l /var/log/demo-app
This command shows permissions on every directory in the path.

3. Check Access Control Lists (if used)
bash
Copy code
getfacl /var/log/demo-app
4. Identify application user
bash
Copy code
ps aux | grep demo-app
or

bash
Copy code
systemctl status demo-app --no-pager
Look for the User= directive.

Recovery Procedure
1. Correct ownership
Assuming application user is ubuntu and group is adm:

bash
Copy code
sudo chown -R ubuntu:adm /var/log/demo-app
2. Fix permissions
bash
Copy code
sudo chmod 750 /var/log/demo-app
This results in:

owner: read/write/execute

group: read/execute

others: no access

3. Verify permissions
bash
Copy code
ls -ld /var/log/demo-app
Expected:

bash
Copy code
drwxr-x--- 2 ubuntu adm 4096 Jan 11 10:45 /var/log/demo-app
4. Restart the service
bash
Copy code
sudo systemctl restart demo-app
5. Validate log writing
bash
Copy code
journalctl -u demo-app -n 20 --no-pager
ls -l /var/log/demo-app
Log files should now be created or updated.

Post-Recovery Validation
bash
Copy code
systemctl status demo-app --no-pager
systemctl --failed
No failed units should be present.

Lessons Learned
Incorrect ownership is a common cause of production incidents.

Always verify full path permissions using namei.

Do not assume parent directories have correct permissions.

Applications should never run as root unless absolutely required.

Prevention
Use configuration management (Ansible) to enforce ownership and permissions.

Define application users explicitly in systemd unit files.

Set directory permissions at deploy time, not manually.

Use consistent group ownership for shared directories.

Evidence
Commands used during recovery:

bash
Copy code
ls -ld /var/log/demo-app
namei -l /var/log/demo-app
getfacl /var/log/demo-app
chown -R ubuntu:adm /var/log/demo-app
chmod 750 /var/log/demo-app
systemctl restart demo-app
Permissions restored and service recovered successfully.

yaml
Copy code

---

# Optional (but very strong) – Chaos Script for R5

If you want this drill to be **repeatable and clean**, create:

scripts/chaos/break_permissions.sh

bash
Copy code

and paste:

```bash
#!/usr/bin/env bash
set -e

TARGET_DIR="/var/log/demo-app"

echo "[*] Creating log directory if missing..."
sudo mkdir -p $TARGET_DIR

echo "[*] Breaking permissions (root:root, 700)..."
sudo chown root:root $TARGET_DIR
sudo chmod 700 $TARGET_DIR

echo "[*] Current state:"
ls -ld $TARGET_DIR

echo "[*] Permissions incident injected."
Make executable:

bash
Copy code
chmod +x scripts/chaos/break_permissions.sh
Run it:

bash
Copy code
./scripts/chaos/break_permissions.sh
Then recover using the runbook.

