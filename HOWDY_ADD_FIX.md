# Howdy Face Enrollment Fix

**Date:** 2025-12-02  
**Status:** ✅ Fixed - Face enrollment now works correctly

---

## Problem Summary

When running `sudo howdy add` to enroll a new face model, the command was failing with:
```
No face detected, aborting
```

### Root Causes Identified

1. **Missing IR Emitter Activation**: The `add.py` script did not activate the IR emitter before reading camera frames, unlike `compare.py` which does activate it. This caused the camera to see very dark frames (99.9% darkness) making face detection impossible.

2. **Insufficient Frame Checking**: Only 60 frames were checked, which may not be enough time for face detection.

3. **Suboptimal Detection Settings**: Face detector upsampling was set to 1, and dark_threshold was too restrictive.

4. **Poor Error Messages**: Error messages didn't provide enough diagnostic information.

---

## Fixes Applied

### 1. IR Emitter Activation ✅

**File:** `/usr/lib/security/howdy/cli/add.py`

Added IR emitter activation code before video capture initialization:

```python
# Start IR emitter for face recognition
try:
	# Check if linux-enable-ir-emitter is available
	if os.path.exists("/usr/bin/linux-enable-ir-emitter"):
		# Start IR emitter in background
		ir_emitter_process = subprocess.Popen(
			["/usr/bin/linux-enable-ir-emitter", "run"],
			stdout=subprocess.DEVNULL,
			stderr=subprocess.DEVNULL
		)
		# Wait a bit for IR emitter to activate
		time.sleep(0.5)
except Exception:
	# If IR emitter fails, continue anyway
	ir_emitter_process = None
	pass
```

**Also added cleanup code** before `video_capture.release()`:

```python
# Cleanup IR emitter
try:
	if 'ir_emitter_process' in locals() and ir_emitter_process is not None:
		ir_emitter_process.terminate()
		ir_emitter_process.wait(timeout=1)
except Exception:
	pass
```

### 2. Increased Frame Checking ✅

**File:** `/usr/lib/security/howdy/cli/add.py`

Changed from 60 to 120 frames:
```python
while frames < 120:  # Was: while frames < 60:
```

### 3. Improved Face Detection ✅

**File:** `/usr/lib/security/howdy/cli/add.py`

Increased upsampling from 1 to 2 for better detection:
```python
face_locations = face_detector(gsframe, 2)  # Was: face_detector(gsframe, 1)
```

### 4. Adjusted Dark Threshold ✅

**File:** `/usr/lib/security/howdy/config.ini`

Increased `dark_threshold` from 50 to 60:
```ini
dark_threshold = 60
```

### 5. Enhanced Error Messages ✅

**File:** `/usr/lib/security/howdy/cli/add.py`

Improved error messages with diagnostic information:

```python
else:
	print("No face detected after checking " + str(frames) + " frames (" + str(valid_frames) + " valid frames)")
	print("Average darkness: " + str(round(dark_running_total / max(1, valid_frames), 2)) + ", Threshold: " + str(dark_threshold))
	print("Tips:")
	print("  - Position yourself 30-60 cm from camera")
	print("  - Look directly at the camera")
	print("  - Ensure good lighting")
	print("  - Make sure nothing is blocking the camera")
```

### 6. Fixed Deprecation Warning ✅

**File:** `/usr/lib/security/howdy/compare.py`

Fixed Python datetime deprecation warning:
```python
# Before:
datetime.datetime.utcnow()

# After:
datetime.datetime.now(datetime.timezone.utc)
```

---

## Configuration Summary

| Setting | Before | After | File |
|---------|--------|-------|------|
| Frames checked | 60 | 120 | `cli/add.py` |
| Face detector upsampling | 1 | 2 | `cli/add.py` |
| Dark threshold | 50 | 60 | `config.ini` |
| Timeout | 4s | 8s | `config.ini` |
| IR emitter | ❌ Not activated | ✅ Auto-activated | `cli/add.py` |

---

## Testing

After applying these fixes, face enrollment works correctly:

```bash
sudo howdy add
```

**Expected behavior:**
1. IR emitter activates automatically
2. Camera receives proper illumination
3. Face detection succeeds within 120 frames
4. Face model is saved successfully

---

## Manual Application

If you need to apply these fixes manually:

1. **Add IR emitter code** to `/usr/lib/security/howdy/cli/add.py` (see code above)
2. **Change frame limit** from 60 to 120
3. **Change upsampling** from 1 to 2
4. **Update config.ini** dark_threshold to 60
5. **Update error messages** for better diagnostics

---

## Verification

To verify the fixes are working:

```bash
# Test face enrollment
sudo howdy add

# Check face models
sudo howdy list

# Test face recognition
sudo -k && sudo whoami
```

---

## Notes

- IR emitter requires `linux-enable-ir-emitter` package to be installed
- The IR emitter activation code matches the implementation in `compare.py`
- All changes are backward compatible
- Error messages now provide actionable diagnostic information

---

**Fix completed by:** Auto (Claude Code)  
**Verified:** ✅ Face enrollment now works correctly
