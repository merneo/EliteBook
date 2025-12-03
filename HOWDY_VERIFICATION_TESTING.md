# Howdy Face Recognition - Verification and Testing

**Date:** 2025-12-02
**Status:** ✅ Howdy Enrolled and PAM Configured for Login

---

## Current Status

### Face Models Enrolled ✅

```
Known face models for <USERNAME>:

ID  Date                 Label
0   2025-12-02 08:56:19  <USERNAME>
1   2025-12-02 09:24:27  Model #2
```

Two face models successfully registered for reliable recognition.

### PAM Configuration ✅

Howdy has been added to all authentication points:

1. **SDDM** (`/etc/pam.d/sddm`)
   - Login screen (graphical)
   - Face recognition enabled

2. **system-login** (`/etc/pam.d/system-login`)
   - Terminal login (tty)
   - Face recognition enabled

3. **sudo** (`/etc/pam.d/sudo`)
   - Privilege escalation
   - Face recognition enabled (already configured)

---

## Testing Procedure

### Test 1: Sudo with Face Recognition

**Objective:** Verify Howdy works with sudo

**Steps:**

```bash
# Clear sudo cache
sudo -k

# Run a command
sudo whoami
```

**Expected Results:**

**Scenario A - Face Recognition Works (Best):**
```
[Camera activates]
[Howdy recognizes face - 2-5 seconds]
root
[No password prompt - authentication succeeded via face]
```

**Scenario B - Face Not Recognized (Fallback):**
```
[Camera activates]
[Face not recognized]
[sudo] password for <USERNAME>:
[Enter password]
root
```

**Verification:**
- ✅ Camera activates (you may see IR light)
- ✅ Either immediate success or password prompt
- ✅ Command executes as root

---

### Test 2: Terminal Login with Face Recognition

**Objective:** Verify Howdy works for terminal login

**Steps:**

1. Open a new terminal/TTY session (or SSH if configured)
2. Observe login process
3. Check if Howdy is invoked

**Expected Results:**

The system will attempt face recognition before asking for password.

**Verification:**
- ✅ Login process completes
- ✅ System recognizes user (with or without face)
- ✅ Terminal becomes available

---

### Test 3: SDDM Login (After Reboot)

**Objective:** Verify Howdy works on login screen

**Important:** This test requires a restart/reboot

**Steps:**

1. Save all work
2. Restart your computer: `sudo reboot`
3. Wait for SDDM login screen
4. Observe the login process
5. Position yourself in front of camera
6. Watch for face recognition

**Expected Behavior:**

**Scenario A - Face Recognition Works (Ideal):**
```
[Login screen appears]
[You position yourself in front of camera]
[Camera activates (IR light visible)]
[Howdy recognizes your face - 2-5 seconds]
[System logs in automatically - no password needed]
[Desktop appears]
```

**Scenario B - Face Not Recognized (Fallback):**
```
[Login screen appears]
[You position yourself in front of camera]
[Camera activates]
[Face not recognized]
[Password prompt appears on login screen]
[You type password]
[System logs in]
[Desktop appears]
```

**Scenario C - Manual Login (Always Works):**
```
[Login screen appears]
[You click on username field and type password]
[System logs in normally]
```

**Verification Checklist:**
- ✅ SDDM login screen appears
- ✅ System attempts face recognition OR asks for password
- ✅ You can log in (with face or password)
- ✅ Desktop loads successfully

---

## Reboot and Testing Plan

### Pre-Reboot Checklist

Before restarting, ensure:

- [ ] All work saved
- [ ] No important programs running
- [ ] Network available (if needed)
- [ ] Familiar with typing password if needed
- [ ] Comfortable with camera position

### Reboot Command

```bash
# Save everything first, then:
sudo reboot

# Or schedule reboot:
sudo shutdown -r +1  # Reboot in 1 minute
```

### During Reboot

1. **Shutdown phase** (10-30 seconds)
   - System shuts down normally
   - Disks sync
   - System powers off

2. **Boot phase** (30-60 seconds)
   - BIOS/UEFI initialization
   - Grub bootloader
   - Kernel loading
   - Systemd initialization

3. **SDDM appears** (should be ready for login)
   - Login screen displays
   - Ready for authentication

### After Login

Once logged in:

```bash
# Test sudo
sudo -k
sudo whoami

# Check Howdy logs
sudo journalctl -u howdy -n 10

# Check auth logs
sudo journalctl -u sddm -n 10
```

---

## Troubleshooting

### If Face Recognition Doesn't Work at SDDM

**Possible causes:**

1. **Camera not working in SDDM context**
   - Different graphics stack than normal
   - Some graphical environments have limited camera access

2. **Different lighting than enrollment**
   - SDDM login screen might have different lighting
   - Re-enroll in login screen location

3. **Distance or angle different**
   - Position yourself same distance as enrollment
   - Look directly at camera

**Solutions:**

