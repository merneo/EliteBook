# Howdy SDDM Login Screen Configuration

**Date:** 2025-12-02  
**Status:** ✅ Configured and Ready

---

## Current Configuration

### PAM Configuration ✅

**SDDM (`/etc/pam.d/sddm`):**
```
#%PAM-1.0

auth        sufficient  pam_python.so /usr/lib/security/howdy/pam.py
auth        include     system-login
...
```

**System Login (`/etc/pam.d/system-login`):**
```
#%PAM-1.0

auth       required   pam_shells.so
auth       sufficient  pam_python.so /usr/lib/security/howdy/pam.py
auth       requisite  pam_nologin.so
auth       include    system-auth
...
```

**Sudo (`/etc/pam.d/sudo`):**
```
#%PAM-1.0

auth      sufficient  pam_python.so /usr/lib/security/howdy/pam.py
auth      include     system-auth
...
```

### PAM Module ✅

- **pam_python.so**: `/usr/lib/security/pam_python.so` → `pam_python3.so`
- **Status**: Installed and working

### Howdy Configuration ✅

- **Face models**: Enrolled and ready
- **IR Camera**: `/dev/video2` configured
- **IR Emitter**: Auto-activated in enrollment and authentication

---

## How It Works

### SDDM Login Flow

1. **User appears at SDDM login screen**
2. **SDDM triggers PAM authentication**
3. **PAM loads howdy module** (`pam_python.so /usr/lib/security/howdy/pam.py`)
4. **Howdy attempts face recognition:**
   - Activates IR emitter
   - Captures frames from `/dev/video2`
   - Compares with enrolled face models
5. **Result:**
   - ✅ **Success**: User logged in automatically (no password needed)
   - ❌ **Failure**: Falls back to password authentication

### Authentication Priority

The `sufficient` keyword means:
- If Howdy succeeds → authentication complete, skip password
- If Howdy fails → continue to next auth method (password)

This ensures:
- ✅ Face recognition works when available
- ✅ Password fallback always available
- ✅ No lockout if camera fails

---

## Testing

### Test SDDM Login

1. **Reboot system:**
   ```bash
   sudo reboot
   ```

2. **At SDDM login screen:**
   - Position yourself 30-60 cm from camera
   - Look directly at camera
   - Wait 2-5 seconds for face detection
   - Should log in automatically if face recognized

3. **If face recognition fails:**
   - Password field appears
   - Enter password normally
   - Login works as usual

### Verify Configuration

```bash
# Check PAM configuration
cat /etc/pam.d/sddm | grep howdy

# Check face models
sudo howdy list

# Check camera
ls -la /dev/video2

# Check PAM module
ls -la /usr/lib/security/pam_python*.so
```

---

## Troubleshooting

### Issue: Face Recognition Not Working at SDDM

**Possible causes:**

1. **Camera permissions**
   - SDDM runs as `sddm` user
   - Camera device needs proper permissions

2. **IR emitter not activating**
   - Check if `linux-enable-ir-emitter` is installed
   - Verify IR emitter works: `sudo linux-enable-ir-emitter test`

3. **Lighting conditions**
   - Different lighting at login screen vs enrollment
   - Re-enroll in login screen location

4. **Face model quality**
   - Re-enroll face model: `sudo howdy remove && sudo howdy add`

**Solutions:**

```bash
# Check camera permissions
ls -la /dev/video2
# Should show: crw-rw----+ 1 root video

# Check if SDDM can access camera (after login)
sudo journalctl -u sddm -n 50 | grep -i camera

# Check Howdy logs
sudo journalctl -u howdy -n 50

# Re-enroll face model
sudo howdy remove
sudo howdy add
```

### Issue: Stuck at Login Screen

**Emergency procedures:**

1. **Use password authentication**
   - Click username field
   - Type username and password
   - Should work even if face recognition fails

2. **Use TTY console**
   - Press: `Ctrl+Alt+F2` (switch to TTY2)
   - Log in with username and password
   - Return to graphical: `Ctrl+Alt+F1`

3. **Disable Howdy temporarily**
   ```bash
   # From TTY or recovery
   sudo sed -i 's/^auth.*pam_python.so.*howdy/# &/' /etc/pam.d/sddm
   sudo sed -i 's/^auth.*pam_python.so.*howdy/# &/' /etc/pam.d/system-login
   ```

---

## Camera Permissions

### Current Setup

- **Device**: `/dev/video2` (HP IR Camera)
- **Permissions**: `crw-rw----+` (root:video)
- **Access**: Users in `video` group can access

### SDDM Access

SDDM runs as `sddm` user, which may not be in `video` group. However:
- PAM modules run with elevated privileges
- Howdy's `pam.py` should have camera access
- If issues occur, may need udev rules or group membership

### Optional: Add SDDM to Video Group

If camera access issues occur:

```bash
# Add sddm user to video group (if needed)
sudo usermod -aG video sddm

# Restart SDDM
sudo systemctl restart sddm
```

**Note:** This may not be necessary if PAM has proper permissions.

---

## Configuration Files

### Modified Files

