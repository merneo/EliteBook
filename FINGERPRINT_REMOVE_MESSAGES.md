# Remove Fingerprint Messages - Configuration Guide

**Date:** 2025-12-02  
**Status:** ✅ Solution Available

---

## Problem

Fingerprint authentication displays intrusive messages:
- "Place your finger on the fingerprint reader"
- "Place your finger on the reader again"
- "Place your finger on the reader again"

These messages prevent direct password entry and are annoying when you want to use password instead.

---

## Solution: Remove Fingerprint from PAM

Since `pam_fprintd.so` does not support suppressing messages, the best solution is to remove fingerprint authentication from PAM configuration. This leaves:
- **Howdy (face recognition)** - Silent, no messages
- **Password** - Always available

**Result:** Clean authentication flow without fingerprint messages.

---

## Quick Setup

### Step 1: Remove Fingerprint from PAM

**Note:** Configuration scripts have been removed from version 1.0. Manual configuration is required. Automated scripts will be available in version 2.0.

**Manual steps:**

1. **Backup PAM configurations:**
```bash
sudo cp /etc/pam.d/sudo /etc/pam.d/sudo.backup
sudo cp /etc/pam.d/sddm /etc/pam.d/sddm.backup
sudo cp /etc/pam.d/system-login /etc/pam.d/system-login.backup
```

2. **Remove fingerprint authentication:**
```bash
# Remove from sudo
sudo sed -i '/pam_fprintd.so/d' /etc/pam.d/sudo

# Remove from SDDM
sudo sed -i '/pam_fprintd.so/d' /etc/pam.d/sddm

# Remove from system-login
sudo sed -i '/pam_fprintd.so/d' /etc/pam.d/system-login
```

This removes fingerprint authentication from PAM files, leaving Howdy and password authentication intact.

### Step 2: Verify Configuration

```bash
# Check sudo PAM configuration
cat /etc/pam.d/sudo | grep -E "howdy|fprintd|system-auth"

# Should show:
# auth      sufficient  pam_python.so /usr/lib/security/howdy/pam.py
# auth      include     system-auth
# (No fingerprint line)
```

### Step 3: Test

```bash
# Clear sudo cache
sudo -k

# Test sudo (cover camera to make Howdy fail)
sudo whoami

# Expected:
# 1. Howdy attempts (fails silently)
# 2. Password prompt appears immediately: "[sudo] password for user:"
# 3. No fingerprint messages!
```

---

## Manual Configuration

If you prefer to configure manually:

### Edit Sudo PAM Configuration

```bash
sudo nano /etc/pam.d/sudo
```

**Comment out or remove the fingerprint line:**
```
#%PAM-1.0
auth      sufficient  pam_python.so /usr/lib/security/howdy/pam.py
# auth      sufficient  pam_fprintd.so  <-- Comment this out
auth      include     system-auth
account   include     system-auth
session   include     system-auth
```

### Edit SDDM PAM Configuration

```bash
sudo nano /etc/pam.d/sddm
```

**Comment out or remove the fingerprint line:**
```
#%PAM-1.0
auth        sufficient  pam_python.so /usr/lib/security/howdy/pam.py
# auth        sufficient  pam_fprintd.so  <-- Comment this out
auth        include     system-login
account     include     system-login
session     include     system-login
```

---

## Authentication Flow After Removal

### Sudo Authentication

1. **Howdy (face recognition)** attempts
   - Silent, no messages
   - If succeeds → authentication passes
   - If fails → proceed to password

2. **Password** authentication
   - Prompt: `[sudo] password for user:`
   - Enter password → authentication passes

### SDDM Login

1. **Auto-activation** triggers (1 second delay)
2. **Howdy (face recognition)** attempts
   - Silent, no messages
   - If succeeds → login complete
   - If fails → proceed to password

3. **Password** field focuses
   - Enter password → login complete

**Result:** Clean, fast authentication without fingerprint messages!

---

## Restore Fingerprint (If Needed)

If you want to restore fingerprint authentication later:

```bash
# Manual configuration required - see Step 1 above
```

Or manually add the line back:
```bash
sudo nano /etc/pam.d/sudo
# Add: auth      sufficient  pam_fprintd.so
```

---

## Benefits

✅ **No fingerprint messages** - Clean authentication experience  
✅ **Faster password fallback** - No waiting for fingerprint timeout  
✅ **Still have face recognition** - Convenient biometric authentication  
✅ **Password always available** - Reliable fallback  
✅ **Simpler authentication flow** - Howdy → Password (2 methods instead of 3)

---

## Summary

**Problem:** Fingerprint messages are intrusive and cannot be suppressed  
**Solution:** Remove fingerprint from PAM configuration  
**Result:** Clean authentication flow (Howdy → Password) without fingerprint messages  
**Status:** ✅ Script available, ready to use

---

**Last Updated:** 2025-12-02
