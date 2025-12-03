# Sudo Authentication Configuration

**Last Updated:** 2025-12-02
**Status:** Password-based authentication (recommended)

---

## Overview

This document describes the recommended sudo configuration for the EliteBook system. The setup uses password-based authentication for privilege escalation, which is the standard and secure approach on Linux systems.

---

## Current Configuration

### Sudoers Rule

```
%wheel ALL=(ALL:ALL) ALL
```

**Interpretation:**
- `%wheel` - All members of the wheel group
- `ALL` (hosts) - Valid on all hosts
- `(ALL:ALL)` - Can execute commands as any user:group
- `ALL` (commands) - Can execute any command
- **Password authentication is implicitly required**

### File Permissions

```
-r--r-----  1 root  root  /etc/sudoers
```

---

## Verification

### Check Current Configuration

```bash
# View wheel group rule
sudo grep "^%wheel" /etc/sudoers

# Expected output:
# %wheel ALL=(ALL:ALL) ALL
```

### Verify No NOPASSWD Rules

```bash
# Search for NOPASSWD (should find nothing)
sudo grep -r "NOPASSWD" /etc/sudoers*

# If output appears, those rules need to be removed
```

### Validate Sudoers Syntax

```bash
# Check for syntax errors
sudo visudo -c

# Expected output:
# /etc/sudoers: parsed OK
```

---

## Security Principles

### Why Password Authentication?

1. **Universal** - Works on any system, any console
2. **Reliable** - No hardware dependencies
3. **Auditable** - All attempts are logged
4. **Flexible** - Can integrate with PAM modules

### Why Avoid NOPASSWD?

NOPASSWD creates security vulnerabilities:

- **Privilege escalation** - Malware/compromised apps can execute privileged commands silently
- **No protection** - Anyone with user access can become root
- **No audit trail** - No way to track who ran what

**Example threat:**
```bash
# With NOPASSWD enabled, malware could run:
sudo rm -rf /

# With password auth, malware cannot:
sudo rm -rf /  # Requires password - malware has no way to provide it
```

---

## PAM Integration

The sudo command integrates with Linux PAM (Pluggable Authentication Modules) through `/etc/pam.d/sudo`.

### Standard PAM Stack

```
auth       include      system-auth
account    include      system-auth
password   include      system-auth
session    include      system-auth
```

This stack:
1. Authenticates the user (via system-auth - password)
2. Checks account validity
3. Applies password policies
4. Starts a session

### Optional: Biometric Authentication Fallback

If face recognition (Howdy) is installed, it can be added as a fallback:

```
auth      sufficient  pam_python.so /usr/lib/security/howdy/pam.py
auth      include     system-auth
account   include     system-auth
password  include     system-auth
session   include     system-auth
```

**How this works:**
- `sufficient` - If Howdy succeeds, skip remaining auth modules
- Falls back to password if Howdy fails (no face detected, camera unavailable, etc.)
- Provides convenience without sacrificing security

---

## Common Tasks

### Edit Sudoers Safely

```bash
# Always use visudo - it validates syntax before saving
sudo visudo

# To edit a specific sudoers.d file:
sudo visudo -f /etc/sudoers.d/custom-rules
```

### Clear Authentication Cache

Sudo caches authentication for 15 minutes by default.

```bash
# Clear the cache (next sudo will require authentication)
sudo -k

# Test (should prompt for password)
sudo whoami
```

### Modify Cache Timeout

To change the authentication cache timeout:

```bash
sudo visudo

# Add to Defaults section:
Defaults timestamp_timeout=20  # 20 minutes instead of 15
```

### List Allowed Commands

```bash
# Show what commands the current user can run
sudo -l

# Output shows all permitted commands for your user
```

### View Sudo Logs

```bash
# Recent sudo attempts
sudo journalctl -u sudo -n 20

# Or via auth log (if available)
sudo tail -20 /var/log/auth.log
```

---

## Troubleshooting

### Sudo Not Requiring Password

**Check for NOPASSWD rules:**

```bash
sudo grep -r "NOPASSWD" /etc/sudoers*
```

**If found, remove them:**

```bash
# If in /etc/sudoers:
sudo visudo
# Remove any lines with NOPASSWD

# If in /etc/sudoers.d/:
sudo rm /etc/sudoers.d/filename-with-nopasswd
```

**Verify:**

```bash
sudo -k
sudo whoami  # Should prompt for password
```

### Syntax Errors

**If you get "sudoers file is world writable" or similar:**

```bash
# Check sudoers syntax
sudo visudo -c

# If errors appear, edit to fix:
sudo visudo

# Check file permissions (should be 440)
ls -l /etc/sudoers
```

### Authentication Failures

**Check logs:**

```bash
sudo journalctl -u sudo -n 20
```

**Common messages:**
- `1 incorrect password attempt` - Wrong password entered
- `sorry, try again` - User denied (not in sudoers group)
- `parse error in sudoers` - Syntax error in configuration

---

## Best Practices

### DO:

✅ Use `sudo visudo` to edit sudoers (validates syntax)
✅ Keep sudoers backups before major changes
✅ Test configuration after changes
✅ Monitor sudo logs for suspicious activity
✅ Use strong passwords
✅ Keep systems updated

### DON'T:

❌ Edit `/etc/sudoers` directly with a text editor
❌ Use NOPASSWD in production environments
❌ Share sudo passwords
❌ Leave sudo credentials in scripts or configs
❌ Run unnecessary commands with sudo
❌ Ignore failed authentication attempts in logs

---

## File Locations

| File | Purpose | Owner:Group | Perms |
|------|---------|------------|-------|
| `/etc/sudoers` | Main configuration | root:root | 440 |
| `/etc/sudoers.d/` | Additional rules | root:root | 440 |
| `/etc/pam.d/sudo` | PAM authentication | root:root | 644 |
| `/var/log/auth.log` | Authentication log | root:root | 640 |

---

## References

### Manual Pages

```bash
man sudo        # Sudo command reference
man sudoers     # Sudoers file format and rules
man visudo      # Safe sudoers editor
man pam         # PAM (Pluggable Authentication Modules)
```

### Documentation

- **ArchWiki Sudo:** https://wiki.archlinux.org/title/Sudo
- **Sudo Official:** https://www.sudo.ws/
- **Sudoers Manual:** https://www.sudo.ws/docs/man/sudoers/

### Related Topics

- PAM authentication: `/etc/pam.d/`
- User groups: `groups`, `usermod`
- Password management: `passwd`, `chage`

---

## Implementation Notes

### Testing Configuration

After any sudoers changes:

```bash
# 1. Verify syntax
sudo visudo -c

# 2. Clear cache
sudo -k

# 3. Test authentication
sudo whoami
```

### Recovery Procedures

If locked out from sudo:

1. **Physical console access** - Boot into recovery mode
2. **Live USB** - Boot from installation media and chroot
3. **Another admin account** - Use a separate admin user with sudo access

---

## Summary

The recommended configuration:

- **Authentication:** Password-based (secure default)
- **Group:** `wheel` has full sudo access
- **Logging:** All attempts logged to `/var/log/auth.log`
- **Flexibility:** Can integrate with PAM for biometric auth
- **Auditing:** Full audit trail of privilege escalation

This provides security, auditability, and flexibility while maintaining ease of use.

---

**Version:** 1.0
**Type:** Configuration Reference
**Scope:** System Administration
