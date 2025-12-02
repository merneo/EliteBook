# Device Files - HP EliteBook x360 1030 G2 Fingerprint Setup

This directory contains all necessary files for setting up the fingerprint sensor on HP EliteBook x360 1030 G2 running Arch Linux.

## Directory Structure

### `/firmware/`
**Lenovo Fingerprint Firmware**

- **File**: `6_07f_lenovo_mis_qm.xpfwext`
- **Size**: ~214 KB
- **Source**: https://download.lenovo.com/pccbbs/mobiles/nz3gf07w.exe
- **SHA512**: `a4a4e6058b1ea8ab721953d2cfd775a1e7bc589863d160e5ebbb90344858f147d695103677a8df0b2de0c95345df108bda97196245b067f45630038fb7c807cd`
- **Usage**: Firmware blob for device initialization
- **Compatibility**: Works with Validity Sensors 138a:0092 (Synaptics VFS7552)

**Installation Location**:
```bash
sudo cp 6_07f_lenovo_mis_qm.xpfwext /usr/share/python-validity/
```

### `/python-modules/`
**Modified Python-Validity Modules for Model 0092 Support**

These files are from the `device/0092` branch of python-validity project with modifications for model 0092 support.

| File | Purpose | Modifications |
|------|---------|----------------|
| **blobs_92.py** | Device-specific firmware blobs | Contains initialization sequences for 0092 model |
| **usb.py** | USB device enumeration | Added SupportedDevices.DEV_92 definition |
| **init_flash.py** | Flash memory initialization | Added 0092 model flash layout configuration |
| **firmware_tables.py** | Firmware lookup tables | Points to Lenovo firmware for 0092 model |
| **blobs.py** | Blob loader | Added conditional import for blobs_92 |
| **util.py** | Utility functions | No model-specific changes |
| **fingerprint_constants.py** | Finger ID mappings | Standard fprint API definitions |
| **table_types.py** | Sensor type definitions | Standard type definitions |

**Installation**:
```bash
# For Arch Linux (package installation):
git clone https://github.com/uunicorn/python-validity.git
cd python-validity
git checkout device/0092
pip install -e .

# Or copy individual files to:
# /usr/lib/python3.13/site-packages/validitysensor/
```

**Source Repository**: https://github.com/uunicorn/python-validity
**Branch**: device/0092
**License**: MIT

### `/config-files/`
**System Configuration Files**

#### **60-validity.rules**
**udev Rules for Fingerprint Device**

Location: `/etc/udev/rules.d/60-validity.rules`

Purpose: Assigns proper permissions to the USB fingerprint device
```bash
SUBSYSTEMS=="usb", ATTRS{idVendor}=="138a", MODE="0666"
```

#### **50-validity.rules** (if present)
**PolicyKit Authorization for Validity Sensor**

Location: `/etc/polkit-1/rules.d/50-validity.rules`

Purpose: Allows the 'input' group to access fingerprint device without password

#### **50-open-fprintd.rules** (if present)
**PolicyKit Authorization for open-fprintd Service**

Location: `/etc/polkit-1/rules.d/50-open-fprintd.rules`

Purpose: Allows fingerprint daemon to access the device

## Installation Instructions

### 1. Install Firmware
```bash
sudo cp device-files/firmware/6_07f_lenovo_mis_qm.xpfwext /usr/share/python-validity/
sudo chown root:root /usr/share/python-validity/6_07f_lenovo_mis_qm.xpfwext
sudo chmod 644 /usr/share/python-validity/6_07f_lenovo_mis_qm.xpfwext
```

### 2. Install Python Modules (if needed)
```bash
sudo cp device-files/python-modules/* /usr/lib/python3.13/site-packages/validitysensor/
sudo systemctl restart python3-validity
```

### 3. Install Configuration Files
```bash
# udev rules
sudo cp device-files/config-files/60-validity.rules /etc/udev/rules.d/
sudo udevadm control --reload

# PolicyKit rules (if they exist)
sudo cp device-files/config-files/50-*.rules /etc/polkit-1/rules.d/ 2>/dev/null
sudo systemctl restart polkit
```

### 4. Reload Services
```bash
sudo systemctl restart python3-validity
sudo systemctl restart open-fprintd
```

## Verification

### Check Firmware is in Place
```bash
ls -lh /usr/share/python-validity/6_07f_lenovo_mis_qm.xpfwext
```

### Verify Device Detection
```bash
lsusb | grep Validity
# Expected: Bus 001 Device XXX: ID 138a:0092 Validity Sensors, Inc.
```

### Test Service
```bash
systemctl status python3-validity
fprintd-list $USER
```

## Key Points

1. **Model 0092 Specific**: These files are tailored for Validity Sensors 138a:0092 (Synaptics VFS7552)
2. **Lenovo Firmware**: Uses Lenovo firmware as HP firmware extraction may fail with modern tools
3. **BIOS Reset Critical**: Device must be reset in BIOS before initialization works
4. **Python 3.13**: These modules are for Python 3.13 (Arch current version)

## Troubleshooting

### Device Not Found
- Check BIOS for fingerprint reader setting
- Ensure BIOS reset was performed
- Verify udev rules are loaded: `udevadm control --print-mesg`

### Firmware Not Loading
- Verify file exists: `ls /usr/share/python-validity/6_07f_lenovo_mis_qm.xpfwext`
- Check permissions: `ls -l /usr/share/python-validity/6_07f_lenovo_mis_qm.xpfwext`
- Check service logs: `journalctl -u python3-validity -n 50`

### Flash Initialization Fails (Error 0304)
- Perform BIOS reset of fingerprint reader
- Wait 10 seconds before reconnecting
- Re-run initialization

## References

- **Main Documentation**: See `../FINGERPRINT_SETUP.md`
- **Python-Validity Project**: https://github.com/uunicorn/python-validity
- **Official Sources**: See `../SOURCES.md`

---

**Last Updated**: December 1, 2025
**Tested On**: HP EliteBook x360 1030 G2, Arch Linux, Python 3.13
