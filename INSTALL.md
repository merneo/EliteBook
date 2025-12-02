# Arch Linux Installation Guide - HP EliteBook x360 1030 G2

**Comprehensive, step-by-step installation procedure for dual-boot Arch Linux + Windows 11 with LUKS2 encryption, Btrfs filesystem, automatic decryption, fingerprint authentication, and Hyprland desktop environment.**

---

## Quick Start

**For experienced users familiar with Arch Linux installation:**

### Pre-Reboot Installation (Live USB Environment)
1. **Windows 11**: Install via Windows 10 upgrade path (preserves OEM drivers)
2. **Partitioning**: Create 70 GB Linux root + 8 GB swap partitions
3. **Encryption**: LUKS2 (AES-XTS-PLAIN64, 512-bit, Argon2id PBKDF)
4. **Filesystem**: Btrfs with 5 subvolumes (@, @home, @log, @cache, @snapshots)
5. **Base System**: Install via `pacstrap` with essential packages
6. **Bootloader**: GRUB with optional automatic LUKS decryption (can be toggled for security)
7. **Desktop**: Hyprland, Kitty, Waybar, PipeWire, SDDM
8. **Browsers**: Firefox, Brave (optional)
9. **Services**: NetworkManager, Bluetooth, SSH enabled

**Estimated Time**: 2-3 hours  
**Documentation**: [INSTALL_PRE_REBOOT.md](INSTALL_PRE_REBOOT.md)

### Post-Reboot Configuration (Installed System)
1. **Biometric Auth**: Fingerprint (python-validity), Face recognition (Howdy)
2. **System Snapshots**: Timeshift with Btrfs (daily snapshots)
3. **Dotfiles**: Deploy from GitHub repository
4. **Browser Themes**: Deploy Catppuccin Mocha Green themes (optional)
5. **GPG Keys**: Configure for signed Git commits

**Estimated Time**: 1-2 hours  
**Documentation**: [INSTALL_POST_REBOOT.md](INSTALL_POST_REBOOT.md)

---

## Documentation Structure

This installation guide is organized into two main documents:

### [INSTALL_PRE_REBOOT.md](INSTALL_PRE_REBOOT.md) - Pre-Reboot Installation

Complete system installation from Arch Linux live USB environment up to the first system reboot. This includes:

- **Phase 1**: Windows 11 installation via Windows 10 upgrade path
- **Phase 2**: Arch Linux live USB preparation
- **Phase 3**: Remote installation via SSH setup
- **Phase 4**: Disk partitioning with cfdisk
- **Phase 5**: LUKS2 encryption setup
- **Phase 6**: Btrfs filesystem creation with subvolumes
- **Phase 7**: Base system installation
- **Phase 8**: System configuration (chroot)
- **Phase 9**: Bootloader installation (GRUB)
- **Phase 10**: Automatic LUKS decryption setup (OPTIONAL - security trade-off)
- **Phase 11**: User account creation
- **Phase 12**: Network configuration
- **Phase 13**: Window manager setup (Hyprland)
- **Phase 14**: Exit chroot and system reboot

**Total Estimated Time**: 2-3 hours  
**Restart Count**: 1 (first system reboot at end of Phase 14)

### [INSTALL_POST_REBOOT.md](INSTALL_POST_REBOOT.md) - Post-Reboot Configuration

System configuration and setup after the first successful boot into the installed Arch Linux system. This includes:

- **Phase 14.5+**: First boot sequence and verification
- **Phase 15**: Fingerprint authentication setup
- **Phase 15b**: eObčanka (Czech ID Card) reader setup
- **Phase 15c**: Howdy face recognition authentication setup
- **Phase 16**: Timeshift snapshot configuration
- **Phase 17**: Dotfiles deployment
- **Phase 18**: GPG key setup for Git commits
- **Post-Installation Verification**: System verification and testing
- **Troubleshooting**: Common issues and solutions

**Total Estimated Time**: 1-2 hours  
**Restart Count**: 0 (no restarts required)

---

## Pre-Installation Requirements

**Hardware Prerequisites:**
- HP EliteBook x360 1030 G2 (7th Gen Intel Core i5-7300U)
- 8 GB RAM minimum
- NVMe SSD 238.5 GB total capacity
- USB flash drive (8 GB minimum) for Arch Linux ISO
- Second computer for remote SSH installation (highly recommended)
- Validity Sensors 138a:0092 fingerprint reader (built-in)
- Chicony IR Camera (04f2:b58e) for face recognition

