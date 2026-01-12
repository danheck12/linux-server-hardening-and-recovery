R3 – Disk Full Runbook
# R3 – Disk Full Incident Response

## Incident Summary
The root filesystem became fully utilized, causing system services to fail and normal operations to degrade. This runbook documents the detection, diagnosis, and recovery process.

---

## Impact
- System commands failed or hung
- Services unable to write logs or temp files
- Risk of application crashes and data loss
- Potential inability to SSH or use sudo

---

## Root Cause
A large file was created in `/var/tmp/chaos/` which consumed all available space on the root filesystem.

---

## Detection

Symptoms observed:
- `sudo` commands failing
- Applications reporting "No space left on device"
- System instability

Verification:

```bash
df -h


Example output:

Filesystem      Size  Used Avail Use% Mounted on
/dev/nvme0n1p1   20G   20G     0 100% /

Diagnosis

Identify top-level directories consuming space:

sudo du -xhd1 / | sort -h


Drill down into problem areas:

sudo du -xhd1 /var | sort -h
sudo du -xhd1 /var/tmp | sort -h


Locate largest files:

sudo find / -xdev -type f -size +500M -exec ls -lh {} \;

Recovery Procedure
1. Remove the offending file(s)
sudo rm -f /var/tmp/chaos/fill

2. Clean up system logs (safe cleanup)
sudo journalctl --disk-usage
sudo journalctl --vacuum-time=7d

3. Recheck disk space
df -h


Expected result:

Filesystem      Size  Used Avail Use% Mounted on
/dev/nvme0n1p1   20G   8G   12G  40% /

4. Verify system stability
systemctl --failed


No failed units should be reported.

Post-Recovery Validation
df -h
free -m
uptime


System returned to normal operation.

Lessons Learned

Disk exhaustion can break core system functionality.

Always investigate large directories with du before deleting files.

journalctl log rotation is critical on small root volumes.

Application temp directories should be monitored.

Prevention

Implement log rotation policies.

Monitor disk usage via alerts (CloudWatch/Prometheus in production).

Separate application data onto dedicated volumes.

Enforce quotas on shared directories.

Evidence

Commands used during incident:

df -h
du -xhd1 /
find / -xdev -type f -size +500M
rm -f /var/tmp/chaos/fill
journalctl --vacuum-time=7d


Recovery was successful.


---

# R4 – systemd Service Failure Runbook

```markdown
# R4 – systemd Service Failure Recovery

## Incident Summary
The `demo-app` systemd service failed to start due to a misconfigured `ExecStart` directive. This runbook documents how the failure was diagnosed and resolved.

---

## Impact
- Application service unavailable
- systemd repeatedly attempted restarts
- Log noise generated in journald

---

## Root Cause
The `ExecStart` path in `/etc/systemd/system/demo-app.service` was modified to point to a non-existent binary.

---

## Detection

Service status check:

```bash
systemctl status demo-app --no-pager


Observed:

failed (Result: exit-code)

No such file or directory

Diagnosis

View detailed logs:

journalctl -u demo-app -n 50 --no-pager


Validate unit file:

systemd-analyze verify /etc/systemd/system/demo-app.service


Check ExecStart path:

grep ExecStart /etc/systemd/system/demo-app.service

Recovery Procedure
1. Fix the systemd unit file
sudo nano /etc/systemd/system/demo-app.service


Correct line:

ExecStart=/opt/demo-app/demo-app.sh

2. Reload systemd daemon
sudo systemctl daemon-reload

3. Restart the service
sudo systemctl restart demo-app

4. Verify service status
sudo systemctl status demo-app --no-pager


Expected:

Active: active (running)

5. Verify application logs
journalctl -u demo-app -n 20 --no-pager

Post-Recovery Validation
systemctl is-enabled demo-app
systemctl --failed


No failed units present.

Lessons Learned

Always validate unit files before restarting services.

journalctl is the primary source of truth for service failures.

systemd-analyze verify helps catch configuration errors.

Keep application paths immutable and controlled via automation.

Prevention

Use configuration management (Ansible) to manage unit files.

Implement CI checks for systemd units where possible.

Avoid manual edits on production systems.

Maintain backups of unit files.

Evidence

Commands used during recovery:

systemctl status demo-app
journalctl -u demo-app
systemd-analyze verify /etc/systemd/system/demo-app.service
systemctl daemon-reload
systemctl restart demo-app


Service successfully restored.
