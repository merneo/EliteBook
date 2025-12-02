# Howdy IR Emitter Fix - Automatic Activation

**Date:** 2025-12-02
**Status:** ✅ Implemented

---

## Problem

IR emitter was not automatically activating when Howdy face recognition was triggered via PAM (e.g., during `sudo` authentication). The camera was working, but without IR illumination, face recognition was unreliable or failed.

---

## Solution

Modified Howdy's PAM integration to automatically start the IR emitter before face recognition begins.

### Changes Made

1. **Modified `/lib/security/howdy/pam.py`**:
   - Added `start_ir_emitter()` function that launches `linux-enable-ir-emitter run` in background
   - Added `stop_ir_emitter()` function to clean up the process
   - Modified `doAuth()` to start IR emitter BEFORE calling `compare.py`
   - Ensured IR emitter is stopped after authentication completes (success or failure)

2. **Modified `/lib/security/howdy/compare.py`** (already done):
   - Added IR emitter startup code as backup (in case pam.py fails)
   - Added cleanup on exit

---

## How It Works

### Authentication Flow

1. User runs `sudo whoami`
2. PAM calls `pam.py` → `doAuth()`
3. **IR emitter starts** (via `start_ir_emitter()`)
4. Wait 0.5 seconds for IR emitter to activate
5. Call `compare.py` for face recognition
6. **IR emitter stops** (via `stop_ir_emitter()`)
7. Return authentication result

### Code Flow

```
sudo command
  ↓
PAM (/etc/pam.d/sudo)
  ↓
pam.py → doAuth()
  ↓
start_ir_emitter()  ← IR emitter starts here
  ↓
compare.py → face recognition
  ↓
stop_ir_emitter()  ← IR emitter stops here
  ↓
Return PAM_SUCCESS or PAM_AUTH_ERR
```

---

## Testing

### Test 1: Basic Sudo

```bash
sudo -k
sudo whoami
```

**Expected:**
- IR emitter activates (you may see red light)
- Face recognition works
- Command executes without password prompt (if face recognized)
- OR falls back to password if face not recognized

### Test 2: Check IR Emitter Process

```bash
# In one terminal, watch for IR emitter process
watch -n 0.5 'ps aux | grep linux-enable-ir-emitter | grep -v grep'

# In another terminal, run:
sudo -k
sudo whoami
```

**Expected:**
- IR emitter process appears briefly during authentication
- Process disappears after authentication completes

### Test 3: Check Logs

```bash
sudo journalctl -u sudo -f
# Or
sudo journalctl | grep -i "howdy\|ir\|emitter" | tail -20
```

**Expected:**
- Log entries showing "IR emitter started"
- Log entries showing "IR emitter stopped"
- Howdy authentication attempts

---

## Technical Details

### IR Emitter Startup

- Command: `/usr/bin/linux-enable-ir-emitter run`
- Runs in background (subprocess.Popen)
- Waits 0.5 seconds for activation
- Logs to syslog if successful/failed

### IR Emitter Cleanup

- Process is terminated after authentication
- Uses `terminate()` first, then `kill()` if needed
- Always cleaned up, even on errors

### Error Handling

- If IR emitter fails to start, authentication continues anyway
- Errors are logged to syslog
- Face recognition will still work (may be less reliable without IR)

---

## Files Modified

1. `/lib/security/howdy/pam.py`
   - Added IR emitter startup/cleanup functions
   - Modified `doAuth()` to use them

2. `/lib/security/howdy/compare.py`
   - Already had IR emitter code (backup)

---

## Dependencies

- `linux-enable-ir-emitter` must be installed and configured
- IR emitter configuration must exist in `/etc/linux-enable-ir-emitter/`
- Camera device must be accessible (`/dev/video2`)

---

## Troubleshooting

### IR Emitter Not Starting

**Check if tool exists:**
```bash
which linux-enable-ir-emitter
ls -la /usr/bin/linux-enable-ir-emitter
```

**Check configuration:**
```bash
ls -la /etc/linux-enable-ir-emitter/
```

**Test manually:**
```bash
sudo linux-enable-ir-emitter run
# Should see red light, press Ctrl+C to stop
```

### IR Emitter Starts But Camera Still Dark

- IR emitter may need more time to activate
- Try increasing the sleep time in `start_ir_emitter()` (currently 0.5 seconds)
- Check camera permissions: `ls -la /dev/video2`

### Face Recognition Still Fails

- IR emitter is working, but face recognition may fail for other reasons:
  - Lighting conditions
  - Face not enrolled properly
  - Camera angle/distance
  - Face model quality

---

## Future Improvements

1. **Configurable delay**: Make IR emitter activation delay configurable in `config.ini`
2. **Better error handling**: More detailed error messages if IR emitter fails
3. **Status checking**: Verify IR emitter is actually running before proceeding
4. **Timeout handling**: Ensure IR emitter stops even if authentication hangs

---

## Notes

- IR emitter runs as root (via PAM context)
- Process is cleaned up automatically
- No manual intervention needed
- Works with all PAM services (sudo, su, login, etc.)

---

**Implementation Date:** 2025-12-02
**Status:** ✅ Active and Working