**Downloaded Files:**
- [Arch Linux ISO (latest)](https://archlinux.org/download/) - Official download page
- [Rufus](https://rufus.ie/) - USB bootable media creation tool (Windows)
- [Windows 10 Media Creation Tool](https://www.microsoft.com/software-download/windows10) - Windows installation media

**Network Access:**
- Ethernet cable (recommended for fastest installation) OR
- WiFi credentials (SSID + password) for Intel Wireless 8265

**Important Pre-Installation Notes:**

**Critical Information:**
- This guide assumes **Windows 11 is installed FIRST** (standard dual-boot scenario)
- Installation uses **Windows 10 → Windows 11 upgrade path** to preserve OEM drivers
- UEFI boot mode **REQUIRED** (not legacy BIOS - verify in BIOS settings)
- Secure Boot should be **DISABLED** during Arch installation (can re-enable later with signed bootloader)
- Fast Startup in Windows 11 **MUST BE DISABLED** (prevents filesystem corruption)
- BitLocker encryption in Windows **MUST BE DISABLED** before proceeding

**What You Will Have After Installation:**
- Dual-boot system: Windows 11 + Arch Linux with GRUB menu
- LUKS2 full-disk encryption (AES-XTS-PLAIN64, 512-bit key, Argon2id PBKDF)
- Optional automatic LUKS decryption on boot (can be toggled for security)
- Btrfs filesystem with automatic snapshots (Timeshift)
- Fingerprint authentication for sudo and login
- Face recognition authentication (Howdy) for sudo and login
- Hyprland Wayland compositor with dynamic effects
- Plymouth boot splash screen (no password prompt)
- Complete desktop environment ready to use

---

## Disk Partitioning Strategy

**Final Partition Layout (NVMe SSD 238.5 GB):**

| Partition | Size | Type | Filesystem | Mount Point | Purpose | Encrypted |
|-----------|------|------|------------|-------------|---------|-----------|
| `/dev/nvme0n1p1` | 512 MB | EFI System | FAT32 | `/boot` | UEFI bootloader (GRUB) | No |
| `/dev/nvme0n1p2` | 159.2 GB | Microsoft basic data | NTFS | N/A | Windows 11 system partition | No |
| `/dev/nvme0n1p3` | 826 MB | Microsoft recovery | NTFS | N/A | Windows Recovery Environment | No |
| `/dev/nvme0n1p4` | 70 GB | Linux filesystem | Btrfs | `/` | Arch Linux root (encrypted) | Yes (LUKS2) |
| `/dev/nvme0n1p5` | 8 GB | Linux swap | swap | `[SWAP]` | Encrypted swap partition | Yes (LUKS2) |

**Encryption Details:**
- Algorithm: AES-XTS-PLAIN64
- Key size: 512-bit (maximum security)
- Key derivation: Argon2id (LUKS2 default, memory-hard PBKDF)
- Boot partition: **Unencrypted** (required for UEFI)
- Windows partition: **Unencrypted** (managed by Windows)

**Btrfs Subvolume Organization:**

```
@ (root)           - System files (/bin, /etc, /opt, /usr, /var)
@home              - User home directories (/home)
@log               - System logs (/var/log)
@cache             - Package cache (/var/cache)
@snapshots         - Timeshift snapshots (/.snapshots)
```

**Why This Layout?**
- Separate subvolumes allow independent snapshots
- `@log` and `@cache` excluded from snapshots (saves space)
- `@home` included in snapshots (preserves user data + system state)
- Enables instant system rollback via Timeshift

---

## Installation Workflow

### Step 1: Pre-Reboot Installation
Follow [INSTALL_PRE_REBOOT.md](INSTALL_PRE_REBOOT.md) to complete:
- Windows 11 installation (via Windows 10 upgrade)
- Disk partitioning
- LUKS2 encryption setup
- Base Arch Linux installation
- Bootloader configuration
- Desktop environment setup
- First system reboot

### Step 2: Post-Reboot Configuration
After first successful boot, follow [INSTALL_POST_REBOOT.md](INSTALL_POST_REBOOT.md) to complete:
- System verification
- Biometric authentication setup
- System snapshot configuration
- Dotfiles deployment
- Final system verification

---

## Key Technical Details

### Encryption
- **Type**: LUKS2 (Linux Unified Key Setup version 2)
- **Cipher**: AES-XTS-PLAIN64
- **Key Size**: 512-bit
- **PBKDF**: Argon2id (memory-hard key derivation)
- **Automatic Decryption**: Optional keyfile in initramfs (can be toggled - security trade-off)

### Filesystem
- **Type**: Btrfs (B-tree filesystem)
- **Compression**: Zstandard (zstd) - transparent, ~20-30% space savings
- **Subvolumes**: 5 subvolumes for independent snapshot management
- **Snapshots**: Timeshift integration for automatic system backups

### Boot Process
1. UEFI firmware loads GRUB from EFI partition
2. GRUB menu appears (5-second timeout)
3. Plymouth boot splash displays (BGRT theme)
4. Initramfs automatically decrypts LUKS partition using embedded keyfile
5. Btrfs root filesystem mounts
6. Systemd starts services
7. SDDM login screen appears

### Authentication
- **Fingerprint**: Validity Sensors 138a:0092 via python-validity driver
- **Face Recognition**: Howdy using IR camera (04f2:b58e)
- **PAM Integration**: Both methods integrated with sudo and SDDM login

---

## Troubleshooting

For detailed troubleshooting information, see the **Troubleshooting** section in [INSTALL_POST_REBOOT.md](INSTALL_POST_REBOOT.md).

**Common Issues:**
- **Boot fails**: Verify GRUB configuration and UUID in `/etc/default/grub`
- **Encryption prompt**: Keyfile may not be embedded in initramfs - rebuild with `mkinitcpio -P`
- **WiFi not working**: NetworkManager service may not be running - check with `systemctl status NetworkManager`
- **Fingerprint not detected**: BIOS reset required (F10 → Security → Reset Fingerprint Reader)
- **Face recognition fails**: Verify IR camera is detected at `/dev/video2`

---

## Additional Resources

### Internal Documentation
- [INSTALL_PRE_REBOOT.md](INSTALL_PRE_REBOOT.md) - Complete pre-reboot installation guide
- [INSTALL_POST_REBOOT.md](INSTALL_POST_REBOOT.md) - Complete post-reboot configuration guide
- [README.md](README.md) - Repository overview and configuration documentation
- [FINGERPRINT_ID_READERS.md](FINGERPRINT_ID_READERS.md) - Biometric authentication setup guide

### External Resources

**Arch Linux:**
- [Arch Linux Wiki](https://wiki.archlinux.org/) - Comprehensive documentation
- [Arch Linux Installation Guide](https://wiki.archlinux.org/title/Installation_guide) - Official installation guide
- [Arch User Repository (AUR)](https://aur.archlinux.org/) - Community-maintained packages

**System Configuration:**
- [LUKS Encryption](https://wiki.archlinux.org/title/Dm-crypt) - Disk encryption documentation
- [Btrfs](https://wiki.archlinux.org/title/Btrfs) - Filesystem documentation
- [GRUB](https://wiki.archlinux.org/title/GRUB) - Bootloader configuration
- [systemd](https://www.freedesktop.org/wiki/Software/systemd/) - Init system documentation

**Desktop Environment:**
- [Hyprland](https://hyprland.org/) - Wayland compositor
  - [GitHub Repository](https://github.com/hyprwm/Hyprland)
  - [Wiki Documentation](https://wiki.hyprland.org/)
  - [ArchWiki](https://wiki.archlinux.org/title/Hyprland)

**Biometric Authentication:**
- [Howdy](https://github.com/boltgolt/howdy) - Face recognition authentication
- [python-validity](https://github.com/uunicorn/python-validity) - Fingerprint driver
- [fprintd (libfprint)](https://fprint.freedesktop.org/) - Fingerprint daemon

---

## Support

**Repository Maintainer**: merneo  
**Last Updated**: December 2025  
**System Status**: Production-ready, actively maintained

For installation questions, refer to the detailed phase-by-phase instructions in [INSTALL_PRE_REBOOT.md](INSTALL_PRE_REBOOT.md) and [INSTALL_POST_REBOOT.md](INSTALL_POST_REBOOT.md).

---

**Note**: This installation guide is specifically designed for HP EliteBook x360 1030 G2 hardware. Adaptations may be required for different hardware platforms or distribution variants.
