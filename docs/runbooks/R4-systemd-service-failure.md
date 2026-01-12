# R4 – systemd Service Failure Recovery

## Incident Summary
The `demo-app` systemd service failed to start due to a misconfigured `ExecStart` directive. This runbook documents the detection, diagnosis, and recovery steps used to restore service functionality.

---

## Impact
- Application service unavailable
- systemd entered a failed state for the service
- Repeated restart attempts generated log noise
- Dependent functionality was disrupted

---

## Root Cause
The `ExecStart` path in `/etc/systemd/system/demo-app.service` was modified to reference a non-existent binary, causing systemd to fail at service startup.

---

## Detection

Service health check:

```bash
systemctl status demo-app --no-pager
Observed:

php
Copy code
Active: failed (Result: exit-code)
Diagnosis
Check service status
bash
Copy code
systemctl status demo-app --no-pager
Review service logs
bash
Copy code
journalctl -u demo-app -n 50 --no-pager
Observed error:

yaml
Copy code
Failed at step EXEC spawning /opt/demo-app/does-not-exist.sh: No such file or directory
Validate unit file
bash
Copy code
systemd-analyze verify /etc/systemd/system/demo-app.service
Confirm ExecStart path
bash
Copy code
grep ExecStart /etc/systemd/system/demo-app.service
Recovery Procedure
1. Edit the systemd unit file
bash
Copy code
sudo nano /etc/systemd/system/demo-app.service
Correct the ExecStart line:

text
Copy code
ExecStart=/opt/demo-app/demo-app.sh
2. Reload systemd daemon
bash
Copy code
sudo systemctl daemon-reload
3. Restart the service
bash
Copy code
sudo systemctl restart demo-app
4. Verify service status
bash
Copy code
systemctl status demo-app --no-pager
Expected:

arduino
Copy code
Active: active (running)
5. Verify application logs
bash
Copy code
journalctl -u demo-app -n 20 --no-pager
Expected:

Regular timestamped log entries

No error messages

Post-Recovery Validation
bash
Copy code
systemctl is-enabled demo-app
systemctl --failed
No failed units should be present.

Lessons Learned
Always validate unit files before restarting services.

journalctl is the primary source of truth for diagnosing systemd issues.

systemd-analyze verify is valuable for catching configuration errors.

Avoid manual edits on production systems without change tracking.

Prevention
Manage systemd unit files using configuration management (Ansible).

Implement version control for service definitions.

Test changes in staging before applying to production.

Maintain backups of unit files.

Evidence
Commands used during recovery:

bash
Copy code
systemctl status demo-app
journalctl -u demo-app
systemd-analyze verify /etc/systemd/system/demo-app.service
systemctl daemon-reload
systemctl restart demo-app
Service successfully restored.

yaml
Copy code
