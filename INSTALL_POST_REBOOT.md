# Arch Linux Post-Reboot Configuration Guide - HP EliteBook x360 1030 G2

**System configuration and setup after the first successful boot into the installed Arch Linux system.**

This guide continues from [INSTALL_PRE_REBOOT.md](INSTALL_PRE_REBOOT.md) after the first successful boot into Arch Linux. It covers biometric authentication setup, system snapshots, dotfiles deployment, and final system verification.

**Estimated Total Time**: 1-2 hours  
**Restart Count**: 0 (no restarts required)

---

## Table of Contents

1. [Phase 14.5+: First Boot Sequence and Verification](#phase-145-first-boot-sequence-and-verification)
2. [Phase 15: Fingerprint Authentication Setup](#phase-15-fingerprint-authentication-setup)
3. [Phase 15b: eObčanka (Czech ID Card) Reader Setup](#phase-15b-eobčanka-czech-id-card-reader-setup)
4. [Phase 15c: Howdy Face Recognition Authentication Setup](#phase-15c-howdy-face-recognition-authentication-setup)
5. [Phase 16: Timeshift Snapshot Configuration](#phase-16-timeshift-snapshot-configuration)
6. [Phase 17: Dotfiles Deployment](#phase-17-dotfiles-deployment)
7. [Phase 18: GPG Key Setup for Git Commits](#phase-18-gpg-key-setup-for-git-commits)
8. [Post-Installation Verification](#post-installation-verification)
9. [Troubleshooting](#troubleshooting)

---

## Phase 14.5: First Boot Sequence and Verification

**TIME: Estimated Time: 10 minutes**

**NEXT: Restart Count: 0 (system already booted)**

### Step 14.5: First Boot Sequence

**What happens during boot:**

1. **UEFI loads GRUB** (~2 seconds)
2. **GRUB menu appears** (5-second timeout):
   ```
   Arch Linux
   Arch Linux (fallback initramfs)
   Windows Boot Manager
   UEFI Firmware Settings
   ```
3. **Select "Arch Linux"** (first option) or wait for auto-boot
4. **Plymouth boot splash** appears (HP logo or UEFI graphics)
5. **No LUKS password prompt** (automatic decryption via keyfile)
6. **Btrfs root mounts**
7. **Services start** (NetworkManager, Bluetooth, PipeWire)
8. **SDDM login screen** appears

### Step 14.6: Login to SDDM

**SDDM login screen shows:**
- **User:** hp
- **Session:** Hyprland (select from dropdown if not default)

**Enter password:** `<YOUR_PASSWORD>`

**Press Enter**

### Step 14.7: Hyprland First Launch

**Hyprland loads** (~5 seconds)

**You should see:**
- Black screen with default Hyprland cursor
- No status bar yet (Waybar not auto-started)
- No wallpaper (not configured yet)

**Open terminal:**
- Press **Super+Q** (Windows key + Q)
- Kitty terminal should open

**If terminal doesn't open:**
- Press **Super+Enter** (alternative terminal binding)
- Or press **Super+R** and type `kitty`

### Step 14.8: Verify System After First Boot

**In Kitty terminal, run these commands:**

```bash
# Check kernel version
uname -r
# Should show: 6.x.x-arch1-1

# Check CPU info
lscpu | grep "Model name"
# Should show: Intel(R) Core(TM) i5-7300U

# Check memory
free -h
# Should show: ~8 GB total

# Check disk encryption status
lsblk -f
# Should show cryptroot and cryptswap

# Check Btrfs subvolumes
btrfs subvolume list /
# Should show: @ @home @log @cache @snapshots

# Check network (WiFi)
nmcli device status
# Should show: wlp58s0 connected (if WiFi is connected)

# Check Bluetooth
systemctl status bluetooth
# Should show: active (running)

# Check audio (PipeWire)
systemctl --user status pipewire
# Should show: active (running)

# Check graphics driver
lspci -k | grep -A 3 VGA
# Should show:
# Kernel driver in use: i915
```

### Step 14.9: Connect to WiFi (If Not Already Connected)

```bash
# Connect to WiFi using nmtui
nmtui
```

**Text UI appears:**
1. Select **Activate a connection**
2. Select your WiFi network
3. Enter WiFi password
4. **< Back >** to exit

**Verify connection:**
```bash
ping -c 3 archlinux.org
```

### Step 14.10: Update System

```bash
# Update package database and system
sudo pacman -Syu

# Enter password: <YOUR_PASSWORD>
```

****WARNING:** If any kernel updates install, reboot:**
```bash
sudo reboot
```

### Step 14.11: Verify Webcam (HD Camera + IR Camera)

The HP EliteBook x360 1030 G2 has two cameras:
- **HP HD Camera** (04f2:b58f) - 720p webcam for video calls
- **HP IR Camera** (04f2:b58e) - Infrared camera for face recognition

```bash
# Verify cameras detected
lsusb | grep -i camera
# Should show:
# Bus 001 Device 005: ID 04f2:b58f Chicony Electronics Co., Ltd HP HD Camera
# Bus 001 Device 007: ID 04f2:b58e Chicony Electronics Co., Ltd HP IR Camera

# List video devices
v4l2-ctl --list-devices
# HP HD Camera: /dev/video0, /dev/video1
# HP IR Camera: /dev/video2, /dev/video3

# Test HD webcam capture (720p)
ffmpeg -f v4l2 -video_size 1280x720 -input_format mjpeg \
  -i /dev/video0 -frames:v 1 -update 1 ~/Pictures/webcam_test.jpg

# Test IR camera capture (480p)
ffmpeg -f v4l2 -video_size 640x480 -input_format yuyv422 \
  -i /dev/video2 -frames:v 1 -update 1 ~/Pictures/ir_test.jpg

# Verify images created
ls -la ~/Pictures/*.jpg
```

**Webcam specifications:**

| Camera | Device | Resolution | Format | Use Case |
|--------|--------|------------|--------|----------|
| HD Camera | /dev/video0 | 1280×720 | MJPEG | Video calls |
| IR Camera | /dev/video2 | 640×480 | YUYV | Face recognition |

****SUCCESS:** Both cameras detected and functional**

### Step 14.12: Verify SSH Service (Optional - for Remote Access)

**If you need to continue configuration remotely via SSH:**

```bash
# Check SSH service status
systemctl status sshd.service
# Should show: active (running)

# Check SSH listening port
ss -tlnp | grep :22
# Should show: LISTEN on port 22

# Get IP address for SSH connection
ip addr show | grep "inet " | grep -v 127.0.0.1
# Example output (HP EliteBook x360 1030 G2): inet 192.168.0.39/24
```

**Connect from remote computer:**
```bash
# From your second computer
ssh root@<IP_ADDRESS>
# Or if user account is created:
ssh <USERNAME>@<IP_ADDRESS>
```

****SUCCESS:** SSH service is running and accessible remotely**

---

****SUCCESS:** Phase 14 Complete: System booted successfully, all services running, SSH accessible for remote administration**

****NEXT:** Next: Configure fingerprint authentication (Phase 15)**

---

## Phase 15: Fingerprint Authentication Setup

### 15.1 Theoretical Foundation of Biometric Authentication

#### 15.1.1 Introduction to Biometric Authentication

Biometric authentication is a security mechanism that uses unique physical or behavioral characteristics to verify identity. Unlike traditional authentication methods (passwords, PINs), biometrics are inherently tied to the individual and cannot be easily transferred or forgotten.

**Biometric Characteristics:**

Biometric systems can use various characteristics:

1. **Physiological Characteristics**:
   - Fingerprints (ridge patterns)
   - Facial features
   - Iris patterns
   - Retinal patterns
   - Hand geometry

2. **Behavioral Characteristics**:
   - Typing rhythm
   - Voice patterns
   - Gait analysis

**Fingerprint Authentication:**

Fingerprint authentication uses the unique ridge patterns on human fingertips. Each fingerprint contains:
- **Ridges**: Raised lines on the skin
- **Valleys**: Spaces between ridges
- **Minutiae**: Unique features (ridge endings, bifurcations)

**Mathematical Representation:**

Fingerprints are typically represented as:
- **Template**: Mathematical model of fingerprint features (minutiae points, ridge patterns)
- **Matching Algorithm**: Algorithm that compares templates and calculates similarity score
- **Threshold**: Similarity threshold that determines match/non-match

**Official Resources:**
- [Biometric Authentication on Wikipedia](https://en.wikipedia.org/wiki/Biometric_authentication)
- [Fingerprint Recognition on Wikipedia](https://en.wikipedia.org/wiki/Fingerprint_recognition)
- [NIST Biometric Standards](https://www.nist.gov/itl/iad/image-group/biometric-specifications)

#### 15.1.2 Fingerprint Sensor Technology

**Optical Sensors:**

Optical sensors use light to capture fingerprint images:
- **Principle**: Light reflects differently from ridges vs. valleys
- **Advantages**: Reliable, good image quality
- **Limitations**: Can be fooled by high-quality images

**Capacitive Sensors:**

Capacitive sensors measure electrical capacitance:
- **Principle**: Ridges and valleys have different capacitance
- **Advantages**: More secure (harder to spoof), compact
- **Limitations**: Requires direct skin contact

**Ultrasonic Sensors:**

Ultrasonic sensors use sound waves:
- **Principle**: Sound waves reflect differently from ridges vs. valleys
- **Advantages**: Can work through thin materials, 3D imaging
- **Limitations**: More expensive, slower

**Validity Sensors 138a:0092:**

The Validity Sensors 138a:0092 (Synaptics VFS7552) used in HP EliteBook x360 1030 G2 is a capacitive fingerprint sensor that:
- **Technology**: Capacitive sensor array
- **Resolution**: Typically 256×360 pixels
- **Interface**: USB (USB HID device)
- **Firmware**: Requires proprietary firmware for initialization

#### 15.1.3 Linux Fingerprint Authentication Stack

**libfprint:**

[libfprint](https://fprint.freedesktop.org/) is the standard Linux fingerprint library, part of the freedesktop.org project. It provides:
- **Device Abstraction**: Unified API for different fingerprint sensors
- **Enrollment**: Template creation and storage
- **Verification**: Template matching and authentication
- **PAM Integration**: Pluggable Authentication Module support

**fprintd:**

fprintd (Fingerprint Daemon) is the system service that manages fingerprint operations:
- **Service**: Runs as systemd service (`fprintd.service`)
- **Database**: Stores fingerprint templates in `/var/lib/fprint/`
- **Security**: Templates are encrypted and user-specific
- **API**: Provides D-Bus API for applications

**python-validity:**

[python-validity](https://github.com/uunicorn/python-validity) is a Linux driver specifically for Validity Sensors fingerprint readers. It provides:
- **Device Communication**: Low-level USB communication with Validity Sensors
- **Firmware Management**: Handles proprietary firmware upload
- **Linux Integration**: Works with fprintd for system integration

**Why python-validity (not libfprint directly)?**

libfprint has limited support for Validity Sensors, especially newer models. python-validity:
- **Validity-Specific**: Designed specifically for Validity Sensors
- **Firmware Support**: Handles proprietary firmware required by Validity Sensors
- **Device Branches**: Different code branches for different sensor models (device/0092 for our sensor)

**Official Resources:**
- [fprintd (libfprint) Website](https://fprint.freedesktop.org/)
- [python-validity GitHub](https://github.com/uunicorn/python-validity)
- [ArchWiki Fprint](https://wiki.archlinux.org/title/Fprint)
- [PAM Documentation](https://www.linux-pam.org/)

#### 15.1.4 Authentication Flow

**Enrollment Process:**

1. **Sensor Initialization**: python-validity uploads firmware to sensor
2. **Finger Placement**: User places finger on sensor multiple times (typically 3-5 times)
3. **Image Capture**: Sensor captures multiple fingerprint images
4. **Feature Extraction**: Algorithm extracts minutiae points and ridge patterns
5. **Template Creation**: Creates mathematical template from features
6. **Storage**: Template stored in `/var/lib/fprint/` (encrypted, user-specific)

**Authentication Process:**

1. **Finger Placement**: User places finger on sensor
2. **Image Capture**: Sensor captures fingerprint image
3. **Feature Extraction**: Algorithm extracts features from image
4. **Template Comparison**: Compares extracted features with stored templates
5. **Similarity Score**: Calculates similarity score (0.0 to 1.0)
6. **Decision**: If score exceeds threshold (typically 0.5-0.7), authentication succeeds

**PAM Integration:**

PAM (Pluggable Authentication Modules) provides the interface between applications and authentication methods:

```
Application (sudo, login, etc.)
    ↓
PAM Framework
    ↓
pam_fprintd.so module
    ↓
fprintd daemon
    ↓
python-validity driver
    ↓
Fingerprint Sensor
```

**Security Considerations:**

1. **False Acceptance Rate (FAR)**: Probability of accepting an unauthorized user
   - Typical values: 0.001% to 0.01%
   - Mitigation: Adjustable similarity threshold

2. **False Rejection Rate (FRR)**: Probability of rejecting an authorized user
   - Typical values: 1% to 5%
   - Mitigation: Multiple enrollment attempts, quality thresholds

3. **Template Security**: Fingerprint templates are stored encrypted and user-specific
4. **Spoofing Resistance**: Capacitive sensors are more resistant to spoofing than optical sensors

**References:**

[18] freedesktop.org. (2007-2025). "libfprint - Open Source Fingerprint Reader Library." fprint.freedesktop.org.  
[19] uunicorn. (2018-2025). "python-validity - Linux Driver for Validity Sensors." GitHub Repository.  
[20] Jain, A. K., Ross, A., & Prabhakar, S. (2004). "An Introduction to Biometric Recognition." IEEE Transactions on Circuits and Systems for Video Technology, 14(1), 4-20.

---

### Understanding Fingerprint Authentication

**What is Biometric Authentication?**

Biometric authentication uses unique physical characteristics (fingerprints, face, iris) to verify identity. It's more convenient than passwords because:
- **No Typing**: Just place finger on sensor
- **Unique**: Each fingerprint is unique (even identical twins have different fingerprints)
- **Fast**: Authentication happens in seconds
- **Secure**: Hard to forge (unlike passwords, can't be written down)

**Why Fingerprint (instead of just passwords)?**

**Password-Only Authentication:**
- **Inconvenient**: Must type password every time
- **Forgettable**: Easy to forget complex passwords
- **Typing**: Slower, especially on mobile devices

**Fingerprint Authentication:**
- **Convenient**: Quick touch authentication
- **Fast**: Authentication in 1-2 seconds
- **Secure**: Unique biometric data
- **User-Friendly**: Natural interaction

**What is python-validity?**

[python-validity](https://github.com/uunicorn/python-validity) is a Linux driver for Validity Sensors fingerprint readers. It provides:
- **Device Communication**: Low-level communication with fingerprint sensor
- **Firmware Management**: Handles firmware upload to sensor
- **Linux Integration**: Works with fprintd (fingerprint daemon)

**Why python-validity (not libfprint directly)?**

**libfprint** is the standard Linux fingerprint library, but:
- **Limited Device Support**: Doesn't support all fingerprint sensors
- **Validity Sensors**: Many Validity Sensors (like 138a:0092) require proprietary firmware

**python-validity**:
- **Validity-Specific**: Designed specifically for Validity Sensors
- **Firmware Support**: Handles proprietary firmware upload
- **Device Branches**: Different branches for different sensor models (device/0092 for our sensor)

**What is fprintd?**

**fprintd** (Fingerprint Daemon) is the system service that manages fingerprint enrollment and authentication:
- **Enrollment**: Stores fingerprint templates
- **Verification**: Compares scanned fingerprint with enrolled templates
- **PAM Integration**: Works with PAM (Pluggable Authentication Modules) for system authentication

**How Fingerprint Authentication Works:**

1. **Enrollment**: User places finger on sensor multiple times, system creates a template
2. **Storage**: Template is stored securely (encrypted) in `/var/lib/fprint/`
3. **Authentication**: User places finger on sensor, system compares with stored templates
4. **PAM Integration**: If match found, PAM grants access (sudo, login, etc.)

**Why BIOS Reset Required?**

Validity Sensors require firmware initialization. If the sensor was previously used (e.g., in Windows), it may be in an incompatible state. BIOS reset:
- **Clears State**: Resets sensor to factory state
- **Firmware Upload**: Allows python-validity to upload correct firmware
- **Initialization**: Prepares sensor for Linux use

**Official Resources:**
- [python-validity GitHub Repository](https://github.com/uunicorn/python-validity)
- [python-validity device/0092 branch](https://github.com/uunicorn/python-validity/tree/device/0092)
- [fprintd (libfprint)](https://fprint.freedesktop.org/) - Fingerprint daemon
- [ArchWiki Fprint](https://wiki.archlinux.org/title/Fprint)

****TIME:** Estimated Time: 10-15 minutes**



---


---

## **SUCCESS:** WORKING SOLUTION: Fingerprint Support for 138a:0092

**Good news!** The Validity 138a:0092 sensor CAN be made to work using the **device/0092 branch** of python-validity.

### Solution Source

This solution was found through community efforts on GitHub and verified working on:
- **Ubuntu 22.04 LTS** with HP x360 1030 G2
- **Arch Linux** with HP EliteBook x360 1030 G2

**Source:** [GitHub Issue #77 - python-validity](https://github.com/uunicorn/python-validity/issues/77)

### Installation Steps for 138a:0092

**Step 1: Install base packages**

```bash
# Install fprintd and dependencies
sudo pacman -S --noconfirm fprintd libfprint python-numpy

# Remove standard fprintd (conflicts with open-fprintd)
sudo pacman -Rdd --noconfirm fprintd libfprint
```

**Step 2: Install python-validity from AUR**

```bash
# This will install open-fprintd and fprintd-clients-git
yay -S --noconfirm python-validity-git
```

**Step 3: Install device/0092 branch support**

```bash
# Clone the device/0092 branch
cd /tmp
git clone -b device/0092 https://github.com/uunicorn/python-validity.git python-validity-0092

# Find python-validity installation location
VALIDITY_DIR=$(python3 -c "import site; print(site.getsitepackages()[0])")/validitysensor

# Backup original files
sudo cp -r $VALIDITY_DIR ${VALIDITY_DIR}.backup

# Copy device/0092 branch files
sudo cp -r /tmp/python-validity-0092/validitysensor/* $VALIDITY_DIR/

# Verify blobs_92.py exists
ls -la $VALIDITY_DIR/blobs_92.py
```

**Step 4: Restart service**

```bash
# Restart python3-validity service
sudo systemctl restart python3-validity.service

# Check service status
systemctl status python3-validity.service
```

**Step 5: Enroll fingerprint**

```bash
# Check device detection
fprintd-list $USER
# Expected: "found 1 devices"

# Enroll fingerprint (right index finger)
fprintd-enroll $USER

# Follow prompts and scan finger 5-10 times
```

**Step 6: Configure PAM for sudo**

```bash
# Edit /etc/pam.d/sudo
sudo nano /etc/pam.d/sudo

# Add at the TOP of the file:
auth      sufficient   pam_fprintd.so

# Save and exit (Ctrl+X, Y, Enter)
```

**Step 7: Test fingerprint sudo**

```bash
# Test sudo with fingerprint
sudo ls /root
# Should prompt: "Place your finger on the fingerprint reader"
```

### Verification

```bash
# Verify device is detected
lsusb | grep -i validity
# Output: Bus 001 Device 003: ID 138a:0092 Validity Sensors, Inc.

# Check enrolled fingerprints
fprintd-list $USER
# Should show: "right-index-finger"

# Check service status
systemctl status python3-validity.service
# Should be: "active (running)"
```

### Troubleshooting

**Issue: Service fails to start**
```bash
# Check logs
journalctl -u python3-validity.service -n 50

# Common fix: Install numpy
sudo pacman -S python-numpy

# Restart service
sudo systemctl restart python3-validity.service
```

**Issue: Device not detected**
```bash
# Check USB device
lsusb -d 138a:0092 -v

# Reload udev rules
sudo udevadm control --reload-rules
sudo udevadm trigger

# Restart service
sudo systemctl restart python3-validity.service
```

**Issue: Enrollment hangs**
```bash
# Kill enrollment process
pkill fprintd-enroll

# Restart service and try again
sudo systemctl restart python3-validity.service
fprintd-enroll $USER
```

### Important Notes

- The device/0092 branch is **NOT merged into master** - you must manually install it
- Requires **python-numpy** package (installed automatically with python-validity-git)
- Service must be running before enrollment: `systemctl status python3-validity.service`
- After system updates, you may need to re-apply the device/0092 files

### Credits

Solution developed by:
- [@uunicorn](https://github.com/uunicorn) - python-validity project
- Community contributors on [Issue #77](https://github.com/uunicorn/python-validity/issues/77)

****SUCCESS:** Phase 15 Complete: Fingerprint authentication configured for 138a:0092**

---



****NEXT:** Restart Count: 0**

**Fingerprint Sensor:** Validity Sensors 138a:0092 (built-in)

### Step 15.1: Install Fingerprint Packages

```bash
# Install fprintd and libfprint
sudo pacman -S fprintd libfprint

# Enter password: <YOUR_PASSWORD>
```

**Proceed with installation: [Y/n]** - Press Enter

### Step 15.2: Verify Fingerprint Sensor is Detected

```bash
# List USB devices to find fingerprint sensor
lsusb | grep -i validity

# Should show:
# Bus 001 Device XXX: ID 138a:0092 Validity Sensors, Inc.
```

****SUCCESS:** Fingerprint sensor detected**

### Step 15.3: Enroll Fingerprint for User "hp"

```bash
# Start fingerprint enrollment
fprintd-enroll hp
```

**You will see:**
```
Using device /net/reactivated/Fprint/Device/0
Enrolling right-index-finger finger.
Enroll result: enroll-stage-passed
Enroll result: enroll-stage-passed
Enroll result: enroll-stage-passed
...
Enroll result: enroll-completed
```

**Instructions:**
1. **Place finger on sensor** when prompted
2. **Lift and place again** (repeat 5-10 times)
3. **Vary finger position** slightly each time (center, left, right, rotated)
4. **Wait for "enroll-completed"** message

****SUCCESS:** Fingerprint enrolled successfully**

**Optional: Enroll additional fingers:**
```bash
# Enroll left index finger
fprintd-enroll -f left-index-finger hp

# Enroll right thumb
fprintd-enroll -f right-thumb hp
```

### Step 15.4: Verify Enrolled Fingerprints

```bash
# List enrolled fingerprints for user hp
fprintd-list hp

# Should show:
# found 1 devices
# Device at /net/reactivated/Fprint/Device/0
# Using device /net/reactivated/Fprint/Device/0
# Fingerprints for user hp on Validity Sensors, Inc.:
#  - #0: right-index-finger
```

### Step 15.5: Test Fingerprint Authentication

```bash
# Test fingerprint verification
fprintd-verify hp
```

**Instructions:**
1. **Place enrolled finger on sensor**
2. **Should show:** `Verify result: verify-match (done)`

**If fails:**
```
Verify result: verify-no-match
```

**Try again** with better finger placement.

### Step 15.6: Configure PAM for Fingerprint Login

**PAM (Pluggable Authentication Modules)** controls authentication methods.

**Configure sudo to accept fingerprint:**

```bash
# Edit sudo PAM configuration
sudo nano /etc/pam.d/sudo
```

**Add this line at the TOP of the file (before all other lines):**

```
auth      sufficient   pam_fprintd.so
```

**Full file should look like:**
```
auth      sufficient   pam_fprintd.so
auth      include      system-auth
account   include      system-auth
session   include      system-auth
```

**Save and exit** (Ctrl+O, Enter, Ctrl+X)

**Configure SDDM login to accept fingerprint:**

```bash
# Edit SDDM PAM configuration
sudo nano /etc/pam.d/sddm
```

**Add this line at the TOP:**

```
auth      sufficient   pam_fprintd.so
```

**Save and exit**

### Step 15.7: Test Fingerprint Sudo

**Open new terminal** (Super+Q)

```bash
# Test sudo with fingerprint
sudo ls /root

# You should see:
# Place your finger on the fingerprint reader
```

**Place enrolled finger on sensor**

**Should authenticate without password** **SUCCESS:**

**If fails, fallback to password:**
```
Password:
```

**Enter:** `<YOUR_PASSWORD>`

### Step 15.8: Test Fingerprint Login (Optional)

**Logout of Hyprland:**
```bash
# Logout
hyprctl dispatch exit
```

**SDDM login screen appears**

**Click on username "hp"**

**Password field should show:** "Place your finger on the fingerprint reader"

**Place enrolled finger**

**Should login without password** **SUCCESS:**

****SUCCESS:** Phase 15 Complete: Fingerprint authentication configured for sudo and login**

---

## Phase 15b: eObčanka (Czech ID Card) Reader Setup

****TIME:** Estimated Time:** 5 minutes  
****NEXT:** Restart Count:** 0 (no restart required)

**Purpose:** Configure the built-in ID card reader for Czech eObčanka (electronic ID card) authentication and digital signatures.

**Hardware:** HP EliteBook x360 1030 G2 has integrated smart card reader

---

### Step 15b.1: Install Smart Card Packages

```bash
# Install PC/SC daemon and tools
sudo pacman -S --noconfirm pcsclite ccid pcsc-tools

# Install Czech eObčanka middleware (from AUR)
yay -S --noconfirm eidklient
```

**Package explanation:**
- `pcsclite` - PC/SC Smart Card Daemon (middleware for smart card readers)
- `ccid` - Generic USB CCID driver (for most card readers)
- `pcsc-tools` - Tools for testing PC/SC (pcsc_scan, etc.)
- `eidklient` - Czech government eObčanka client (requires AUR)

---

### Step 15b.2: Enable and Start PC/SC Service

```bash
# Enable PC/SC daemon to start on boot
sudo systemctl enable pcscd.service

# Start PC/SC daemon immediately
sudo systemctl start pcscd.service

# Verify service is running
sudo systemctl status pcscd.service
```

**Expected output:**
```
● pcscd.service - PC/SC Smart Card Daemon
     Loaded: loaded (/usr/lib/systemd/system/pcscd.service; enabled; preset: disabled)
     Active: active (running) since ...
```

---

### Step 15b.3: Detect Smart Card Reader

```bash
# List connected smart card readers
pcsc_scan
```

**Expected output:**
```
PC/SC device scanner
V 1.x.x (c) 2001-2024, Ludovic Rousseau
Using reader plug'n play mechanism
Scanning present readers...
0: Alcor Micro AU9560 00 00
 
Waiting for card insertion/removal...
```

**Press Ctrl+C to stop scanning**

---

### Step 15b.4: Test eObčanka Detection

**Insert your eObčanka card into the reader, then:**

```bash
# Test card detection
pcsc_scan

# Alternative: Check card ATR (Answer To Reset)
opensc-tool --list-readers
opensc-tool --name
```

**Expected output with card inserted:**
```
Card state: State has changed
ATR: 3B DF 18 FF 81 F1 FE 43 00 3F 03 83 ... (eObčanka ATR)
```

---

### Step 15b.5: Launch eObčanka Client (GUI)

```bash
# Launch eObčanka Klient (graphical application)
eidklient &
```

**Features of eObčanka Klient:**
- View certificate information
- Sign PDF documents
- Authenticate to Czech government portals (Portál občana, Czech POINT)
- Change PIN/PUK codes
- Export certificates

---

### Step 15b.6: Browser Integration (Optional)

For web authentication with eObčanka in Chromium/Chrome:

```bash
# Enable PKCS#11 module in Chrome
# Go to: chrome://settings/security
# Advanced → Manage certificates → Your Certificates → Import
# Select: /usr/lib/libeToken.so (eObčanka PKCS#11 module)
```

---

### Step 15b.7: Verify Setup

```bash
# Check if PC/SC daemon is running
systemctl status pcscd.service

# Check if reader is detected
pcsc_scan

# Check if eObčanka middleware is installed
which eidklient

# Test eObčanka GUI
eidklient
```

****SUCCESS:** eObčanka reader is now configured and ready to use**

---

****NEXT:** Next: Configure face recognition authentication with Howdy (Phase 15c) or proceed to Timeshift snapshots (Phase 16)**

**Note:** Phase 15c requires yay (AUR helper). If yay is not yet installed, it will be installed in Phase 17. You can either install yay now (Step 15c.0) or complete Phase 15c after Phase 17.

---

## Phase 15c: Howdy Face Recognition Authentication Setup

****TIME:** Estimated Time: 20-30 minutes**

****NEXT:** Restart Count: 0 (no restart required)**

**Purpose:** Configure Howdy (Windows Hello-style facial authentication) for passwordless sudo and login authentication using the built-in IR camera.

**Hardware Requirements:**
- HP EliteBook x360 1030 G2 with Chicony IR Camera (04f2:b58e)
- IR camera device: `/dev/video2` (640×480, YUYV format)
- Video4Linux2 (v4l2) support enabled in kernel

**Software Requirements:**
- AUR helper (yay) installed (see Step 15c.0 below if not yet installed)
- Python 3.x
- Video4Linux2 utilities (`v4l-utils`)

---

### Step 15c.0: Install AUR Helper (yay) - If Not Already Installed

****WARNING:** Skip this step if yay is already installed (check with `which yay`)**

```bash
# Check if yay is installed
which yay

# If command returns nothing, install yay:
cd /tmp
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

# Proceed with installation: [Y/n] - Press Enter
```

**Verify yay installation:**
```bash
yay --version
# Expected: yay vXX.X.X
```

****SUCCESS:** yay installed and ready for AUR package installation**

---

---

### Step 15c.1: Verify IR Camera Detection

```bash
# Verify IR camera is detected
lsusb | grep -i "IR Camera"
# Expected: Bus 001 Device XXX: ID 04f2:b58e Chicony Electronics Co., Ltd HP IR Camera

# List video devices
v4l2-ctl --list-devices
# Should show: HP IR Camera at /dev/video2

# Test IR camera capture capability
v4l2-ctl --device=/dev/video2 --list-formats-ext
# Should show: YUYV format support
```

****SUCCESS:** IR camera must be detected before proceeding**

---

### Step 15c.2: Install Build Dependencies

```bash
# Install required build tools and dependencies
sudo pacman -S --noconfirm base-devel cmake git python python-pip python-setuptools

# Install video4linux2 utilities
sudo pacman -S --noconfirm v4l-utils

# Install Python scientific computing libraries
sudo pacman -S --noconfirm python-numpy python-scipy

# Install linear algebra libraries (required for dlib)
sudo pacman -S --noconfirm openblas lapack
```

---

### Step 15c.3: Install python-dlib (CPU-only build)

**[python-dlib](https://aur.archlinux.org/packages/python-dlib)** is a Python library for machine learning, required by Howdy for face recognition.

**Official Resources:**
- [dlib C++ Library](http://dlib.net/)
- [python-dlib AUR Package](https://aur.archlinux.org/packages/python-dlib)

**Note:** Howdy requires `python-dlib` for face recognition. The AUR package builds both CPU and CUDA versions by default. We will build only the CPU version to avoid CUDA dependency issues.

```bash
# Clone python-dlib AUR package
cd /tmp
git clone https://aur.archlinux.org/python-dlib.git
cd python-dlib

# Modify PKGBUILD to disable CUDA build
sed -i 's/_build_cuda=1/_build_cuda=0/' PKGBUILD

# Build and install python-dlib (CPU-only)
makepkg -si --noconfirm

# Verify installation
python3 -c "import dlib; print('dlib version:', dlib.__version__)"
# Expected: dlib version: 20.0.0
```

****TIME:** Build time: 15-30 minutes** (compiles dlib C++ library with Python bindings)

**Troubleshooting:**
- If build fails with CUDA errors, ensure `_build_cuda=0` in PKGBUILD
- If build fails with compiler errors, install `gcc` and `gcc-libs`
- If build fails with missing headers, install `python` development headers

---

### Step 15c.4: Install Howdy from AUR

```bash
# Install howdy-bin (pre-built binary package, faster installation)
yay -S --noconfirm howdy-bin

# Alternative: Install howdy (source build, requires python2)
# yay -S --noconfirm howdy
```

**Package dependencies installed:**
- `howdy-bin` (main package)
- `python-dlib` (face recognition library, already installed)
- `pam-python` (PAM module for Python authentication)

**Verify installation:**
```bash
# Check howdy binary location
which howdy
# Expected: /usr/bin/howdy

# Check howdy version
howdy --version
# Expected: howdy 2.6.1
```

---

### Step 15c.5: Configure Howdy Video Device

```bash
# List available video devices
v4l2-ctl --list-devices

# Configure Howdy to use IR camera
sudo howdy config

# In the configuration editor, set:
# device_path = /dev/video2
# 
# Save and exit (Ctrl+X, Y, Enter)
```

**Alternative: Manual configuration**

```bash
# Edit Howdy configuration file
sudo nano /lib/security/howdy/config.ini

# Find [video] section and set:
# device_path = /dev/video2

# Save and exit
```

**Configuration file location:** `/lib/security/howdy/config.ini`

---

### Step 15c.6: Test Camera Access

```bash
# Test IR camera with Howdy
sudo howdy test

# Expected output:
# Opening camera...
# Camera opened successfully
# Press Ctrl+C to exit
```

**If camera fails to open:**
- Verify device path: `ls -la /dev/video2`
- Check permissions: `ls -la /dev/video2` (should be readable by root)
- Test with v4l2-ctl: `v4l2-ctl --device=/dev/video2 --stream-mmap --stream-count=1`

---

### Step 15c.7: Enroll Face Model

**⚠️ IMPORTANT: This step requires interactive user input and cannot be automated.**

```bash
# Add face model for current user
sudo howdy add

# Or for specific user:
sudo howdy -U <USERNAME> add
```

**Enrollment Process:**

1. **Position yourself:**
   - Stand 30-60 cm from the camera
   - Look directly at the camera
   - Ensure good lighting (IR camera works in low light)

2. **Follow on-screen prompts:**
   - Enter a label for the face model (e.g., "Initial model" or your username)
   - Wait for camera to capture your face
   - Camera will capture multiple images (3-5 times)
   - Wait for "Face model saved successfully" message

3. **Expected output:**
   ```
   Adding face model for the user <USERNAME>
   Enter a label for this new model [Initial model] (max 24 characters): 
   [Enter label and press Enter]
   Opening camera...
   Look straight into the camera until it turns green
   [Camera captures face multiple times]
   Face model saved successfully
   ```

**Enrollment Details:**
- Howdy captures multiple face images from different angles
- Face model is stored in `/lib/security/howdy/models/`
- Each user has a separate model file
- Label can be up to 24 characters

**Verify enrollment:**
```bash
# List enrolled models
sudo howdy list

# Expected output:
# Known face models:
# <USERNAME> (ID: 0)
```

**Note:** If enrollment fails or is interrupted, you can re-run `sudo howdy add` to try again. To remove an existing model first, use `sudo howdy remove`.

---

### Step 15c.8: Configure PAM for sudo Authentication

```bash
# Backup original PAM configuration
sudo cp /etc/pam.d/sudo /etc/pam.d/sudo.backup

# Edit sudo PAM configuration
sudo nano /etc/pam.d/sudo

# Add at the TOP of the file (before other auth lines):
auth      sufficient  pam_python.so /lib/security/howdy/pam.py

# Save and exit (Ctrl+X, Y, Enter)
```

**PAM configuration order is critical:**
- `sufficient` means if Howdy authentication succeeds, no password is required
- If Howdy fails, PAM falls back to password authentication
- Place Howdy line before `pam_unix.so` for proper fallback behavior

**Example `/etc/pam.d/sudo` configuration:**
```
auth      sufficient  pam_python.so /lib/security/howdy/pam.py
auth      sufficient  pam_fprintd.so
auth      include    system-auth
```

---

### Step 15c.9: Configure PAM for Login Authentication (Optional)

**For SDDM login screen authentication:**

```bash
# Backup original PAM configuration
sudo cp /etc/pam.d/sddm /etc/pam.d/sddm.backup

# Edit SDDM PAM configuration
sudo nano /etc/pam.d/sddm

# Add at the TOP of the file:
auth      sufficient  pam_python.so /lib/security/howdy/pam.py

# Save and exit
```

**Note:** SDDM login screen may require additional configuration for camera access during login.

**SDDM Auto-Activation (New Feature):**

The SDDM theme has been enhanced with automatic biometric activation. The camera and fingerprint sensor activate automatically 1 second after the login screen appears, without requiring user interaction.

**How it works:**
1. Login screen displays
2. After 1 second, auto-auth timer triggers
3. PAM authentication starts with empty password
4. Howdy (camera) activates first (face recognition)
5. If face recognition fails, fingerprint sensor activates
6. If both fail, password field is focused

**Benefits:**
- ✅ No user interaction required for biometric activation
- ✅ Faster login when biometrics succeed
- ✅ Seamless fallback to password

**Documentation:**
- See [HOWDY_SDDM_AUTO_ACTIVATION.md](HOWDY_SDDM_AUTO_ACTIVATION.md) for detailed implementation
- See [HOWDY_SDDM_SETUP.md](HOWDY_SDDM_SETUP.md) for SDDM configuration details

---

### Step 15c.10: Test Face Recognition Authentication

```bash
# Test sudo authentication with face recognition
sudo whoami

# Expected behavior:
# 1. Camera activates (IR LED may turn on)
# 2. Face detection occurs
# 3. Authentication succeeds without password prompt
# 4. Command executes
```

**If authentication fails:**
- Verify face model exists: `sudo howdy list`
- Check camera access: `sudo howdy test`
- Review Howdy logs: `sudo journalctl -u howdy -n 50`
- Re-enroll face model: `sudo howdy remove` then `sudo howdy add`

---

### Step 15c.11: Configure Howdy Settings (Optional)

```bash
# Open Howdy configuration
sudo howdy config

# Recommended settings:
# [video]
# device_path = /dev/video2
# 
# [snapshots]
# capture_failed = true          # Save failed authentication attempts
# capture_successful = false      # Don't save successful authentications
# 
# [timeout]
# detection_timeout = 5          # Seconds to wait for face detection
# 
# [core]
# no_confirmation = false         # Require confirmation for model deletion
# 
# Save and exit
```

**Configuration file:** `/lib/security/howdy/config.ini`

---

### Step 15c.12: Verify Howdy Service Status

```bash
# Check Howdy installation
sudo howdy version

# List enrolled face models
sudo howdy list

# Test camera access
sudo howdy test

# Check PAM configuration
grep -i howdy /etc/pam.d/sudo
# Expected: auth sufficient pam_python.so /lib/security/howdy/pam.py
```

---

### Step 15c.13: Troubleshooting Common Issues

**Issue: Camera not detected**
```bash
# Verify camera device exists
ls -la /dev/video2

# Check USB device connection
lsusb | grep -i camera

# Test camera with v4l2-ctl
v4l2-ctl --device=/dev/video2 --list-formats-ext
```

**Issue: Face recognition fails**
```bash
# Remove and re-enroll face model
sudo howdy remove
sudo howdy add

# Check Howdy logs
sudo journalctl -u howdy -n 100

# Verify camera lighting (IR camera works in low light)
```

**Issue: PAM authentication not working**
```bash
# Verify PAM module is installed
ls -la /lib/security/howdy/pam.py

# Check PAM configuration syntax
sudo pamtest auth sudo

# Review PAM logs
sudo journalctl -u pam -n 50
```

**Issue: Permission denied errors**
```bash
# Verify howdy binary permissions
ls -la /usr/bin/howdy

# Check PAM module permissions
ls -la /lib/security/howdy/pam.py

# Ensure user is in video group (if required)
groups $USER
```

---

### Step 15c.14: Security Considerations

**Howdy Security Notes:**
- Face recognition is less secure than fingerprint authentication
- Face models are stored in `/lib/security/howdy/models/` (root access required)
- Failed authentication attempts can be logged (configure in `config.ini`)
- IR camera provides better security than RGB camera (harder to spoof)

**Best Practices:**
- Use face recognition as convenience feature, not primary security
- Keep password authentication enabled as fallback
- Regularly update face model if appearance changes significantly
- Monitor authentication logs for suspicious activity

---

****SUCCESS:** Phase 15c Complete: Howdy face recognition authentication configured**

****NEXT:** Next: Configure Timeshift snapshots (Phase 16) or proceed to dotfiles deployment (Phase 17)**

---

## Phase 16: Timeshift Snapshot Configuration

### Understanding System Snapshots

**What is a System Snapshot?**

A system snapshot is a point-in-time copy of your entire system (or selected parts). Think of it like a "save point" in a video game - you can return to that exact state later.

**Why System Snapshots?**

**Common Scenarios:**
1. **System Updates**: Before updating, create snapshot. If update breaks something, restore snapshot.
2. **Configuration Changes**: Before changing system config, create snapshot. If something goes wrong, restore.
3. **Software Installation**: Before installing new software, create snapshot. If it causes issues, restore.
4. **Experimentation**: Try new things safely - if it breaks, restore.

**Without Snapshots:**
- **Risky Updates**: Every update is a risk (could break system)
- **Time-Consuming Recovery**: If something breaks, must reinstall or manually fix
- **Data Loss Risk**: Mistakes can cause data loss

**With Snapshots:**
- **Safe Updates**: Update with confidence (can always restore)
- **Instant Recovery**: Restore system in minutes (not hours)
- **Peace of Mind**: Experiment freely, knowing you can undo changes

**What is [Timeshift](https://github.com/teejee2008/timeshift)?**

Timeshift is a system restore utility for Linux. It creates snapshots using:
- **Btrfs Snapshots**: For Btrfs filesystems (what we use)
- **RSYNC Snapshots**: For other filesystems (ext4, XFS, etc.)

**Why Timeshift (instead of manual Btrfs snapshots)?**

**Manual Btrfs Snapshots:**
- **Command-Line Only**: Must remember commands
- **No Scheduling**: Must manually create snapshots
- **No GUI**: No graphical interface
- **Complex Management**: Must manually manage snapshot retention

**Timeshift Advantages:**
1. **GUI Interface**: Easy-to-use graphical interface
2. **Automatic Scheduling**: Can schedule automatic snapshots (daily, weekly, etc.)
3. **Smart Retention**: Automatically manages old snapshots (keeps recent, deletes old)
4. **Easy Restoration**: Simple restore process (select snapshot, click restore)
5. **Btrfs Integration**: Optimized for Btrfs (uses native snapshots, very fast)
6. **Selective Restore**: Can restore system files but keep user data

**How Btrfs Snapshots Work:**

Btrfs snapshots are **copy-on-write**:
- **Instant Creation**: Snapshot creation is instant (just creates pointers)
- **Space Efficient**: Snapshots share data blocks with original
- **Only Changes Stored**: When you modify a file, only the changed blocks are stored separately
- **Fast Restore**: Restore is also fast (just updates pointers)

**Example:**
```
Original:  [File A] [File B] [File C]  (10 GB)
Snapshot:  [File A] [File B] [File C]  (0 GB - just pointers)

After modifying File B:
Original:  [File A] [File B'] [File C]  (10.1 GB)
Snapshot:  [File A] [File B]  [File C]  (0.1 GB - only changed File B stored)
```

**Why These Snapshot Settings?**

- **Daily Snapshots**: Catch daily changes (good balance between safety and space)
- **Keep 5 Daily**: Recent snapshots (last 5 days) for quick recovery
- **Keep 2 Weekly**: Weekly snapshots for longer-term recovery
- **Keep 2 Monthly**: Monthly snapshots for very long-term recovery

**What Gets Snapshot?**

- **System Files** (`/`, `/usr`, `/etc`, etc.): Included (system state)
- **User Data** (`/home`): Included (complete system state)
- **Logs** (`/var/log`): Excluded (logs change frequently, don't need history)
- **Cache** (`/var/cache`): Excluded (can be regenerated, saves space)

**Official Resources:**
- [Timeshift GitHub Repository](https://github.com/teejee2008/timeshift)
- [Timeshift Documentation](https://github.com/teejee2008/timeshift/wiki)
- [ArchWiki Timeshift](https://wiki.archlinux.org/title/Timeshift)

****TIME:** Estimated Time: 10 minutes**

****NEXT:** Restart Count: 0**

### Step 16.1: Install Timeshift

```bash
# Install Timeshift for Btrfs
sudo pacman -S timeshift cronie

# Enter password or use fingerprint
```

### Step 16.2: Enable Cron Daemon

```bash
# Enable cronie service (required for scheduled snapshots)
sudo systemctl enable --now cronie

# --now: Enable and start immediately
```

### Step 16.3: Launch Timeshift GUI

```bash
# Launch Timeshift (GUI)
sudo timeshift-launcher
```

**Timeshift setup wizard appears**

### Step 16.4: Configure Timeshift

**Step 1: Select Snapshot Type**
- Select: **BTRFS**
- Click **Next**

**Step 2: Select Snapshot Location**
- Timeshift should auto-detect: `/dev/mapper/cryptroot`
- Click **Next**

**Step 3: Snapshot Levels**

Configure schedule:
- **Monthly**: ☐ Unchecked, Keep: 2
- **Weekly**: ☐ Unchecked, Keep: 3
- **Daily**: ☑ Checked, Keep: 5
- **Hourly**: ☐ Unchecked, Keep: 6
- **Boot**: ☐ Unchecked, Keep: 5

**Step 4: User Home Directories**
- ☑ Check **Include @home subvolume in backups**

**Step 5: Finish**
- Click **Finish**

### Step 16.5: Create First Manual Snapshot

**In Timeshift GUI:**
1. Click **Create** button
2. Comment: `Initial snapshot after installation`
3. Click **OK**

**Wait for snapshot creation** (30-60 seconds)

****SUCCESS:** First snapshot created**

### Step 16.6: Verify Snapshots

```bash
# List Timeshift snapshots
sudo timeshift --list

# Should show:
# Device : /dev/mapper/cryptroot
# Mode   : BTRFS
# Status : 1 snapshots, 70 GB free
#
# Num     Name    Tags    Description
# ----------------------------------------------
# 0    >  2025-12-01_16-30-00    M    Initial snapshot after installation
```

****SUCCESS:** Phase 16 Complete: Timeshift configured with daily snapshots**

****NEXT:** Next: Deploy dotfiles from GitHub (Phase 17)**

---

## Phase 17: Dotfiles Deployment

****TIME:** Estimated Time: 15-20 minutes**

****NEXT:** Restart Count: 0 (but logout/login recommended)**

### Step 17.1: Install AUR Helper (yay)

```bash
# Install yay (AUR helper)
cd /tmp
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

# Proceed with installation: [Y/n] - Press Enter
```

### Step 17.2: Install Missing AUR Packages

```bash
# Install swayosd from AUR (if not available in official repos)
yay -S swayosd

# Install swww (Wayland wallpaper daemon)
yay -S swww

# Install albert (application launcher)
yay -S albert
```

### Step 17.3: Clone Dotfiles Repository

```bash
# Navigate to home directory
cd ~

# Clone EliteBook repository
git clone https://github.com/merneo/EliteBook.git

# Navigate into repository
cd EliteBook
```

### Step 17.4: Review Repository Contents

```bash
# List repository contents
ls -la

# Should show:
# README.md
# INSTALL.md
# hypr/
# kitty/
# waybar/
# nvim/
# tmux/
# scripts/
# browsers/
# ...
```

### Step 17.5: Deploy Configuration Files

****WARNING:** Method depends on repository structure**

**If using GNU Stow:**
```bash
# Install stow
sudo pacman -S stow

# Deploy all configurations
stow hypr kitty waybar nvim tmux scripts browsers -t ~/
```

**If manual copy:**
```bash
# Copy Hyprland config
mkdir -p ~/.config/hypr
cp -r hypr/.config/hypr/* ~/.config/hypr/

# Copy Kitty config
mkdir -p ~/.config/kitty
cp -r kitty/.config/kitty/* ~/.config/kitty/

# Copy Waybar config
mkdir -p ~/.config/waybar
cp -r waybar/.config/waybar/* ~/.config/waybar/

# Copy Neovim config
mkdir -p ~/.config/nvim
cp -r nvim/.config/nvim/* ~/.config/nvim/

# Copy Tmux config
cp tmux/.tmux.conf ~/.tmux.conf

# Copy scripts
mkdir -p ~/.local/bin
cp -r scripts/.local/bin/* ~/.local/bin/
chmod +x ~/.local/bin/*

# Copy browser configurations (optional - can be done later)
# See browsers/THEME_DEPLOYMENT.md for browser theme deployment
```

### Step 17.6: Install Tmux Plugin Manager

```bash
# Clone TPM (Tmux Plugin Manager)
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Install Tmux plugins
~/.tmux/plugins/tpm/bin/install_plugins
```

### Step 17.7: Install Neovim Plugins

```bash
# Open Neovim (lazy.nvim will auto-install plugins)
nvim

# Wait for plugins to install (30-60 seconds)
# Press 'q' to close lazy.nvim window
# Type :q to exit Neovim
```

### Step 17.8: Deploy Browser Themes (Optional)

**Browser theme configuration is available in the repository:**

**Firefox Theme:**
```bash
# Find Firefox profile
FIREFOX_PROFILE=$(find ~/.mozilla/firefox -name "*.default-release" -type d | head -1)

# Create chrome directory
mkdir -p "$FIREFOX_PROFILE/chrome"

# Copy theme files
cp ~/EliteBook/browsers/firefox/userChrome.css "$FIREFOX_PROFILE/chrome/"
cp ~/EliteBook/browsers/firefox/catppuccin-mocha-green.css "$FIREFOX_PROFILE/chrome/"
cp ~/EliteBook/browsers/firefox/user.js "$FIREFOX_PROFILE/"

# Enable userChrome.css in Firefox
# Open Firefox: about:config
# Set: toolkit.legacyUserProfileCustomizations.stylesheets = true
# Restart Firefox
```

**Brave Theme:**
```bash
# Install Brave theme extension
# Open Brave: brave://extensions/
# Enable Developer mode
# Click "Load unpacked"
# Select: ~/EliteBook/browsers/brave
```

**Documentation:**
- Complete deployment guide: `browsers/THEME_DEPLOYMENT.md`
- Theme documentation: `browsers/BROWSER_THEMES_DOCUMENTATION.md`
- Desktop entries: `browsers/DESKTOP_ENTRIES_DEPLOYMENT.md`

**Note:** Browser themes can be deployed at any time after browsers are installed. This step is optional during initial setup.

### Step 17.9: Logout and Login

**Logout of Hyprland:**
```bash
# Logout
hyprctl dispatch exit
```

**Login again** at SDDM screen

**Hyprland should now load with:**
- **SUCCESS:** Waybar status bar (top)
- **SUCCESS:** Wallpaper rotating every 3 minutes
- **SUCCESS:** Custom keybindings working
- **SUCCESS:** Rounded corners (or corner mode as configured)
- **SUCCESS:** All scripts functional
- **SUCCESS:** Browser themes available (if deployed)

****SUCCESS:** Phase 17 Complete: Dotfiles deployed and active**

****NEXT:** Next: Configure GPG for Git commits (Phase 18)**

---

## Phase 18: GPG Key Setup for Git Commits

****TIME:** Estimated Time: 10 minutes**

****NEXT:** Restart Count: 0**

### Step 18.1: Install GPG

```bash
# Install GnuPG (should already be installed)
sudo pacman -S gnupg
```

### Step 18.2: Generate GPG Key

```bash
# Generate new GPG key
gpg --full-generate-key
```

**Prompts:**

**1. Key type:**
```
Please select what kind of key you want:
   (1) RSA and RSA (default)
   (2) DSA and Elgamal
   (3) DSA (sign only)
   (4) RSA (sign only)
Your selection?
```

**Enter:** `1` (RSA and RSA)

**2. Key size:**
```
RSA keys may be between 1024 and 4096 bits long.
What keysize do you want? (3072)
```

**Enter:** `4096` (maximum security)

**3. Expiration:**
```
Please specify how long the key should be valid.
         0 = key does not expire
      <n>  = key expires in n days
      <n>w = key expires in n weeks
      <n>m = key expires in n months
      <n>y = key expires in n years
Key is valid for? (0)
```

**Enter:** `0` (no expiration) or `2y` (2 years)

**Confirm:** `y` (yes)

**4. User ID:**
```
Real name:
```

**Enter your name** (e.g., `hp`)

```
Email address:
```

**Enter your email** (e.g., `hp@elitebook.local` or your real email)

```
Comment:
```

**Press Enter** (leave blank or add description)

**Confirm:** `O` (okay)

**5. Passphrase:**

**Enter strong GPG passphrase** (different from user password)

**Confirm passphrase**

**Wait for key generation** (30-60 seconds - move mouse/type to generate entropy)

### Step 18.3: List GPG Keys

```bash
# List GPG keys
gpg --list-secret-keys --keyid-format LONG

# Example output:
# sec   rsa4096/ABCD1234EFGH5678 2025-12-01 [SC]
#       XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
# uid   [ultimate] hp <hp@elitebook.local>
# ssb   rsa4096/IJKL9012MNOP3456 2025-12-01 [E]
```

**Copy the key ID:** `ABCD1234EFGH5678` (after `rsa4096/`)

### Step 18.4: Configure Git to Use GPG

```bash
# Set GPG key for Git signing (replace with your key ID)
git config --global user.signingkey ABCD1234EFGH5678

# Enable automatic commit signing
git config --global commit.gpgsign true

# Set Git user information
git config --global user.name "hp"
git config --global user.email "hp@elitebook.local"
```

### Step 18.5: Export Public Key (for GitHub)

```bash
# Export public key in ASCII format (replace with your key ID)
gpg --armor --export ABCD1234EFGH5678

# Copy the entire output (including BEGIN/END lines)
```

**Output looks like:**
```
-----BEGIN PGP PUBLIC KEY BLOCK-----

mQINBGXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
...
-----END PGP PUBLIC KEY BLOCK-----
```

### Step 18.6: Add GPG Key to GitHub

1. **Open browser** → https://github.com/settings/keys
2. Click **New GPG key**
3. **Paste** public key (entire block including BEGIN/END)
4. Click **Add GPG key**

### Step 18.7: Test GPG Signing

```bash
# Navigate to EliteBook repository
cd ~/EliteBook

# Create test commit
echo "Test GPG signing" > test.txt
git add test.txt
git commit -m "Test GPG signed commit"

# Should show: (no password prompt if using gpg-agent)
# [main XXXXXXX] Test GPG signed commit
#  1 file changed, 1 insertion(+)
```

**Verify commit is signed:**
```bash
git log --show-signature -1

# Should show:
# commit XXXXXXX
# gpg: Signature made ...
# gpg: Good signature from "hp <hp@elitebook.local>" [ultimate]
```

****SUCCESS:** Phase 18 Complete: GPG key configured, Git commits will be signed**

****NEXT:** Next: Final verification (Phase 19)**

---

## Post-Installation Verification

****TIME:** Estimated Time: 10 minutes**

****NEXT:** Restart Count: 0**

### Comprehensive System Check

**Run all verification commands:**

```bash
# System Information
echo "=== SYSTEM INFORMATION ==="
uname -a
neofetch

# CPU and Memory
echo -e "\n=== CPU & MEMORY ==="
lscpu | grep "Model name"
free -h

# Disk Encryption
echo -e "\n=== DISK ENCRYPTION ==="
lsblk -f | grep -E "nvme0n1|crypt|btrfs|swap"

# Btrfs Subvolumes
echo -e "\n=== BTRFS SUBVOLUMES ==="
sudo btrfs subvolume list /

# Network Status
echo -e "\n=== NETWORK ==="
nmcli device status
systemctl status NetworkManager --no-pager

# WiFi Driver
echo -e "\n=== WIFI DRIVER ==="
lsmod | grep iwlwifi
ls /lib/firmware/iwlwifi-8265-*.ucode*

# Bluetooth
echo -e "\n=== BLUETOOTH ==="
systemctl status bluetooth --no-pager
bluetoothctl show

# Audio (PipeWire)
echo -e "\n=== AUDIO ==="
systemctl --user status pipewire --no-pager
pactl list short sinks

# Graphics Driver
echo -e "\n=== GRAPHICS ==="
lspci -k | grep -A 3 VGA

# Fingerprint Sensor
echo -e "\n=== FINGERPRINT ==="
lsusb | grep Validity
fprintd-list hp

# Webcams (HD + IR)
echo -e "\n=== WEBCAMS ==="
lsusb | grep -i camera
v4l2-ctl --list-devices

# Timeshift Snapshots
echo -e "\n=== TIMESHIFT ==="
sudo timeshift --list | head -20

# Services Running
echo -e "\n=== SERVICES ==="
systemctl --type=service --state=running | grep -E "NetworkManager|bluetooth|sddm|cronie"
```

### Test Functionality

**1. Test Brightness Control:**
```bash
# Increase brightness
brightnessctl set +10%

# Decrease brightness
brightnessctl set 10%-

# Set specific brightness (50%)
brightnessctl set 50%
```

**2. Test Volume Control (SwayOSD):**
- Press **Volume Up** key (should show OSD overlay)
- Press **Volume Down** key
- Press **Mute** key

**3. Test Fingerprint:**
```bash
# Test sudo with fingerprint
sudo ls /root
# (Place finger on sensor)
```

**4. Test Webcam:**
```bash
# Test HD camera capture
ffmpeg -f v4l2 -video_size 1280x720 -input_format mjpeg \
  -i /dev/video0 -frames:v 1 -update 1 ~/Pictures/webcam_test.jpg

# Verify image
ls -la ~/Pictures/webcam_test.jpg
file ~/Pictures/webcam_test.jpg
# Should show: JPEG image data, 1280x720
```

**5. Test Screenshot:**
- Press **Super+S** (should show region selector)
- Select region
- Screenshot saved to ~/Pictures/

**6. Test Window Navigation:**
- Press **Super+H/J/K/L** (focus window)
- Press **Super+1-5** (switch workspace)

### Verify Boot Process

**Reboot and observe:**
```bash
sudo reboot
```

**Boot checklist:**
- **SUCCESS:** GRUB menu shows Arch Linux + Windows Boot Manager
- **SUCCESS:** Plymouth boot splash appears (no password prompt)
- **SUCCESS:** SDDM login screen appears
- **SUCCESS:** Fingerprint authentication works at login
- **SUCCESS:** Hyprland loads with Waybar
- **SUCCESS:** Wallpaper displays correctly
- **SUCCESS:** Audio works
- **SUCCESS:** WiFi auto-connects
- **SUCCESS:** Webcam works (test in browser or OBS)

****SUCCESS:** Post-Installation Verification Complete**

---

## Troubleshooting

### Issue 1: GRUB Doesn't Show Windows 11

**Solution:**
```bash
# Reinstall os-prober
sudo pacman -S os-prober

# Mount Windows partition
sudo mkdir -p /mnt/windows
sudo mount /dev/nvme0n1p2 /mnt/windows

# Regenerate GRUB config
sudo grub-mkconfig -o /boot/grub/grub.cfg

# Should show: "Found Windows Boot Manager on /dev/nvme0n1p1"

# Unmount
sudo umount /mnt/windows
```

### Issue 2: LUKS Prompts for Password (Keyfile Not Working)

**Solution:**
```bash
# Verify keyfile exists
sudo ls -la /etc/cryptsetup.d/root.key
# Should show: -rw------- 1 root root 512

# Verify keyfile is in initramfs
lsinitcpio /boot/initramfs-linux.img | grep root.key
# Should show: etc/cryptsetup.d/root.key

# If missing, rebuild initramfs:
sudo mkinitcpio -P
sudo grub-mkconfig -o /boot/grub/grub.cfg
sudo reboot
```

### Issue 3: WiFi Not Working

**Solution:**
```bash
# Check if iwlwifi driver loaded
lsmod | grep iwlwifi

# If not loaded, load manually:
sudo modprobe iwlwifi

# Check firmware exists
ls -la /lib/firmware/iwlwifi-8265-*.ucode*

# If missing, reinstall linux-firmware:
sudo pacman -S linux-firmware

# Restart NetworkManager
sudo systemctl restart NetworkManager

# Connect to WiFi
nmtui
```

### Issue 4: No Audio

**Solution:**
```bash
# Check PipeWire status
systemctl --user status pipewire

# If not running, start:
systemctl --user start pipewire

# Check audio devices
pactl list short sinks

# Unmute and set volume
pactl set-sink-mute @DEFAULT_SINK@ 0
pactl set-sink-volume @DEFAULT_SINK@ 65%

# Restart PipeWire if needed
systemctl --user restart pipewire
```

### Issue 5: Fingerprint Not Working

**Solution:**
```bash
# Restart fprintd service
sudo systemctl restart fprintd

# Re-verify fingerprint
fprintd-verify hp

# If fails, re-enroll:
fprintd-delete hp
fprintd-enroll hp

# Check PAM configuration
cat /etc/pam.d/sudo | head -3
# Should show: auth sufficient pam_fprintd.so
```

### Issue 6: Brightness Keys Not Working

**Solution:**
```bash
# Verify brightnessctl installed
which brightnessctl
# Should show: /usr/bin/brightnessctl

# Check current brightness
brightnessctl

# Test manual control
brightnessctl set 50%

# If works, check Hyprland keybindings:
grep -i brightness ~/.config/hypr/hyprland.conf
```

### Issue 7: Hyprland Not Starting

**Solution:**
```bash
# Check SDDM session selector
# At SDDM login screen, click session dropdown
# Ensure "Hyprland" is selected

# If missing, check Hyprland desktop entry:
ls /usr/share/wayland-sessions/
# Should show: hyprland.desktop

# Check Hyprland binary exists:
which Hyprland
# Should show: /usr/bin/Hyprland

# Check logs:
journalctl -b | grep -i hyprland
```

### Issue 8: Waybar Not Showing

**Solution:**
```bash
# Start Waybar manually
waybar &

# Check Waybar config
cat ~/.config/waybar/config.jsonc

# Check Hyprland autostart
grep waybar ~/.config/hypr/hyprland.conf
# Should show: exec-once = waybar
```

### Issue 9: Webcam Not Working

**Solution:**
```bash
# Check if cameras detected
lsusb | grep -i camera
# Should show:
# 04f2:b58f HP HD Camera
# 04f2:b58e HP IR Camera

# Check uvcvideo driver
lsmod | grep uvcvideo

# If not loaded, load it
sudo modprobe uvcvideo

# List video devices
v4l2-ctl --list-devices
# HD Camera = /dev/video0
# IR Camera = /dev/video2

# Check for errors
dmesg | grep -i "video\|uvc\|camera"

# If camera in use by another app
fuser /dev/video0
fuser -k /dev/video0  # Kill process using camera
```

### Issue 10: Wrong Camera Selected in Apps

**Problem:** Apps using IR camera instead of HD camera

**Solution:**
```bash
# In apps, select "HP HD Camera" not "HP IR Camera"
# Or specify device directly:

# HD Camera (for video calls)
/dev/video0

# IR Camera (for face recognition only)
/dev/video2
```

---

## Summary

****SUCCESS:** Installation Complete!**

You now have:
- **SUCCESS:** Dual-boot: Arch Linux + Windows 11 (GRUB bootloader)
- **SUCCESS:** LUKS2 full-disk encryption (AES-XTS-PLAIN64, 512-bit)
- **SUCCESS:** Automatic decryption on boot (passwordless via keyfile)
- **SUCCESS:** Btrfs filesystem with 5 subvolumes
- **SUCCESS:** Timeshift automatic snapshots (daily, keep 5)
- **SUCCESS:** Fingerprint authentication (sudo + login)
- **SUCCESS:** Face recognition authentication (Howdy, sudo + login)
- **SUCCESS:** SDDM auto-activation (automatic biometric activation at login)
- **SUCCESS:** HD Webcam (720p, video calls)
- **SUCCESS:** IR Camera (face recognition ready)
- **SUCCESS:** Hyprland Wayland compositor
- **SUCCESS:** Complete window manager setup (Hyprland, Waybar, Kitty, etc.)
- **SUCCESS:** PipeWire audio server
- **SUCCESS:** NetworkManager for WiFi (Intel Wireless 8265)
- **SUCCESS:** Bluetooth support (Intel 8087:0a2b)
- **SUCCESS:** Plymouth boot splash (BGRT theme)
- **SUCCESS:** Brightness control (brightnessctl)
- **SUCCESS:** Volume OSD (SwayOSD)
- **SUCCESS:** GPG-signed Git commits
- **SUCCESS:** All dotfiles deployed from GitHub

**User Account:**
- Username: `hp`
- Password: `<YOUR_PASSWORD>`
- Shell: Zsh
- Groups: wheel, video, audio, storage, input, power, network

**System Hostname:**
- `elitebook`

**Next Steps:**
1. Customize Hyprland configuration
2. Install additional applications as needed
3. Configure Timeshift snapshot schedule
4. Backup GPG keys to secure location
5. Enjoy your new Arch Linux installation!

---

## References

**Arch Linux:**
- [Arch Linux Wiki](https://wiki.archlinux.org/) - Comprehensive documentation
- [Arch Linux Installation Guide](https://wiki.archlinux.org/title/Installation_guide)
- [Arch User Repository (AUR)](https://aur.archlinux.org/) - Community packages

**System Configuration:**
- [LUKS Encryption](https://wiki.archlinux.org/title/Dm-crypt) - Disk encryption
- [Btrfs](https://wiki.archlinux.org/title/Btrfs) - Filesystem
- [GRUB](https://wiki.archlinux.org/title/GRUB) - Bootloader
- [Timeshift](https://github.com/teejee2008/timeshift) - System snapshots

**Window Manager:**
- [Hyprland](https://hyprland.org/) - Wayland compositor (window manager)
  - [GitHub](https://github.com/hyprwm/Hyprland)
  - [Wiki](https://wiki.hyprland.org/)

**Biometric Authentication:**
- [fprintd (libfprint)](https://fprint.freedesktop.org/) - Fingerprint daemon
  - [ArchWiki Fprint](https://wiki.archlinux.org/title/Fprint)
- [python-validity](https://github.com/uunicorn/python-validity) - Fingerprint driver
- [Howdy](https://github.com/boltgolt/howdy) - Face recognition

**Repository:**
- [EliteBook GitHub Repository](https://github.com/merneo/EliteBook)

**Installation Guide Version:** 2.0 (Complete)
**Last Updated:** December 1, 2025
**Author:** merneo
