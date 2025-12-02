# EliteBook System Configuration Repository

**Well-Documented Arch Linux System Configuration for HP EliteBook x360 1030 G2**

---

## Overview

This repository contains a comprehensive, well-documented system configuration suite for Arch Linux deployments on HP EliteBook x360 1030 G2 hardware. The configuration emphasizes operational reliability, security hardening, power management optimization, and maintainable infrastructure practices.

**Target Audience:** System administrators, Linux enthusiasts, and users seeking a well-documented reference for configuring Arch Linux on similar hardware platforms.

**Repository Philosophy:** This is a **personal system configuration repository** with comprehensive documentation. While primarily designed for personal use, the configurations and documentation may serve as a reference for similar hardware deployments. All configurations are designed for operational reliability, maintainability, and thorough documentation.

---

## System Architecture Overview

### Hardware Platform
- **Model:** HP EliteBook x360 1030 G2
- **Processor:** Intel Core i5-7300U (4 cores, 2.60 GHz base, 3.50 GHz turbo)
- **Graphics:** Intel HD Graphics 620 (integrated)
- **Memory:** 8 GB DDR4 RAM
- **Storage:** 238.5 GB NVMe SSD (LUKS2 encrypted, Btrfs filesystem)
- **Display:** 1920×1080 13.3" FHD touchscreen
- **Network:** Intel Wireless 8265 (802.11ac), Bluetooth 4.2
- **Biometrics:** Validity Sensors 138a:0092 (fingerprint), Chicony IR Camera (face recognition)
- **Smart Card:** Alcor Micro AU9560 (PC/SC compatible)

### Operating System Stack
- **Distribution:** Arch Linux (rolling release)
- **Kernel:** Linux 6.x (LTS variants supported)
- **Init System:** systemd
- **Display Server:** Wayland (via Hyprland compositor)
- **Encryption:** LUKS2 (AES-XTS-PLAIN64, 512-bit key)
- **Filesystem:** Btrfs with subvolumes and snapshots

---

## Repository Structure

```
EliteBook/
├── hypr/                    # Hyprland Wayland compositor configuration
│   └── .config/hypr/
│       └── hyprland.conf    # Window manager, input, keybindings, visual effects
│
├── kitty/                   # Terminal emulator configuration
│   └── .config/kitty/
│       ├── kitty.conf       # Font, opacity, remote control settings
│       └── themes/          # Catppuccin Mocha Green color scheme
│
├── waybar/                  # System status bar configuration
│   └── .config/waybar/
│       ├── config.jsonc     # Module definitions (workspaces, network, battery)
│       ├── style.css        # Visual styling and layout
│       └── weather.sh       # Weather API integration script
│
├── nvim/                    # Neovim text editor configuration
│   └── .config/nvim/
│       ├── init.lua         # Lazy.nvim plugin manager setup
│       └── lua/plugins/      # Plugin definitions (LSP, Treesitter, themes)
│
├── tmux/                    # Terminal multiplexer configuration
│   └── .tmux.conf           # Session management, vim-style navigation, clipboard
│
├── scripts/                 # Operational automation scripts
│   ├── .local/bin/
│   │   ├── effects-*.sh     # Visual effects toggle (blur, shadows, transparency)
│   │   ├── hyprland-*.sh    # Desktop mode switching (corner/rounded)
│   │   ├── screenshot-*.sh # Screenshot capture workflows
│   │   ├── wallpaper-*.sh   # Wallpaper rotation and management
│   │   └── waybar-*.sh      # Status bar theme switching
│   └── install-howdy.sh     # Automated Howdy face recognition installation script
│
├── systemd/                 # systemd user service definitions
│   └── .config/systemd/user/
│       └── dotfiles-restore.service  # Automatic dotfiles symlink restoration
│
├── tlp/                     # Power management configuration
│   └── etc/tlp.d/
│       └── 01-elitebook.conf # CPU scaling, WiFi, USB, battery optimization
│
├── grub/                    # Bootloader configuration
│   └── etc/default/
│       └── grub             # Kernel parameters, LUKS decryption, sleep modes
│
├── plymouth/                # Boot splash screen configuration
│   └── etc/
│       └── mkinitcpio.conf  # Initramfs hooks for Plymouth integration
│
├── sddm/                    # Display manager (login screen) configuration
│   ├── etc/sddm.conf.d/     # SDDM theme and session management
│   └── usr/share/sddm/themes/catppuccin-mocha-green/  # Custom SDDM theme
│       ├── Components/       # QML components (LoginPanel, UserField, etc.)
│       │   ├── LoginPanel.qml    # Main login panel with auto-activation
│       │   └── UserField.qml     # Username input with auto-auth detection
│       └── Main.qml          # Main login screen layout
│
├── fingerprint/             # Biometric authentication device files
│   └── device-files/
│       ├── config-files/    # udev rules for USB device permissions
│       ├── python-modules/  # Python-Validity driver modules (device/0092 branch)
│       └── firmware/       # Lenovo firmware blob for sensor initialization
│
├── swayosd/                 # On-screen display (OSD) styling
│   └── .config/swayosd/
│       └── style.css        # Volume/brightness indicator appearance
│
├── albert/                  # Application launcher theme files
│   └── .local/share/albert/ # Catppuccin Mocha theme variants
│
└── neofetch/                # System information display configuration
    └── .config/neofetch/
        └── config.conf      # ASCII art, system info formatting
```