1. **`/etc/pam.d/sddm`**
   - Added: `auth sufficient pam_python.so /usr/lib/security/howdy/pam.py`

2. **`/etc/pam.d/system-login`**
   - Added: `auth sufficient pam_python.so /usr/lib/security/howdy/pam.py`

3. **`/etc/pam.d/sudo`**
   - Added: `auth sufficient pam_python.so /usr/lib/security/howdy/pam.py`

### Backup Files

Backups were created:
- `/etc/pam.d/sddm.backup`
- `/etc/pam.d/system-login.backup`
- `/etc/pam.d/sudo.backup`

---

## Best Practices

### 1. Multiple Face Models

Enroll multiple face models for better recognition:
```bash
sudo howdy add  # Add second model
sudo howdy add  # Add third model
```

### 2. Re-enroll After Changes

If you change appearance significantly:
```bash
sudo howdy remove
sudo howdy add
```

### 3. Test Regularly

Periodically test face recognition:
```bash
# Test sudo
sudo -k && sudo whoami

# Test at login screen
sudo reboot
```

### 4. Monitor Logs

Check logs if issues occur:
```bash
# SDDM logs
sudo journalctl -u sddm -n 50

# Howdy logs
sudo journalctl -u howdy -n 50

# Auth logs
sudo journalctl -f | grep -i howdy
```

---

## Security Notes

### What Face Recognition Provides

✅ **Convenience**: No typing password  
✅ **Biometric factor**: Something you are  
✅ **Still uses authorization**: Sudo rules still apply  
✅ **Fallback available**: Password always works  

### What It Doesn't Provide

❌ **Doesn't replace password**: Just convenience layer  
❌ **Not foolproof**: Can be bypassed with good photo/video  
❌ **Requires camera**: Doesn't work without it  
❌ **Lighting dependent**: May fail in poor conditions  

### Best Practices

✅ Keep camera clean  
✅ Periodically test fallback to password  
✅ Monitor logs for suspicious activity  
✅ Use good lighting during enrollment  
✅ Enroll multiple face models for robustness  

---

## Auto-Activation Feature

**Feature:** Automatic face recognition activation at login screen

The SDDM theme has been enhanced with automatic activation of the camera. This feature activates face recognition authentication 1 second after the login screen appears, without requiring user interaction.

**Implementation:**
- **Timer-based activation:** `LoginPanel.qml` includes auto-auth timer
- **User input detection:** Auto-activation stops if user begins typing
- **Priority order:** Face recognition → Password (or Fingerprint if configured)
- **Non-conflicting:** Timer stops on authentication success/failure

**How it works:**
1. SDDM login screen displays
2. `Component.onCompleted` triggers auto-auth timer (1 second delay)
3. Timer invokes `sddm.login(lastUser, "", session)` with empty password
4. PAM authentication starts, activating Howdy (camera) first
5. If face recognition fails, system proceeds to next authentication method
6. If face recognition fails, password field is focused

**Benefits:**
- ✅ No user interaction required for camera activation
- ✅ Faster login process when face recognition succeeds
- ✅ Seamless fallback to password authentication
- ✅ Intelligent conflict prevention (stops on user input)

**Note:** If fingerprint authentication is also configured, it activates after face recognition fails. See [FINGERPRINT_SETUP_COMPLETE.md](FINGERPRINT_SETUP_COMPLETE.md) for fingerprint details.

**Documentation:**
- See [HOWDY_SDDM_AUTO_ACTIVATION.md](HOWDY_SDDM_AUTO_ACTIVATION.md) for detailed implementation
- See [HOWDY_SDDM_AUTO_AUTH.md](HOWDY_SDDM_AUTO_AUTH.md) for auto-authentication flow
- See [BIOMETRIC_AUTHENTICATION_SUMMARY.md](BIOMETRIC_AUTHENTICATION_SUMMARY.md) for complete system overview

**Testing:**
1. Reboot system: `sudo reboot`
2. Wait 1 second at login screen
3. Camera should activate automatically
4. If face recognized, login completes automatically
5. If not, password field focuses (or fingerprint activates if configured)

---

## Summary

✅ **SDDM is configured** for Howdy face recognition  
✅ **PAM modules** are properly set up  
✅ **Face models** are enrolled  
✅ **Camera** is accessible  
✅ **Auto-activation** enabled for seamless login  
✅ **Fallback** to password always available  

**Status**: Ready to use! Reboot and test at SDDM login screen.

**Related Documentation:**
- [HOWDY_SETUP_COMPLETE.md](HOWDY_SETUP_COMPLETE.md) - Face recognition setup completion
- [HOWDY_SDDM_AUTO_ACTIVATION.md](HOWDY_SDDM_AUTO_ACTIVATION.md) - Auto-activation implementation
- [BIOMETRIC_AUTHENTICATION_SUMMARY.md](BIOMETRIC_AUTHENTICATION_SUMMARY.md) - Complete biometric system

---

**Configuration completed by:** Auto (Claude Code)  
**Date:** 2025-12-02  
**Auto-activation added:** 2025-12-02
