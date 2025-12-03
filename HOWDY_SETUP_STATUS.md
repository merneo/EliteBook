# Howdy Face Recognition Setup Status

**Date:** 2025-12-01  
**System:** HP EliteBook x360 1030 G2 - Arch Linux  
**User:** <USERNAME>

---

## Current Status

### ✅ Completed Configuration

1. **Howdy Installation**
   - Version: 2.6.1
   - Location: `/usr/bin/howdy`
   - Status: Installed and functional

2. **IR Camera Detection**
   - Device ID: `04f2:b58e` (Chicony Electronics Co., Ltd HP IR Camera)
   - Video Device: `/dev/video2`
   - Status: Detected and accessible

3. **Howdy Configuration**
   - Config File: `/usr/lib/security/howdy/config.ini`
   - Device Path: `/dev/video2` ✅
   - Timeout: 4 seconds
   - Status: Configured

4. **PAM Configuration**
   - Sudo PAM: `/etc/pam.d/sudo`
   - Howdy PAM Line: `auth sufficient pam_python.so /usr/lib/security/howdy/pam.py` ✅
   - Backup Created: `/etc/pam.d/sudo.backup.20251201_*`
   - Status: Configured

5. **User Permissions**
   - User: `<USERNAME>`
   - Video Group: Member ✅
   - Status: Permissions correct

### ⚠️ Pending: Face Model Enrollment

**Status:** Face model not yet enrolled

**Required Action:** Interactive enrollment needed

---

## Next Steps: Complete Face Model Enrollment

### Step 1: Enroll Face Model

Run the following command to start interactive enrollment:

```bash
sudo howdy add
```

**Or for specific user:**

```bash
sudo howdy -U <USERNAME> add
```

### Step 2: Enrollment Process

1. **Position yourself:**
   - Stand 30-60 cm from the camera
   - Look directly at the camera
   - Ensure good lighting (IR camera works in low light)

2. **Follow prompts:**
   - Enter a label for the face model (e.g., "Initial model" or "<USERNAME>")
   - Wait for camera to capture your face
   - Repeat 3-5 times for better accuracy

3. **Expected output:**
   ```
   Adding face model for the user <USERNAME>
   Enter a label for this new model [Initial model] (max 24 characters): 
   [Enter label]
   Opening camera...
   Look straight into the camera until it turns green
   [Camera captures face multiple times]
   Face model saved successfully
   ```

### Step 3: Verify Enrollment

```bash
# List enrolled face models
sudo howdy list

# Expected output:
# Known face models:
# <USERNAME> (ID: 0)
```

### Step 4: Test Face Recognition

```bash
# Test sudo authentication with face recognition
sudo whoami

# Expected behavior:
# 1. Camera activates (IR LED may turn on)
# 2. Face detection occurs (2-5 seconds)
# 3. Authentication succeeds without password prompt
# 4. Command executes: "root"
```

---

## Configuration Details

### Howdy Configuration File

**Location:** `/usr/lib/security/howdy/config.ini`

**Key Settings:**
```ini
[video]
device_path = /dev/video2

[timeout]
timeout = 4
```

### PAM Configuration

**File:** `/etc/pam.d/sudo`

**Current Configuration:**
```
auth      sufficient  pam_python.so /usr/lib/security/howdy/pam.py
#%PAM-1.0
auth		include		system-auth
account		include		system-auth
session		include		system-auth
```

**Explanation:**
- `sufficient`: If Howdy authentication succeeds, no password is required
- If Howdy fails, PAM falls back to password authentication
- Howdy line is placed before `system-auth` for proper fallback behavior

---

## Troubleshooting

### Issue: Camera Test Fails

**Symptoms:**
```
Authorization required, but no authorization protocol specified
qt.qpa.xcb: could not connect to display
```

**Solution:**
- This is normal in headless/terminal environment
- Camera test requires X11/Wayland display
- Enrollment should work despite this error
- Camera access works through Howdy's own mechanism

### Issue: Face Recognition Not Working

**Check:**
```bash
# Verify face model exists
sudo howdy list

# Check camera access
sudo howdy test

# Review Howdy logs
sudo journalctl -u howdy -n 50

# Check PAM configuration
grep -i howdy /etc/pam.d/sudo
```

**Solutions:**
- Re-enroll face model: `sudo howdy remove` then `sudo howdy add`
- Verify device path: `sudo grep device_path /usr/lib/security/howdy/config.ini`
- Check camera permissions: `ls -la /dev/video2`
- Ensure user is in video group: `groups $USER`

### Issue: Authentication Always Fails

**Possible Causes:**
1. Face model not enrolled
2. Camera not accessible
3. PAM configuration incorrect
4. Lighting conditions too poor

**Solutions:**
1. Enroll face model: `sudo howdy add`
2. Test camera: `sudo howdy test`
3. Verify PAM: Check `/etc/pam.d/sudo` has Howdy line
4. Re-enroll in better lighting conditions

---

## Additional Configuration (Optional)

### Configure SDDM Login Authentication

For face recognition at login screen:

```bash
# Backup SDDM PAM configuration
sudo cp /etc/pam.d/sddm /etc/pam.d/sddm.backup

# Edit SDDM PAM configuration
sudo nano /etc/pam.d/sddm

# Add at the TOP of the file:
auth      sufficient  pam_python.so /usr/lib/security/howdy/pam.py

# Save and exit
```

**Note:** SDDM login screen may require additional configuration for camera access during login.

### Adjust Howdy Settings

```bash
# Open Howdy configuration editor
sudo howdy config

# Recommended settings:
# [video]
# device_path = /dev/video2
# 
# [snapshots]
# capture_failed = true          # Save failed authentication attempts
# capture_successful = false      # Don't save successful authentications
# 
# [timeout]
# detection_timeout = 5          # Seconds to wait for face detection
# 
# [core]
# no_confirmation = false         # Require confirmation for model deletion
```

---

## Commands Reference

### Howdy Management

```bash
# Enroll face model
sudo howdy add

# List enrolled models
sudo howdy list

# Remove face model
sudo howdy remove

# Test camera
sudo howdy test

# Open configuration editor
sudo howdy config

# Check version
howdy --version
```

### Verification Commands

```bash
# Check camera detection
lsusb | grep -i "IR Camera"
v4l2-ctl --list-devices

# Check video device
ls -la /dev/video2

# Check Howdy configuration
sudo cat /usr/lib/security/howdy/config.ini | grep device_path

# Check PAM configuration
grep -i howdy /etc/pam.d/sudo

# Check user groups
groups $USER
```

---

## References

- [Howdy GitHub Repository](https://github.com/boltgolt/howdy)
- [Howdy Wiki](https://github.com/boltgolt/howdy/wiki)
- [ArchWiki Howdy](https://wiki.archlinux.org/title/Howdy)
- [dlib Documentation](http://dlib.net/)
- [PAM Documentation](https://www.linux-pam.org/)

---

## Installation Script

An automated installation script is available at:
- `HOWDY_SETUP_MANUAL.md` (installation guide)

**Usage:**
```bash
cd EliteBook/scripts
# See HOWDY_SETUP_MANUAL.md for installation instructions
```

**Options:**
- `--skip-dlib`: Skip python-dlib installation (if already installed)
- `--skip-enroll`: Skip face enrollment (enroll manually later)

---

**Last Updated:** 2025-12-01  
**Status:** Configuration complete, enrollment pending
