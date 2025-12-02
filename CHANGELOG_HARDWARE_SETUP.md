# Hardware Configuration Changes - December 1, 2025

## Summary
Complete hardware configuration setup and fixes for HP EliteBook x360 1030 G2.

---

## Changes Made

### 1. TLP Power Management Configuration
- **Installed:** `/etc/tlp.d/01-elitebook.conf`
- **Status:** ✅ Active and configured
- **Settings:**
  - CPU Governor: `performance` (AC) / `powersave` (BAT)
  - WiFi Power Save: Off (AC) / On (BAT)
  - USB Autosuspend: Disabled
  - PCIe ASPM: Default (AC) / PowerSuperSave (BAT)

### 2. Trackpad Configuration (Hyprland)
- **File:** `~/.config/hypr/hyprland.conf`
- **Changes:**
  - Added comprehensive trackpad settings:
    - `tap-to-click = true`
    - `clickfinger_behavior = true`
    - `middle_button_emulation = true`
    - `tap-and-drag = true`
    - `disable_while_typing = true`
  - **FIXED:** Removed invalid `scroll_method = 2fg` (not supported by Hyprland)
  - Two-finger scroll works automatically via libinput

### 3. ACPI Configuration
- **Created:** `/etc/acpi/events/lid`
- **Purpose:** Handle lid switch events (suspend/resume)
- **Status:** ✅ Active

### 4. GRUB Configuration
- **File:** `/etc/default/grub`
- **Added:** `mem_sleep_default=deep` to `GRUB_CMDLINE_LINUX_DEFAULT`
- **Purpose:** Enable S3 deep sleep for better battery life during suspend
- **⚠️ ACTION REQUIRED:** Must run `sudo grub-mkconfig -o /boot/grub/grub.cfg` before next reboot

### 5. systemd-rfkill Masking
- **Action:** Masked `systemd-rfkill.service` and `systemd-rfkill.socket`
- **Purpose:** Allow TLP to manage radio devices (WiFi/Bluetooth)

### 6. Documentation Updates
- **Updated:** `EliteBook/README.md` - Power Management section
- **Updated:** `EliteBook/FINGERPRINT_ID_READERS.md` - Trackpad configuration
- **Created:** `EliteBook/HARDWARE_SETUP_SUMMARY.md` - Complete hardware status
- **Created:** `EliteBook/CHANGELOG_HARDWARE_SETUP.md` - This file

---

## Files Modified

### Dotfiles Repository
- `hypr/.config/hypr/hyprland.conf` - Trackpad configuration updated, invalid option removed

### EliteBook Repository
- `hypr/.config/hypr/hyprland.conf` - Trackpad configuration updated, invalid option removed
- `README.md` - Power Management section updated
- `FINGERPRINT_ID_READERS.md` - Trackpad documentation updated
- `HARDWARE_SETUP_SUMMARY.md` - New file (hardware status)
- `CHANGELOG_HARDWARE_SETUP.md` - New file (this changelog)

### System Files (require sudo)
- `/etc/tlp.d/01-elitebook.conf` - Created
- `/etc/default/grub` - Modified (mem_sleep_default added)
- `/etc/acpi/events/lid` - Created
- `/etc/systemd/system/systemd-rfkill.service` - Masked
- `/etc/systemd/system/systemd-rfkill.socket` - Masked

---

## Verification Status

| Component | Status |
|-----------|--------|
| Wi-Fi | ✅ Connected |
| Bluetooth | ✅ Active |
| Trackpad | ✅ Fully configured |
| TLP | ✅ Installed and active |
| CPU Governor | ✅ Correct (performance on AC) |
| ACPI Lid Event | ✅ Configured |
| GRUB mem_sleep | ✅ Added (needs grub-mkconfig) |

---

## Next Steps

### ⚠️ REQUIRED: Before Next Reboot

1. **Regenerate GRUB configuration:**
   ```bash
   sudo grub-mkconfig -o /boot/grub/grub.cfg
   ```

2. **Restart system:**
   ```bash
   sudo reboot
   ```

3. **After reboot, verify:**
   ```bash
   # Check sleep mode
   cat /sys/power/mem_sleep
   # Should show: [s2idle] deep

   # Check TLP status
   sudo tlp-stat -s

   # Check CPU governor (should be performance on AC)
   cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
   ```

---

## Notes

- **scroll_method removal:** Hyprland doesn't support `scroll_method` option. Two-finger scroll is automatically handled by libinput.
- **TLP radio management:** systemd-rfkill is masked to prevent conflicts with TLP's radio device management.
- **Battery thresholds:** Not supported by this hardware model (HP EliteBook x360 1030 G2).

---

**Date:** December 1, 2025  
**Author:** merneo  
**Status:** ✅ Configuration complete, pending GRUB regeneration and reboot
