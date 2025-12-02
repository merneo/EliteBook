# Fingerprint Sensor Setup - HP EliteBook x360 1030 G2

**Device:** Validity Sensors 138a:0092 (Synaptics VFS7552)  
**Status:** ✅ Fully Functional  
**Repository:** This directory contains all necessary files for fingerprint sensor setup.

---

## Directory Structure

```
fingerprint/
├── README.md                    # This file
├── device-files/
│   ├── README.md                # Device files documentation
│   ├── config-files/
│   │   └── 60-validity.rules   # udev rules for USB device permissions
│   ├── python-modules/          # Modified Python-Validity modules (device/0092 branch)
│   │   ├── blobs_92.py          # Device-specific firmware blobs
│   │   ├── blobs.py             # Blob loader
│   │   ├── fingerprint_constants.py
│   │   ├── firmware_tables.py
│   │   ├── init_flash.py
│   │   ├── table_types.py
│   │   ├── usb.py
│   │   └── util.py
│   └── firmware/
│       └── 6_07f_lenovo_mis_qm.xpfwext  # Lenovo firmware (if available locally)
```

---

## Quick Start

### 1. Install Required Packages

```bash
# Install from AUR
yay -S python-validity-git

# Or install dependencies
sudo pacman -S libfprint fprintd libfprint-goodix-git
sudo pacman -S libusb pyusb
```

### 2. BIOS Reset (CRITICAL)

**⚠️ The fingerprint sensor WILL NOT work without a BIOS reset first.**

1. Restart → Press **F10** during HP logo
2. Navigate: **Security → Fingerprint Reader Reset**
3. Enable: "Reset fingerprint reader on next boot"
4. Save and restart (F10)
5. Wait 1-2 minutes during boot (reset in progress)

### 3. Install Device Files

```bash
cd ~/EliteBook/fingerprint

# Install udev rules
sudo cp device-files/config-files/60-validity.rules /etc/udev/rules.d/
sudo udevadm control --reload
sudo udevadm trigger

# Install Python modules (if needed)
VALIDITY_DIR=$(python3 -c "import site; print(site.getsitepackages()[0])")/validitysensor
sudo cp -r device-files/python-modules/* $VALIDITY_DIR/

# Install firmware (if available locally)
if [ -f device-files/firmware/6_07f_lenovo_mis_qm.xpfwext ]; then
    sudo cp device-files/firmware/6_07f_lenovo_mis_qm.xpfwext /usr/share/python-validity/
    sudo chown root:root /usr/share/python-validity/6_07f_lenovo_mis_qm.xpfwext
    sudo chmod 644 /usr/share/python-validity/6_07f_lenovo_mis_qm.xpfwext
fi

# Add user to input group
sudo usermod -a -G input $USER
```

### 4. Start Service

```bash
sudo systemctl enable --now python3-validity
```

### 5. Enroll Fingerprint

```bash
# Verify detection
fprintd-list $USER

# Enroll fingerprint
fprintd-enroll $USER

# Test verification
fprintd-verify $USER
```

### 6. Enable for sudo/SDDM

```bash
# Enable for sudo
echo "auth sufficient pam_fprintd.so" | sudo tee -i /etc/pam.d/sudo

# Enable for SDDM login
echo "auth sufficient pam_fprintd.so" | sudo tee -i /etc/pam.d/sddm
```

---

## Firmware

The sensor requires Lenovo firmware:
- **File:** `6_07f_lenovo_mis_qm.xpfwext`
- **Size:** ~214 KB
- **Source:** https://download.lenovo.com/pccbbs/mobiles/nz3gf07w.exe
- **Installation Location:** `/usr/share/python-validity/`

**Note:** Firmware file may not be in repository due to licensing. Download from Lenovo or copy from local installation.

---

## Troubleshooting

### Device Not Detected

```bash
# Check USB device
lsusb | grep Validity
# Should show: Bus 001 Device XXX: ID 138a:0092 Validity Sensors, Inc.

# Check service
systemctl status python3-validity

# Check logs
journalctl -u python3-validity -n 50
```

### Service Won't Start

```bash
# Install numpy dependency
sudo pacman -S python-numpy

# Restart service
sudo systemctl restart python3-validity
```

### BIOS Reset Required

If enrollment fails, BIOS reset is required:
1. Restart → F10
2. Security → Reset Fingerprint Reader
3. Save and restart
4. Wait for reset process
5. Re-enroll: `fprintd-delete $USER && fprintd-enroll $USER`

---

## Documentation

For complete documentation, see:
- `EliteBook/FINGERPRINT_ID_READERS.md` - Complete hardware integration guide
- `EliteBook/INSTALL.md` - Installation guide (Phase 15)
- `device-files/README.md` - Device files documentation

---

## Source

These files are based on:
- **Repository:** https://github.com/uunicorn/python-validity
- **Branch:** device/0092
- **License:** MIT

---

**Last Updated:** December 1, 2025  
**Status:** ✅ All files included in EliteBook repository
