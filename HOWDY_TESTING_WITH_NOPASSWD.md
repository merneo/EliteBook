# Howdy Testing with NOPASSWD Configuration

**Issue Discovered:** 2025-12-02  
**Problem:** Sudo is configured with NOPASSWD, making Howdy testing impossible

---

## Problem

### Current Sudo Configuration

The system has `NOPASSWD` configured in `/etc/sudoers`:

```
%wheel ALL=(ALL) NOPASSWD: ALL
<USERNAME> ALL=(ALL) NOPASSWD: ALL
```

**This means:**
- Sudo does **NOT** require password for wheel group members
- Sudo does **NOT** require password for user `<USERNAME>`
- **Howdy cannot be tested** because sudo never prompts for authentication
- Previous test results were **invalid** - sudo worked without Howdy

---

## Solution Options

### Option 1: Remove NOPASSWD for Wheel Group (Recommended)

**Change sudoers configuration:**

```bash
# Edit sudoers
sudo visudo

# Find this line:
%wheel ALL=(ALL) NOPASSWD: ALL

# Change to:
%wheel ALL=(ALL:ALL) ALL

# Save and exit
```

**Result:**
- Wheel group members must authenticate (password or Howdy)
- Howdy can be properly tested
- More secure configuration

### Option 2: Remove NOPASSWD for Specific User

**Remove user-specific NOPASSWD:**

```bash
# Edit sudoers
sudo visudo

# Find and remove this line:
<USERNAME> ALL=(ALL) NOPASSWD: ALL

# Save and exit
```

**Result:**
- User `<USERNAME>` must authenticate
- Wheel group still has NOPASSWD (if desired)
- Howdy can be tested for this user

### Option 3: Keep NOPASSWD, Test Howdy with Alternative Method

**Test Howdy with `su` command (if configured):**

```bash
# Configure su to use Howdy
sudo nano /etc/pam.d/su

# Add at the top:
auth      sufficient  pam_python.so /lib/security/howdy/pam.py

# Test with:
su - root
```

**Note:** This requires root password or Howdy authentication

---

## Recommended Approach

### Step 1: Remove NOPASSWD

```bash
# Backup sudoers
sudo cp /etc/sudoers /etc/sudoers.backup.$(date +%Y%m%d_%H%M%S)

# Edit sudoers
sudo visudo

# Change:
# FROM: %wheel ALL=(ALL) NOPASSWD: ALL
# TO:   %wheel ALL=(ALL:ALL) ALL

# Remove user-specific NOPASSWD if present:
# DELETE: <USERNAME> ALL=(ALL) NOPASSWD: ALL
```

### Step 2: Verify Configuration

```bash
# Check sudoers syntax
sudo visudo -c

# Should show: /etc/sudoers: parsed OK
```

### Step 3: Test Howdy

```bash
# Clear sudo cache
sudo -k

# Test sudo (should require authentication)
sudo whoami

# Expected:
# 1. Camera activates
# 2. Face recognition occurs
# 3. Authentication succeeds without password
# 4. Command executes: "root"
```

### Step 4: Verify Howdy is Working

```bash
# Temporarily disable Howdy PAM line
sudo sed -i '1s/^/# DISABLED: /' /etc/pam.d/sudo

# Test sudo (should require password now)
sudo -k
sudo whoami
# Should prompt for password

# Re-enable Howdy
sudo sed -i '1s/^# DISABLED: //' /etc/pam.d/sudo

# Test sudo (should use Howdy)
sudo -k
sudo whoami
# Should use face recognition
```

---

## Security Considerations

### NOPASSWD Security Risk

**Why NOPASSWD is risky:**
- Anyone with access to your user account can run sudo without authentication
- No protection if account is compromised
- Reduces security posture

### Recommended Configuration

**Secure configuration:**
```
%wheel ALL=(ALL:ALL) ALL
```

**Benefits:**
- Requires authentication (password or biometric)
- Howdy can provide convenient authentication
- Falls back to password if Howdy fails
- Better security posture

---

## Testing Procedure After Fix

### Test 1: Verify Password Authentication Works

```bash
# Disable Howdy temporarily
sudo sed -i '1s/^/# DISABLED: /' /etc/pam.d/sudo

# Clear sudo cache
sudo -k

# Test sudo (should require password)
sudo whoami
# Enter password when prompted

# Re-enable Howdy
sudo sed -i '1s/^# DISABLED: //' /etc/pam.d/sudo
```

### Test 2: Verify Howdy Works

```bash
# Clear sudo cache
sudo -k

# Test sudo (should use Howdy)
sudo whoami

# Expected:
# - Camera activates
# - Face recognition (2-5 seconds)
# - Authentication succeeds
# - Command executes: "root"
```

### Test 3: Verify Fallback to Password

```bash
# Cover camera or look away
sudo -k
sudo whoami

# Expected:
# - Camera activates
# - Face recognition fails (no face detected)
# - Falls back to password prompt
# - Enter password
# - Command executes: "root"
```

---

## Current Configuration Status

### Sudo Configuration
- **File:** `/etc/sudoers`
- **Wheel group:** `NOPASSWD: ALL` ⚠️
- **User <USERNAME>:** `NOPASSWD: ALL` ⚠️
- **Status:** ⚠️ **NOPASSWD enabled - Howdy cannot be tested**

### Howdy Configuration
- **Installation:** ✅ Complete
- **Face model:** ✅ Enrolled
- **PAM integration:** ✅ Configured
- **Camera:** ✅ Working
- **Testing:** ❌ **Cannot test due to NOPASSWD**

---

## Next Steps

1. **Decide on security policy:**
   - Keep NOPASSWD (convenient but less secure)
   - Remove NOPASSWD (more secure, enables Howdy testing)

2. **If removing NOPASSWD:**
   - Edit `/etc/sudoers` with `sudo visudo`
   - Change wheel group configuration
   - Remove user-specific NOPASSWD
   - Test Howdy authentication

3. **If keeping NOPASSWD:**
   - Howdy will not be used for sudo
   - Can still configure for SDDM login
   - Consider security implications

---

## References

- [ArchWiki Sudo](https://wiki.archlinux.org/title/Sudo)
- [Sudo Manual](https://www.sudo.ws/docs/man/)
- [Howdy GitHub](https://github.com/boltgolt/howdy)

---

**Status:** ⚠️ NOPASSWD configuration prevents Howdy testing  
**Action Required:** Remove NOPASSWD to enable Howdy testing
