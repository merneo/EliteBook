# HP EliteBook x360 1030 G2 - Hardware Integration Guide

**Author:** merneo  
**Last Updated:** December 1, 2025  
**Status:** ✅ All Hardware Functional

---

## Table of Contents

1. [Hardware Summary](#hardware-summary)
2. [Trackpad](#trackpad)
3. [HD Webcam](#hd-webcam)
4. [IR Camera](#ir-camera)
5. [Fingerprint Sensor](#fingerprint-sensor)
6. [Smart Card Reader](#smart-card-reader)
7. [Power Management](#power-management)
8. [Troubleshooting](#troubleshooting)

---

## Hardware Summary

| Device | ID | Status | Driver |
|--------|----|----|--------|
| **Trackpad** | AlpsPS/2 | ✅ Fully Functional | psmouse (alps) |
| **HD Webcam** | 04f2:b58f | ✅ Fully Functional | uvcvideo |
| **IR Camera** | 04f2:b58e | ✅ Functional | uvcvideo |
| **Fingerprint Reader** | 138a:0092 | ✅ Fully Functional | python-validity |
| **Smart Card Reader** | (integrated) | ✅ Functional | pcsclite |

### Quick Detection

```bash
lsusb | grep -E "Validity|Camera"
```

Expected output:
```
Bus 001 Device 003: ID 138a:0092 Validity Sensors, Inc.
Bus 001 Device 005: ID 04f2:b58f Chicony Electronics Co., Ltd HP HD Camera
Bus 001 Device 007: ID 04f2:b58e Chicony Electronics Co., Ltd HP IR Camera
```

---

## Trackpad

### Specifications

| Property | Value |
|----------|-------|
| **Device** | AlpsPS/2 ALPS GlidePoint |
| **Interface** | PS/2 (i8042) |
| **Driver** | psmouse (alps protocol) |
| **Features** | Multi-touch, tap-to-click, gestures |
| **Device Node** | /dev/input/event25 |

### Hyprland Configuration

The trackpad is configured in `~/.config/hypr/hyprland.conf`:

```ini
input {
    touchpad {
        # Scroll direction: false = Unix (drag down = scroll down)
        natural_scroll = false

        # Tap-to-click: Single tap = left click
        tap-to-click = true

        # Drag lock: Lift finger during drag without releasing
        drag_lock = false

        # Disable touchpad while typing to prevent accidental touches
        disable_while_typing = true

        # Click behavior: clickfinger = 1-finger click = left, 2-finger = right
        clickfinger_behavior = true

        # Middle mouse button emulation (3-finger tap)
        middle_button_emulation = true

        # Tap-and-drag: Double tap and hold to drag
        tap-and-drag = true
    }
}

# Gestures
gesture = 3, horizontal, workspace  # 3-finger swipe left/right = workspace switch
```

### Testing

```bash
# List input devices
cat /proc/bus/input/devices | grep -A 5 "ALPS"

# Test with libinput (if available)
sudo libinput debug-events --device /dev/input/event25

# Check Hyprland devices
hyprctl devices
```

### Troubleshooting

```bash
# Verify driver loaded
lsmod | grep psmouse

# Check kernel messages
dmesg | grep -i "alps\|touchpad"

# Reload driver if needed
sudo modprobe -r psmouse
sudo modprobe psmouse
```

---

## HD Webcam

### Specifications

| Property | Value |
|----------|-------|
| **Device ID** | 04f2:b58f |
| **Manufacturer** | Chicony Electronics |
| **Model** | HP HD Camera |
| **Interface** | USB 2.0 High Speed (480 Mbps) |
| **Max Resolution** | 1280×720 @ 30 fps |
| **Formats** | MJPEG, YUYV 4:2:2 |
| **Driver** | uvcvideo (kernel built-in) |
| **Device Nodes** | /dev/video0, /dev/video1 |

### Supported Resolutions

| Resolution | Format | Frame Rate |
|------------|--------|------------|
| 1280×720 | MJPEG | 30/15 fps |
| 960×540 | MJPEG | 30/15 fps |
| 848×480 | MJPEG | 30/15 fps |
| 640×480 | MJPEG, YUYV | 30/15 fps |
| 640×360 | MJPEG, YUYV | 30/15 fps |
| 424×240 | MJPEG, YUYV | 30/15 fps |
| 320×240 | MJPEG, YUYV | 30/15 fps |
| 320×180 | MJPEG, YUYV | 30/15 fps |

### Camera Controls

| Control | Range | Default |
|---------|-------|---------|
| Brightness | -64 to 64 | 0 |
| Contrast | 0 to 64 | 32 |
| Saturation | 0 to 128 | 64 |
| Hue | -40 to 40 | 0 |
| Gamma | 72 to 500 | 100 |
| Sharpness | 0 to 5 | 0 |
| White Balance | 2800K to 6500K | 4000K (auto) |
| Backlight Compensation | 0/1 | 0 |
| Auto Exposure | Manual/Aperture Priority | Aperture Priority |

### Usage

```bash
# Install tools
sudo pacman -S v4l-utils ffmpeg

# List camera info
v4l2-ctl -d /dev/video0 --all

# List supported formats
v4l2-ctl -d /dev/video0 --list-formats-ext

# Capture single image (720p)
ffmpeg -f v4l2 -video_size 1280x720 -input_format mjpeg \
  -i /dev/video0 -frames:v 1 -update 1 photo.jpg

# Record video (720p, 30 fps, 10 seconds)
ffmpeg -f v4l2 -video_size 1280x720 -framerate 30 -input_format mjpeg \
  -i /dev/video0 -t 10 -c:v libx264 -preset fast video.mp4

# Live preview (requires display)
ffplay -f v4l2 -video_size 1280x720 -input_format mjpeg /dev/video0

# Adjust brightness
v4l2-ctl -d /dev/video0 --set-ctrl brightness=10

# Reset to defaults
v4l2-ctl -d /dev/video0 --set-ctrl brightness=0
v4l2-ctl -d /dev/video0 --set-ctrl contrast=32
```

### Application Support

| Application | Status | Notes |
|-------------|--------|-------|
| **OBS Studio** | ✅ Works | Select "Video Capture Device (V4L2)" |
| **Firefox** | ✅ Works | WebRTC video calls |
| **Chromium** | ✅ Works | Google Meet, Zoom web |
| **Zoom** | ✅ Works | Native Linux client |
| **Teams** | ✅ Works | Web or native client |
| **Cheese** | ✅ Works | GNOME webcam app |
| **Kamoso** | ✅ Works | KDE webcam app |

---

## IR Camera

### Specifications

| Property | Value |
|----------|-------|
| **Device ID** | 04f2:b58e |
| **Manufacturer** | Chicony Electronics / Realtek |
| **Model** | HP IR Camera |
| **Interface** | USB 2.0 High Speed (480 Mbps) |
| **Max Resolution** | 640×480 @ 30 fps |
| **Special Mode** | 340×340 @ 30 fps (face detection) |
| **Format** | YUYV 4:2:2 only |
| **Driver** | uvcvideo (kernel built-in) |
| **Device Nodes** | /dev/video2, /dev/video3 |
| **Purpose** | Windows Hello face recognition |

### Supported Resolutions

| Resolution | Format | Frame Rate | Purpose |
|------------|--------|------------|---------|
| 640×480 | YUYV | 30 fps | Standard capture |
| 340×340 | YUYV | 30 fps | Face detection (square) |

### Usage

```bash
# List IR camera info
v4l2-ctl -d /dev/video2 --all

# Capture IR image
ffmpeg -f v4l2 -video_size 640x480 -input_format yuyv422 \
  -i /dev/video2 -frames:v 1 -update 1 ir_capture.jpg

# Live IR preview
ffplay -f v4l2 -video_size 640x480 /dev/video2
```

### Face Recognition on Linux

The IR camera works with these face recognition solutions:

**1. Howdy (Windows Hello alternative)**
```bash
yay -S howdy

# Configure for IR camera
sudo howdy config
# Set device_path = /dev/video2

# Add face
sudo howdy add

# Test
sudo howdy test
```

**2. OpenCV + Python**
```bash
pip install opencv-python opencv-contrib-python numpy
```

```python
import cv2

# Open IR camera
cap = cv2.VideoCapture(2)  # /dev/video2

while True:
    ret, frame = cap.read()
    if ret:
        cv2.imshow('IR Camera', frame)
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()
```

### Notes

- IR image appears grayscale (infrared light)
- Best for face detection in low light
- Cannot replace HD camera for video calls
- Windows Hello features require custom software on Linux

---

## Fingerprint Sensor

### Specifications

| Property | Value |
|----------|-------|
| **Device ID** | 138a:0092 |
| **Manufacturer** | Validity Sensors / Synaptics |
| **Model** | VFS7552 Touch Fingerprint Sensor |
| **Interface** | USB 2.0 Full Speed (12 Mbps) |
| **Device Class** | Vendor Specific (0xFF) |
| **Linux Support** | python-validity (device/0092 branch) |

### ⚠️ Critical: BIOS Reset Required

**The fingerprint sensor WILL NOT work without a BIOS reset first.**

1. Restart → Press **F10** during HP logo
2. Navigate: **Security → Fingerprint Reader Reset**
3. Enable: "Reset fingerprint reader on next boot"
4. Save and restart (F10)
5. Wait 1-2 minutes during boot (reset in progress)

### Installation

```bash
# Install from AUR
yay -S python-validity-git

# Install device/0092 branch support
cd /tmp
git clone -b device/0092 https://github.com/uunicorn/python-validity.git

VALIDITY_DIR=$(python3 -c "import site; print(site.getsitepackages()[0])")/validitysensor
sudo cp -r /tmp/python-validity/validitysensor/* $VALIDITY_DIR/

# Create udev rules
sudo tee /etc/udev/rules.d/60-validity.rules << 'EOF'
SUBSYSTEMS=="usb", ATTRS{idVendor}=="138a", MODE="0666"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="138a", ATTRS{idProduct}=="0092", MODE="0666"
EOF

sudo udevadm control --reload
sudo udevadm trigger
sudo usermod -a -G input $USER

# Start service
sudo systemctl enable --now python3-validity
```

### Enrollment

```bash
# Verify detection
fprintd-list $USER

# Enroll fingerprint
fprintd-enroll $USER

# Test verification
fprintd-verify $USER
```

### PAM Configuration

```bash
# Enable for sudo
echo "auth sufficient pam_fprintd.so" | sudo tee -i /etc/pam.d/sudo

# Enable for SDDM login
echo "auth sufficient pam_fprintd.so" | sudo tee -i /etc/pam.d/sddm
```

### Firmware

The sensor requires Lenovo firmware:
- **File:** `6_07f_lenovo_mis_qm.xpfwext`
- **Location:** `/usr/share/python-validity/`
- **Source:** https://download.lenovo.com/pccbbs/mobiles/nz3gf07w.exe

---

## Smart Card Reader

### Specifications

| Property | Value |
|----------|-------|
| **Reader** | Alcor Micro AU9560 (integrated) |
| **Standard** | PC/SC |
| **Supported Cards** | ISO 7816 contact cards |
| **Use Cases** | eObčanka, PKI cards, smart cards |

### Installation

```bash
# Install PC/SC stack
sudo pacman -S pcsclite ccid pcsc-tools

# Enable service
sudo systemctl enable --now pcscd

# Test reader
pcsc_scan
```

### eObčanka (Czech ID Card)

```bash
# Install client from AUR
yay -S eidklient

# Launch
eidklient &
```

---

## Troubleshooting

### Webcam Not Detected

```bash
# Check kernel module
lsmod | grep uvcvideo

# Load if missing
sudo modprobe uvcvideo

# Check dmesg for errors
dmesg | grep -i "video\|uvc\|camera"
```

### Webcam In Use by Another Application

```bash
# Find process using camera
fuser /dev/video0

# Kill process
fuser -k /dev/video0
```

### Fingerprint Enrollment Fails

1. **Perform BIOS reset** (most common fix)
2. Clean sensor surface with microfiber cloth
3. Consistent finger placement during enrollment
4. Check service: `systemctl status python3-validity`
5. Check logs: `journalctl -u python3-validity -n 50`

### Fingerprint Service Won't Start

```bash
# Install numpy dependency
sudo pacman -S python-numpy

# Restart service
sudo systemctl restart python3-validity
```

### Wrong Camera Selected in Apps

```bash
# List all cameras
v4l2-ctl --list-devices

# HD Camera = /dev/video0
# IR Camera = /dev/video2

# In apps, select "HP HD Camera" not "HP IR Camera"
```

---

## Power Management

### Overview

The HP EliteBook x360 1030 G2 uses TLP and thermald for power management optimization.

| Service | Purpose | Status |
|---------|---------|--------|
| **TLP** | Battery/CPU power management | ✅ Enabled |
| **thermald** | Intel CPU thermal management | ✅ Enabled |
| **acpid** | ACPI event handling | ✅ Enabled |

### TLP Configuration

Configuration file: `/etc/tlp.d/01-elitebook.conf`

| Setting | AC | Battery |
|---------|-----|---------|
| CPU Governor | performance | powersave |
| CPU Energy Policy | balance_performance | balance_power |
| Platform Profile | balanced | low-power |
| WiFi Power Save | off | on |
| PCIE ASPM | default | powersupersave |
| USB Autosuspend | off | off |

### Deep Sleep (S3)

The system uses S3 deep sleep instead of s2idle for better battery life during suspend.

Configured via kernel parameter in `/etc/default/grub`:
```
mem_sleep_default=deep
```

### Thermal Management

Thermald automatically manages CPU temperature to prevent throttling.

```bash
# Check thermal zones
cat /sys/class/thermal/thermal_zone*/type
cat /sys/class/thermal/thermal_zone*/temp

# Monitor CPU temperature
watch -n 1 'cat /sys/class/thermal/thermal_zone*/temp'
```

### Battery Health

Battery information:
- **Vendor**: Hewlett-Packard
- **Technology**: Lithium-ion
- **Design Capacity**: 57 Wh
- **Charge Cycles**: Check with `upower -i /org/freedesktop/UPower/devices/battery_BAT0`

```bash
# Detailed battery info
upower -i /org/freedesktop/UPower/devices/battery_BAT0

# TLP battery report
sudo tlp-stat -b
```

### Status Commands

```bash
# TLP status
sudo tlp-stat -s

# CPU/processor info
sudo tlp-stat -p

# Battery
sudo tlp-stat -b

# USB devices
sudo tlp-stat -u

# Thermald status
systemctl status thermald

# Current suspend mode
cat /sys/power/mem_sleep
```

---

## References

**Fingerprint Authentication:**
- [python-validity](https://github.com/uunicorn/python-validity) - Fingerprint driver for Validity Sensors
  - [device/0092 branch](https://github.com/uunicorn/python-validity/tree/device/0092) - Specific branch for Validity Sensors 138a:0092
- [fprintd (libfprint)](https://fprint.freedesktop.org/) - Fingerprint daemon
  - [ArchWiki Fprint](https://wiki.archlinux.org/title/Fprint) - Comprehensive Arch Linux documentation

**Hardware Documentation:**
- [ArchWiki Webcam](https://wiki.archlinux.org/title/Webcam) - Webcam configuration
- [V4L2 Documentation](https://www.kernel.org/doc/html/latest/userspace-api/media/v4l/v4l2.html) - Video4Linux2 API reference

**Power Management:**
- [ArchWiki TLP](https://wiki.archlinux.org/title/TLP) - TLP power management
- [ArchWiki Power Management](https://wiki.archlinux.org/title/Power_management) - General power management guide
