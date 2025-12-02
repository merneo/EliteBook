# Silent Fingerprint Authentication Configuration

**Date:** 2025-12-02  
**Status:** ✅ Configuration Guide

---

## Problem Statement

When both IR camera (Howdy) and fingerprint authentication fail, the system should allow password entry. However, fingerprint authentication displays messages like:
- "Place your finger on the fingerprint reader"
- "Place your finger on the reader again"
- "Place your finger on the reader again"

These messages are intrusive and prevent direct password entry.

---

## Solution

Configure PAM to use silent fingerprint authentication with proper password fallback.

### Method 1: Using PAM Configuration (Recommended)

Update PAM configuration to ensure proper fallback to password:

**`/etc/pam.d/sudo`:**
```
auth      sufficient  pam_python.so /lib/security/howdy/pam.py
auth      sufficient  pam_fprintd.so
auth      include     system-auth
```

**Important:** The `sufficient` keyword ensures:
- If Howdy succeeds → authentication passes (skip remaining)
- If Howdy fails → try fingerprint
- If fingerprint succeeds → authentication passes (skip remaining)
- If fingerprint fails → proceed to `system-auth` (password)

### Method 2: Suppressing Fingerprint Messages

Unfortunately, `pam_fprintd.so` does not have a built-in `quiet` parameter. However, we can:

1. **Reduce fingerprint timeout** - Make it fail faster if no finger is detected
2. **Use PAM conversation** - Redirect messages (requires custom PAM module)
3. **Accept that messages appear** - But ensure password prompt appears after failure

### Method 3: Custom PAM Wrapper (Advanced)

Create a wrapper that suppresses messages, but this is complex and not recommended.

---

## Recommended Configuration

### Current PAM Configuration

**`/etc/pam.d/sudo`:**
```
#%PAM-1.0
auth      sufficient  pam_python.so /lib/security/howdy/pam.py
auth      sufficient  pam_fprintd.so
auth      include     system-auth
account   include     system-auth
session   include     system-auth
```

**`/etc/pam.d/sddm`:**
```
#%PAM-1.0
auth        sufficient  pam_python.so /lib/security/howdy/pam.py
auth        sufficient  pam_fprintd.so
auth        include     system-login
account     include     system-login
session     include     system-login
```

### How It Works

1. **Howdy (IR Camera)** attempts authentication
   - If succeeds → login complete
   - If fails → continue to next method

2. **Fingerprint** attempts authentication
   - Displays: "Place your finger on the fingerprint reader"
   - If succeeds → login complete
   - If fails (after timeout/retries) → continue to next method

3. **Password** authentication
   - System prompts for password
   - User can enter password normally

### Expected Behavior

**At SDDM Login Screen:**
1. Auto-activation triggers (1 second delay)
2. Howdy attempts face recognition (silent, no messages)
3. If Howdy fails → Fingerprint activates
   - Message: "Place your finger on the fingerprint reader"
   - User can either:
     - Place finger on sensor (if available)
     - Wait for timeout (fingerprint fails)
     - Press Enter or start typing password (may interrupt fingerprint)
4. If fingerprint fails → Password field focuses
   - User can enter password directly

**In Terminal (sudo):**
1. Howdy attempts face recognition
2. If fails → Fingerprint prompt appears
   - Message: "Place your finger on the fingerprint reader"
   - User can either:
     - Place finger on sensor
     - Wait for timeout
     - Press Ctrl+C to cancel and try password (may not work)
3. If fingerprint fails → Password prompt appears
   - User enters password

---

## Limitation: Fingerprint Messages Cannot Be Fully Suppressed

**Important:** The `pam_fprintd.so` module does not support a `quiet` parameter. The messages are hardcoded in the PAM module and cannot be suppressed without modifying the source code.

**Workarounds:**
1. **Accept the messages** - They appear briefly before password prompt
2. **Use only Howdy** - Remove fingerprint from PAM if messages are too intrusive
3. **Wait for timeout** - Fingerprint will timeout and proceed to password

---

## Configuration Script

Use the provided script to ensure proper PAM configuration:

```bash
sudo ~/EliteBook/scripts/configure-silent-fingerprint.sh
```

**Note:** The script attempts to add `quiet` parameter, but it may not work if `pam_fprintd.so` doesn't support it. The script will still ensure proper fallback to password.

---

## Testing

### Test Password Fallback

1. **Clear sudo cache:**
   ```bash
   sudo -k
   ```

2. **Cover camera and don't use fingerprint:**
   ```bash
   sudo whoami
   ```

3. **Expected behavior:**
   - Howdy attempts (fails silently)
   - Fingerprint prompt appears: "Place your finger on the fingerprint reader"
   - Wait 5-10 seconds (fingerprint timeout)
   - Password prompt appears: `[sudo] password for user:`
   - Enter password → authentication succeeds

### Test at SDDM Login

1. **Reboot system:**
   ```bash
   sudo reboot
   ```

2. **At login screen:**
   - Wait 1 second (auto-activation)
   - Cover camera (Howdy fails)
   - Don't use fingerprint
   - Wait for fingerprint timeout
   - Password field should focus
   - Enter password → login succeeds

---

## Alternative: Remove Fingerprint from PAM

If fingerprint messages are too intrusive, you can remove fingerprint authentication:

```bash
# Edit PAM configuration
sudo nano /etc/pam.d/sudo

# Remove or comment out fingerprint line:
# auth      sufficient  pam_fprintd.so

# Keep only Howdy and password:
auth      sufficient  pam_python.so /lib/security/howdy/pam.py
auth      include     system-auth
```

**Result:**
- Howdy (face recognition) → Password
- No fingerprint messages
- Faster fallback to password

---

## Summary

✅ **Password fallback works** - If both Howdy and fingerprint fail, password prompt appears  
⚠️ **Fingerprint messages cannot be suppressed** - `pam_fprintd.so` doesn't support quiet mode  
✅ **Proper PAM configuration** - `sufficient` ensures correct fallback chain  
✅ **Auto-activation works** - SDDM automatically tries biometrics first

**Recommendation:** Accept fingerprint messages as they appear briefly before password prompt. If too intrusive, consider removing fingerprint from PAM and using only Howdy + Password.

---

**Last Updated:** 2025-12-02
