# R2 – Broken /etc/fstab Boot Failure Recovery

## Incident Summary
System failed to boot normally after an invalid entry was added to `/etc/fstab`. The instance dropped into emergency mode due to a failed mount.

This runbook documents the steps used to diagnose and recover the system.

---

## Impact
- System was not accessible via SSH
- Boot process halted due to filesystem mount failure
- Application services were unavailable

---

## Root Cause
An invalid device/UUID entry was added to `/etc/fstab`, causing the mount process to fail during boot.

---

## Detection
Symptoms observed:
- Instance failed to complete boot
- Console output indicated filesystem mount errors
- SSH was unavailable
- Emergency mode prompt displayed

---

## Recovery Procedure

### 1. Access the Instance via AWS SSM Session Manager
Used AWS Systems Manager Session Manager to gain shell access since SSH was unavailable.

---

### 2. Remount Root Filesystem as Read-Write

```bash
mount -o remount,rw /
Verify:

bash
Copy code
mount | grep ' / '
3. Edit /etc/fstab
bash
Copy code
nano /etc/fstab
Actions taken:

Located the invalid mount entry for /mnt/data

Commented out the broken line or corrected the UUID/device path

Example fix:

text
Copy code
# UUID=deadbeef-dead-beef-dead-beefdeadbeef  /mnt/data  ext4  defaults  0  2
UUID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx  /mnt/data  ext4  defaults,nofail  0  2
4. Reboot the System
bash
Copy code
reboot
5. Post-Recovery Validation
After reboot, verified filesystem mounts:

bash
Copy code
lsblk
df -h | grep /mnt/data
Verified system state:

bash
Copy code
systemctl --failed
No failed units reported.

Lessons Learned
Always test /etc/fstab changes with:

bash
Copy code
mount -a
before rebooting.

Use UUIDs instead of device names to avoid device renumbering issues.

The nofail option is critical for non-root filesystems to prevent boot blocking.

AWS SSM Session Manager is an essential recovery tool when SSH is unavailable.

Prevention
Always backup /etc/fstab before editing:

bash
Copy code
cp /etc/fstab /etc/fstab.bak.$(date +%F)
Validate mounts before reboot.

Use configuration management (Ansible) to enforce safe filesystem entries.

Evidence
Commands used during recovery:

bash
Copy code
mount -o remount,rw /
nano /etc/fstab
reboot
lsblk
df -h
Recovery was successful and the system returned to normal operation.