```bash
# Check if SDDM can access camera
ls -la /dev/video*
# Should show: /dev/video0, /dev/video1, /dev/video2, /dev/video3

# Check Howdy logs
sudo journalctl -u howdy -n 20

# Re-enroll optimized for login screen
sudo howdy remove
sudo howdy add
```

### If You Get Stuck at Login Screen

**Emergency procedures:**

1. **Use password authentication**
   - Click username field
   - Type username and password normally
   - Should work

2. **Use TTY console**
   - Press: `Ctrl+Alt+F2` (switch to TTY2)
   - Log in with username and password
   - Return to graphical: `Ctrl+Alt+F1`

3. **Use recovery mode**
   - Restart
   - At GRUB, press 'e'
   - Add `rd.break` to kernel parameters
   - Boot into recovery

---

## Configuration Files Modified

### 1. `/etc/pam.d/sddm`

**Before:**
```
#%PAM-1.0
auth        include     system-login
```

**After:**
```
#%PAM-1.0
auth        sufficient  pam_python.so /usr/lib/security/howdy/pam.py
auth        include     system-login
```

**Effect:** Face recognition attempted during SDDM login

### 2. `/etc/pam.d/system-login`

**Before:**
```
#%PAM-1.0
auth       required   pam_shells.so
auth       requisite  pam_nologin.so
auth       include    system-auth
```

**After:**
```
#%PAM-1.0
auth       required   pam_shells.so
auth       sufficient  pam_python.so /usr/lib/security/howdy/pam.py
auth       requisite  pam_nologin.so
auth       include    system-auth
```

**Effect:** Face recognition attempted during terminal/SSH login

### 3. `/etc/pam.d/sudo` (Already Configured)

```
auth      sufficient  pam_python.so /usr/lib/security/howdy/pam.py
auth      include     system-auth
```

**Effect:** Face recognition attempted with sudo

---

## Expected Behavior Summary

### With Howdy Enabled (Current)

| Scenario | Auth Method | Result |
|----------|-------------|--------|
| Face recognized | Face only | Immediate login ✅ |
| Face not recognized | Falls back | Password prompt |
| No camera | Falls back | Password prompt |
| SSH login | Falls back | Password prompt |
| Headless system | Falls back | Password prompt |

### Security Model

```
Request Authentication
        ↓
Try Howdy (face recognition)
        ↓
If recognized → SUCCESS ✅
If not recognized → Falls back
        ↓
Try system-auth (password)
        ↓
If password correct → SUCCESS ✅
If password wrong → DENIED ❌
```

---

## Monitoring After Reboot

### Check Howdy Activity

```bash
# Recent Howdy events
sudo journalctl -u howdy -n 20

# Howdy errors/warnings
sudo journalctl -u howdy -p err

# Real-time Howdy monitoring
sudo journalctl -u howdy -f
```

### Check SDDM Activity

```bash
# SDDM logs
sudo journalctl -u sddm -n 20

# Real-time monitoring
sudo journalctl -u sddm -f
```

### Check System Auth

```bash
# All authentication attempts
sudo journalctl -u sudo -n 20

# Auth logs
sudo journalctl SYSLOG_IDENTIFIER=sudo -n 20
```

---

## Next Steps

1. **Verify Current Setup Works**
   ```bash
   sudo -k && sudo whoami
   ```

2. **Schedule Reboot**
   ```bash
   sudo reboot
   ```

3. **Test Face Recognition at Login**
   - Position yourself in front of camera
   - Observe authentication process
   - Note if face is recognized

4. **Monitor Logs**
   ```bash
   sudo journalctl -u howdy -f
   ```

5. **Document Results**
   - Note if face recognition worked
   - Note any issues or fallbacks
   - Record success/failure rates

---

## Success Criteria

✅ **Test passes if:**
- [ ] Sudo works (with or without face)
- [ ] SDDM login works (with or without face)
- [ ] Terminal login works (with or without face)
- [ ] Password fallback works
- [ ] No system crashes or hangs
- [ ] All authentication methods functional

---

## Known Limitations

1. **SSH Sessions** - Camera not available, password only
2. **Headless Systems** - Camera not available, password only
3. **Different Graphics** - Some environments have limited camera access
4. **Lighting** - Face recognition works best with good lighting
5. **First Login** - May need password if camera unavailable during boot

---

## Backup and Recovery

If something goes wrong with PAM:

```bash
# Restore SDDM backup
sudo cp /etc/pam.d/sddm.backup /etc/pam.d/sddm

# Restore system-login backup
sudo cp /etc/pam.d/system-login.backup /etc/pam.d/system-login

# Check current configuration
cat /etc/pam.d/sddm
cat /etc/pam.d/system-login
```

---

## Summary

Your system is configured for face recognition at three points:
1. ✅ SDDM (graphical login)
2. ✅ system-login (terminal login)
3. ✅ sudo (privilege escalation)

Password authentication remains as secure fallback.

**Ready to test! Restart your computer to verify SDDM login works.**

---

**Setup Date:** 2025-12-02
**Status:** Ready for Testing
**Next Action:** Reboot to verify SDDM face recognition