---

## Core Configuration Components

### 1. Window Manager ([Hyprland](https://hyprland.org/))

**Purpose:** Dynamic tiling Wayland compositor providing efficient window management for server administration workflows.

**Official Resources:**
- **Website:** [hyprland.org](https://hyprland.org/)
- **GitHub:** [github.com/hyprwm/Hyprland](https://github.com/hyprwm/Hyprland)
- **Documentation:** [wiki.hyprland.org](https://wiki.hyprland.org/)
- **ArchWiki:** [wiki.archlinux.org/title/Hyprland](https://wiki.archlinux.org/title/Hyprland)

**Key Features:**
- **Vim-style navigation:** Consistent hjkl keybindings across all applications
- **Multi-monitor support:** Fixed workspace assignment (1-5: laptop, 6-10: external)
- **Performance modes:** Corner mode (0px, no animations) vs. Rounded mode (12px, animations)
- **Dynamic effects:** Toggleable blur, shadows, transparency for performance tuning
- **Hardware integration:** Trackpad gestures, multimedia keys, lid switch handling

**Configuration File:** `hypr/.config/hypr/hyprland.conf`

**Operational Notes:**
- Monitor hotplug detection via socat event listener
- Automatic wallpaper rotation on monitor connection
- PolicyKit authentication agent integration for privilege escalation

### 2. Power Management ([TLP](https://linrunner.de/tlp/))

**Purpose:** Advanced Linux power management for optimizing battery life and thermal performance on mobile hardware.

**Official Resources:**
- **Website:** [linrunner.de/tlp](https://linrunner.de/tlp/)
- **GitHub:** [github.com/linrunner/TLP](https://github.com/linrunner/TLP)
- **ArchWiki:** [wiki.archlinux.org/title/TLP](https://wiki.archlinux.org/title/TLP)
- **Documentation:** [linrunner.de/tlp/documentation](https://linrunner.de/tlp/documentation/)

**Key Features:**
- **CPU scaling:** Performance governor on AC, powersave on battery
- **WiFi power save:** Disabled on AC (stability), enabled on battery
- **USB autosuspend:** Disabled globally (prevents device disconnects)
- **PCIe ASPM:** Default on AC, PowerSuperSave on battery
- **Radio management:** TLP controls WiFi/Bluetooth (systemd-rfkill masked)

**Configuration File:** `tlp/etc/tlp.d/01-elitebook.conf`

**Operational Notes:**
- Requires `systemctl mask systemd-rfkill.service systemd-rfkill.socket`
- CPU governor automatically switches based on AC adapter state
- Battery charge thresholds not supported by this hardware model

### 3. Boot Configuration ([GRUB](https://www.gnu.org/software/grub/))

**Purpose:** Bootloader configuration for encrypted LUKS2 root filesystem with automatic decryption and dual-boot support.

**Official Resources:**
- **Website:** [gnu.org/software/grub](https://www.gnu.org/software/grub/)
- **GitHub:** [savannah.gnu.org/projects/grub](https://savannah.gnu.org/projects/grub)
- **ArchWiki:** [wiki.archlinux.org/title/GRUB](https://wiki.archlinux.org/title/GRUB)
- **Documentation:** [gnu.org/software/grub/manual](https://www.gnu.org/software/grub/manual/)

**Key Features:**
- **LUKS2 decryption:** Passwordless boot via embedded keyfile in initramfs
- **Sleep mode:** S3 deep sleep (better battery life than s2idle)
- **USB stability:** Kernel parameters prevent USB device disconnection issues
- **Plymouth integration:** Graphical boot splash during initialization
- **OS detection:** Automatic Windows 11 detection for dual-boot menu

**Configuration File:** `grub/etc/default/grub`

**Security Considerations:**
- Keyfile stored in `/boot` (unencrypted partition)
- Physical access to `/boot` could extract keyfile
- Trade-off: Convenience vs. security (acceptable for laptop deployment)

**Operational Notes:**
- After modifying, regenerate: `sudo grub-mkconfig -o /boot/grub/grub.cfg`
- UUID in `GRUB_CMDLINE_LINUX` must match actual LUKS partition UUID

### 4. Biometric Authentication

**Purpose:** Multi-factor biometric authentication system supporting both fingerprint and face recognition with automatic activation.

#### 4.1 Fingerprint Authentication

**Device:** Validity Sensors 138a:0092 (Synaptics VFS7552)

**Official Resources:**
- **python-validity GitHub:** [github.com/uunicorn/python-validity](https://github.com/uunicorn/python-validity)
- **fprintd (libfprint):** [fprint.freedesktop.org](https://fprint.freedesktop.org/)
- **ArchWiki Fprint:** [wiki.archlinux.org/title/Fprint](https://wiki.archlinux.org/title/Fprint)

**Key Features:**
- **Device support:** Python-Validity driver with device/0092 branch modifications
- **Firmware:** Lenovo firmware blob (6_07f_lenovo_mis_qm.xpfwext)
- **PAM integration:** sudo and SDDM login authentication
- **BIOS requirement:** Critical - device must be reset in BIOS before initialization

**Configuration Files:**
- `fingerprint/device-files/config-files/60-validity.rules` (udev rules)
- `fingerprint/device-files/python-modules/*` (driver modules)
- `fingerprint/device-files/firmware/6_07f_lenovo_mis_qm.xpfwext` (firmware)

**Operational Notes:**
- **CRITICAL:** BIOS reset required: F10 → Security → Reset Fingerprint Reader
- Service: `systemctl enable --now python3-validity`
- Enrollment: `fprintd-enroll $USER`
- PAM configuration: Add `auth sufficient pam_fprintd.so` to `/etc/pam.d/sudo` and `/etc/pam.d/sddm`

#### 4.2 Face Recognition (Howdy)

**Device:** Chicony IR Camera (`/dev/video2`)

**Official Resources:**
- **Howdy GitHub:** [github.com/boltgolt/howdy](https://github.com/boltgolt/howdy)
- **ArchWiki Howdy:** [wiki.archlinux.org/title/Howdy](https://wiki.archlinux.org/title/Howdy)

**Key Features:**
- **IR camera support:** Automatic IR emitter activation for face recognition
- **PAM integration:** sudo and SDDM login authentication
- **Multiple face models:** Support for multiple enrollment models
- **Auto-activation:** Camera and fingerprint activate automatically at SDDM login screen

**Configuration Files:**
- `/etc/pam.d/sudo` - Howdy PAM module configuration
- `/etc/pam.d/sddm` - SDDM Howdy integration
- `~/.howdy/` - Face model storage (encrypted)

**Operational Notes:**
- Enrollment: `sudo howdy add`
- PAM module: `pam_python.so` (installed from GitHub fork)
- IR emitter: Auto-activated via `linux-enable-ir-emitter`
- Auto-activation: SDDM theme automatically triggers authentication 1 second after login screen display

#### 4.3 SDDM Auto-Activation

**Feature:** Automatic biometric authentication activation at login screen

**Implementation:**
- **Timer-based activation:** 1-second delay after login screen initialization
- **Automatic PAM trigger:** Invokes authentication with empty password to activate biometrics
- **Priority order:** Face recognition → Fingerprint → Password fallback
- **User input detection:** Auto-activation stops if user begins typing

**Configuration:**
- SDDM theme: `catppuccin-mocha-green`
- Components: `LoginPanel.qml` (auto-auth timer), `UserField.qml` (input detection)
- Documentation: `HOWDY_SDDM_AUTO_ACTIVATION.md`

**Benefits:**
- No user interaction required for biometric activation
- Faster login process when biometrics succeed
- Seamless fallback to password if biometrics fail

### 5. Terminal Environment

**Kitty Terminal:**
- GPU-accelerated rendering for smooth performance
- Dynamic opacity control (0.90 with effects, 1.0 without)
- Remote control interface for script-based configuration changes
- Catppuccin Mocha Green color scheme

**Official Resources:**
- **Website:** [sw.kovidgoyal.net/kitty](https://sw.kovidgoyal.net/kitty/)
- **GitHub:** [github.com/kovidgoyal/kitty](https://github.com/kovidgoyal/kitty)
- **ArchWiki:** [wiki.archlinux.org/title/Kitty](https://wiki.archlinux.org/title/Kitty)

**Tmux Multiplexer:**
- Persistent sessions across SSH disconnections
- Vim-style navigation (Ctrl+h/j/k/l) matching Hyprland/Neovim
- Wayland clipboard integration (wl-copy/wl-paste)
- TPM plugin manager for extensibility

**Official Resources:**
- **Website:** [tmux.github.io](https://tmux.github.io/)
- **GitHub:** [github.com/tmux/tmux](https://github.com/tmux/tmux)
- **ArchWiki:** [wiki.archlinux.org/title/Tmux](https://wiki.archlinux.org/title/Tmux)
- **TPM (Plugin Manager):** [github.com/tmux-plugins/tpm](https://github.com/tmux-plugins/tpm)

**Configuration Files:**
- `kitty/.config/kitty/kitty.conf`
- `tmux/.tmux.conf`

### 6. Operational Scripts

**Purpose:** Automation scripts for common system administration tasks and visual mode switching.

**Script Inventory:**
- `effects-toggle.sh`: Toggle blur/shadows/transparency effects
- `effects-on.sh` / `effects-off.sh`: Explicit effect state management
- `hyprland-corner.sh`: Switch to performance mode (0px corners, no animations)
- `hyprland-rounded.sh`: Switch to aesthetic mode (12px corners, animations)
- `screenshot-mode.sh` / `screenshot-mode-exit.sh`: Prepare environment for clean screenshots
- `wallpaper-rotate.sh`: Automatic wallpaper rotation daemon (3-minute interval)
- `wallpaper-change.sh`: Manual wallpaper rotation trigger
- `waybar-theme-switch.sh`: Status bar theme switching

**Operational Notes:**
- All scripts are idempotent (safe to run multiple times)
- Scripts modify configuration files and apply runtime changes via `hyprctl`
- Logging: Scripts write to `~/.local/share/hyprland-effects.log`

---

## Deployment Procedures

### Initial System Setup

**Prerequisites:**
- Arch Linux base installation completed
- User account created with sudo privileges
- Network connectivity established
- AUR helper (yay) installed (optional, for AUR packages)

**Step 1: Clone Repository**
```bash
git clone https://github.com/merneo/EliteBook.git ~/EliteBook
cd ~/EliteBook
```

**Step 2: Install System Dependencies**
```bash
# Core packages
sudo pacman -S hyprland kitty waybar neovim tmux zsh stow

# Fonts
sudo pacman -S ttf-jetbrains-mono-nerd noto-fonts noto-fonts-emoji

# Graphics drivers (Intel HD 620)
sudo pacman -S mesa vulkan-intel intel-media-driver

# Audio stack
sudo pacman -S pipewire pipewire-pulse wireplumber pavucontrol

# Utilities
sudo pacman -S grim wl-clipboard mako brightnessctl swww albert

# Power management
sudo pacman -S tlp thermald acpid
sudo systemctl enable --now tlp thermald acpid

# AUR packages (if yay is installed)
# yay: AUR helper - https://github.com/Jguer/yay
yay -S swayosd python-validity-git

# Optional: Install Howdy face recognition (automated script)
# ./scripts/install-howdy.sh
```

**Step 3: Deploy Configurations with GNU Stow**
```bash
cd ~/EliteBook

# Deploy all configurations (creates symlinks)
stow hypr kitty waybar nvim tmux scripts neofetch swayosd

# Make scripts executable
chmod +x ~/.local/bin/*.sh

# Install Tmux plugins
# TPM: https://github.com/tmux-plugins/tpm
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
~/.tmux/plugins/tpm/bin/install_plugins
```

**Step 4: Install System-Level Configurations**
```bash
# TLP power management
sudo cp tlp/etc/tlp.d/01-elitebook.conf /etc/tlp.d/
sudo tlp start

# Mask systemd-rfkill (TLP manages radios)
sudo systemctl mask systemd-rfkill.service systemd-rfkill.socket

# GRUB configuration
sudo cp grub/etc/default/grub /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg

# ACPI lid switch
sudo cp -r fingerprint/device-files/config-files/60-validity.rules /etc/udev/rules.d/
sudo udevadm control --reload
```

**Step 5: Configure Fingerprint Sensor (Optional)**
```bash
# Install fingerprint device files
sudo cp fingerprint/device-files/config-files/60-validity.rules /etc/udev/rules.d/
sudo cp fingerprint/device-files/firmware/6_07f_lenovo_mis_qm.xpfwext /usr/share/python-validity/

# Install Python modules (if needed)
VALIDITY_DIR=$(python3 -c "import site; print(site.getsitepackages()[0])")/validitysensor
sudo cp -r fingerprint/device-files/python-modules/* $VALIDITY_DIR/

# CRITICAL: BIOS reset required
# Restart → F10 → Security → Reset Fingerprint Reader

# Start service and enroll
sudo systemctl enable --now python3-validity
fprintd-enroll $USER

# Enable for sudo and SDDM
echo "auth sufficient pam_fprintd.so" | sudo tee -i /etc/pam.d/sudo
echo "auth sufficient pam_fprintd.so" | sudo tee -i /etc/pam.d/sddm
```

**Step 6: Enable systemd User Service**
```bash
# Automatic dotfiles symlink restoration on login
systemctl --user enable dotfiles-restore.service
systemctl --user start dotfiles-restore.service
```

### Post-Deployment Verification

**System Services:**
```bash
# Check power management
sudo tlp-stat -s
sudo tlp-stat -p  # CPU governor status
sudo tlp-stat -b  # Battery information

# Check fingerprint service
systemctl status python3-validity
fprintd-list $USER

# Check Hyprland
hyprctl monitors
hyprctl devices
```

**Configuration Validation:**
```bash
# Verify symlinks created
ls -la ~/.config/hypr/hyprland.conf
ls -la ~/.config/kitty/kitty.conf
ls -la ~/.tmux.conf

# Test keybindings
# Super+Q: Launch terminal
# Super+E: Launch file manager
# Super+R: Launch application launcher
# Super+Shift+E: Toggle visual effects
```

---

## Operational Procedures

### Configuration Management

**Updating Configurations:**
```bash
cd ~/EliteBook

# Modify configuration files in repository
vim hypr/.config/hypr/hyprland.conf

# Re-stow to update symlinks
stow -R hypr

# Apply runtime changes (Hyprland)
hyprctl reload
```

**Adding New Configurations:**
```bash
# Create new directory structure matching target location
mkdir -p newconfig/.config/newapp

# Add configuration file
vim newconfig/.config/newapp/config.conf

# Deploy with stow
stow newconfig
```

### Visual Mode Switching

**Performance Mode (Corner):**
- **Activation:** `Super+Shift+C` or `Super+Ctrl+C`
- **Characteristics:**
  - Sharp corners (0px rounding)
  - Animations disabled
  - GPU load: ~2-3%
  - Best for: Vim users, performance-critical tasks

**Aesthetic Mode (Rounded):**
- **Activation:** `Super+Shift+R` or `Super+Ctrl+R`
- **Characteristics:**
  - Rounded corners (12px rounding)
  - Animations enabled
  - GPU load: ~5-10%
  - Best for: Presentations, aesthetic preferences

**Visual Effects Toggle:**
- **Activation:** `Super+Shift+E`
- **Toggles:**
  - Background blur (Gaussian blur on transparent windows)
  - Drop shadows (depth rendering)
  - Window transparency (Kitty terminal: 0.90 opacity)

### Troubleshooting Procedures

**Hyprland Not Starting:**
```bash
# Check configuration syntax
hyprctl reload

# View error logs
journalctl --user -u hyprland -n 50

# Verify Wayland session
echo $XDG_SESSION_TYPE  # Should output: wayland
```

**Power Management Issues:**
```bash
# Verify TLP is active
sudo tlp-stat -s

# Check CPU governor
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
# Should show: performance (on AC) or powersave (on battery)

# Restart TLP
sudo tlp start
```

**Fingerprint Sensor Not Working:**
```bash
# Verify device detection
lsusb | grep Validity
# Expected: Bus 001 Device XXX: ID 138a:0092 Validity Sensors, Inc.

# Check service status
systemctl status python3-validity

# View service logs
journalctl -u python3-validity -n 50

# CRITICAL: BIOS reset required if enrollment fails
# Restart → F10 → Security → Reset Fingerprint Reader
```

**Network Connectivity Issues:**
```bash
# Check NetworkManager
systemctl status NetworkManager
nmcli device status

# Restart network stack
sudo systemctl restart NetworkManager
```

---

## Security Considerations

### Encryption
- **Full-disk encryption:** LUKS2 with AES-XTS-PLAIN64 (512-bit key)
- **Automatic decryption:** Keyfile embedded in initramfs (passwordless boot)
- **Security trade-off:** Keyfile in `/boot` (unencrypted) for convenience

### Authentication
- **Biometric authentication:** Fingerprint for sudo and login
- **PAM integration:** `pam_fprintd.so` module for authentication
- **Fallback:** Password authentication remains available

### System Hardening
- **USB autosuspend:** Disabled to prevent device disconnection attacks
- **Kernel parameters:** USB descriptor timeout increased for stability
- **Service isolation:** systemd user services for non-privileged operations

---

## Performance Optimization

### CPU Scaling
- **AC Power:** Performance governor (maximum clock speed)
- **Battery:** Powersave governor (dynamic frequency scaling)
- **Energy Policy:** balance_performance (AC) / balance_power (BAT)

### GPU Rendering
- **Corner Mode:** Minimal GPU load (~2-3%) for maximum performance
- **Rounded Mode:** Moderate GPU load (~5-10%) for visual effects
- **Effects Toggle:** Additional 2-3% GPU load when blur/shadows enabled

### Thermal Management
- **Thermald:** Active CPU thermal daemon prevents throttling
- **Platform Profile:** balanced (AC) / low-power (BAT)
- **Monitoring:** `cat /sys/class/thermal/thermal_zone*/temp`

---

## Maintenance Procedures

### Regular Maintenance Tasks

**Weekly:**
- Review system logs: `journalctl --since "1 week ago" | grep -i error`
- Check disk space: `df -h`
- Verify backup snapshots: `timeshift --list` (if Timeshift configured)

**Monthly:**
- Update system packages: `sudo pacman -Syu`
- Regenerate GRUB config (if kernel updated): `sudo grub-mkconfig -o /boot/grub/grub.cfg`
- Review TLP statistics: `sudo tlp-stat -s`

**Quarterly:**
- Review and update configuration files
- Test disaster recovery procedures
- Audit security configurations

### Backup and Recovery

**Configuration Backup:**
```bash
# Backup dotfiles repository
cd ~/EliteBook
git add -A
git commit -m "Configuration backup $(date +%Y-%m-%d)"
git push
```

**System Snapshot (Btrfs):**
```bash
# Create snapshot (if Timeshift configured)
sudo timeshift --create --comments "Pre-update snapshot"

# List snapshots
sudo timeshift --list

# Restore snapshot
sudo timeshift --restore --snapshot 'YYYY-MM-DD_HH-MM-SS'
```

---

## Documentation References

### Internal Documentation

#### Configuration Documentation
- **`CONFIGURATION_FILES_DOCUMENTATION.md`**: Comprehensive academic-level documentation for all configuration files
  - Window manager configuration (Hyprland)
  - Terminal emulator configuration (Kitty)
  - Status bar configuration (Waybar)
  - Terminal multiplexer configuration (Tmux)
  - Power management configuration (TLP)
  - Bootloader configuration (GRUB)
  - Operational scripts documentation
  - Academic explanations, architectural decisions, and best practices

#### Installation Documentation
- `INSTALL.md`: Installation guide overview and quick reference
- `INSTALL_PRE_REBOOT.md`: Complete pre-reboot installation guide (Phases 1-14)
  - Windows 11 installation via Windows 10 upgrade path
  - Disk partitioning, LUKS2 encryption, Btrfs filesystem
  - Base system installation, bootloader configuration
- `INSTALL_POST_REBOOT.md`: Complete post-reboot configuration guide (Phases 14.5+)
  - Biometric authentication (fingerprint, face recognition)
  - System snapshots, dotfiles deployment, GPG setup
  - Post-installation verification and troubleshooting

#### Hardware and Authentication Documentation
- `FINGERPRINT_ID_READERS.md`: Biometric authentication setup guide
- `HARDWARE_SETUP_SUMMARY.md`: Hardware configuration status and verification
- `CHANGELOG_HARDWARE_SETUP.md`: Configuration change history
- `SUDO_CONFIGURATION.md`: Sudo authentication configuration reference
  - Password-based authentication setup and verification
  - Security principles and best practices
  - PAM integration and troubleshooting
- `HOWDY_SETUP_MANUAL.md`: Howdy face recognition setup guide
  - Step-by-step enrollment procedure
  - PAM integration explanation
  - Troubleshooting and testing
- `HOWDY_SETUP_COMPLETE.md`: Howdy face recognition setup completion
  - Face enrollment status and verification
  - Sudo authentication usage scenarios
  - Security and convenience balance
- `HOWDY_SDDM_SETUP.md`: SDDM login screen Howdy configuration
  - PAM integration for SDDM
  - Camera permissions and access
  - Auto-activation feature overview
  - Troubleshooting procedures
- `HOWDY_SDDM_AUTO_ACTIVATION.md`: Automatic biometric activation at login screen
  - Auto-activation implementation details
  - Timer-based authentication trigger
  - User input detection and conflict prevention
  - Testing procedures and troubleshooting
- `HOWDY_SDDM_AUTO_AUTH.md`: SDDM auto-authentication fix documentation
  - Empty password authentication trigger
  - PAM authentication flow
  - Fallback mechanisms
- `HOWDY_PAM_PYTHON_FIX.md`: PAM Python module installation from GitHub
  - Compilation fixes for newer compilers
  - GitHub fork selection and installation
  - Troubleshooting compilation issues
- `FINGERPRINT_SETUP_COMPLETE.md`: Fingerprint authentication setup completion
  - Enrollment status and verification
  - PAM configuration for fingerprint
  - Usage examples and testing
- `FINGERPRINT_PASSWORD_FALLBACK.md`: Password fallback configuration guide
  - Ensuring password entry after biometric failure
  - Fingerprint message suppression options
  - PAM configuration for proper fallback chain
- `FINGERPRINT_REMOVE_MESSAGES.md`: Remove fingerprint messages guide
  - Solution for intrusive fingerprint messages
  - Script to remove fingerprint from PAM
  - Clean authentication flow (Howdy → Password)
- `BIOMETRIC_AUTHENTICATION_SUMMARY.md`: Complete biometric authentication system overview
  - Multi-factor authentication priority order
  - SDDM auto-activation details
  - Complete system integration
- `HOWDY_VERIFICATION_TESTING.md`: Howdy face recognition verification and testing guide
  - SDDM login screen face recognition setup
  - Testing procedures for all authentication points
  - Reboot and testing plan for login verification

### External Resources

**Arch Linux:**
- [Arch Linux Wiki](https://wiki.archlinux.org/) - Comprehensive documentation
- [Arch Linux Installation Guide](https://wiki.archlinux.org/title/Installation_guide)
- [Arch User Repository (AUR)](https://aur.archlinux.org/) - Community packages

**Desktop Environment:**
- [Hyprland](https://hyprland.org/) - Wayland compositor
  - [GitHub](https://github.com/hyprwm/Hyprland)
  - [Wiki](https://wiki.hyprland.org/)
- [Waybar](https://github.com/Alexays/Waybar) - Status bar for Wayland
- [Kitty](https://sw.kovidgoyal.net/kitty/) - GPU-accelerated terminal
- [SDDM](https://github.com/sddm/sddm) - Display manager

**System Tools:**
- [TLP](https://linrunner.de/tlp/) - Power management
- [GRUB](https://www.gnu.org/software/grub/) - Bootloader
- [Plymouth](https://www.freedesktop.org/wiki/Software/Plymouth) - Boot splash
- [Timeshift](https://github.com/teejee2008/timeshift) - System snapshots
- [PipeWire](https://pipewire.org/) - Audio/video server

**Development Tools:**
- [Neovim](https://neovim.io/) - Text editor
  - [GitHub](https://github.com/neovim/neovim)
- [Tmux](https://tmux.github.io/) - Terminal multiplexer
  - [TPM Plugin Manager](https://github.com/tmux-plugins/tpm)

**Biometric Authentication:**
- [python-validity](https://github.com/uunicorn/python-validity) - Fingerprint driver
- [Howdy](https://github.com/boltgolt/howdy) - Face recognition
- [fprintd (libfprint)](https://fprint.freedesktop.org/) - Fingerprint daemon

**Additional Resources:**
- [LUKS Encryption](https://wiki.archlinux.org/title/Dm-crypt) - Disk encryption
- [Btrfs](https://wiki.archlinux.org/title/Btrfs) - Filesystem
- [systemd](https://www.freedesktop.org/wiki/Software/systemd/) - Init system

---

## Repository Management

### Version Control
- **Primary Branch:** `main`
- **Commit Strategy:** Configuration changes committed with descriptive messages
- **Tagging:** Major configuration updates tagged with version numbers

### Contribution Guidelines
This repository is designed for **system configuration and documentation**. Contributions should focus on:
- Configuration improvements for operational reliability
- Documentation enhancements for clarity and completeness
- Script optimizations for automation workflows
- Security hardening recommendations
- Hardware compatibility improvements

### License
All configuration files and scripts are provided as-is for operational use. Refer to individual component licenses for third-party software.

---

## Support and Contact

**Repository Maintainer:** merneo  
**Last Updated:** December 2025  
**System Status:** Production-ready, actively maintained

For operational issues, refer to troubleshooting procedures in this document. For configuration questions, consult the internal documentation files referenced above.

---

**Note:** This repository is maintained for personal system configuration with comprehensive documentation. All configurations have been tested on HP EliteBook x360 1030 G2 hardware running Arch Linux. While primarily designed for this specific hardware, the configurations and documentation may serve as a reference for similar hardware platforms. Adaptations may be required for different hardware or distribution variants.
