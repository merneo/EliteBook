# Howdy Face Recognition Setup - Interactive Guide

**Purpose:** Register your face with Howdy for biometric authentication with sudo

**Status:** Camera detected and Howdy installed ✅

---

## Prerequisites Check

✅ **Howdy installed:** `/usr/bin/howdy` exists
✅ **IR Camera available:** Chicony HP IR Camera (Device 008)
✅ **PAM configured:** Howdy is in `/etc/pam.d/sudo`
✅ **No face enrolled yet:** Ready for first enrollment

---

## Step 1: Prepare for Enrollment

Before starting, ensure:

1. **Good lighting**
   - Face should be well-lit
   - Avoid backlighting (light behind your head)
   - Side lighting or front lighting works best

2. **Camera position**
   - Position yourself 30-45cm (12-18 inches) from laptop
   - Camera should be at eye level
   - Laptop screen should face you directly

3. **Head position**
   - Keep head steady
   - Look directly at camera
   - Don't tilt head too much
   - Can wear glasses if needed (but optional lens better)

4. **Clothing & appearance**
   - Wear typical clothing (same as you'll wear when using sudo)
   - Style your hair as usual
   - Natural lighting preferred

---

## Step 2: Enroll Your Face

Open terminal and run:

```bash
sudo howdy add
```

**What happens:**
1. Howdy will prompt you to name this face model (or just press Enter for default)
2. Camera will activate (IR camera, not visible light)
3. Howdy will capture multiple photos as you look at camera
4. Process takes 5-10 seconds
5. Message will confirm enrollment success or failure

**During enrollment:**
- Keep still and look at camera
- Let camera scan from different angles
- Don't move head rapidly
- System will indicate when done

**If enrollment fails:**
- Lighting might be too dark
- Camera might be blocked
- Try again with better lighting

---

## Step 3: Verify Enrollment

Check what was enrolled:

```bash
sudo howdy list
```

**Expected output:**
```
Face models for user <USERNAME>:

ID    | Model name             | User pose | Accuracy
------|------------------------|-----------|----------
 1    | Default model          | Frontal   | 87.4%
```

Multiple models can be enrolled for better recognition in different conditions.

---

## Step 4: Test Face Recognition

### Test 1: Face Recognition (Should Work)

Clear sudo cache and test:

```bash
sudo -k
sudo whoami
```

**Expected behavior:**
1. You see: (nothing visible - IR camera works)
2. Camera activates (you might see IR light)
3. Recognition happens (2-5 seconds)
4. Command executes - shows: `root`
5. **No password prompt!**

### Test 2: Fallback to Password (Verify)

Cover the camera and try again:

```bash
sudo -k
sudo whoami
```

**Expected behavior:**
1. Camera activates but can't see face
2. Recognition fails
3. Falls back to password prompt: `[sudo] password for <USERNAME>:`
4. You type your password
5. Command executes - shows: `root`

### Test 3: Different Lighting

Try in different rooms/lighting:

```bash
sudo -k
sudo whoami
```

If face recognition fails in certain lighting, you can add another face model optimized for that lighting:

```bash
sudo howdy add
```

---

## Step 5: Understanding the Setup

### How It Works

The PAM stack for sudo is configured as:

```
auth      sufficient  pam_python.so /lib/security/howdy/pam.py
auth      include     system-auth
```

**Processing flow:**
1. User runs: `sudo whoami`
2. PAM starts authentication
3. **First:** Tries Howdy face recognition
   - If face matches → Authentication succeeds ✅
   - Continue to next modules (just to log session)
   - Command executes without password
4. **If Howdy fails:** Falls back to system-auth
   - Prompts for password
   - Verifies against `/etc/shadow`
   - If correct → Authentication succeeds ✅

**Key word: `sufficient`**
- Means "this module is enough to succeed the whole stack"
- If Howdy recognizes face, other modules are skipped
- If Howdy fails, system continues to next module (password)

### Security Model

**Benefits:**
✅ Convenience - no password typing
✅ Secure - requires both (sudo rules + biometric/password)
✅ Fallback - works without camera
✅ Auditable - all attempts logged
✅ Flexible - can add multiple face models

**You still need:**
✅ Proper sudoers configuration (%wheel ALL=(ALL:ALL) ALL)
✅ User account (<USERNAME>)
✅ To be in wheel group

---

## Troubleshooting

### Face Recognition Not Working

**Problem:** Howdy tries but always falls back to password

**Solutions:**

1. **Check enrollment quality:**
   ```bash
   sudo howdy test
   ```
   Shows how well current enrollment works

2. **Check camera:**
   ```bash
   # Test IR camera feed
   v4l2-ctl --list-devices
   ```

3. **Try in better lighting:**
   ```bash
   # Re-enroll with better lighting
   sudo howdy remove
   sudo howdy add
   ```

4. **Add another face model for this lighting:**
   ```bash
   sudo howdy add
   ```

### Camera Not Detected

**Problem:** "No camera found" message

**Solutions:**

```bash
# Check devices
lsusb | grep Chicony

# Should show:
# Bus 001 Device 008: ID 04f2:b58e Chicony Electronics Co., Ltd HP IR Camera

# Check video devices
ls -l /dev/video*

# Test camera access
v4l2-ctl --device=/dev/video1 --list-formats
```

### PAM Not Configured

**Problem:** Howdy line is missing from `/etc/pam.d/sudo`

**Current configuration (should have this):**
```bash
cat /etc/pam.d/sudo
```

**Expected first line:**
```
auth      sufficient  pam_python.so /lib/security/howdy/pam.py
```

If missing, the line was already there and Howdy is properly configured.

---

## Managing Enrollments

### View All Models

```bash
sudo howdy list
```

### Test Current Models

```bash
sudo howdy test
```

Shows how well each enrolled model recognizes your face.

### Add Another Face

```bash
sudo howdy add
```

Useful for:
- Different lighting conditions
- Different accessories (glasses, hat, etc.)
- Improved accuracy

### Remove All Enrollments

```bash
sudo howdy remove
```

**Warning:** This removes all face models. You'll need to re-enroll.

### View Howdy Logs

```bash
sudo journalctl -u howdy -n 20
```

Shows recent Howdy authentication attempts.

---

## Advanced Configuration

### Adjust Recognition Strictness

Edit Howdy configuration:

```bash
sudo nano /etc/howdy/config.ini
```

Key settings:

- `timeout` - How long to wait for face (seconds)
- `auth_type` - How to authenticate (face, or fall back to password)
- `position_model_path` - Face detection model used
- `recognition_model_path` - Recognition model used

### Disable Howdy Temporarily

If you want to use password-only authentication:

```bash
sudo sed -i '1s/^/# /' /etc/pam.d/sudo
```

This comments out the Howdy line.

**Re-enable:**

```bash
sudo sed -i '1s/^# //' /etc/pam.d/sudo
```

---

## Performance Notes

### First Run
- May be slow (2-10 seconds) while downloading AI models
- Subsequent runs use cached models

### Recognition Time
- Typical: 2-5 seconds
- With multiple models: 3-7 seconds
- Network/disk speed affects speed

### Resource Usage
- CPU: ~30-50% during recognition
- Memory: ~200-300 MB
- GPU: Used if available (speeds up recognition)

---

## Security Notes

### What Face Recognition Provides
✅ Convenience (no typing password)
✅ Biometric factor (something you are)
✅ Still uses sudo rules (authorization)
✅ Fallback to password (robustness)

### What It Doesn't Provide
❌ Doesn't replace password (just convenience)
❌ Isn't foolproof (can be bypassed with good photo/video)
❌ Requires camera (doesn't work without it)

### Best Practices
✅ Keep camera clean
✅ Periodically test fallback to password
✅ Monitor `/var/log/auth.log` for suspicious activity
✅ Use good lighting during enrollment
✅ Enroll multiple face models for robustness

---

## Testing Checklist

- [ ] Howdy installed: `which howdy`
- [ ] Face enrolled: `sudo howdy list` shows a model
- [ ] Face recognition works: `sudo -k && sudo whoami` (no password)
- [ ] Fallback works: Cover camera, `sudo -k && sudo whoami` (asks password)
- [ ] PAM configured: `cat /etc/pam.d/sudo` shows Howdy line
- [ ] Different lighting: Test in 2+ different locations
- [ ] Multiple models: (optional) Enroll in different conditions

---

## Quick Commands Reference

```bash
# Enrollment
sudo howdy add          # Enroll new face
sudo howdy remove       # Remove all enrollments

# Testing
sudo howdy list         # Show enrolled models
sudo howdy test         # Test recognition quality

# Troubleshooting
sudo journalctl -u howdy -n 20          # View Howdy logs
cat /etc/pam.d/sudo                     # View PAM configuration

# Authentication
sudo -k && sudo whoami  # Test with cache cleared
```

---

## Next Steps

1. **Enroll your face:**
   ```bash
   sudo howdy add
   ```

2. **Test face recognition:**
   ```bash
   sudo -k
   sudo whoami
   ```

3. **Test password fallback:**
   - Cover camera
   - Run: `sudo -k && sudo whoami`

4. **Monitor usage:**
   ```bash
   sudo journalctl -u sudo -f  # Watch sudo attempts in real-time
   ```

---

## Support

### View Configuration
```bash
# Howdy config
cat /etc/howdy/config.ini

# PAM configuration
cat /etc/pam.d/sudo

# Sudoers rules
sudo grep "^%wheel" /etc/sudoers
```

### Check Logs
```bash
# Howdy-specific
sudo journalctl -u howdy -n 50

# All sudo attempts
sudo journalctl -u sudo -n 50
```

### Manual Pages
```bash
man howdy
man pam
man sudo
```

---

**Status:** Ready for enrollment
**Camera:** ✅ Available
**PAM:** ✅ Configured
**Next step:** Run `sudo howdy add`
