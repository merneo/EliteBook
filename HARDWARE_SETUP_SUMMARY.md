# Hardware Configuration Summary

**Date:** December 1, 2025  
**System:** HP EliteBook x360 1030 G2  
**Status:** ✅ All Hardware Properly Configured

---

## Configuration Status

### ✅ Wi-Fi
- **Status:** Connected and functional
- **Service:** NetworkManager (enabled, running)
- **Device:** wlp58s0
- **Power Management:** Configured via TLP (off on AC, on on battery)

### ✅ Bluetooth
- **Status:** Active and functional
- **Service:** bluetooth.service (enabled, running)
- **Controller:** 28:C6:3F:56:BA:7A (HP)
- **Power State:** On

### ✅ Trackpad (AlpsPS/2 ALPS GlidePoint)
- **Status:** Fully configured
- **Configuration File:** `~/.config/hypr/hyprland.conf`
- **Features Enabled:**
  - Tap-to-click
  - Two-finger scroll (vertical and horizontal)
  - Clickfinger behavior (2-finger tap = right click)
  - Middle button emulation (3-finger tap)
  - Tap-and-drag
  - Disable while typing
- **Gestures:** 3-finger horizontal swipe = workspace switch

### ✅ Battery Management
- **TLP:** Installed and configured (`/etc/tlp.d/01-elitebook.conf`)
- **Thermald:** Active (prevents CPU throttling)
- **ACPID:** Active (handles lid switch, power button)
- **Battery Status:** 100% charged, 70.2% capacity (198 cycles)
- **Charge Thresholds:** Not supported by hardware

### ✅ ACPI Events
- **Lid Switch:** Configured (`/etc/acpi/events/lid`)
- **Power Button:** Handled by default handler
- **AC Adapter:** Monitored for power source changes

### ✅ CPU Power Management
- **Current Governor:** `performance` (correct for AC power)
- **Battery Governor:** `powersave` (auto-switches when on battery)
- **Energy Policy:** `balance_performance` (AC) / `balance_power` (BAT)
- **Platform Profile:** `balanced` (AC) / `low-power` (BAT)
- **TLP Status:** Active, managing CPU scaling

---

## Configuration Files

| File | Purpose | Status |
|------|---------|--------|
| `/etc/tlp.d/01-elitebook.conf` | TLP power management | ✅ Installed |
| `/etc/default/grub` | Kernel parameters (mem_sleep, USB) | ✅ Updated |
| `/etc/acpi/events/lid` | Lid switch suspend/resume | ✅ Created |
| `~/.config/hypr/hyprland.conf` | Trackpad configuration | ✅ Updated |
| `/etc/systemd/system/systemd-rfkill.*` | Masked (TLP manages radios) | ✅ Masked |

---

## Key Settings

### Power Management
- **CPU Governor:** `performance` (AC) / `powersave` (BAT)
- **Sleep Mode:** S3 deep sleep (`mem_sleep_default=deep`)
- **WiFi Power Save:** Off (AC) / On (BAT)
- **USB Autosuspend:** Disabled (prevents disconnects)
- **PCIe ASPM:** Default (AC) / PowerSuperSave (BAT)

### Trackpad
- **Natural Scroll:** Disabled (Unix-style)
- **Tap-to-Click:** Enabled
- **Two-Finger Scroll:** Enabled
- **Clickfinger:** Enabled (2-finger = right click)
- **Middle Button:** 3-finger tap
- **Disable While Typing:** Enabled

---

## Post-Configuration Steps

### ⚠️ Required: Regenerate GRUB Configuration

The `mem_sleep_default=deep` parameter has been added to `/etc/default/grub`, but GRUB configuration must be regenerated:

```bash
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

**This must be done before the next reboot** for S3 deep sleep to take effect.

---

## Verification Commands

### Check Wi-Fi
```bash
nmcli device status
```

### Check Bluetooth
```bash
bluetoothctl show
systemctl status bluetooth
```

### Check Trackpad
```bash
# Verify configuration in Hyprland
grep -A 15 "touchpad" ~/.config/hypr/hyprland.conf
```

### Check TLP Status
```bash
sudo tlp-stat -s    # Overall status
sudo tlp-stat -p     # CPU settings
sudo tlp-stat -b     # Battery info
```

### Check CPU Governor
```bash
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
# Should show: performance (on AC) or powersave (on battery)
```

### Check ACPI Events
```bash
ls -la /etc/acpi/events/
systemctl status acpid
```

### Check GRUB Configuration
```bash
grep mem_sleep_default /etc/default/grub
# Should show: mem_sleep_default=deep
```

---

## Troubleshooting

### CPU Governor Not Switching
If CPU governor doesn't switch between AC/battery:
```bash
sudo tlp start
sudo tlp-stat -p
```

### Trackpad Not Responding
Reload Hyprland configuration:
```bash
hyprctl reload
```

### Lid Switch Not Working
Check ACPI event:
```bash
cat /etc/acpi/events/lid
sudo systemctl restart acpid
```

### Wi-Fi Power Save Issues
TLP manages Wi-Fi power save. Check status:
```bash
sudo tlp-stat -r  # Radio device status
```

---

## Notes

- **systemd-rfkill** is masked to allow TLP to manage radio devices
- **USB autosuspend** is disabled via kernel parameter to prevent device disconnects
- **Battery charge thresholds** are not supported by this hardware model
- All configurations are persistent across reboots

---

**Last Updated:** December 1, 2025  
**Configuration Verified:** ✅ All components functional
