# Troubleshooting Guide - EliteBook Repository

**Comprehensive troubleshooting guide for common issues and solutions.**

**Version:** 2.0.0  
**Last Updated:** December 2, 2025  
**Repository:** https://github.com/merneo/EliteBook

---

## Quick Navigation

- [Installation Issues](#installation-issues)
- [Boot & Encryption](#boot--encryption)
- [Hardware Issues](#hardware-issues)
- [Authentication Problems](#authentication-problems)
- [Network & Connectivity](#network--connectivity)
- [Audio & Video](#audio--video)
- [Window Manager](#window-manager)
- [Browser Issues](#browser-issues)
- [General System Issues](#general-system-issues)

---

## Installation Issues

### GRUB Doesn't Show Windows 11

**Symptoms:** GRUB menu doesn't include Windows 11 option after installation.

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

**Reference:** [INSTALL_POST_REBOOT.md](INSTALL_POST_REBOOT.md) - Troubleshooting section

---

### Installation Fails at Partitioning

**Symptoms:** `cfdisk` or partitioning commands fail.

**Possible Causes:**
- Disk is mounted
- Disk is in use by another process
- Incorrect device path

**Solution:**
```bash
# Verify disk is not mounted
lsblk

# Unmount if needed
sudo umount /dev/nvme0n1p*

# Check if disk is in use
sudo fuser -v /dev/nvme0n1

# Verify correct device
lsblk -f
```

---

## Boot & Encryption

### LUKS Prompts for Password (Keyfile Not Working)

**Symptoms:** System prompts for LUKS password even though automatic decryption is configured.

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

**Reference:** [INSTALL_POST_REBOOT.md](INSTALL_POST_REBOOT.md) - Issue 2

---

### System Won't Boot

**Symptoms:** Black screen, GRUB errors, or boot loop.

**Solution:**
```bash
# Boot from live USB
# Mount encrypted partition
sudo cryptsetup open /dev/nvme0n1p4 cryptroot
sudo mount /dev/mapper/cryptroot /mnt
sudo mount /dev/nvme0n1p1 /mnt/boot

# Chroot into system
sudo arch-chroot /mnt

# Verify GRUB configuration
cat /etc/default/grub

# Reinstall GRUB if needed
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# Exit chroot and reboot
exit
sudo umount -R /mnt
sudo reboot
```

---

## Hardware Issues

### Fingerprint Not Detected

**Symptoms:** `fprintd-list` shows no devices, or fingerprint reader not recognized.

**Solution:**
```bash
# Check if device is detected
lsusb | grep -i validity
# Should show: Validity Sensors, Inc. 138a:0092

# Check if service is running
systemctl status fprintd

# If device not detected, BIOS reset required:
# 1. Restart → F10 → Security → Reset Fingerprint Reader
# 2. Reboot
# 3. Verify: lsusb | grep -i validity

# Reinstall python-validity if needed
yay -Rns python-validity-git
yay -S python-validity-git

# Clone device/0092 branch files
# (See FINGERPRINT_ID_READERS.md for complete procedure)
```

**Reference:** [FINGERPRINT_ID_READERS.md](FINGERPRINT_ID_READERS.md)

---

### IR Camera Not Working (Howdy)

**Symptoms:** Howdy cannot access IR camera, or camera not detected.

**Solution:**
```bash
# Check camera device
ls -la /dev/video*
# Should show: /dev/video2 (IR camera)

# Check camera permissions
ls -la /dev/video2
# Should show: crw-rw----+ 1 root video

# Verify camera is accessible
v4l2-ctl --device=/dev/video2 --info

# If camera not detected:
# 1. Check USB connection
# 2. Verify camera in BIOS (F10 → Security → Camera)
# 3. Check kernel modules: lsmod | grep uvcvideo

# Reinstall Howdy if needed
yay -Rns howdy-bin
yay -S howdy-bin
sudo howdy test
```

**Reference:** [HOWDY_CAMERA_FIX.md](HOWDY_CAMERA_FIX.md)

---

## Authentication Problems

### Fingerprint Authentication Not Working

**Symptoms:** Fingerprint doesn't work for sudo or login.

**Solution:**
```bash
# Check if fingerprint is enrolled
fprintd-list $USER

# If not enrolled:
fprintd-enroll $USER

# Verify PAM configuration
grep -i fprintd /etc/pam.d/sudo
# Should show: auth sufficient pam_fprintd.so

# Check service status
systemctl status fprintd

# Restart service if needed
sudo systemctl restart fprintd
```

**Reference:** [FINGERPRINT_SETUP_COMPLETE.md](FINGERPRINT_SETUP_COMPLETE.md)

---

### Howdy Face Recognition Not Working

**Symptoms:** Face recognition fails for sudo or login.

**Solution:**
```bash
# Check if face models are enrolled
sudo howdy list

# If no models, enroll:
sudo howdy add

# Verify PAM configuration
grep -i howdy /etc/pam.d/sudo
# Should show: auth sufficient pam_python.so /usr/lib/security/howdy/pam.py

# Check PAM Python module
ls -la /usr/lib/security/pam_python*.so

# If missing, install from GitHub:
# (See HOWDY_PAM_PYTHON_FIX.md)

# Test Howdy
sudo howdy test
```

**Reference:** [HOWDY_SETUP_MANUAL.md](HOWDY_SETUP_MANUAL.md), [HOWDY_PAM_PYTHON_FIX.md](HOWDY_PAM_PYTHON_FIX.md)

---

## Network & Connectivity

### WiFi Not Working

**Symptoms:** WiFi doesn't connect, or no networks visible.

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

# Check NetworkManager status
systemctl status NetworkManager

# Restart NetworkManager
sudo systemctl restart NetworkManager

# Connect to WiFi
nmtui
```

**Reference:** [INSTALL_POST_REBOOT.md](INSTALL_POST_REBOOT.md) - Issue 3

---

### Bluetooth Not Working

**Symptoms:** Bluetooth devices not detected or cannot pair.

**Solution:**
```bash
# Check Bluetooth service
systemctl status bluetooth

# Start service if not running
sudo systemctl start bluetooth
sudo systemctl enable bluetooth

# Check if adapter is detected
bluetoothctl
# In bluetoothctl:
#   power on
#   scan on
#   devices

# If adapter not detected:
# 1. Check hardware: lsusb | grep -i bluetooth
# 2. Load module: sudo modprobe btusb
# 3. Restart service: sudo systemctl restart bluetooth
```

---

## Audio & Video

### No Audio

**Symptoms:** No sound output, or audio devices not detected.

**Solution:**
```bash
# Check PipeWire status
systemctl --user status pipewire

# If not running, start:
systemctl --user start pipewire
systemctl --user enable pipewire

# Check audio devices
pactl list short sinks

# Unmute and set volume
pactl set-sink-mute @DEFAULT_SINK@ 0
pactl set-sink-volume @DEFAULT_SINK@ 65%

# Restart PipeWire if needed
systemctl --user restart pipewire

# Check if audio is routed correctly
pactl list sinks | grep -A 10 "State:"
```

**Reference:** [INSTALL_POST_REBOOT.md](INSTALL_POST_REBOOT.md) - Issue 4

---

### Display Issues

**Symptoms:** Screen resolution incorrect, or display not detected.

**Solution:**
```bash
# Check connected displays
hyprctl monitors

# Check current resolution
xrandr  # (if X11 compatibility layer)

# For Hyprland, configure in hyprland.conf:
# monitor=,preferred,auto,auto

# Reload Hyprland
hyprctl reload
```

---

## Window Manager

### Hyprland Not Starting

**Symptoms:** Black screen after login, or Hyprland fails to start.

**Solution:**
```bash
# Check Hyprland logs
journalctl -b -u hyprland

# Check configuration syntax
hyprctl reload

# If config has errors, check:
cat ~/.config/hypr/hyprland.conf

# Verify Wayland session
echo $XDG_SESSION_TYPE
# Should show: wayland

# Check if running in correct session
loginctl show-session $(loginctl | grep $(whoami) | awk '{print $1}') -p Type
```

---

### Waybar Not Displaying

**Symptoms:** Status bar doesn't appear, or modules not showing.

**Solution:**
```bash
# Check if Waybar is running
pgrep waybar

# If not running, start:
waybar &

# Check configuration
cat ~/.config/waybar/config.jsonc

# Verify JSON syntax
cat ~/.config/waybar/config.jsonc | jq .

# Reload Waybar
pkill waybar && waybar &
```

---

## Browser Issues

### Albert Launcher Can't Find Browsers

**Symptoms:** Firefox and Brave not appearing in Albert launcher.

**Solution:**
```bash
# First, install browsers if not installed:
sudo pacman -S firefox
yay -S brave-bin

# Verify desktop entries exist
ls -la ~/.local/share/applications/firefox.desktop
ls -la ~/.local/share/applications/brave.desktop

# Update desktop database
update-desktop-database ~/.local/share/applications

# Clear Albert cache
rm -rf ~/.cache/albert

# Restart Albert
pkill albert
albert &

# Wait for indexing (5-10 seconds)
```

**Reference:** [browsers/ALBERT_TROUBLESHOOTING.md](browsers/ALBERT_TROUBLESHOOTING.md)

---

### Browser Themes Not Applied

**Symptoms:** Catppuccin Mocha Green theme not visible in browser.

**Solution:**
```bash
# Firefox:
# 1. Enable userChrome.css in about:config
#    toolkit.legacyUserProfileCustomizations.stylesheets = true
# 2. Verify files exist:
#    ~/.mozilla/firefox/*.default-release/chrome/userChrome.css
#    ~/.mozilla/firefox/*.default-release/chrome/catppuccin-mocha-green.css
# 3. Restart Firefox

# Brave:
# 1. Open: brave://extensions
# 2. Enable "Developer mode"
# 3. Click "Load unpacked"
# 4. Select: ~/.config/BraveSoftware/Brave-Browser/Default/Extensions/catppuccin-mocha-green
# 5. Verify theme is active
```

**Reference:** [browsers/THEME_DEPLOYMENT.md](browsers/THEME_DEPLOYMENT.md)

---

## General System Issues

### System Slow or Unresponsive

**Symptoms:** System feels sluggish, or applications hang.

**Solution:**
```bash
# Check system resources
htop
# or
free -h
df -h

# Check for high CPU usage
top

# Check disk I/O
iostat -x 1

# Check systemd services
systemctl --failed

# Check journal for errors
journalctl -p err -b

# Clear system caches if needed
sudo pacman -Sc
```

---

### Package Installation Fails

**Symptoms:** `pacman` or `yay` fails to install packages.

**Solution:**
```bash
# Update package database
sudo pacman -Sy

# Fix package database if corrupted
sudo pacman -S archlinux-keyring
sudo pacman-key --refresh-keys

# Clear package cache
sudo pacman -Sc

# For AUR packages (yay):
yay -Syu
yay -Sc

# Check disk space
df -h /var/cache/pacman/pkg
```

---

## Getting More Help

### Documentation References

- **Installation Issues:** [INSTALL_POST_REBOOT.md](INSTALL_POST_REBOOT.md) - Troubleshooting section
- **Fingerprint:** [FINGERPRINT_ID_READERS.md](FINGERPRINT_ID_READERS.md)
- **Howdy:** [HOWDY_SETUP_MANUAL.md](HOWDY_SETUP_MANUAL.md)
- **Configuration:** [CONFIGURATION_FILES_DOCUMENTATION.md](CONFIGURATION_FILES_DOCUMENTATION.md)
- **Complete Index:** [DOCUMENTATION_INDEX.md](DOCUMENTATION_INDEX.md)

### AI Assistant Help

If you're using an AI assistant (Cursor CLI, Claude, ChatGPT):

1. Mention the issue: "I have problem with [issue] on HP EliteBook"
2. AI will automatically check [docs/installation/AI_ASSISTANT_CONTEXT.md](docs/installation/AI_ASSISTANT_CONTEXT.md)
3. AI will reference relevant documentation

**Example:**
```
I have problem with fingerprint not working on HP EliteBook
```

### Manual Troubleshooting

1. Check relevant documentation file from [DOCUMENTATION_INDEX.md](DOCUMENTATION_INDEX.md)
2. Search for your issue in the documentation
3. Follow step-by-step solutions
4. Verify each step before proceeding

---

**Repository:** https://github.com/merneo/EliteBook  
**Last Updated:** December 2, 2025  
**Version:** 2.0.0
