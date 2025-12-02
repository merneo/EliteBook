# Arch Linux Installation Guide - GIGABYTE Brix 5300

**Version:** 2.0.0  
**Last Updated:** December 2, 2025  
**Language:** US English (Academic Publication Standard)  
**Purpose:** Arch Linux installation guide for GIGABYTE Brix 5300 barebone with AMD Ryzen 3 5300U and Radeon RX Vega graphics

This document provides a comprehensive guide for installing Arch Linux on GIGABYTE Brix 5300 barebone system with full-disk encryption, Btrfs filesystem, and a minimal window manager setup. This guide includes AMD-specific microcode updates and AMD Radeon RX Vega graphics drivers.

---

## Abstract

This installation guide documents the complete procedure for installing Arch Linux on GIGABYTE Brix 5300 barebone system with the following features:

- **Full-Disk Encryption**: LUKS2 encryption with AES-XTS-PLAIN64 cipher and Argon2id key derivation
- **Btrfs Filesystem**: Copy-on-write filesystem with subvolume organization for snapshots
- **UEFI Boot**: GRUB bootloader with Windows 11 dual-boot support
- **Hyprland Wayland Compositor**: Dynamic tiling window manager with visual effects
- **Complete Wayland Desktop**: Waybar status bar, Kitty terminal, Dolphin file manager
- **AMD Ryzen 3 5300U Microcode**: AMD processor microcode updates for security and stability
- **AMD Radeon RX Vega Graphics Drivers**: Mesa, Vulkan, and VA-API drivers for integrated Radeon RX Vega graphics
- **Academic Documentation**: Comprehensive theoretical foundations, references, and citations

**System Specifications:**
- **Model**: GIGABYTE Brix 5300 barebone
- **Processor**: AMD Ryzen™ 3 5300U (4C/8T, 2.6-3.8 GHz, Zen 2, 15W TDP)
- **Graphics**: AMD Radeon™ RX Vega (6 compute units, integrated)
- **Memory**: Kingston FURY Impact 2×32GB DDR4 3200MHz CL20 SO-DIMM (64 GB total)
- **Storage**: M.2 NVMe SSD (user-installed, PCIe 3.0 ×4)
- **Audio**: Realtek ALC897 HD Audio Codec
- **Network**: Gigabit Ethernet, AMD RZ608 WiFi 6 (802.11ax), Bluetooth 5.2

**Target Audience:**
- System administrators installing Arch Linux on GIGABYTE Brix 5300
- Users with AMD Ryzen 3 5300U processor and Radeon RX Vega graphics
- Educational institutions teaching Linux system administration on mini PC systems
- Researchers documenting Linux installation procedures for barebone systems

**Hardware Specifications:**
- **System:** GIGABYTE Brix 5300 barebone
- **Processor:** AMD Ryzen™ 3 5300U (4 cores / 8 threads, 2.6 GHz base / 3.8 GHz boost)
- **Architecture:** Zen 2 (7nm)
- **Cache:** 6 MB L3 cache
- **TDP:** 15W
- **Graphics:** AMD Radeon™ RX Vega (integrated, 6 compute units)
- **Memory:** Kingston FURY Impact 2×32GB DDR4 3200MHz CL20 SO-DIMM (64 GB total)
- **Storage:** M.2 NVMe SSD (user-installed)
- **Audio:** Realtek ALC897 HD Audio Codec
- **Network:** Gigabit Ethernet, AMD RZ608 WiFi 6 (802.11ax), Bluetooth 5.2
- **Video Output:** HDMI 2.0, DisplayPort 1.4, USB-C (DisplayPort Alt Mode)

**Prerequisites:**
- GIGABYTE Brix 5300 barebone system
- AMD Ryzen 3 5300U processor (pre-installed)
- AMD Radeon RX Vega graphics (integrated)
- Kingston FURY Impact 2×32GB DDR4 3200MHz CL20 SO-DIMM (64 GB total, pre-installed)
- M.2 NVMe SSD (user-installed, minimum 128 GB recommended)
- UEFI firmware (not legacy BIOS)
- USB flash drive (8 GB minimum)
- Internet connection (for package downloads)
- Basic Linux command-line knowledge

---

## Table of Contents

1. [Pre-Installation Requirements](#pre-installation-requirements)
2. [Placeholders and Variables](#placeholders-and-variables)
3. [Disk Partitioning Strategy](#disk-partitioning-strategy)
4. [Phase 1: Arch Linux Live USB Preparation](#phase-1-arch-linux-live-usb-preparation)
5. [Phase 2: Remote Installation via SSH (Optional)](#phase-2-remote-installation-via-ssh-optional)
6. [Phase 3: Disk Partitioning](#phase-3-disk-partitioning)
7. [Phase 4: LUKS2 Encryption Setup](#phase-4-luks2-encryption-setup)
8. [Phase 5: Btrfs Filesystem Creation](#phase-5-btrfs-filesystem-creation)
9. [Phase 6: Base System Installation](#phase-6-base-system-installation)
10. [Phase 7: System Configuration (Chroot)](#phase-7-system-configuration-chroot)
11. [Phase 8: Bootloader Installation (GRUB)](#phase-8-bootloader-installation-grub)
12. [Phase 9: Automatic LUKS Decryption Setup (Optional)](#phase-9-automatic-luks-decryption-setup-optional)
13. [Phase 10: User Account Creation](#phase-10-user-account-creation)
14. [Phase 11: Network Configuration](#phase-11-network-configuration)
15. [Phase 12: Window Manager Setup](#phase-12-window-manager-setup)
16. [Phase 13: Exit Chroot and System Reboot](#phase-13-exit-chroot-and-system-reboot)
17. [Troubleshooting Guide](#troubleshooting-guide)
18. [References](#references)

---

## Pre-Installation Requirements

### Hardware Prerequisites

**GIGABYTE Brix 5300 System Requirements:**
- **Processor:** AMD Ryzen 3 5300U (pre-installed, 4C/8T, 2.6-3.8 GHz)
- **Memory:** Kingston FURY Impact 2×32GB DDR4 3200MHz CL20 SO-DIMM
  - **Total RAM:** 64 GB (32 GB × 2)
  - **Speed:** DDR4-3200 (3200 MHz)
  - **Timing:** CL20 (CAS Latency 20)
  - **Form Factor:** SO-DIMM (laptop memory)
- **Storage:** M.2 NVMe SSD (user-installed)
  - Minimum: 128 GB (for minimal installation)
  - Recommended: 256 GB or larger (for comfortable usage)
  - Form factor: M.2 2280 (22mm × 80mm)
  - Interface: PCIe 3.0 ×4 NVMe
- **USB flash drive:** 8 GB minimum for Arch Linux ISO
- **Second computer:** Highly recommended for remote SSH installation (optional)

**Network Options:**
- **Ethernet:** Gigabit Ethernet port (recommended for fastest installation)
- **WiFi:** AMD RZ608 WiFi 6 (802.11ax) - requires driver configuration during installation
- **Bluetooth:** Bluetooth 5.2 (integrated with AMD RZ608 WiFi module)

**Audio:**
- **Audio Codec:** Realtek ALC897 HD Audio Codec
- **Driver:** ALSA (Advanced Linux Sound Architecture) - included in kernel
- **Audio Server:** PipeWire (installed in Phase 12)

### Software Prerequisites

**Downloaded Files:**
- [Arch Linux ISO (latest)](https://archlinux.org/download/) - Official download page with mirrors
- USB creation tool:
  - **Linux/macOS**: `dd` command (built-in)
  - **Windows**: [Rufus](https://rufus.ie/) or [Ventoy](https://www.ventoy.net/)

**Network Access:**
- Ethernet cable (recommended for fastest installation) OR
- WiFi credentials (SSID + password) for wireless installation

### Important Pre-Installation Notes

**WARNING: Critical Information:**
- **Windows 11 MUST BE INSTALLED FIRST** - This guide assumes Windows 11 is already installed
- UEFI boot mode **REQUIRED** (not legacy BIOS - verify in BIOS settings)
- Secure Boot should be **DISABLED** during Arch installation (can re-enable later with signed bootloader)
- **Fast Startup in Windows 11 MUST BE DISABLED** (prevents filesystem corruption)
- **BitLocker encryption in Windows 11 MUST BE DISABLED** before proceeding

**What You Will Have After Installation:**
- **SUCCESS:** Dual-boot system: Windows 11 + Arch Linux with GRUB menu
- **SUCCESS:** Arch Linux with GRUB bootloader on GIGABYTE Brix 5300
- **SUCCESS:** LUKS2 full-disk encryption (AES-XTS-PLAIN64, 512-bit key)
- **SUCCESS:** Optional automatic LUKS decryption on boot (can be toggled for security)
- **SUCCESS:** Btrfs filesystem with subvolume organization
- **SUCCESS:** AMD Ryzen 3 5300U microcode updates installed
- **SUCCESS:** AMD Radeon RX Vega graphics drivers (Mesa, Vulkan, VA-API)
- **SUCCESS:** Hyprland Wayland compositor with dynamic tiling and visual effects
- **SUCCESS:** Complete Wayland desktop environment (Waybar, Kitty, Dolphin, Firefox)
- **SUCCESS:** PipeWire audio server with low latency
- **SUCCESS:** SDDM display manager for graphical login
- **SUCCESS:** Complete system ready for daily use

---

## Placeholders and Variables

**IMPORTANT:** This guide uses specific placeholders and variables. Replace them with your actual values when executing commands.

### Device Partitions (GIGABYTE Brix 5300)

| Variable | Value | Description | First Used In |
|----------|-------|-------------|---------------|
| `<DISK>` | `/dev/nvme0n1` | Main disk device (M.2 NVMe SSD) | Phase 3 |
| `<EFI_PARTITION>` | `/dev/nvme0n1p1` | EFI System Partition (512 MB, shared with Windows) | Phase 5 |
| `<ROOT_PARTITION>` | `/dev/nvme0n1p4` | Arch Linux root partition (225 GB, encrypted) | Phase 4 |
| `<SWAP_PARTITION>` | `/dev/nvme0n1p5` | Swap partition (8 GB, encrypted) | Phase 4 |

**Note:** These are the standard partition numbers for GIGABYTE Brix 5300 with Windows 11 pre-installed. Verify with `lsblk` before proceeding.

### User-Specific Variables

| Variable | Description | When to Set | Example |
|----------|-------------|-------------|---------|
| `<username>` | Your chosen username | Phase 10 | `john`, `alice`, `user` |
| `<YOUR_UUID>` | UUID of encrypted root partition | Phase 8, Step 8.2 | `a1b2c3d4-e5f6-7890-abcd-ef1234567890` |
| `<YOUR_PASSWORD>` | User account password | Phase 10 | (choose strong password) |
| `<LUKS_PASSPHRASE>` | LUKS encryption passphrase | Phase 4 | (choose strong passphrase, 20+ chars) |
| `<TIMEZONE>` | System timezone | Phase 7 | `Europe/London`, `America/New_York` |
| `<HOSTNAME>` | System hostname | Phase 7 | `archlinux`, `gigabyte-brix` |

### Network Variables (if using WiFi)

| Variable | Description | When to Set |
|----------|-------------|-------------|
| `<YourSSID>` | WiFi network name (SSID) | Phase 2 |
| `<WiFi_PASSWORD>` | WiFi network password | Phase 2 |
| `<IP_ADDRESS>` | IP address assigned to target system | Phase 2 |

### Environment Indicators

Throughout this guide, you will see environment indicators:

- **`[Live USB]`** - Commands executed in Arch Linux live USB environment
- **`[Chroot]`** - Commands executed inside chroot (installed system)
- **`[First Boot]`** - Commands executed after first system boot

**Prompt Examples:**
- Live USB: `root@archiso ~ #`
- Chroot: `[root@archiso /]#`
- First Boot: `username@hostname ~ $`

### AI Helper Usage Notes

**For AI Assistants and Automated Scripts:**

This guide is optimized for AI helper usage with:
- **Structured placeholders:** All variables clearly defined in tables above
- **Explicit success criteria:** Each phase has verifiable completion criteria
- **Error handling:** Common errors and solutions provided inline
- **Context indicators:** Environment clearly marked for each phase
- **Checklists:** Prerequisites and verification steps for each phase

**Key Patterns for AI Parsing:**
- **Placeholders:** Always in format `<PLACEHOLDER>` or clearly marked as variables
- **Commands:** All commands in code blocks with `bash` syntax highlighting
- **Success indicators:** `**SUCCESS:**` markers for completed steps
- **Warnings:** `**WARNING:**` markers for critical information
- **Verification:** `**Verification:**` sections with checklists

**Recommended AI Helper Workflow:**
1. Read "Placeholders and Variables" section to understand all variables
2. Follow phases sequentially, checking prerequisites before each phase
3. Verify success criteria after each phase before proceeding
4. Use troubleshooting sections if errors occur
5. Reference Quick Reference section for command syntax

---

## Disk Partitioning Strategy

### Partition Layout for SAMSUNG 970 EVO Plus 500GB

**IMPORTANT:** This guide assumes **Windows 11 is already installed**. The partitioning strategy below shows the layout after Windows 11 installation, with space reserved for Arch Linux.

**Disk Specifications:**
- **Model:** SAMSUNG 970 EVO Plus
- **Capacity:** 500 GB (formatted capacity: ~465-500 GB)
- **Interface:** M.2 NVMe PCIe 3.0 ×4
- **Form Factor:** M.2 2280

**Final Partition Layout (after Windows 11 installation):**

| Partition | Percentage | Real Size | Type | Filesystem | Mount Point | Purpose | Encrypted |
|-----------|------------|-----------|------|------------|-------------|---------|-----------|
| `/dev/nvme0n1p1` | 0.1% | 512 MB | EFI System | FAT32 | `/boot` | UEFI bootloader (GRUB + Windows) | **No** |
| `/dev/nvme0n1p2` | 50% | ~250 GB | Microsoft basic data | NTFS | N/A | Windows 11 system partition | **No** |
| `/dev/nvme0n1p3` | 0.2% | ~1 GB | Microsoft recovery | NTFS | N/A | Windows Recovery Environment | **No** |
| `/dev/nvme0n1p4` | 45% | ~225 GB | Linux filesystem | Btrfs | `/` | Arch Linux root (encrypted) | **Yes (LUKS2)** |
| `/dev/nvme0n1p5` | 1.6% | ~8 GB | Linux swap | swap | `[SWAP]` | Encrypted swap partition | **Yes (LUKS2)** |
| **Unallocated** | ~3% | ~15 GB | - | - | - | Reserved for future use | - |

**Total Disk Usage:**
- **Windows 11:** ~251 GB (50.2%)
- **Arch Linux:** ~233 GB (46.6%)
- **Unallocated:** ~15 GB (3.0%)
- **Total Used:** ~485 GB (97%)

**Detailed Breakdown:**

**Windows 11 Partitions (created during Windows installation):**
- **EFI System Partition (p1):** 512 MB
  - Shared between Windows 11 and Arch Linux
  - Contains Windows Boot Manager and GRUB bootloader
  - FAT32 filesystem (required for UEFI)

- **Windows 11 System Partition (p2):** ~250 GB (50%)
  - Windows 11 installation files
  - User data, applications, system files
  - NTFS filesystem

- **Windows Recovery Partition (p3):** ~1 GB (0.2%)
  - Windows Recovery Environment (WinRE)
  - System restore functionality
  - NTFS filesystem

**Arch Linux Partitions (created during Arch installation):**

- **Root Partition (p4):** ~225 GB (45%)
  - Arch Linux system files
  - User home directories
  - Applications and packages
  - Btrfs filesystem with subvolumes
  - LUKS2 encrypted
  - **Increased from 175 GB to 225 GB** for more storage space

- **Swap Partition (p5):** ~8 GB (1.6%)
  - Virtual memory (swap space)
  - **For 64 GB RAM:** 8 GB swap is sufficient
  - With 64 GB RAM, swap is rarely used (only for hibernation or extreme memory pressure)
  - LUKS2 encrypted
  - **Note:** For 64 GB RAM systems, swap is primarily for:
    - Hibernation (suspend-to-disk) - requires swap ≥ RAM size
    - Emergency overflow (rarely needed with 64 GB RAM)
    - If hibernation is needed, increase swap to 64 GB or disable hibernation

**Unallocated Space (~15 GB, 3%):**
- Reserved for future expansion
- Can be used for additional data partitions if needed
- Provides flexibility for future disk space needs

**Note:** Actual sizes may vary slightly due to:
- Disk formatting overhead
- Windows 11 installation size variations
- Partition alignment requirements
- File system overhead

### Encryption Details

- **Algorithm**: AES-XTS-PLAIN64
- **Key size**: 512-bit (maximum security)
- **Key derivation**: Argon2id (LUKS2 default, memory-hard)
- **Boot partition**: **Unencrypted** (required for UEFI)
- **Root partition**: **Encrypted** (LUKS2)
- **Swap partition**: **Encrypted** (LUKS2)

### Btrfs Subvolume Organization

```
@ (root)           - System files (/bin, /etc, /opt, /usr, /var)
@home              - User home directories (/home)
@log               - System logs (/var/log)
@cache             - Package cache (/var/cache)
@snapshots         - Snapshot storage (/.snapshots)
```

**Why This Layout?**
- Separate subvolumes allow independent snapshots
- `@log` and `@cache` excluded from snapshots (saves space)
- `@home` included in snapshots (preserves user data + system state)
- Enables instant system rollback via snapshot tools

---

## Phase 1: Arch Linux Live USB Preparation

**ENVIRONMENT:** [Preparation Machine] → [Live USB]  
**TIME:** Estimated Time: 10-15 minutes  
**NEXT:** Restart Count: 0 (preparation only)

**Prerequisites Checklist:**
- [ ] Second computer available (for USB creation)
- [ ] USB flash drive (8 GB minimum) available
- [ ] Internet connection on preparation machine
- [ ] Arch Linux ISO downloaded (or ready to download)

**Success Criteria:**
- [ ] Arch Linux ISO downloaded and verified
- [ ] USB drive created successfully
- [ ] System boots from USB into Arch Linux live environment
- [ ] UEFI boot mode verified

### Step 1.1: Download Arch Linux ISO

On your **preparation machine** (second computer):

**Linux/macOS:**
```bash
# Download latest Arch Linux ISO
wget https://mirror.rackspace.com/archlinux/iso/latest/archlinux-x86_64.iso

# Download signature for verification
wget https://mirror.rackspace.com/archlinux/iso/latest/archlinux-x86_64.iso.sig

# Verify ISO integrity (optional but recommended)
gpg --verify archlinux-x86_64.iso.sig archlinux-x86_64.iso
```

**Windows:**
- Download from: https://archlinux.org/download/
- Select a mirror near you
- Download: `archlinux-YYYY.MM.DD-x86_64.iso`

### Step 1.2: Create Bootable USB

**On Linux:**
```bash
# Find USB device name
lsblk
# Look for your USB drive (e.g., /dev/sdb, NOT /dev/sdb1)

# Write ISO to USB (**WARNING:** REPLACE /dev/sdX WITH YOUR USB DEVICE)
sudo dd if=archlinux-x86_64.iso of=/dev/sdX bs=4M status=progress oflag=sync

# Wait for completion (2-5 minutes)
sync
```

**On Windows (using Rufus):**
1. Download Rufus: https://rufus.ie/
2. Insert USB drive (8 GB minimum)
3. Open Rufus
4. **Device**: Select your USB drive
5. **Boot selection**: Click "SELECT" → Choose `archlinux-x86_64.iso`
6. **Partition scheme**: GPT
7. **Target system**: UEFI (non CSM)
8. **File system**: FAT32
9. Click **START**
10. **Write mode**: Select "DD Image" (important!)
11. Click **OK** to confirm
12. Wait for completion (3-5 minutes)

**On macOS:**
```bash
# Find USB device
diskutil list
# Look for your USB (e.g., /dev/disk2)

# Unmount USB
diskutil unmountDisk /dev/diskX

# Write ISO to USB (**WARNING:** REPLACE /dev/diskX)
sudo dd if=archlinux-x86_64.iso of=/dev/rdiskX bs=4m && sync

# Wait for completion (2-5 minutes)
```

### Step 1.3: Boot into Arch Linux Live Environment

1. **Shut down target system** completely
2. **Insert Arch Linux USB** into target system
3. **Power on** and **enter boot menu** (typically F9, F12, or Del key)
4. **Select USB drive** from boot menu
5. **GRUB menu** appears:
   - Select: **Arch Linux install medium (x86_64, UEFI)** (first option)
   - Press **Enter**
6. **Wait for boot** to complete (~30-60 seconds)
7. **You should see**:
   ```
   Arch Linux 6.x.x-arch1-1 (tty1)

   archiso login: root (automatic login)
   ```

**SUCCESS:** You are now in Arch Linux live environment

### Step 1.4: Verify UEFI Boot Mode

```bash
# Verify UEFI mode (not BIOS)
ls /sys/firmware/efi/efivars

# If this directory exists and shows files, you are in UEFI mode ✅
# If error "No such file or directory", you booted in BIOS mode ❌ (restart and fix BIOS settings)
```

### Step 1.5: Set Larger Console Font (Optional, for readability)

```bash
# Increase console font size for easier reading
setfont ter-132b
```

**SUCCESS:** Phase 1 Complete: Booted into Arch Linux live USB in UEFI mode

**Verification:**
- [x] UEFI mode confirmed (`/sys/firmware/efi/efivars` exists)
- [x] Root prompt available (`root@archiso ~ #`)
- [x] Network connectivity (if needed for Phase 2)

**NEXT:** Next: Setup SSH for remote installation (Phase 2) or proceed to disk partitioning (Phase 3)

**Troubleshooting:**
- **If UEFI directory doesn't exist:** Reboot and enter BIOS/UEFI settings, ensure UEFI mode is enabled (not Legacy/CSM)
- **If system doesn't boot from USB:** Check boot order in BIOS/UEFI settings, ensure USB is first boot device

---

## Phase 2: Remote Installation via SSH (Optional)

**ENVIRONMENT:** [Live USB]  
**TIME:** Estimated Time: 5-10 minutes  
**NEXT:** Restart Count: 0

**Prerequisites Checklist:**
- [ ] Phase 1 completed successfully
- [ ] Booted into Arch Linux live USB
- [ ] Second computer available for SSH connection
- [ ] Network connection available (Ethernet or WiFi credentials)

**Success Criteria:**
- [ ] Root password set on live USB
- [ ] SSH service running
- [ ] Network connected (Ethernet or WiFi)
- [ ] IP address obtained
- [ ] SSH connection established from second computer

**Why Remote SSH Installation?**

Installing via SSH from a second computer provides:
- **SUCCESS:** Ability to copy-paste commands from this guide (zero typing errors)
- **SUCCESS:** Reference documentation on second screen while installing
- **SUCCESS:** More comfortable than working on laptop keyboard
- **SUCCESS:** Ability to save command history for future reference

### Step 2.1: Set Root Password on Live USB

On the **Arch Linux live environment** (target system console):

```bash
# Set temporary root password for SSH access
passwd

# Enter new password: (choose temporary password, e.g., "install123")
# Retype new password: (confirm)
```

**Note:** This password is **temporary** and only for SSH access during installation.

### Step 2.2: Start SSH Server

```bash
# Start SSH daemon
systemctl start sshd

# Verify SSH is running
systemctl status sshd

# Should show: "active (running)" in green
# Press 'q' to exit status view
```

### Step 2.3: Connect to Network

**For Ethernet:**
```bash
# Ethernet should work automatically
# Verify connection:
ping -c 3 archlinux.org
```

**For WiFi (AMD RZ608 WiFi 6):**
```bash
# Launch iwctl (interactive WiFi tool)
iwctl

# You are now in iwctl prompt: [iwd]#
```

**Inside iwctl prompt, execute:**
```bash
# List WiFi devices
device list
# Should show: wlan0 (AMD RZ608 WiFi 6 adapter)

# Scan for networks
station wlan0 scan

# Wait 3 seconds for scan to complete

# List available networks
station wlan0 get-networks
# Shows list of SSIDs with signal strength

# Connect to your network (replace "YourSSID" with your actual WiFi name)
station wlan0 connect "YourSSID"

# Enter passphrase: (type your WiFi password)

# Exit iwctl
exit
```

**Note:** AMD RZ608 WiFi 6 adapter uses the `mt7921e` kernel module (MediaTek chipset). The driver is included in `linux-firmware` package, which is installed in Phase 6.

**Verify internet connection:**
```bash
# Test internet connectivity
ping -c 3 archlinux.org

# Should show successful replies:
# 64 bytes from archlinux.org (95.217.163.246): icmp_seq=1 ttl=54 time=12.3 ms
# If timeout, troubleshoot network connection before continuing
```

### Step 2.4: Find IP Address

```bash
# Get IP address assigned to network interface
ip -brief addr show

# Example output:
# wlan0   UP   192.168.1.100/24
# or
# eth0    UP   192.168.1.100/24

# Note the IP address (e.g., 192.168.1.100)
```

### Step 2.5: Connect from Second Computer

On your **second computer** (the one you'll use for installation):

**Linux/macOS:**
```bash
# SSH into the target system
ssh root@192.168.1.100

# Replace 192.168.1.100 with actual IP from previous step
```

**Windows (PowerShell or Windows Terminal):**
```powershell
# SSH into the target system
ssh root@192.168.1.100
```

**First connection warning:**
```
The authenticity of host '192.168.1.100' can't be established.
ED25519 key fingerprint is SHA256:XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
```

Type `yes` and press Enter.

**Enter password:** (the temporary password you set earlier)

**You should now see:**
```
root@archiso ~ #
```

**SUCCESS:** You are now connected via SSH and ready to install

**All remaining commands will be executed on your second computer via SSH.**

**SUCCESS:** Phase 2 Complete: SSH connection established

**Verification:**
- [x] SSH service running (`systemctl status sshd` shows "active (running)")
- [x] Network connected (`ping -c 3 archlinux.org` succeeds)
- [x] IP address known (`ip -brief addr show` shows assigned IP)
- [x] SSH connection working (can execute commands from second computer)

**NEXT:** Next: Partition the disk (Phase 3)

**Troubleshooting:**
- **If SSH connection fails:** Verify IP address, check firewall on second computer, ensure SSH service is running
- **If WiFi doesn't connect:** Verify SSID and password, check if `mt7921e` driver is loaded (`lsmod | grep mt7921e`)
- **If network ping fails:** Check cable (Ethernet) or WiFi credentials, verify router is working

---

## Phase 3: Disk Partitioning

**ENVIRONMENT:** [Live USB]  
**TIME:** Estimated Time: 5-10 minutes  
**NEXT:** Restart Count: 0

**WARNING:** CRITICAL WARNING: Double-check every command before pressing Enter

**Prerequisites Checklist:**
- [ ] Phase 1 completed (booted into live USB)
- [ ] Windows 11 already installed (verified in Step 3.1)
- [ ] Disk device identified (`/dev/nvme0n1` for GIGABYTE Brix 5300)
- [ ] Free space available (~250 GB for Arch Linux)

**Success Criteria:**
- [ ] Windows 11 partitions verified (p1, p2, p3 exist)
- [ ] Root partition created (`/dev/nvme0n1p4`, 225 GB)
- [ ] Swap partition created (`/dev/nvme0n1p5`, 8 GB)
- [ ] Partition table written successfully
- [ ] Partitions verified with `lsblk`

### Step 3.1: Verify Existing Windows 11 Partitions

```bash
# List all block devices and partitions
lsblk

# Expected output for GIGABYTE Brix 5300 (M.2 NVMe SSD):
# NAME        MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
# nvme0n1     259:0    0 500.0G  0 disk
# ├─nvme0n1p1 259:1    0   512M  0 part  (EFI System - Windows 11)
# ├─nvme0n1p2 259:2    0 250.0G  0 part  (Windows 11 system partition)
# ├─nvme0n1p3 259:3    0   500M  0 part  (Windows Recovery)
# └─(free space ~250 GB - not shown yet)

# Verify:
# - Three partitions exist (p1, p2, p3)
# - Total used space: ~250-300 GB (Windows 11)
# - Free space: ~200-250 GB remaining (for Arch Linux)
```

**Note your disk device name** (typically `/dev/nvme0n1` for M.2 NVMe SSD on GIGABYTE Brix 5300)

**If Windows 11 partitions are missing, DO NOT PROCEED** - install Windows 11 first.

### Step 3.2: Launch cfdisk Partition Editor

```bash
# Open cfdisk for your disk
# For GIGABYTE Brix 5300: Use /dev/nvme0n1 (M.2 NVMe SSD)
cfdisk /dev/nvme0n1

# Partition table type should be: gpt
# If asked "Select label type", choose: gpt
```

**cfdisk Text UI appears with partition table**

### Step 3.3: Navigate cfdisk Interface

**cfdisk Keyboard Controls:**
- **↑ ↓ Arrow Keys**: Select partition
- **← → Arrow Keys**: Select menu option (New, Delete, Type, Write, Quit)
- **Enter**: Execute selected menu option
- **Esc**: Cancel current operation

**Current partition list should show:**
```
Device          Start        End    Sectors  Size Type
/dev/nvme0n1p1   2048    1050623    1048576  512M EFI System
/dev/nvme0n1p2   ...         ...        ... 250.0G Microsoft basic data
/dev/nvme0n1p3   ...         ...        ...  500M Microsoft reserved
Free space       ...         ...        ...  ~250G
```

**WARNING:** DO NOT modify existing Windows 11 partitions (p1, p2, p3). Only create new partitions in the free space.

### Step 3.4: Skip EFI System Partition (Already Exists)

**The EFI System Partition (p1) was already created by Windows 11. We will use it for GRUB bootloader.**

**No action needed** - proceed to Step 3.5.

### Step 3.5: Create Linux Root Partition

1. **Use arrow keys** to navigate to remaining **Free space** row (after Windows partitions)
2. **Press Enter** on **[ New ]** menu option
3. **Partition size**: Type `225G` (225 GB for 500 GB disk) and press **Enter**
   - **For SAMSUNG 970 EVO Plus 500GB:** Use `225G` (45% of disk)
   - **Alternative percentage method**: Type `45%` if cfdisk supports percentage input
4. Partition type will default to **Linux filesystem** (correct, do not change)

**New partition created: /dev/nvme0n1p4 (225 GB, Linux filesystem)**

**Size Calculation for 500GB Disk:**
- Total disk: 500 GB
- Windows 11: ~251 GB (50%)
- Remaining: ~249 GB
- Arch Linux root: 225 GB (45% of total, ~90% of remaining)
- Swap: 8 GB (1.6% of total)
- Unallocated: ~15 GB (3% of total)

### Step 3.6: Create Linux Swap Partition

1. **Use arrow keys** to navigate to remaining **Free space** row
2. **Press Enter** on **[ New ]** menu option
3. **Partition size**: Type `8G` (8 GB) and press **Enter**
   - **For 64 GB RAM (GIGABYTE Brix 5300):** Use `8G` (8 GB swap)
   - **Swap size rationale for 64 GB RAM:**
     - With 64 GB RAM, swap is rarely used during normal operation
     - 8 GB swap is sufficient for emergency overflow
     - **For hibernation (suspend-to-disk):** Requires swap ≥ RAM size (64 GB)
     - If hibernation is needed, increase swap to 64 GB or disable hibernation
   - **Minimum**: 2 GB
   - **Recommended for 64 GB RAM**: 8 GB (sufficient for normal use)
4. **Navigate to the newly created partition**
5. **Press Enter** on **[ Type ]** menu option
6. **Scroll down** to find **Linux swap** (type code 19 or 82)
7. **Press Enter** to select Linux swap

**New partition created: /dev/nvme0n1p5 (8 GB, Linux swap)**

**Swap Size for GIGABYTE Brix 5300 (64 GB RAM):**
- **64 GB RAM (Kingston FURY Impact 2×32GB):** 8 GB swap
- **Rationale:**
  - With 64 GB RAM, swap is rarely used during normal operation
  - 8 GB provides emergency overflow capacity
  - **Hibernation note:** If hibernation (suspend-to-disk) is required, swap must be ≥ 64 GB
  - For most use cases, 8 GB swap is sufficient with 64 GB RAM

### Step 3.7: Verify Final Partition Layout

**Your partition table should now look like this (SAMSUNG 970 EVO Plus 500GB):**

```
Device          Start        End    Sectors  Size Type
/dev/nvme0n1p1   2048    1050623    1048576  512M EFI System (Windows 11 - shared)
/dev/nvme0n1p2   ...         ...        ... 250.0G Microsoft basic data (Windows 11)
/dev/nvme0n1p3   ...         ...        ...  1.0G Microsoft reserved (Windows Recovery)
/dev/nvme0n1p4   ...         ...        ... 225.0G Linux filesystem (NEW - Arch Linux)
/dev/nvme0n1p5   ...         ...        ...  8.0G Linux swap (NEW)
```

**SUCCESS:** Verify:
- Total partitions: **5**
- nvme0n1p1: **512 MB EFI System** (Windows 11 - shared with GRUB)
- nvme0n1p2: **250.0 GB Microsoft basic data** (Windows 11 system partition)
- nvme0n1p3: **1.0 GB Microsoft reserved** (Windows Recovery Environment)
- nvme0n1p4: **225.0 GB Linux filesystem** (NEW - Arch Linux root, encrypted)
- nvme0n1p5: **8.0 GB Linux swap** (NEW - encrypted swap)

**Total Disk Usage Summary:**
- **Windows 11 partitions:** ~251.5 GB (50.3%)
- **Arch Linux partitions:** ~233 GB (46.6%)
- **Unallocated space:** ~15.5 GB (3.1%)
- **Total used:** ~485 GB (97%)

**If anything is wrong, DO NOT WRITE. Press 'q' to quit without saving and start over.**

### Step 3.8: Write Changes to Disk

**WARNING:** FINAL WARNING: This step is IRREVERSIBLE

1. **Navigate to** **[ Write ]** menu option
2. **Press Enter**
3. **Confirmation prompt**: `Are you sure you want to write the partition table to disk? (yes or no):`
4. **Type exactly**: `yes` (lowercase, no quotes)
5. **Press Enter**
6. **Should show**: `The partition table has been altered.`
7. **Navigate to** **[ Quit ]** menu option
8. **Press Enter** to exit cfdisk

### Step 3.9: Verify Partition Table Was Written

```bash
# Force kernel to re-read partition table
# For GIGABYTE Brix 5300: Use /dev/nvme0n1
partprobe /dev/nvme0n1

# List partitions again
lsblk -f

# Should now show:
# sdX
# ├─sdX1  vfat   FAT32  (EFI System)
# ├─sdX2          (Linux root - empty, will be encrypted)
# └─sdX3          (Linux swap - empty, will be encrypted)
```

**SUCCESS:** Phase 3 Complete: Disk partitioned successfully

**Verification:**
- [x] All 5 partitions exist (p1=EFI, p2=Windows, p3=Recovery, p4=Root, p5=Swap)
- [x] Partition sizes correct (p4=225 GB, p5=8 GB)
- [x] Partition table written (`partprobe` executed)
- [x] Partitions visible in `lsblk`

**NEXT:** Next: Encrypt Linux partitions with LUKS2 (Phase 4)

**Troubleshooting:**
- **If partition creation fails:** Verify free space exists, check disk is not mounted, ensure Windows partitions are not modified
- **If "target is busy" error:** Unmount any mounted partitions, close any programs accessing the disk
- **If partition sizes incorrect:** Recalculate based on actual disk size, verify Windows partition sizes first

---

## Phase 4: LUKS2 Encryption Setup

**ENVIRONMENT:** [Live USB]  
**TIME:** Estimated Time: 10-15 minutes  
**NEXT:** Restart Count: 0

**Prerequisites Checklist:**
- [ ] Phase 3 completed successfully
- [ ] Root partition exists (`/dev/nvme0n1p4`)
- [ ] Swap partition exists (`/dev/nvme0n1p5`)
- [ ] Strong passphrase prepared (20+ characters recommended)

**Success Criteria:**
- [ ] Root partition encrypted with LUKS2
- [ ] Swap partition encrypted with LUKS2
- [ ] Both partitions unlocked and mapped (`cryptroot`, `cryptswap`)
- [ ] Encryption verified (`cryptsetup luksDump` shows correct configuration)

### 4.1 Theoretical Foundation of Disk Encryption

#### 4.1.1 Introduction to LUKS

The Linux Unified Key Setup (LUKS) specification, first introduced in 2005, establishes a standardized format for encrypted disk partitions on Linux systems [1]. LUKS addresses the fundamental challenge of transparent disk encryption: providing strong cryptographic protection while maintaining compatibility across different Linux distributions and tools.

The LUKS specification defines a header structure that contains all necessary metadata for encryption, including cipher specifications, key derivation parameters, and key slot information. This header-based approach enables interoperability—a LUKS-encrypted partition created on one distribution can be decrypted on another, provided the necessary tools are available.

#### 4.1.2 LUKS2 Architecture and Design Principles

LUKS2, introduced in 2016 as part of cryptsetup 2.0.0, represents a significant evolution from LUKS1. The design addresses several limitations of the original specification while maintaining backward compatibility where possible.

**Key Architectural Improvements:**

1. **Multiple Key Slots**: LUKS2 supports up to 32 key slots (compared to 8 in LUKS1), enabling more flexible key management strategies. Each key slot can contain either a passphrase-derived key or a keyfile-derived key, allowing for multiple authentication methods on a single encrypted volume.

2. **Modern Key Derivation Functions**: LUKS2 adopts Argon2id as the default Password-Based Key Derivation Function (PBKDF), replacing the PBKDF2 algorithm used in LUKS1. Argon2, the winner of the Password Hashing Competition (2015), provides superior resistance to both time-memory trade-off attacks and side-channel attacks [2].

3. **Metadata Integrity Protection**: LUKS2 includes integrity protection for metadata structures, preventing tampering with encryption headers. This is achieved through cryptographic checksums embedded in the header structure.

4. **Per-Segment Encryption**: LUKS2 supports segment-based encryption, allowing different encryption parameters for different regions of the disk. This enables optimization for specific use cases, such as using different ciphers for different data types.

5. **Active Development**: LUKS2 is actively maintained and receives new features, while LUKS1 is in maintenance mode with only security updates.

#### 4.1.3 Cryptographic Primitives and Algorithm Selection

**AES-XTS-PLAIN64 Cipher Mode:**

The Advanced Encryption Standard (AES) in XTS (XEX-based Tweaked CodeBook mode with Ciphertext Stealing) mode represents the current best practice for disk encryption [3]. The selection of this specific cipher mode is based on several critical factors:

**XTS Mode Characteristics:**
- **Random Access Optimization**: Unlike block cipher modes designed for sequential data (such as CBC), XTS is specifically optimized for random access patterns typical in filesystem operations. Each disk sector can be encrypted and decrypted independently without requiring access to previous sectors.

- **Tweakable Encryption**: XTS uses a "tweak" value derived from the sector number, ensuring that identical plaintext blocks at different sector positions produce different ciphertext. This prevents pattern analysis attacks that could reveal information about disk contents.

- **Performance**: XTS mode is highly parallelizable and benefits significantly from hardware acceleration (AES-NI instructions available in modern CPUs). The mode's design allows for efficient implementation in both software and hardware.

**Key Size Selection (512-bit):**

The 512-bit key size in XTS mode actually consists of two independent 256-bit AES keys. This configuration provides:
- **Maximum Security**: 256-bit keys provide security equivalent to 2^256 operations, which is computationally infeasible to brute-force with current and foreseeable technology.
- **Hardware Compatibility**: 256-bit keys are fully supported by AES-NI instructions in modern Intel and AMD processors, ensuring optimal performance.
- **Standard Compliance**: The 512-bit XTS configuration aligns with NIST recommendations for disk encryption [4].

**PLAIN64 Sector Addressing:**

The "PLAIN64" designation refers to 64-bit sector addressing, which enables encryption of disks larger than 2TB. This is essential for modern storage devices, including NVMe SSDs.

#### 4.1.4 Key Derivation: Argon2id Analysis

**Password-Based Key Derivation Function (PBKDF) Requirements:**

The transformation of a human-memorizable passphrase into a cryptographic key suitable for encryption requires a key derivation function that addresses several security challenges:

1. **Dictionary Attack Resistance**: Simple passphrases must be protected against brute-force attacks using common password dictionaries.
2. **Time-Memory Trade-off Resistance**: The function should resist attacks that precompute hashes (rainbow tables).
3. **Parallelization Resistance**: The function should be difficult to parallelize, preventing GPU-based attacks.
4. **Side-Channel Attack Resistance**: The function should not leak information through timing or power consumption patterns.

**Argon2id Algorithm:**

Argon2id, the hybrid variant of the Argon2 family, combines the security properties of Argon2i (resistant to side-channel attacks) and Argon2d (resistant to GPU attacks) [2]. The algorithm's design includes:

- **Memory-Hard Function**: Argon2id requires a configurable amount of memory (typically 64MB-1GB) during computation, making GPU-based attacks impractical due to memory limitations of graphics processors.

- **Time Cost Parameter**: The algorithm includes a time cost parameter that determines the number of iterations, allowing adjustment of the computational cost to balance security and usability.

- **Adaptive Security**: The memory and time parameters can be adjusted based on threat model and hardware capabilities, providing flexibility for different deployment scenarios.

**Iteration Time Selection (5000ms):**

The `--iter-time 5000` parameter specifies that key derivation should take approximately 5 seconds. This duration represents a balance between:
- **Security**: Longer derivation times increase resistance to brute-force attacks.
- **Usability**: Excessive derivation times (beyond 10-15 seconds) become impractical for regular use.
- **Hardware Considerations**: The actual time depends on CPU performance; 5 seconds provides adequate security on modern hardware while remaining acceptable for user experience.

**References:**
[1] Fruhwirth, C. (2005). "New Methods in Hard Disk Encryption." Vienna University of Technology.  
[2] Biryukov, A., Dinu, D., & Khovratovich, D. (2015). "Argon2: the memory-hard function for password hashing and other applications." Password Hashing Competition.  
[3] IEEE Computer Society. (2007). "IEEE Standard for Cryptographic Protection of Data on Block-Oriented Storage Devices." IEEE Std 1619-2007.  
[4] National Institute of Standards and Technology. (2012). "Recommendation for Block Cipher Modes of Operation: Methods for Key Wrapping." NIST Special Publication 800-38F.

---

### Step 4.1: Encrypt Root Partition

**WARNING:** You will create a LUKS passphrase - choose a STRONG passphrase (minimum 20 characters recommended)

```bash
# Create LUKS2 encrypted container on root partition
# For GIGABYTE Brix 5300: Use /dev/nvme0n1p4 (root partition created in Phase 3)
cryptsetup luksFormat --type luks2 \
  --cipher aes-xts-plain64 \
  --key-size 512 \
  --pbkdf argon2id \
  --iter-time 5000 \
  /dev/nvme0n1p4
```

**Prompt 1: Confirmation**
```
WARNING!
========
This will overwrite data on /dev/nvme0n1p4 irrevocably.

Are you sure? (Type 'yes' in capital letters):
```

**Type exactly:** `YES` (uppercase) and press **Enter**

**Prompt 2: Passphrase**
```
Enter passphrase for /dev/nvme0n1p4:
```

**Enter a STRONG passphrase** (e.g., minimum 20 characters, mix of letters/numbers/symbols)

**Example:** `MySecureL1nux!Passphrase2025`

**WARNING:** CRITICAL: Memorize this passphrase or store in password manager - if lost, data is UNRECOVERABLE

**Prompt 3: Verify passphrase**
```
Verify passphrase:
```

**Re-type the EXACT SAME passphrase** and press **Enter**

**Wait for completion** (30-60 seconds - shows progress bar)

**Should show:** `Command successful.`

**If error occurs:**
- **"Device already in use":** Close any existing mappings (`cryptsetup close cryptroot`), verify partition is not mounted
- **"Operation not permitted":** Verify you have root privileges, check partition is not in use
- **"No space left on device":** Check available space (`df -h`), verify partition size is correct

### Step 4.2: Open Encrypted Root Partition

```bash
# Unlock LUKS container and map to /dev/mapper/cryptroot
# For GIGABYTE Brix 5300: Use /dev/nvme0n1p4 (root partition)
cryptsetup open /dev/nvme0n1p4 cryptroot
```

**Prompt:**
```
Enter passphrase for /dev/nvme0n1p4:
```

**Enter the passphrase** you just created and press **Enter**

**Should show:** (no output = success)

**If error occurs:**
- **"No key available":** Verify passphrase is correct, check for typos, verify keyboard layout
- **"Device already in use":** Close any existing mappings, verify partition is not mounted elsewhere
- **"Operation not permitted":** Verify root privileges, check partition permissions

### Step 4.3: Verify Encrypted Root Volume

```bash
# Check that cryptroot is available
ls -la /dev/mapper/

# Should show:
# total 0
# crw------- 1 root root 10, 236 Dec  1 15:00 control
# lrwxrwxrwx 1 root root       7 Dec  1 15:01 cryptroot -> ../dm-0
```

**SUCCESS:** cryptroot is now unlocked and ready

### Step 4.4: Encrypt Swap Partition

```bash
# Create LUKS2 encrypted container on swap partition
# For GIGABYTE Brix 5300: Use /dev/nvme0n1p5 (swap partition created in Phase 3)
cryptsetup luksFormat --type luks2 \
  --cipher aes-xts-plain64 \
  --key-size 512 \
  --pbkdf argon2id \
  --iter-time 5000 \
  /dev/nvme0n1p5
```

**Prompt 1: Confirmation**
```
Are you sure? (Type 'yes' in capital letters):
```

**Type:** `YES` and press **Enter**

**Prompt 2 & 3: Passphrase**

**WARNING:** IMPORTANT: Use the SAME passphrase as root partition** (for simplicity during boot)

**Enter the SAME passphrase** twice.

**Wait for completion** (30-60 seconds)

**If error occurs:**
- **"Device already in use":** Close any existing mappings, verify swap partition is not in use
- **"Operation not permitted":** Verify root privileges, check partition permissions
- **"No key available":** Verify passphrase is correct, check for typos

### Step 4.5: Open Encrypted Swap Partition

```bash
# Unlock swap container and map to /dev/mapper/cryptswap
# For GIGABYTE Brix 5300: Use /dev/nvme0n1p5 (swap partition)
cryptsetup open /dev/nvme0n1p5 cryptswap
```

**Enter the SAME passphrase** as before.

**If error occurs:**
- **"No key available":** Verify passphrase matches root partition passphrase, check for typos
- **"Device already in use":** Close any existing mappings, verify swap is not already unlocked

### Step 4.6: Verify Both Encrypted Volumes

```bash
# List all mapped devices
ls -la /dev/mapper/

# Should show:
# control
# cryptroot -> ../dm-0
# cryptswap -> ../dm-1
```

**SUCCESS:** Both partitions are now encrypted and unlocked

### Step 4.7: Verify Encryption Details

```bash
# Display LUKS header information for root partition
# For GIGABYTE Brix 5300: Use /dev/nvme0n1p4 (root partition)
cryptsetup luksDump /dev/nvme0n1p4 | head -20

# Should show:
# LUKS header information for /dev/nvme0n1p4
# Version:        2
# Cipher name:    aes
# Cipher mode:    xts-plain64
# Hash spec:      sha512
# Key Slot 0: ENABLED
```

**SUCCESS:** Phase 4 Complete: Both Linux partitions encrypted with LUKS2

**Verification:**
- [x] Root partition encrypted (`cryptsetup luksDump /dev/nvme0n1p4` shows LUKS2 header)
- [x] Swap partition encrypted (`cryptsetup luksDump /dev/nvme0n1p5` shows LUKS2 header)
- [x] Both volumes unlocked (`ls -la /dev/mapper/` shows `cryptroot` and `cryptswap`)
- [x] Passphrase works (can unlock both volumes)

**NEXT:** Next: Create Btrfs filesystem with subvolumes (Phase 5)

**Troubleshooting:**
- **If "device already in use" error:** Close any existing mappings (`cryptsetup close cryptroot`), verify partition is not mounted
- **If passphrase rejected:** Verify passphrase is correct, check keyboard layout (especially for special characters)
- **If encryption takes too long:** Normal for large partitions (30-60 seconds), wait for completion

---

## Phase 5: Btrfs Filesystem Creation

**ENVIRONMENT:** [Live USB]  
**TIME:** Estimated Time: 5-10 minutes  
**NEXT:** Restart Count: 0

**Prerequisites Checklist:**
- [ ] Phase 4 completed successfully
- [ ] Root partition encrypted and unlocked (`cryptroot` mapped)
- [ ] Swap partition encrypted and unlocked (`cryptswap` mapped)
- [ ] `btrfs-progs` package available (included in live USB)

**Success Criteria:**
- [ ] Btrfs filesystem created on `cryptroot`
- [ ] All 5 subvolumes created (@, @home, @log, @cache, @snapshots)
- [ ] All subvolumes mounted correctly
- [ ] EFI partition mounted
- [ ] Swap enabled and active

### 5.1 Theoretical Foundation of Copy-on-Write Filesystems

#### 5.1.1 Introduction to Btrfs

Btrfs (B-tree filesystem) is a modern copy-on-write (CoW) filesystem developed for Linux, first merged into the mainline kernel in 2009. The filesystem was designed to address fundamental limitations of traditional filesystems (ext4, XFS) while providing advanced features such as built-in snapshots, checksums, and compression [5].

The B-tree data structure, from which Btrfs derives its name, provides efficient indexing and enables the filesystem to scale to very large sizes (up to 16 exbibytes) while maintaining consistent performance characteristics. Btrfs represents a paradigm shift from traditional in-place modification filesystems to a copy-on-write architecture that fundamentally changes how data integrity and system recovery are achieved.

#### 5.1.2 Copy-on-Write Architecture: Principles and Implementation

**Traditional In-Place Modification:**

Conventional filesystems (ext4, XFS) employ in-place modification: when a file is updated, the filesystem directly overwrites the existing data blocks. This approach has several critical limitations:

1. **Atomicity Challenges**: If a write operation is interrupted (power loss, system crash), the filesystem may be left in an inconsistent state, requiring filesystem check (fsck) operations that can take significant time on large filesystems.

2. **Snapshot Complexity**: Creating snapshots requires copying all data blocks, which is both time-consuming and space-intensive. This limitation typically requires external tools (LVM snapshots) that add complexity and overhead.

3. **Data Integrity**: Without checksums, silent data corruption (bit rot) can occur undetected, potentially leading to data loss.

**Copy-on-Write Mechanism:**

Btrfs implements a copy-on-write architecture where modifications are never performed in-place. Instead:

1. **New Block Allocation**: When a file is modified, Btrfs allocates new blocks for the changed data rather than overwriting existing blocks.

2. **Pointer Updates**: After successful write, Btrfs updates metadata pointers to reference the new blocks.

3. **Old Data Preservation**: The original data blocks remain intact until they are no longer referenced (either by the current filesystem state or by snapshots).

This mechanism ensures that the filesystem can always revert to a previous consistent state, as the original blocks remain available until explicitly freed.

#### 5.1.3 Snapshot Mechanism and Space Efficiency

**Snapshot Creation:**

Btrfs snapshots are implemented through reference counting and shared block allocation. When a snapshot is created:

1. **Instant Creation**: The snapshot creation is effectively instantaneous (typically < 1 second) regardless of filesystem size, as it only involves creating new metadata structures that reference existing data blocks.

2. **Shared Blocks**: The snapshot and the original filesystem share all data blocks initially. Only when a block is modified in either the original or the snapshot does Btrfs allocate a new block (copy-on-write).

3. **Space Efficiency**: The space overhead of a snapshot is proportional to the amount of data that differs between the snapshot and the current state, not the total filesystem size.

**References:**
[5] Rodeh, O., Bacik, J., & Mason, C. (2013). "BTRFS: The Linux B-Tree Filesystem." ACM Transactions on Storage, 9(3), 9:1-9:32.  
[6] Collet, Y., & Kucherawy, M. (2016). "Zstandard Compression and the 'application/zstd' Media Type." RFC 8878.

---

### Step 5.1: Format Root Partition with Btrfs

```bash
# Create Btrfs filesystem on encrypted root
mkfs.btrfs -L "Arch Linux" /dev/mapper/cryptroot

# -L "Arch Linux" = Human-readable label
```

**Output:**
```
btrfs-progs v6.x.x
Label:              Arch Linux
UUID:               XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
Node size:          16384
Sector size:        4096
...
```

**Completion time:** 5-10 seconds

**If error occurs:**
- **"No such file or directory":** Verify `cryptroot` is mapped (`ls /dev/mapper/`), unlock partition if needed
- **"Device or resource busy":** Verify partition is not already mounted, check with `mount`
- **"Invalid argument":** Verify device mapping exists, check Btrfs filesystem was created successfully

### Step 5.2: Mount Btrfs Root Temporarily

```bash
# Mount encrypted Btrfs partition to /mnt
mount /dev/mapper/cryptroot /mnt
```

### Step 5.3: Create Btrfs Subvolumes

**WARNING:** Subvolume names MUST match exactly (@ symbol is critical)

```bash
# Create @ subvolume (root filesystem)
btrfs subvolume create /mnt/@

# Create @home subvolume (user home directories)
btrfs subvolume create /mnt/@home

# Create @log subvolume (system logs)
btrfs subvolume create /mnt/@log

# Create @cache subvolume (package cache)
btrfs subvolume create /mnt/@cache

# Create @snapshots subvolume (snapshot storage)
btrfs subvolume create /mnt/@snapshots
```

**Each command should output:**
```
Create subvolume '/mnt/@'
Create subvolume '/mnt/@home'
...
```

**If error occurs:**
- **"No such file or directory":** Verify Btrfs filesystem is mounted at `/mnt`, check mount point exists
- **"File exists":** Subvolume may already exist, verify with `btrfs subvolume list /mnt`
- **"Operation not permitted":** Verify root privileges, check filesystem permissions

### Step 5.4: Verify Subvolumes Were Created

```bash
# List all Btrfs subvolumes
btrfs subvolume list /mnt

# Should show:
# ID 256 gen X top level 5 path @
# ID 257 gen X top level 5 path @home
# ID 258 gen X top level 5 path @log
# ID 259 gen X top level 5 path @cache
# ID 260 gen X top level 5 path @snapshots
```

**SUCCESS:** All 5 subvolumes created successfully

### Step 5.5: Unmount and Remount with Subvolumes

```bash
# Unmount root
umount /mnt

# Mount @ subvolume as root with compression
mount -o subvol=@,compress=zstd,noatime /dev/mapper/cryptroot /mnt
```

**Mount options explained:**
- `subvol=@` - Mount specific Btrfs subvolume
- `compress=zstd` - Enable Zstandard compression (transparent, fast, ~20-30% space savings)
- `noatime` - Don't update file access time (improves performance, reduces SSD wear)

### Step 5.6: Create Mount Point Directories

```bash
# Create directories for mount points
mkdir -p /mnt/{home,var/log,var/cache,boot,.snapshots}
```

### Step 5.7: Mount All Btrfs Subvolumes

```bash
# Mount @home subvolume
mount -o subvol=@home,compress=zstd,noatime /dev/mapper/cryptroot /mnt/home

# Mount @log subvolume
mount -o subvol=@log,compress=zstd,noatime /dev/mapper/cryptroot /mnt/var/log

# Mount @cache subvolume
mount -o subvol=@cache,compress=zstd,noatime /dev/mapper/cryptroot /mnt/var/cache

# Mount @snapshots subvolume
mount -o subvol=@snapshots,compress=zstd,noatime /dev/mapper/cryptroot /mnt/.snapshots
```

### Step 5.8: Mount EFI Boot Partition

```bash
# Mount EFI partition
# For GIGABYTE Brix 5300: Use /dev/nvme0n1p1 (EFI System Partition)
mount /dev/nvme0n1p1 /mnt/boot
```

**WARNING:** This partition is SHARED between Windows and Linux bootloaders (if dual-booting)

### Step 5.9: Format and Enable Swap

```bash
# Create swap filesystem on encrypted swap partition
mkswap /dev/mapper/cryptswap

# Output:
# Setting up swapspace version 1, size = X GiB
# no label, UUID=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX

# Enable swap
swapon /dev/mapper/cryptswap
```

### Step 5.10: Verify All Mounts

```bash
# Check complete mount hierarchy
lsblk -f

# Should show:
# sdX
# ├─sdX1
# │ vfat        FAT32                                    /mnt/boot
# ├─sdX2
# │ crypto_LUKS 2
# │ └─cryptroot
# │   btrfs           Arch Linux                         /mnt/.snapshots
# │                                                       /mnt/var/cache
# │                                                       /mnt/var/log
# │                                                       /mnt/home
# │                                                       /mnt
# └─sdX3
#   crypto_LUKS 2
#   └─cryptswap
#     swap                                                [SWAP]
```

**SUCCESS:** Verify:
- /mnt - mounted (@ subvolume)
- /mnt/home - mounted (@home subvolume)
- /mnt/var/log - mounted (@log subvolume)
- /mnt/var/cache - mounted (@cache subvolume)
- /mnt/.snapshots - mounted (@snapshots subvolume)
- /mnt/boot - mounted (EFI partition)
- SWAP - active (cryptswap)

**SUCCESS:** Phase 5 Complete: Btrfs filesystem with 5 subvolumes + swap active

**Verification:**
- [x] Btrfs filesystem created (`mkfs.btrfs` completed successfully)
- [x] All 5 subvolumes exist (`btrfs subvolume list /mnt` shows all subvolumes)
- [x] All mount points correct (`lsblk -f` shows all subvolumes mounted)
- [x] EFI partition mounted (`/mnt/boot` exists and mounted)
- [x] Swap active (`swapon --show` shows `cryptswap`)

**NEXT:** Next: Install base Arch Linux system (Phase 6)

**Troubleshooting:**
- **If subvolume creation fails:** Verify Btrfs filesystem exists, check mount point permissions
- **If mount fails:** Verify subvolume names are correct (including @ symbol), check device mapping exists
- **If swap not active:** Verify swap partition is formatted (`mkswap` executed), check `swapon` command succeeded

---

## Phase 6: Base System Installation

**ENVIRONMENT:** [Live USB]  
**TIME:** Estimated Time: 15-30 minutes (depends on internet speed)  
**NEXT:** Restart Count: 0

**Download Size: ~800 MB - 1.2 GB**

**Prerequisites Checklist:**
- [ ] Phase 5 completed successfully
- [ ] All partitions mounted correctly (`/mnt` and subvolumes)
- [ ] Internet connection active (for package downloads)
- [ ] Sufficient disk space available (~2 GB minimum)

**Success Criteria:**
- [ ] Pacman mirror list updated
- [ ] Base system packages installed
- [ ] All essential packages installed (kernel, firmware, tools)
- [ ] Installation verified (directories exist in `/mnt`)

### Step 6.1: Update Pacman Mirror List (for faster downloads)

```bash
# Backup original mirrorlist
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup

# Sort mirrors by speed using reflector
reflector --country US,Germany,France \
  --age 12 \
  --protocol https \
  --sort rate \
  --save /etc/pacman.d/mirrorlist
```

**Wait 10-20 seconds** for reflector to test mirrors.

**Verify mirrorlist:**
```bash
# Show top 5 fastest mirrors
head -10 /etc/pacman.d/mirrorlist
```

**If error occurs:**
- **"Failed to retrieve mirror list":** Check internet connection, try different reflector options, manually edit mirrorlist
- **"No mirrors found":** Verify internet connection, check reflector options, use default mirrorlist as fallback

### Step 6.2: Install Base System and Essential Packages

**WARNING:** This is a LARGE command - copy entire block carefully

```bash
pacstrap /mnt \
  base \
  base-devel \
  linux \
  linux-firmware \
  linux-headers \
  amd-ucode \
  btrfs-progs \
  dosfstools \
  e2fsprogs \
  ntfs-3g \
  exfat-utils \
  networkmanager \
  network-manager-applet \
  wireless_tools \
  wpa_supplicant \
  dialog \
  git \
  vim \
  nano \
  neovim \
  tmux \
  zsh \
  sudo \
  man-db \
  man-pages \
  grub \
  efibootmgr \
  os-prober \
  openssh
```

**Package Breakdown (for understanding):**

**Core System:**
- `base` - Minimal Arch Linux base
  - [ArchWiki Base Package](https://wiki.archlinux.org/title/Installation_guide#Installation)
- `base-devel` - Build tools (gcc, make, patch)
  - [ArchWiki Base-Devel](https://wiki.archlinux.org/title/Base-devel)
- `linux` - [Linux kernel](https://www.kernel.org/)
  - [ArchWiki Linux Kernel](https://wiki.archlinux.org/title/Kernel)
  - [Linux Kernel Documentation](https://www.kernel.org/doc/html/latest/)
- `linux-firmware` - Firmware for WiFi, Bluetooth, GPU
  - [ArchWiki Linux Firmware](https://wiki.archlinux.org/title/Linux_firmware)
- `linux-headers` - Kernel headers (for DKMS modules)
  - [ArchWiki DKMS](https://wiki.archlinux.org/title/Dynamic_Kernel_Module_Support)
- `amd-ucode` - AMD CPU microcode updates
  - [ArchWiki Microcode](https://wiki.archlinux.org/title/Microcode)
  - [AMD Microcode Updates](https://github.com/AMDESE/amd-ucode)

**Filesystem Tools:**
- `btrfs-progs` - [Btrfs](https://wiki.archlinux.org/title/Btrfs) utilities
  - [Btrfs Wiki](https://btrfs.wiki.kernel.org/)
- `dosfstools` - FAT32 tools (for EFI)
  - [ArchWiki FAT](https://wiki.archlinux.org/title/File_systems#FAT)
- `e2fsprogs` - ext2/3/4 tools
  - [ArchWiki ext4](https://wiki.archlinux.org/title/Ext4)
- `ntfs-3g` - NTFS support (Windows partition access)
  - [NTFS-3G Website](https://www.tuxera.com/community/open-source-ntfs-3g/)
  - [ArchWiki NTFS](https://wiki.archlinux.org/title/NTFS)
- `exfat-utils` - exFAT support (USB drives)
  - [ArchWiki exFAT](https://wiki.archlinux.org/title/ExFAT)

**Network:**
- `networkmanager` - [NetworkManager](https://wiki.archlinux.org/title/NetworkManager) daemon
  - [NetworkManager Website](https://networkmanager.dev/)
  - [NetworkManager Documentation](https://networkmanager.dev/docs/)
- `network-manager-applet` - NetworkManager GUI
- `wireless_tools` - WiFi tools
  - [ArchWiki Wireless Network Configuration](https://wiki.archlinux.org/title/Wireless_network_configuration)
- `wpa_supplicant` - WPA/WPA2 authentication
  - [ArchWiki WPA Supplicant](https://wiki.archlinux.org/title/Wpa_supplicant)
  - [wpa_supplicant Documentation](https://w1.fi/wpa_supplicant/)
- `dialog` - TUI dialogs (for WiFi setup)
  - [Dialog Website](https://invisible-island.net/dialog/)

**Text Editors:**
- `vim` - [Vi IMproved](https://www.vim.org/) editor
  - [ArchWiki Vim](https://wiki.archlinux.org/title/Vim)
  - [Vim Documentation](https://www.vim.org/docs.php)
- `nano` - Simple text editor
  - [Nano Website](https://www.nano-editor.org/)
  - [ArchWiki Nano](https://wiki.archlinux.org/title/GNU_nano)
- `neovim` - [Neovim](https://neovim.io/) (Modern Vim fork)
  - [Neovim GitHub](https://github.com/neovim/neovim)
  - [ArchWiki Neovim](https://wiki.archlinux.org/title/Neovim)

**Shell & Utilities:**
- `tmux` - [Tmux](https://tmux.github.io/) terminal multiplexer
  - [Tmux GitHub](https://github.com/tmux/tmux)
  - [ArchWiki Tmux](https://wiki.archlinux.org/title/Tmux)
  - [Tmux Manual](https://man.openbsd.org/tmux)
- `zsh` - [Z shell](https://www.zsh.org/) (user default shell)
  - [ArchWiki Zsh](https://wiki.archlinux.org/title/Zsh)
  - [Zsh Documentation](https://zsh.sourceforge.io/Doc/)
- `sudo` - Privilege escalation
  - [Sudo Website](https://www.sudo.ws/)
  - [ArchWiki Sudo](https://wiki.archlinux.org/title/Sudo)
  - [Sudo Manual](https://www.sudo.ws/docs/man/)
- `man-db` + `man-pages` - Manual pages
  - [ArchWiki Man Pages](https://wiki.archlinux.org/title/Man_page)

**Bootloader:**
- `grub` - [GRUB](https://www.gnu.org/software/grub/) bootloader
  - [GRUB Manual](https://www.gnu.org/software/grub/manual/)
  - [ArchWiki GRUB](https://wiki.archlinux.org/title/GRUB)
- `efibootmgr` - EFI boot entry management
  - [ArchWiki EFI Boot Entries](https://wiki.archlinux.org/title/Unified_Extensible_Firmware_Interface#efibootmgr)
- `os-prober` - Detect other operating systems (Windows, if dual-booting)
  - [ArchWiki os-prober](https://wiki.archlinux.org/title/GRUB#Detecting_other_operating_systems)

**Remote Access:**
- `openssh` - [OpenSSH](https://www.openssh.com/) server for remote administration
  - [ArchWiki OpenSSH](https://wiki.archlinux.org/title/OpenSSH)
  - [OpenSSH Manual](https://www.openssh.com/manual.html)

**Installation Progress:**

You will see:
```
:: Synchronizing package databases...
 core downloading...
 extra downloading...
 community downloading...
:: Proceeding with installation? [Y/n]
```

**Press Enter** (default is Yes)

**Download and installation takes 10-25 minutes** depending on internet speed.

**Progress indicators:**
```
downloading linux-6.x.x...
downloading systemd-xxx...
installing base...
installing linux...
...
```

**Completion message:**
```
(XXX/XXX) installing ...
```

**If error occurs:**
- **"Failed to synchronize database":** Check internet connection, update keyring (`pacman-key --refresh-keys`), verify mirrorlist
- **"Out of disk space":** Check available space (`df -h`), verify partition sizes, clean package cache
- **"Package not found":** Verify package name is correct, check repository is enabled, update package database
- **"Signature verification failed":** Update keyring (`pacman-key --refresh-keys`), verify package signatures

**SUCCESS:** Base system installation complete

### Step 6.3: Verify Installation

```bash
# Check that critical files were installed
ls /mnt/bin /mnt/etc /mnt/usr

# Should show directories with files
```

**SUCCESS:** Phase 6 Complete: Base Arch Linux system installed to /mnt

**Verification:**
- [x] Mirror list updated (`head -10 /etc/pacman.d/mirrorlist` shows mirrors)
- [x] Base packages installed (`ls /mnt/bin /mnt/etc /mnt/usr` shows directories with files)
- [x] Kernel installed (`ls /mnt/boot/vmlinuz-linux` exists)
- [x] Firmware installed (`ls /mnt/usr/lib/firmware` shows firmware files)

**NEXT:** Next: Configure system (timezone, locale, hostname) in chroot (Phase 7)

**Troubleshooting:**
- **If mirror list update fails:** Check internet connection, try different reflector options, manually edit mirrorlist
- **If package installation fails:** Check disk space (`df -h`), verify internet connection, check pacman keyring (`pacman-key --refresh-keys`)
- **If installation incomplete:** Re-run `pacstrap` command, verify all packages listed in output

---

## Phase 7: System Configuration (Chroot)

**ENVIRONMENT:** [Live USB] → [Chroot]  
**TIME:** Estimated Time: 10-15 minutes  
**NEXT:** Restart Count: 0

**What is chroot?**
- Change root into the new system
- Allows configuration as if you're booted into the installed system
- All following commands run inside the new Arch installation

**Prerequisites Checklist:**
- [ ] Phase 6 completed successfully
- [ ] Base system installed to `/mnt`
- [ ] Fstab generated (`/mnt/etc/fstab` exists)
- [ ] Timezone, locale, and hostname information ready

**Success Criteria:**
- [ ] Fstab generated correctly
- [ ] Chroot entered successfully (prompt changed)
- [ ] Timezone configured
- [ ] Locale generated and set
- [ ] Hostname configured
- [ ] Root password set
- [ ] Pacman configured (multilib enabled, parallel downloads)

### Step 7.1: Generate Fstab (Filesystem Table)

```bash
# Generate /etc/fstab based on current mounts (UUID-based)
# Note: This command appends to /mnt/etc/fstab - if file exists, it will be overwritten
genfstab -U /mnt > /mnt/etc/fstab
```

**Verify fstab was created:**
```bash
cat /mnt/etc/fstab

# Should show (UUIDs will differ):
# UUID=XXXX-XXXX  /boot  vfat  defaults  0  2
# UUID=YYYY...    /      btrfs subvol=@,compress=zstd,noatime  0  0
# UUID=YYYY...    /home  btrfs subvol=@home,compress=zstd,noatime  0  0
# UUID=YYYY...    /var/log  btrfs subvol=@log,compress=zstd,noatime  0  0
# UUID=YYYY...    /var/cache  btrfs subvol=@cache,compress=zstd,noatime  0  0
# UUID=YYYY...    /.snapshots  btrfs subvol=@snapshots,compress=zstd,noatime  0  0
# UUID=ZZZZ...    none   swap  defaults  0  0
```

**SUCCESS:** Fstab generated successfully

### Step 7.2: Chroot into New System

```bash
# Change root into the new Arch installation
arch-chroot /mnt
```

**Prompt changes to:**
```
[root@archiso /]#
```

**SUCCESS:** You are now INSIDE the new Arch system

**WARNING:** ALL REMAINING COMMANDS RUN INSIDE CHROOT (until we exit later)

**If error occurs:**
- **"chroot: failed to run command":** Verify all partitions are mounted, check `/mnt` contains system files
- **"No such file or directory":** Verify base system is installed, check mount points are correct
- **Prompt doesn't change:** Verify chroot command succeeded, check for error messages

### Step 7.3: Set Timezone

```bash
# Set timezone (replace <TIMEZONE> with your timezone)
# Examples:
#   Europe/London
#   America/New_York
#   Asia/Tokyo
#   Europe/Prague
#   America/Los_Angeles
ln -sf /usr/share/zoneinfo/<TIMEZONE> /etc/localtime

# Example: For Prague, Czech Republic:
# ln -sf /usr/share/zoneinfo/Europe/Prague /etc/localtime

# Generate /etc/adjtime
hwclock --systohc
```

**Verify timezone:**
```bash
timedatectl status

# Should show:
# Time zone: Europe/London (GMT, +0000)
```

### Step 7.4: Set Locale (Language and Character Encoding)

```bash
# Uncomment en_US.UTF-8 in locale.gen
sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen

# Generate locales
locale-gen

# Should show:
# Generating locales...
#   en_US.UTF-8... done
# Generation complete.
```

**Set system locale:**
```bash
# Create locale.conf
echo "LANG=en_US.UTF-8" > /etc/locale.conf
```

**Verify locale:**
```bash
cat /etc/locale.conf

# Should show:
# LANG=en_US.UTF-8
```

### Step 7.5: Set Hostname

```bash
# Set hostname (replace <HOSTNAME> with your desired hostname)
echo "<HOSTNAME>" > /etc/hostname

# Example: To set hostname "gigabyte-brix":
# echo "gigabyte-brix" > /etc/hostname
```

**Configure hosts file:**
```bash
# Create /etc/hosts
# Replace <HOSTNAME> with your actual hostname
cat > /etc/hosts << EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   <HOSTNAME>.localdomain <HOSTNAME>
EOF

# Example: If hostname is "gigabyte-brix":
# 127.0.1.1   gigabyte-brix.localdomain gigabyte-brix
```

**Verify hosts file:**
```bash
cat /etc/hosts

# Should show (with your actual hostname):
# 127.0.0.1   localhost
# ::1         localhost
# 127.0.1.1   <HOSTNAME>.localdomain <HOSTNAME>
```

### Step 7.6: Set Root Password

```bash
# Set root password
passwd
```

**Prompt:**
```
New password:
```

**Enter strong root password** (this is for system recovery, not daily use)

**Retype password** to confirm.

**SUCCESS:** Root password set

### Step 7.7: Configure Pacman (Enable Multilib and Parallel Downloads)

```bash
# Edit /etc/pacman.conf
nano /etc/pacman.conf
```

**Find and uncomment these lines:**

```ini
# Misc options
#UseSyslog
Color
#NoProgressBar
#CheckSpace
#VerbosePkgLists
ParallelDownloads = 5

# Enable multilib repository (for 32-bit support)
[multilib]
Include = /etc/pacman.d/mirrorlist
```

**Changes to make:**
1. Uncomment `Color` (already shown above)
2. Uncomment `ParallelDownloads = 5`
3. Uncomment `[multilib]` section (both lines)

**Save and exit** (Ctrl+O, Enter, Ctrl+X)

**Update package database:**
```bash
pacman -Sy
```

**SUCCESS:** Phase 7 Complete: System configured (timezone, locale, hostname, root password)

**Verification:**
- [x] Fstab generated (`cat /etc/fstab` shows all mount points)
- [x] Timezone set (`timedatectl status` shows correct timezone)
- [x] Locale generated (`locale` shows `en_US.UTF-8`)
- [x] Hostname set (`cat /etc/hostname` shows hostname)
- [x] Root password set (can verify with `passwd` command)
- [x] Pacman configured (`grep -E "Color|ParallelDownloads|multilib" /etc/pacman.conf` shows enabled)

**NEXT:** Next: Install and configure GRUB bootloader (Phase 8)

**Troubleshooting:**
- **If chroot fails:** Verify all partitions are mounted, check `/mnt` contains system files
- **If timezone not set:** Verify timezone name is correct (`ls /usr/share/zoneinfo/` to list available)
- **If locale not generated:** Verify `locale.gen` was edited correctly, re-run `locale-gen`

---

## Phase 8: Bootloader Installation (GRUB)

**ENVIRONMENT:** [Chroot]  
**TIME:** Estimated Time: 5-10 minutes  
**NEXT:** Restart Count: 0

**Prerequisites Checklist:**
- [ ] Phase 7 completed successfully
- [ ] Still in chroot environment (prompt shows `[root@archiso /]#`)
- [ ] EFI partition mounted at `/boot`
- [ ] UUID of root partition ready (obtained in Step 8.2)

**Success Criteria:**
- [ ] GRUB installed to EFI partition
- [ ] Root partition UUID obtained
- [ ] GRUB configured for LUKS encryption
- [ ] GRUB configuration generated
- [ ] Windows detected (if dual-booting)

**[GRUB](https://www.gnu.org/software/grub/)** (GRand Unified Bootloader):
- Manages boot menu
- Handles LUKS decryption parameters
- Displays boot options with 5-second timeout
- **Official Resources:**
  - [GNU GRUB Website](https://www.gnu.org/software/grub/)
  - [ArchWiki GRUB](https://wiki.archlinux.org/title/GRUB)
  - [GRUB Manual](https://www.gnu.org/software/grub/manual/)

### Step 8.1: Install GRUB to EFI Partition

```bash
# Install GRUB bootloader to EFI partition
grub-install --target=x86_64-efi \
  --efi-directory=/boot \
  --bootloader-id=GRUB \
  --recheck

# --target=x86_64-efi: UEFI 64-bit mode
# --efi-directory=/boot: Mount point of EFI partition
# --bootloader-id=GRUB: Boot entry name in UEFI
# --recheck: Force device map regeneration
```

**Output:**
```
Installing for x86_64-efi platform.
Installation finished. No error reported.
```

**SUCCESS:** GRUB installed to EFI partition

### Step 8.2: Get UUID of Encrypted Root Partition

**What is UUID?**
UUID (Universally Unique Identifier) is a permanent identifier for disk partitions. GRUB needs the UUID to locate the encrypted partition during boot.

```bash
# Display ALL partition UUIDs
blkid

# Display only encrypted root partition UUID
# For GIGABYTE Brix 5300: Use /dev/nvme0n1p4 (root partition)
blkid /dev/nvme0n1p4

# Alternative: Filter only UUID value
blkid -s UUID -o value /dev/nvme0n1p4
```

**Expected output:**
```
/dev/nvme0n1p4: UUID="a1b2c3d4-e5f6-7890-abcd-ef1234567890" TYPE="crypto_LUKS" PARTUUID="..."
```

**Steps to copy UUID:**
1. Run: `blkid /dev/nvme0n1p4`
2. Look for `UUID="..."` in the output
3. Copy the value between quotes (format: `XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX`)
4. Example: `a1b2c3d4-e5f6-7890-abcd-ef1234567890`

**WARNING:** You will need this UUID in the next step (Step 8.3)

**Tip:** Write down the UUID or keep this terminal window open for reference.

**If error occurs:**
- **"No such file or directory":** Verify partition exists (`lsblk`), check device name is correct
- **No UUID shown:** Verify partition is encrypted (`TYPE="crypto_LUKS"`), check partition was encrypted in Phase 4
- **Multiple UUIDs shown:** Use the UUID from the root partition (`/dev/nvme0n1p4`), ignore other partitions

### Step 8.3: Configure GRUB for LUKS Encryption

```bash
# Edit /etc/default/grub
nano /etc/default/grub
```

**Find and modify the following lines:**

**Line 1: GRUB_CMDLINE_LINUX_DEFAULT**

Find:
```bash
GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet"
```

**No change needed** - This line should remain as-is (already correct).

**Line 2: GRUB_CMDLINE_LINUX**

Find:
```bash
GRUB_CMDLINE_LINUX=""
```

Change to (**WARNING:** REPLACE `<YOUR_UUID>` WITH YOUR ACTUAL UUID):
```bash
GRUB_CMDLINE_LINUX="cryptdevice=UUID=<YOUR_UUID>:cryptroot root=/dev/mapper/cryptroot rootflags=subvol=@"
```

**Line 3: GRUB_DISABLE_OS_PROBER**

Find:
```bash
#GRUB_DISABLE_OS_PROBER=false
```

Uncomment (remove #) if you want to detect Windows:
```bash
GRUB_DISABLE_OS_PROBER=false
```

**Parameter Explanation:**
- `cryptdevice=UUID=...:cryptroot` - Decrypt LUKS partition and name it "cryptroot"
- `root=/dev/mapper/cryptroot` - Use decrypted device as root
- `rootflags=subvol=@` - Mount Btrfs @ subvolume as root
- `GRUB_DISABLE_OS_PROBER=false` - Allow detection of Windows (if dual-booting)

**Save and exit** (Ctrl+O, Enter, Ctrl+X)

### Step 8.4: Generate GRUB Configuration

```bash
# Generate GRUB config file
grub-mkconfig -o /boot/grub/grub.cfg
```

**Expected output:**
```
Generating grub configuration file ...
Found linux image: /boot/vmlinuz-linux
Found initrd image: /boot/initramfs-linux.img
Found fallback initrd image: /boot/initramfs-linux-fallback.img
done
```

**If Windows is detected (dual-boot):**
```
Warning: os-prober will be executed to detect other bootable partitions.
Found Windows Boot Manager on /dev/nvme0n1p1@/EFI/Microsoft/Boot/bootmgfw.efi
Adding boot menu entry for UEFI Firmware Settings ...
done
```

**SUCCESS:** Phase 8 Complete: GRUB bootloader installed and configured

**Verification:**
- [x] GRUB installed (`ls /boot/EFI/GRUB/` shows GRUB files)
- [x] UUID obtained (`blkid /dev/nvme0n1p4` shows UUID)
- [x] GRUB configured (`cat /etc/default/grub` shows `cryptdevice=UUID=...`)
- [x] GRUB config generated (`ls /boot/grub/grub.cfg` exists)
- [x] Windows detected (if applicable, `grub-mkconfig` shows Windows entry)

**NEXT:** Next: Setup automatic LUKS decryption with keyfile (Phase 9, optional)

**Troubleshooting:**
- **If GRUB installation fails:** Verify EFI partition is mounted at `/boot`, check disk space, verify UEFI mode
- **If UUID not found:** Verify partition exists (`lsblk`), check partition is encrypted (`blkid` shows `crypto_LUKS`)
- **If Windows not detected:** Verify `os-prober` is installed, check Windows partition exists, verify `GRUB_DISABLE_OS_PROBER=false`

---

## Phase 9: Automatic LUKS Decryption Setup (Optional)

**ENVIRONMENT:** [Chroot]  
**TIME:** Estimated Time: 10-15 minutes  
**NEXT:** Restart Count: 0

**What This Does:**
- Creates a keyfile for LUKS decryption
- Embeds keyfile in initramfs (boot image)
- Configures boot to auto-decrypt without password prompt
- Maintains full encryption security (data encrypted at rest)

**Prerequisites Checklist:**
- [ ] Phase 8 completed successfully
- [ ] Still in chroot environment
- [ ] LUKS passphrase known (to add keyfile)
- [ ] Decision made: automatic decryption desired (vs. password prompt)

**Success Criteria:**
- [ ] Keyfile created and secured
- [ ] Keyfile added to root partition LUKS
- [ ] Keyfile added to swap partition LUKS
- [ ] Initramfs configured to include keyfile
- [ ] GRUB configured for keyfile
- [ ] Initramfs rebuilt with keyfile
- [ ] Keyfile verified in initramfs

**Security Note:**
- Keyfile is in `/boot` (unencrypted partition)
- Physical access to `/boot` allows decryption
- Acceptable for personal systems under your control
- If higher security needed, keep password prompt enabled

### Step 9.1: Create Keyfile Directory

```bash
# Create directory for LUKS keyfile
mkdir -p /etc/cryptsetup.d

# Set strict permissions (root-only access)
chmod 700 /etc/cryptsetup.d
```

### Step 9.2: Generate LUKS Keyfile

```bash
# Generate 512-byte random keyfile
dd if=/dev/urandom of=/etc/cryptsetup.d/root.key bs=512 count=1

# Output:
# 1+0 records in
# 1+0 records out
# 512 bytes copied, 0.000... s, ... MB/s
```

**Set strict permissions:**
```bash
# Only root can read/write this file
chmod 600 /etc/cryptsetup.d/root.key
```

**Verify permissions:**
```bash
ls -la /etc/cryptsetup.d/root.key

# Should show:
# -rw------- 1 root root 512 Dec  1 15:30 /etc/cryptsetup.d/root.key
```

### Step 9.3: Add Keyfile to LUKS Key Slot

```bash
# Add keyfile to LUKS key slot 1 (slot 0 has your passphrase)
# For GIGABYTE Brix 5300: Use /dev/nvme0n1p4 (root partition)
cryptsetup luksAddKey /dev/nvme0n1p4 /etc/cryptsetup.d/root.key
```

**Prompt:**
```
Enter any existing passphrase:
```

**Enter the LUKS passphrase** you created earlier during encryption.

**Should show:** (no output = success)

**If error occurs:**
- **"No key available":** Verify LUKS passphrase is correct, check for typos
- **"Key slot is full":** Use different key slot (`--key-slot 2`), or remove existing key from slot
- **"Operation not permitted":** Verify root privileges, check keyfile permissions

**Verify keyfile was added:**
```bash
# For GIGABYTE Brix 5300: Use /dev/nvme0n1p4 (root partition)
cryptsetup luksDump /dev/nvme0n1p4 | grep "Key Slot"

# Should show:
# Key Slot 0: ENABLED
# Key Slot 1: ENABLED
# Key Slot 2: DISABLED
# ...
```

**SUCCESS:** Keyfile added to LUKS

### Step 9.4: Add Keyfile to Swap Partition (Same Process)

```bash
# Add keyfile to encrypted swap partition
# For GIGABYTE Brix 5300: Use /dev/nvme0n1p5 (swap partition)
cryptsetup luksAddKey /dev/nvme0n1p5 /etc/cryptsetup.d/root.key

# Enter existing passphrase: (same as before)
```

### Step 9.5: Configure Initramfs to Include Keyfile

```bash
# Edit /etc/mkinitcpio.conf
nano /etc/mkinitcpio.conf
```

**Find and modify these lines:**

**Line 1: FILES**

Find:
```bash
FILES=()
```

Change to:
```bash
FILES=(/etc/cryptsetup.d/root.key)
```

**This embeds the keyfile into initramfs**

**Line 2: HOOKS**

Find:
```bash
HOOKS=(base udev autodetect modconf block filesystems keyboard fsck)
```

Change to:
```bash
HOOKS=(base udev autodetect modconf block encrypt filesystems keyboard fsck)
```

**Added:** `encrypt` hook (handles LUKS decryption at boot)

**WARNING:** CRITICAL: Order matters:
- `block` MUST come BEFORE `encrypt`
- `encrypt` MUST come BEFORE `filesystems`
- `keyboard` should come AFTER `filesystems`

**Save and exit** (Ctrl+O, Enter, Ctrl+X)

### Step 9.6: Update GRUB for Keyfile

```bash
# Edit /etc/default/grub again
nano /etc/default/grub
```

**Find line starting with `GRUB_CMDLINE_LINUX=`**

Change from:
```bash
GRUB_CMDLINE_LINUX="cryptdevice=UUID=<YOUR_UUID>:cryptroot root=/dev/mapper/cryptroot rootflags=subvol=@"
```

To (add `cryptkey` parameter at the beginning):
```bash
GRUB_CMDLINE_LINUX="cryptkey=rootfs:/etc/cryptsetup.d/root.key cryptdevice=UUID=<YOUR_UUID>:cryptroot root=/dev/mapper/cryptroot rootflags=subvol=@"
```

**WARNING:** REPLACE UUID with your actual UUID from blkid

**Parameter added:** `cryptkey=rootfs:/etc/cryptsetup.d/root.key`

**Save and exit** (Ctrl+O, Enter, Ctrl+X)

### Step 9.7: Configure Encrypted Swap Auto-Unlock

```bash
# Create /etc/crypttab for swap
# For GIGABYTE Brix 5300: Use /dev/nvme0n1p5 (swap partition)
cat > /etc/crypttab << EOF
# <name>       <device>                             <keyfile>                          <options>
cryptswap      /dev/nvme0n1p5                      /etc/cryptsetup.d/root.key         luks
EOF

**Verify crypttab:**
```bash
cat /etc/crypttab

# Should show:
# cryptswap /dev/nvme0n1p5 /etc/cryptsetup.d/root.key luks
```

**Update fstab for encrypted swap:**
```bash
# Edit /etc/fstab
nano /etc/fstab
```

**Find the swap line** (looks like):
```
UUID=ZZZZ-ZZZZ-ZZZZ  none  swap  defaults  0  0
```

**Change to:**
```
/dev/mapper/cryptswap  none  swap  defaults  0  0
```

**Save and exit** (Ctrl+O, Enter, Ctrl+X)

### Step 9.8: Rebuild Initramfs and GRUB

```bash
# Regenerate initramfs (includes keyfile now)
mkinitcpio -P

# Should show:
# ==> Building image from preset: /etc/mkinitcpio.d/linux.preset: 'default'
#   -> -k /boot/vmlinuz-linux -c /etc/mkinitcpio.conf -g /boot/initramfs-linux.img
# ==> Starting build: '6.x.x-arch1-1'
# ...
# ==> Image generation successful
# ==> Building image from preset: /etc/mkinitcpio.d/linux.preset: 'fallback'
# ...
# ==> Image generation successful
```

**If error occurs:**
- **"No such file or directory" (keyfile):** Verify keyfile path in `FILES=()` is correct, check file exists
- **"Hook 'encrypt' not found":** Verify `encrypt` hook is installed (`pacman -Q mkinitcpio`), check hook order
- **"Failed to build image":** Check disk space (`df -h`), verify kernel is installed, check mkinitcpio config syntax

**Regenerate GRUB config:**
```bash
grub-mkconfig -o /boot/grub/grub.cfg
```

### Step 9.9: Verify Keyfile is in Initramfs

```bash
# List contents of initramfs
lsinitcpio /boot/initramfs-linux.img | grep root.key

# Should show:
# etc/cryptsetup.d/root.key
```

**SUCCESS:** Keyfile is embedded in initramfs

**SUCCESS:** Phase 9 Complete: Automatic LUKS decryption configured

**Verification:**
- [x] Keyfile created (`ls -la /etc/cryptsetup.d/root.key` shows file with 600 permissions)
- [x] Keyfile added to root (`cryptsetup luksDump /dev/nvme0n1p4 | grep "Key Slot"` shows slot 1 enabled)
- [x] Keyfile added to swap (`cryptsetup luksDump /dev/nvme0n1p5 | grep "Key Slot"` shows slot 1 enabled)
- [x] Initramfs includes keyfile (`lsinitcpio /boot/initramfs-linux.img | grep root.key` shows file)
- [x] GRUB configured (`cat /etc/default/grub` shows `cryptkey=rootfs:...`)

**Note:** You can toggle this on/off anytime by modifying `/etc/mkinitcpio.conf` and rebuilding initramfs.

**Troubleshooting:**
- **If keyfile creation fails:** Verify `/etc/cryptsetup.d` directory exists, check disk space
- **If keyfile not added:** Verify LUKS passphrase is correct, check partition device name
- **If keyfile not in initramfs:** Verify `FILES=(...)` in `/etc/mkinitcpio.conf`, re-run `mkinitcpio -P`

---

## Phase 10: User Account Creation

**ENVIRONMENT:** [Chroot]  
**TIME:** Estimated Time: 5 minutes  
**NEXT:** Restart Count: 0

**Prerequisites Checklist:**
- [ ] Phase 7 completed successfully (or Phase 9 if using automatic decryption)
- [ ] Still in chroot environment
- [ ] Username chosen (replace `<username>` in commands)
- [ ] User password prepared

**Success Criteria:**
- [ ] User account created with home directory
- [ ] User added to required groups (wheel, video, audio, etc.)
- [ ] User password set
- [ ] Sudo access configured
- [ ] User verified (can check with `id` command)

### Step 10.1: Create User Account

```bash
# Create user with home directory and group memberships
# Replace <username> with your desired username (e.g., john, alice, user)
useradd -m -G wheel,video,audio,storage,input,power,network -s /bin/zsh <username>

# Example: To create user "john":
# useradd -m -G wheel,video,audio,storage,input,power,network -s /bin/zsh john
```

# Explanation:
# -m: Create home directory (/home/<username>)
# -G: Add to supplementary groups:
#     wheel: sudo access
#     video: GPU access
#     audio: sound access
#     storage: removable media access
#     input: input devices
#     power: power management
#     network: network configuration
# -s /bin/zsh: Default shell is Zsh
```

### Step 10.2: Set User Password

```bash
# Set password for user
# Replace <username> with your actual username
passwd <username>

# Example: To set password for user "john":
# passwd john
```

**Prompt:**
```
New password:
```

**Enter:** `<YOUR_PASSWORD>`

**Retype password:** `<YOUR_PASSWORD>`

**SUCCESS:** User password set

### Step 10.3: Configure Sudo Access

```bash
# Edit sudoers file
EDITOR=nano visudo
```

**Find line:**
```bash
# %wheel ALL=(ALL:ALL) ALL
```

**Uncomment (remove #):**
```bash
%wheel ALL=(ALL:ALL) ALL
```

**This allows members of "wheel" group to use sudo**

**Save and exit** (Ctrl+O, Enter, Ctrl+X)

### Step 10.4: Verify User Was Created

```bash
# Check user information
# Replace <username> with your actual username
id <username>

# Should show:
# uid=1000(<username>) gid=1000(<username>) groups=1000(<username>),wheel,video,audio,storage,input,power,network

# Example: To check user "john":
# id john
```

**SUCCESS:** User created with groups and sudo access

**SUCCESS:** Phase 10 Complete: User account created

**Verification:**
- [x] User created (`id <username>` shows user with groups)
- [x] Home directory exists (`ls -la /home/<username>` shows directory)
- [x] User in wheel group (`id <username>` shows `wheel` in groups)
- [x] Sudo configured (`visudo` shows `%wheel ALL=(ALL:ALL) ALL` uncommented)
- [x] User password set (can verify by attempting to change password)

**NEXT:** Next: Configure network (Phase 11)

**Troubleshooting:**
- **If user creation fails:** Verify username doesn't contain special characters, check disk space
- **If groups not added:** Verify group names are correct, re-run `usermod -aG ... <username>`
- **If sudo not working:** Verify `%wheel` line is uncommented in `/etc/sudoers`, check user is in wheel group

---

## Phase 11: Network Configuration

**ENVIRONMENT:** [Chroot]  
**TIME:** Estimated Time: 5 minutes  
**NEXT:** Restart Count: 0

**Prerequisites Checklist:**
- [ ] Phase 10 completed successfully
- [ ] Still in chroot environment
- [ ] NetworkManager package installed (from Phase 6)

**Success Criteria:**
- [ ] NetworkManager service enabled
- [ ] Bluetooth packages installed (if needed)
- [ ] Bluetooth service enabled (if installed)

### Step 11.1: Enable NetworkManager Service

```bash
# Enable NetworkManager to start on boot
systemctl enable NetworkManager

# Output:
# Created symlink /etc/systemd/system/multi-user.target.wants/NetworkManager.service → /usr/lib/systemd/system/NetworkManager.service
```

**SUCCESS:** NetworkManager will start automatically on boot

### Step 11.2: Install Bluetooth Packages (Bluetooth 5.2)

```bash
# Install Bluetooth stack (Bluetooth 5.2 on GIGABYTE Brix 5300)
pacman -S bluez bluez-utils

# bluez: Bluetooth protocol stack
# bluez-utils: bluetoothctl and other tools
```

**Note:** GIGABYTE Brix 5300 includes Bluetooth 5.2. The Bluetooth adapter is typically integrated with the AMD RZ608 WiFi 6 module.

**Prompt:**
```
Proceed with installation? [Y/n]
```

**Press Enter** (default is Yes)

### Step 11.3: Enable Bluetooth Service (Optional)

```bash
# Enable Bluetooth daemon to start on boot (if installed)
systemctl enable bluetooth

# Output:
# Created symlink /etc/systemd/system/dbus-org.bluez.service → /usr/lib/systemd/system/bluetooth.service
```

**SUCCESS:** Phase 11 Complete: NetworkManager (and optionally Bluetooth) enabled

**Verification:**
- [x] NetworkManager enabled (`systemctl is-enabled NetworkManager` shows "enabled")
- [x] Bluetooth installed (if needed, `pacman -Q bluez bluez-utils` shows packages)
- [x] Bluetooth enabled (if installed, `systemctl is-enabled bluetooth` shows "enabled")

**NEXT:** Next: Install window manager and utilities (Phase 12)

**Troubleshooting:**
- **If NetworkManager not enabled:** Verify package is installed, check service name (`systemctl list-unit-files | grep NetworkManager`)
- **If Bluetooth not working:** Verify hardware is supported, check `lsmod | grep btusb` for Bluetooth modules

---

## Phase 12: Window Manager Setup

**ENVIRONMENT:** [Chroot]  
**TIME:** Estimated Time: 20-40 minutes (depends on internet speed)  
**NEXT:** Restart Count: 0

**Download Size: ~1.5 GB - 2 GB**

**Prerequisites Checklist:**
- [ ] Phase 11 completed successfully
- [ ] Still in chroot environment
- [ ] Internet connection available (for package downloads)
- [ ] Username known (for configuration file creation)
- [ ] Sufficient disk space (~2-3 GB for packages)

**Success Criteria:**
- [ ] Hyprland installed
- [ ] All Wayland utilities installed
- [ ] AMD graphics drivers installed
- [ ] PipeWire audio server installed
- [ ] SDDM display manager installed
- [ ] Hyprland configuration created
- [ ] Waybar configuration created
- [ ] SSH service enabled
- [ ] All configuration files have correct ownership

**Note:** This phase installs AMD graphics drivers. For other hardware configurations, refer to:
- `blank_arch.md` for vendor-neutral installation (no graphics drivers)
- `blank_intel_arch.md` for Intel CPU microcode and graphics drivers

### Step 12.1: Install Wayland Compositor (Hyprland)

```bash
# Install Hyprland Wayland compositor
pacman -S hyprland
```

**Proceed with installation: [Y/n]** - Press Enter

**Official Resources:**
- [Hyprland Website](https://hyprland.org/)
- [GitHub Repository](https://github.com/hyprwm/Hyprland)
- [ArchWiki Hyprland](https://wiki.archlinux.org/title/Hyprland)

### Step 12.2: Install Terminal Emulator (Kitty)

```bash
# Install Kitty GPU-accelerated terminal
pacman -S kitty
```

**Official Resources:**
- [Kitty Website](https://sw.kovidgoyal.net/kitty/)
- [GitHub Repository](https://github.com/kovidgoyal/kitty)
- [ArchWiki Kitty](https://wiki.archlinux.org/title/Kitty)

### Step 12.3: Install Status Bar (Waybar)

```bash
# Install Waybar with dependencies
pacman -S waybar otf-font-awesome ttf-font-awesome
```

**Official Resources:**
- [Waybar GitHub Repository](https://github.com/Alexays/Waybar)
- [ArchWiki Waybar](https://wiki.archlinux.org/title/Waybar)

### Step 12.4: Install Application Launcher and Utilities

```bash
# Install core utilities
pacman -S wofi grim slurp wl-clipboard mako polkit-kde-agent xdg-desktop-portal-hyprland
```

**Package breakdown:**
- `wofi` - Application launcher (dmenu replacement for Wayland)
- `grim` - Screenshot tool
- `slurp` - Region selection tool (for screenshots)
- `wl-clipboard` - Wayland clipboard utilities (wl-copy, wl-paste)
- `mako` - Notification daemon
- `polkit-kde-agent` - Authentication agent (for password prompts)
- `xdg-desktop-portal-hyprland` - Desktop portal for Hyprland

### Step 12.5: Install Fonts

```bash
# Install JetBrainsMono Nerd Font and other fonts
pacman -S \
  ttf-jetbrains-mono-nerd \
  noto-fonts \
  noto-fonts-emoji \
  noto-fonts-cjk
```

### Step 12.6: Install AMD Graphics Drivers

#### 12.6.1 Theoretical Foundation of AMD Graphics Drivers

**AMD Graphics Architecture:**

AMD Radeon graphics can be either integrated into AMD APUs (Accelerated Processing Units) or discrete GPUs. AMD provides open-source graphics drivers through the Mesa project, which implements OpenGL, Vulkan, and other graphics APIs.

**Graphics Stack Architecture:**

```
Applications (OpenGL, Vulkan, X11, Wayland)
    ↓
Graphics API (Mesa, Vulkan)
    ↓
Kernel Graphics Driver (amdgpu for modern AMD, radeon for older)
    ↓
Hardware (AMD Radeon GPU)
```

**Mesa:**

[Mesa](https://www.mesa3d.org/) is an open-source implementation of OpenGL, Vulkan, and other graphics APIs:

- **OpenGL**: Industry-standard 3D graphics API
- **Vulkan**: Modern, low-level graphics API
- **Gallium3D**: Mesa's driver architecture
- **Hardware Support**: Supports Intel, AMD, NVIDIA (nouveau), and other GPUs

**Official Resources:**
- [Mesa Website](https://www.mesa3d.org/)
- [Mesa Documentation](https://docs.mesa3d.org/)
- [ArchWiki Mesa](https://wiki.archlinux.org/title/Mesa)
- [AMD Graphics on ArchWiki](https://wiki.archlinux.org/title/AMDGPU)

**Vulkan:**

[Vulkan](https://www.vulkan.org/) is a modern, low-level graphics API:

- **Performance**: Lower overhead than OpenGL
- **Multi-threading**: Better multi-threaded performance
- **Modern**: Designed for modern GPUs
- **Cross-Platform**: Works on Windows, Linux, Android, etc.

**Official Resources:**
- [Vulkan Website](https://www.vulkan.org/)
- [Vulkan Specification](https://www.khronos.org/vulkan/)
- [ArchWiki Vulkan](https://wiki.archlinux.org/title/Vulkan)

**VA-API (Video Acceleration API):**

VA-API provides hardware-accelerated video decoding/encoding:

- **Hardware Acceleration**: Uses GPU for video processing (lower CPU usage)
- **Codec Support**: H.264, H.265, VP8, VP9, AV1, etc.
- **Applications**: Video players, browsers, video conferencing

**Official Resources:**
- [VA-API GitHub](https://github.com/intel/libva)
- [ArchWiki Hardware Video Acceleration](https://wiki.archlinux.org/title/Hardware_video_acceleration)

**AMD GPU Driver Selection:**

AMD graphics drivers are divided into two categories:

1. **amdgpu** (Modern): For AMD GCN (Graphics Core Next) architecture and newer (Radeon HD 7000 series and newer, Radeon RX series, Radeon Vega, RDNA/RDNA2/RDNA3)
2. **radeon** (Legacy): For older AMD GPUs (pre-GCN architecture)

This guide focuses on **amdgpu** (modern AMD GPUs), which is the default for most current AMD systems.

```bash
# Install AMD graphics drivers
pacman -S \
  mesa \
  lib32-mesa \
  vulkan-radeon \
  lib32-vulkan-radeon \
  libva-mesa-driver
```

**Driver breakdown:**
- `mesa` - [OpenGL implementation](https://www.mesa3d.org/)
  - [ArchWiki Mesa](https://wiki.archlinux.org/title/Mesa)
- `lib32-mesa` - 32-bit OpenGL (for games/Wine)
  - [ArchWiki 32-bit Applications](https://wiki.archlinux.org/title/Architecture#Multilib)
- `vulkan-radeon` - [Vulkan API](https://www.vulkan.org/) (modern graphics) for AMD Radeon
  - [ArchWiki Vulkan](https://wiki.archlinux.org/title/Vulkan)
- `lib32-vulkan-radeon` - 32-bit Vulkan
- `libva-mesa-driver` - Hardware video acceleration (VA-API) for AMD Radeon
  - [VA-API Documentation](https://github.com/intel/libva)
  - [ArchWiki Hardware Video Acceleration](https://wiki.archlinux.org/title/Hardware_video_acceleration)

**Note:** For older AMD GPUs (pre-GCN, before Radeon HD 7000 series), you may need the `xf86-video-ati` package instead. However, most modern AMD systems use the `amdgpu` kernel driver with Mesa, which is included in the kernel and does not require additional installation.

### Step 12.7: Install Audio Server (PipeWire)

#### 12.7.1 Theoretical Foundation of PipeWire

**PipeWire** is a modern multimedia framework that unifies audio and video handling. It was designed to replace both PulseAudio (for desktop audio) and JACK (for professional audio) while providing superior capabilities.

**Key Advantages:**
- **Low Latency**: Designed for low latency (important for gaming, video calls, professional audio)
- **Unified**: Handles both audio (PulseAudio replacement) and video (screen sharing, webcam)
- **Security**: Better sandboxing and security model
- **Compatibility**: Drop-in replacement for PulseAudio (applications don't need changes)
- **Wayland Integration**: Better integration with Wayland compositors like Hyprland

**GIGABYTE Brix 5300 Audio Hardware:**
- **Audio Codec:** Realtek ALC897 HD Audio Codec
- **ALSA Support:** Realtek ALC897 is fully supported by the Linux kernel's ALSA (Advanced Linux Sound Architecture) subsystem
- **Driver:** `snd-hda-intel` kernel module (automatically loaded for Realtek audio codecs)
- **Compatibility:** PipeWire works seamlessly with Realtek ALC897 through ALSA compatibility layer

**Official Resources:**
- [PipeWire Website](https://pipewire.org/)
- [PipeWire Documentation](https://docs.pipewire.org/)
- [PipeWire GitHub](https://gitlab.freedesktop.org/pipewire/pipewire)
- [ArchWiki PipeWire](https://wiki.archlinux.org/title/PipeWire)
- [ArchWiki Advanced Linux Sound Architecture](https://wiki.archlinux.org/title/Advanced_Linux_Sound_Architecture)
- [Realtek Audio Codec Support](https://www.realtek.com/en/products/computer-peripheral-ics/category/audio-codecs)

```bash
# Install PipeWire audio stack
pacman -S \
  pipewire \
  pipewire-alsa \
  pipewire-pulse \
  pipewire-jack \
  wireplumber \
  pavucontrol
```

**Package breakdown:**
- `pipewire` - Core PipeWire server
- `pipewire-alsa` - ALSA compatibility layer (for applications using ALSA directly)
  - **Note:** This provides compatibility with Realtek ALC897 HD Audio Codec through ALSA
- `pipewire-pulse` - PulseAudio compatibility layer (for applications expecting PulseAudio)
- `pipewire-jack` - JACK compatibility layer (for professional audio applications)
- `wireplumber` - Session manager (handles device routing, policy, permissions)
- `pavucontrol` - GUI volume control (familiar interface for PulseAudio users)

**Realtek ALC897 HD Audio Codec Configuration:**
- The Realtek ALC897 audio codec is automatically detected and configured by the Linux kernel
- No additional drivers or firmware are required (included in `linux-firmware` package)
- Audio output is available through:
  - **HDMI/DisplayPort:** Audio passthrough via graphics card (AMD Radeon RX Vega)
  - **3.5mm Audio Jack:** Analog audio output (if available on GIGABYTE Brix 5300)
  - **USB Audio:** USB audio devices (if connected)

**Verification After Installation:**
After first boot, verify audio functionality:
```bash
# Check if audio codec is detected
cat /proc/asound/cards

# Should show Realtek ALC897 or similar
# Expected output:
# 0 [Generic        ]: HDA-Intel - HD-Audio Generic
#                      HD-Audio Generic at 0x... irq ...

# Check audio devices
pactl list short sinks

# Test audio (if speaker-test is installed)
speaker-test -c 2 -t wav
```

**Official Resources:**
- [ArchWiki Advanced Linux Sound Architecture](https://wiki.archlinux.org/title/Advanced_Linux_Sound_Architecture)
- [ArchWiki Realtek Audio](https://wiki.archlinux.org/title/Advanced_Linux_Sound_Architecture#Realtek)
- [Realtek ALC897 Specifications](https://www.realtek.com/en/products/computer-peripheral-ics/category/audio-codecs)

### Step 12.8: Install Display Manager (SDDM)

```bash
# Install SDDM login manager
pacman -S sddm
```

**Enable SDDM service:**
```bash
systemctl enable sddm

# Output:
# Created symlink /etc/systemd/system/display-manager.service → /usr/lib/systemd/system/sddm.service
```

**Official Resources:**
- [SDDM GitHub Repository](https://github.com/sddm/sddm)
- [ArchWiki SDDM](https://wiki.archlinux.org/title/SDDM)

### Step 12.9: Enable SSH Service for Post-Installation Remote Access

**WARNING:** CRITICAL: Enable SSH before exiting chroot to allow remote access after first boot

**Purpose:** After the first system reboot, you may need to continue configuration remotely via SSH. Enabling SSH service in chroot ensures that the SSH daemon starts automatically on first boot, allowing remote access without physical access to the system.

**Note:** The `openssh` package was already installed in Phase 6 (base system installation). This step only enables the SSH service to start automatically on boot.

```bash
# Enable SSH service to start on boot
systemctl enable sshd.service

# Verify service is enabled
systemctl is-enabled sshd.service
# Expected output: enabled
```

**SSH Configuration Notes:**
- SSH service will start automatically on first boot
- Default SSH port: 22
- Root login via SSH is enabled by default (can be disabled later for security)
- SSH keys can be configured after first boot for passwordless authentication
- NetworkManager must be running for SSH to accept connections (enabled in Phase 11)

**Security Considerations:**
- After first boot, consider disabling root SSH login: Edit `/etc/ssh/sshd_config` and set `PermitRootLogin no`
- Configure firewall rules if needed: `ufw allow 22/tcp` or `iptables` rules
- Use SSH keys instead of passwords for better security

**SUCCESS:** SSH service enabled and will start automatically on first boot

### Step 12.10: Configure Hyprland for AMD Radeon RX Vega

#### 12.10.1 AMD-Specific Hyprland Configuration

**Early KMS (Kernel Mode Setting) for AMD Graphics:**

For AMD Radeon RX Vega graphics, early KMS enables graphics during boot (before user space starts). This is configured in `/etc/mkinitcpio.conf`:

```bash
# Edit /etc/mkinitcpio.conf
nano /etc/mkinitcpio.conf

# Find MODULES line:
MODULES=()

# Change to (add amdgpu for AMD Radeon RX Vega):
MODULES=(amdgpu)

# Rebuild initramfs
mkinitcpio -P
```

**amdgpu** is the kernel module for AMD Radeon RX Vega (GCN 5.0 architecture). This enables early graphics initialization, improving boot experience and display output.

#### 12.10.2 Create Hyprland Configuration Directory

**IMPORTANT:** Replace `<username>` with the actual username you created in Phase 10.

```bash
# Create Hyprland config directory
# Replace <username> with your actual username (e.g., john, alice, user)
mkdir -p /home/<username>/.config/hypr
```

#### 12.10.3 Create Basic Hyprland Configuration

**For GIGABYTE Brix 5300 with AMD Radeon RX Vega:**

```bash
# Create basic Hyprland configuration
# Replace <username> with your actual username
cat > /home/<username>/.config/hypr/hyprland.conf << 'EOF'
# Hyprland Configuration for GIGABYTE Brix 5300
# AMD Ryzen 3 5300U, Radeon RX Vega Graphics

# Monitor Configuration
# GIGABYTE Brix 5300 supports:
# - HDMI 2.0 output
# - DisplayPort 1.4 output
# - USB-C (DisplayPort Alt Mode)
monitor=,preferred,auto,auto

# Workspace Assignment
workspace = 1, monitor:HDMI-A-1, default:true
workspace = 2, monitor:HDMI-A-1
workspace = 3, monitor:HDMI-A-1
workspace = 4, monitor:HDMI-A-1
workspace = 5, monitor:HDMI-A-1

# Application Aliases
$terminal = kitty
$fileManager = dolphin
$menu = wofi --show drun

# Autostart Applications
exec-once = waybar
exec-once = mako
exec-once = swaybg --image ~/.config/wallpaper.png

# Environment Variables
env = XCURSOR_SIZE,24
env = HYPRCURSOR_SIZE,24
env = LANG,en_US.UTF-8
env = LC_ALL,en_US.UTF-8

# General Settings
general {
    gaps_in = 11
    gaps_out = 11
    border_size = 2
    col.active_border = rgba(a6e3a1ff)
    col.inactive_border = rgba(1e1e2eff)
    layout = dwindle
}

# Decoration (Window Appearance)
decoration {
    rounding = 12
    active_opacity = 1.0
    inactive_opacity = 1.0
    
    blur {
        enabled = yes
        size = 10
        passes = 2
        vibrancy = 0.3
    }
    
    shadow {
        enabled = yes
        range = 4
        render_power = 3
        color = rgba(11111bee)
    }
}

# Animations
animations {
    enabled = yes
    bezier = ios, 0.25, 0.1, 0.25, 1
    bezier = smooth, 0.4, 0, 0.2, 1
    
    animation = windows, 1, 7, ios, slide
    animation = windowsIn, 1, 7, ios, slide
    animation = windowsOut, 1, 5, ios, slide
    animation = fade, 1, 8, ios
    animation = workspaces, 1, 6, ios, slide
}

# Dwindle Layout
dwindle {
    pseudotile = true
    preserve_split = true
}

# Input Configuration
input {
    kb_layout = us
    follow_mouse = 1
    sensitivity = 0
    
    touchpad {
        natural_scroll = false
        tap-to-click = true
        disable_while_typing = true
    }
}

# Keybindings
$mainMod = SUPER

# Application Launchers
bind = $mainMod, Q, exec, $terminal
bind = $mainMod, E, exec, $fileManager
bind = $mainMod, R, exec, $menu

# Window Management
bind = $mainMod, C, killactive
bind = $mainMod, M, exit
bind = $mainMod, V, togglefloating
bind = , F11, fullscreen
bind = $mainMod, P, pseudo

# Window Navigation (vim-style)
bind = $mainMod, h, movefocus, l
bind = $mainMod, j, movefocus, d
bind = $mainMod, k, movefocus, u
bind = $mainMod, l, movefocus, r

# Workspace Navigation
bind = $mainMod, 1, workspace, 1
bind = $mainMod, 2, workspace, 2
bind = $mainMod, 3, workspace, 3
bind = $mainMod, 4, workspace, 4
bind = $mainMod, 5, workspace, 5

# Move Window to Workspace
bind = $mainMod SHIFT, 1, movetoworkspace, 1
bind = $mainMod SHIFT, 2, movetoworkspace, 2
bind = $mainMod SHIFT, 3, movetoworkspace, 3
bind = $mainMod SHIFT, 4, movetoworkspace, 4
bind = $mainMod SHIFT, 5, movetoworkspace, 5

# Window Movement
bind = $mainMod SHIFT, h, movewindow, l
bind = $mainMod SHIFT, j, movewindow, d
bind = $mainMod SHIFT, k, movewindow, u
bind = $mainMod SHIFT, l, movewindow, r

# Mouse Controls
bind = $mainMod, mouse_down, workspace, e+1
bind = $mainMod, mouse_up, workspace, e-1
bindm = $mainMod, mouse:272, movewindow
bindm = $mainMod, mouse:273, resizewindow
EOF
```

**IMPORTANT:** Replace `<username>` with your actual username created in Phase 10 (e.g., if you created user `john`, use `/home/john/.config/hypr/hyprland.conf`).

**Official Resources:**
- [Hyprland Configuration Documentation](https://wiki.hyprland.org/Configuring/Variables/)
- [Hyprland Keybindings](https://wiki.hyprland.org/Configuring/Binds/)
- [Hyprland AMD GPU Support](https://wiki.hyprland.org/Configuring/Master-Configuration/)

#### 12.10.4 Create Waybar Configuration

```bash
# Create Waybar config directory
# Replace <username> with your actual username
mkdir -p /home/<username>/.config/waybar

# Create basic Waybar configuration
cat > /home/<username>/.config/waybar/config.jsonc << 'EOF'
{
  "layer": "top",
  "position": "top",
  "height": 24,
  
  "modules-left": ["hyprland/workspaces"],
  "modules-center": ["clock"],
  "modules-right": ["pulseaudio", "network", "battery"],
  
  "hyprland/workspaces": {
    "format": "{id}",
    "on-click": "activate"
  },
  
  "clock": {
    "format": "{:%Y-%m-%d %H:%M:%S}",
    "tooltip-format": "{:%A %B %d %Y}"
  },
  
  "pulseaudio": {
    "format": "{icon} {volume}%",
    "format-muted": "🔇 Muted",
    "on-click": "pactl set-sink-mute @DEFAULT_SINK@ toggle"
  },
  
  "network": {
    "format-wifi": "📶 {signalStrength}%",
    "format-ethernet": "🌐 Connected",
    "format-disconnected": "❌ Disconnected"
  },
  
  "battery": {
    "format": "{icon} {capacity}%",
    "format-charging": "🔌 {capacity}%",
    "states": {
      "warning": 30,
      "critical": 15
    }
  }
}
EOF
```

**Official Resources:**
- [Waybar Configuration](https://github.com/Alexays/Waybar/wiki/Configuration)
- [Waybar Modules](https://github.com/Alexays/Waybar/wiki/Modules)

#### 12.10.5 Create Waybar Style

```bash
# Create Waybar style
# Replace <username> with your actual username
cat > /home/<username>/.config/waybar/style.css << 'EOF'
* {
    border: none;
    border-radius: 0;
    font-family: "JetBrainsMono Nerd Font", "Font Awesome 6 Free";
    font-size: 13px;
    min-height: 0;
}

window#waybar {
    background-color: rgba(24, 24, 37, 0.95);
    color: #cdd6f4;
    border-bottom: 2px solid rgba(166, 227, 161, 0.5);
}

#workspaces button {
    padding: 0 10px;
    background-color: transparent;
    color: #6c7086;
}

#workspaces button.active {
    color: #a6e3a1;
    background-color: rgba(166, 227, 161, 0.1);
}

#clock, #pulseaudio, #network, #battery {
    padding: 0 10px;
    margin: 0 4px;
}
EOF
```

#### 12.10.6 Install Additional Wayland Utilities

```bash
# Install additional Wayland utilities for GIGABYTE Brix 5300
pacman -S \
  swaybg \
  brightnessctl \
  qt5-wayland \
  qt6-wayland \
  xdg-utils \
  xdg-user-dirs
```

**Package breakdown:**
- `swaybg` - Wallpaper utility for Wayland
  - [swaybg GitHub](https://github.com/swaywm/swaybg)
- `brightnessctl` - Screen brightness control (important for mini PC systems)
  - [brightnessctl GitHub](https://github.com/Hummer12007/brightnessctl)
- `qt5-wayland` + `qt6-wayland` - Qt Wayland support (for KDE applications like Dolphin)
  - [Qt Wayland Documentation](https://doc.qt.io/qt-6/wayland.html)
- `xdg-utils` - Desktop integration utilities
  - [XDG Utils Specification](https://www.freedesktop.org/wiki/Software/xdg-utils/)
- `xdg-user-dirs` - User directory management (Documents, Downloads, etc.)
  - [XDG User Dirs Specification](https://www.freedesktop.org/wiki/Software/xdg-user-dirs/)

#### 12.10.7 Install File Manager and Utilities

```bash
# Install file manager and essential utilities
pacman -S \
  dolphin \
  firefox \
  htop \
  btop \
  neofetch
```

**Package breakdown:**
- `dolphin` - KDE file manager (works with Hyprland, full Wayland support)
  - [Dolphin Website](https://apps.kde.org/dolphin/)
- `firefox` - Web browser (Wayland native)
  - [Firefox Website](https://www.mozilla.org/firefox/)
- `htop` - Interactive process viewer
- `btop` - Modern resource monitor
- `neofetch` - System information tool

#### 12.10.8 Configure SDDM for Hyprland Session

```bash
# Create SDDM session file for Hyprland
mkdir -p /usr/share/wayland-sessions

cat > /usr/share/wayland-sessions/hyprland.desktop << 'EOF'
[Desktop Entry]
Name=Hyprland
Comment=Hyprland Wayland compositor
Exec=/usr/bin/Hyprland
Type=Application
DesktopNames=Hyprland
EOF
```

**Note:** SDDM should automatically detect Hyprland session after installation. Verify by checking SDDM session selection menu after first boot.

**Official Resources:**
- [SDDM Session Configuration](https://github.com/sddm/sddm/wiki/Sessions)
- [ArchWiki SDDM](https://wiki.archlinux.org/title/SDDM)

#### 12.10.9 Set Permissions for User Configuration Files

```bash
# Set correct ownership for user configuration files
# Replace <username> with your actual username
chown -R <username>:<username> /home/<username>/.config

# Example: If username is "john", use:
# chown -R john:john /home/john/.config
```

**SUCCESS:** Phase 12 Complete: Hyprland Wayland compositor, AMD graphics drivers, and complete desktop environment installed

**Verification:**
- [x] Hyprland installed (`pacman -Q hyprland` shows package)
- [x] Graphics drivers installed (`pacman -Q mesa vulkan-radeon` shows packages)
- [x] PipeWire installed (`pacman -Q pipewire wireplumber` shows packages)
- [x] SDDM installed (`pacman -Q sddm` shows package)
- [x] Hyprland config exists (`ls /home/<username>/.config/hypr/hyprland.conf` shows file)
- [x] Waybar config exists (`ls /home/<username>/.config/waybar/config.jsonc` shows file)
- [x] SSH enabled (`systemctl is-enabled sshd` shows "enabled")
- [x] File ownership correct (`ls -la /home/<username>/.config` shows correct user:group)

**NEXT:** Next: Exit chroot and prepare for first boot (Phase 13)

**Troubleshooting:**
- **If package installation fails:** Check internet connection, verify disk space, check pacman keyring
- **If configuration files not created:** Verify username is correct, check directory permissions
- **If ownership incorrect:** Re-run `chown -R <username>:<username> /home/<username>/.config`

---

## Phase 13: Exit Chroot and System Reboot

**ENVIRONMENT:** [Chroot] → [Live USB] → [System Reboot]  
**TIME:** Estimated Time: 10 minutes  
**NEXT:** Restart Count: 1 (FIRST SYSTEM RESTART)

**Prerequisites Checklist:**
- [ ] Phase 12 completed successfully
- [ ] All configuration complete
- [ ] USB drive ready to remove (after shutdown)

**Success Criteria:**
- [ ] Exited chroot successfully
- [ ] All partitions unmounted
- [ ] Encrypted volumes closed
- [ ] System rebooted
- [ ] USB drive removed before boot

### Step 13.1: Exit Chroot Environment

```bash
# Exit chroot
exit
```

**Prompt changes back to:**
```
root@archiso ~ #
```

**SUCCESS:** You are now back in Arch Linux live USB environment

### Step 13.2: Unmount All Partitions

```bash
# Unmount all mounted filesystems recursively
umount -R /mnt
```

**If error "target is busy":**
```bash
# Force unmount
umount -lR /mnt
```

### Step 13.3: Close Encrypted Volumes

```bash
# Close encrypted swap
cryptsetup close cryptswap

# Close encrypted root
cryptsetup close cryptroot
```

**Verify all closed:**
```bash
ls /dev/mapper/

# Should show only:
# control
```

### Step 13.4: Reboot System

```bash
# Reboot the system
reboot
```

**Remove USB drive** when system shuts down (before it boots again).

**SUCCESS:** Phase 13 Complete: System ready for first boot

**Verification:**
- [x] Exited chroot (prompt changed back to `root@archiso ~ #`)
- [x] All partitions unmounted (`lsblk` shows no mount points)
- [x] Encrypted volumes closed (`ls /dev/mapper/` shows only `control`)
- [x] System rebooted (or ready to reboot)

**NEXT:** After reboot, log in and verify system functionality

**Troubleshooting:**
- **If "target is busy" error:** Check for open files (`lsof /mnt`), close any processes, use `umount -lR /mnt` for lazy unmount
- **If encrypted volumes won't close:** Verify no processes are using them, check `lsblk` for active mounts
- **If system won't boot:** Verify GRUB is installed, check UEFI boot order, verify USB drive is removed

---

## Quick Reference

### Critical Commands Reference

**Disk and Partition Management:**
```bash
# List block devices
lsblk

# List partitions with filesystems
lsblk -f

# Open partition editor
cfdisk /dev/nvme0n1

# Re-read partition table
partprobe /dev/nvme0n1
```

**Encryption Management:**
```bash
# Encrypt partition
cryptsetup luksFormat --type luks2 --cipher aes-xts-plain64 --key-size 512 --pbkdf argon2id --iter-time 5000 /dev/nvme0n1p4

# Unlock encrypted partition
cryptsetup open /dev/nvme0n1p4 cryptroot

# View LUKS information
cryptsetup luksDump /dev/nvme0n1p4

# Close encrypted volume
cryptsetup close cryptroot
```

**Btrfs Management:**
```bash
# Create Btrfs filesystem
mkfs.btrfs -L "Arch Linux" /dev/mapper/cryptroot

# Create subvolume
btrfs subvolume create /mnt/@

# List subvolumes
btrfs subvolume list /mnt

# Mount subvolume
mount -o subvol=@,compress=zstd,noatime /dev/mapper/cryptroot /mnt
```

**System Installation:**
```bash
# Install base system
pacstrap /mnt base base-devel linux linux-firmware ...

# Generate fstab
genfstab -U /mnt > /mnt/etc/fstab

# Enter chroot
arch-chroot /mnt

# Install GRUB
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB

# Generate GRUB config
grub-mkconfig -o /boot/grub/grub.cfg
```

**Service Management:**
```bash
# Enable service
systemctl enable NetworkManager

# Check service status
systemctl status NetworkManager

# Check if service is enabled
systemctl is-enabled NetworkManager
```

### Partition Layout Quick Reference

**GIGABYTE Brix 5300 (500 GB SSD):**
- `/dev/nvme0n1p1` - EFI System Partition (512 MB, FAT32, `/boot`)
- `/dev/nvme0n1p2` - Windows 11 System (250 GB, NTFS)
- `/dev/nvme0n1p3` - Windows Recovery (1 GB, NTFS)
- `/dev/nvme0n1p4` - Arch Linux Root (225 GB, Btrfs, encrypted, `/`)
- `/dev/nvme0n1p5` - Swap (8 GB, encrypted, `[SWAP]`)

### Key File Locations

**Configuration Files:**
- `/etc/fstab` - Filesystem mount table
- `/etc/default/grub` - GRUB configuration
- `/etc/mkinitcpio.conf` - Initramfs configuration
- `/etc/crypttab` - Encrypted device configuration
- `/etc/locale.conf` - System locale
- `/etc/hostname` - System hostname
- `/home/username/.config/hypr/hyprland.conf` - Hyprland configuration
- `/home/username/.config/waybar/config.jsonc` - Waybar configuration

**Important Directories:**
- `/boot` - Boot files (EFI partition)
- `/mnt` - Installation mount point (live USB)
- `/dev/mapper/` - Encrypted device mappings
- `/etc/cryptsetup.d/` - LUKS keyfiles

### Environment Quick Reference

**Live USB Environment:**
- Prompt: `root@archiso ~ #`
- Mount point: `/mnt` (for installed system)
- Commands: Disk operations, installation

**Chroot Environment:**
- Prompt: `[root@archiso /]#`
- Root: `/` (installed system root)
- Commands: System configuration, package installation

**First Boot Environment:**
- Prompt: `username@hostname ~ $`
- Root: `/` (running system)
- Commands: Post-installation configuration

---

## Troubleshooting Guide

### Common Issues and Solutions

#### Boot Issues

**Problem: System won't boot / GRUB menu doesn't appear**
- **Check:** UEFI boot order (GRUB should be first)
- **Check:** EFI partition exists and is mounted correctly
- **Check:** GRUB installed correctly (`ls /boot/EFI/GRUB/`)
- **Solution:** Reinstall GRUB from live USB, verify UEFI mode

**Problem: LUKS password prompt appears but password doesn't work**
- **Check:** Keyboard layout (may be different during boot)
- **Check:** Caps Lock state
- **Check:** Passphrase is correct (copy-paste may have issues)
- **Solution:** Try typing passphrase manually, verify keyboard layout

**Problem: System boots but shows "cannot open root device"**
- **Check:** UUID in GRUB config matches actual partition UUID
- **Check:** `cryptdevice=UUID=...` parameter is correct
- **Check:** Initramfs includes encryption hooks
- **Solution:** Verify UUID with `blkid`, update GRUB config, rebuild initramfs

#### Partition and Encryption Issues

**Problem: Partition not found / "No such device"**
- **Check:** Partition exists (`lsblk` shows partition)
- **Check:** Device name is correct (`/dev/nvme0n1p4` for root)
- **Check:** Partition table written (`partprobe` executed)
- **Solution:** Re-read partition table, verify device name

**Problem: Encryption fails / "Device already in use"**
- **Check:** Partition is not mounted
- **Check:** No existing LUKS mapping (`ls /dev/mapper/`)
- **Check:** Partition is not in use by another process
- **Solution:** Close any mappings, unmount partition, verify with `lsof`

**Problem: Cannot unlock encrypted volume**
- **Check:** Passphrase is correct
- **Check:** Partition device name is correct
- **Check:** LUKS header is intact (`cryptsetup luksDump`)
- **Solution:** Verify passphrase, check for typos, verify partition

#### Network Issues

**Problem: No internet connection after first boot**
- **Check:** NetworkManager service is running (`systemctl status NetworkManager`)
- **Check:** Network interface is up (`ip link show`)
- **Check:** WiFi credentials are correct (if using WiFi)
- **Solution:** Start NetworkManager, connect to network manually, check WiFi driver

**Problem: WiFi not working (AMD RZ608)**
- **Check:** Driver is loaded (`lsmod | grep mt7921e`)
- **Check:** Firmware is installed (`ls /usr/lib/firmware/mediatek/`)
- **Check:** NetworkManager sees interface (`nmcli device status`)
- **Solution:** Load driver manually (`modprobe mt7921e`), verify firmware files exist

#### Graphics and Display Issues

**Problem: No display output / black screen**
- **Check:** Graphics drivers installed (`pacman -Q mesa vulkan-radeon`)
- **Check:** Early KMS configured (`cat /etc/mkinitcpio.conf | grep MODULES`)
- **Check:** Monitor is connected and powered
- **Solution:** Verify `amdgpu` in MODULES, rebuild initramfs, check monitor connection

**Problem: Hyprland doesn't start**
- **Check:** Hyprland is installed (`pacman -Q hyprland`)
- **Check:** Configuration file exists and is valid (`hyprctl reload`)
- **Check:** User has correct permissions
- **Solution:** Verify config syntax, check file ownership, review Hyprland logs

#### Audio Issues

**Problem: No audio output**
- **Check:** Audio codec detected (`cat /proc/asound/cards`)
- **Check:** PipeWire is running (`systemctl --user status pipewire`)
- **Check:** Audio device selected (`pactl list short sinks`)
- **Solution:** Start PipeWire, select correct audio device, verify Realtek ALC897 is detected

#### Package Installation Issues

**Problem: Package installation fails / "failed to synchronize database"**
- **Check:** Internet connection is active
- **Check:** Pacman keyring is updated (`pacman-key --refresh-keys`)
- **Check:** Mirror list is valid
- **Solution:** Update keyring, refresh mirror list, check internet connection

**Problem: "Out of disk space" during installation**
- **Check:** Available disk space (`df -h`)
- **Check:** Partition sizes are correct
- **Check:** No unnecessary packages installed
- **Solution:** Free up space, verify partition sizes, clean package cache

### Getting Help

**Official Resources:**
- [Arch Linux Forums](https://bbs.archlinux.org/)
- [Arch Linux Wiki](https://wiki.archlinux.org/)
- [Arch Linux IRC](irc://irc.libera.chat/archlinux)
- [Arch Linux Reddit](https://www.reddit.com/r/archlinux/)

**GIGABYTE Brix Specific:**
- [ArchWiki GIGABYTE Brix](https://wiki.archlinux.org/title/GIGABYTE_Brix)
- [GIGABYTE Support](https://www.gigabyte.com/Support)

**Log Files for Debugging:**
- Boot logs: `journalctl -b` (after first boot)
- System logs: `journalctl -xe`
- Hyprland logs: `~/.local/share/hyprland/hyprland.log`
- PipeWire logs: `journalctl --user -u pipewire`

### Verification Checklist After First Boot

**After first boot, verify the following:**

**System Boot:**
- [ ] GRUB menu appears with Arch Linux and Windows 11 options
- [ ] System boots to SDDM login screen (if automatic decryption enabled)
- [ ] OR system prompts for LUKS passphrase (if automatic decryption disabled)
- [ ] System completes boot successfully

**Network:**
- [ ] NetworkManager service is running (`systemctl status NetworkManager`)
- [ ] Internet connection works (`ping -c 3 archlinux.org`)
- [ ] WiFi connects automatically (if configured)
- [ ] Bluetooth works (if needed, `bluetoothctl`)

**Graphics:**
- [ ] Display output works (no black screen)
- [ ] Resolution is correct (`xrandr` or `hyprctl monitors`)
- [ ] Graphics acceleration works (`glxinfo | grep "OpenGL renderer"`)

**Audio:**
- [ ] Audio codec detected (`cat /proc/asound/cards` shows Realtek ALC897)
- [ ] PipeWire running (`systemctl --user status pipewire`)
- [ ] Audio output works (`pactl list short sinks` shows devices)

**Desktop Environment:**
- [ ] Hyprland starts successfully (select from SDDM)
- [ ] Waybar appears at top of screen
- [ ] Terminal (Kitty) launches with `Super+Q`
- [ ] File manager (Dolphin) launches with `Super+E`
- [ ] Application launcher (wofi) works with `Super+R`

**System Services:**
- [ ] SSH service running (if enabled, `systemctl status sshd`)
- [ ] NetworkManager managing network
- [ ] All essential services active

**If any item fails, refer to Troubleshooting Guide above.**

---

## References

### Academic References

[1] Fruhwirth, C. (2005). "New Methods in Hard Disk Encryption." Vienna University of Technology.

[2] Biryukov, A., Dinu, D., & Khovratovich, D. (2015). "Argon2: the memory-hard function for password hashing and other applications." Password Hashing Competition.

[3] IEEE Computer Society. (2007). "IEEE Standard for Cryptographic Protection of Data on Block-Oriented Storage Devices." IEEE Std 1619-2007.

[4] National Institute of Standards and Technology. (2012). "Recommendation for Block Cipher Modes of Operation: Methods for Key Wrapping." NIST Special Publication 800-38F.

[5] Rodeh, O., Bacik, J., & Mason, C. (2013). "BTRFS: The Linux B-Tree Filesystem." ACM Transactions on Storage, 9(3), 9:1-9:32.

[6] Collet, Y., & Kucherawy, M. (2016). "Zstandard Compression and the 'application/zstd' Media Type." RFC 8878.

### Official Documentation

- [Arch Linux Installation Guide](https://wiki.archlinux.org/title/Installation_guide)
- [ArchWiki LUKS](https://wiki.archlinux.org/title/Dm-crypt/Device_encryption)
- [ArchWiki Btrfs](https://wiki.archlinux.org/title/Btrfs)
- [ArchWiki GRUB](https://wiki.archlinux.org/title/GRUB)
- [ArchWiki Hyprland](https://wiki.archlinux.org/title/Hyprland)
- [ArchWiki PipeWire](https://wiki.archlinux.org/title/PipeWire)

### Related Documentation

- `blank_arch.md` - Vendor-neutral installation (no graphics drivers)
- `blank_intel_arch.md` - Intel CPU microcode and graphics drivers installation

---

**Document Version:** 2.0.0  
**Last Updated:** December 2, 2025  
**Author:** Arch Linux Installation Guide - GIGABYTE Brix 5300  
**Hardware:** GIGABYTE Brix 5300 barebone, AMD Ryzen 3 5300U, Radeon RX Vega  
**License:** This document is provided for educational purposes.

---

## AMD-Specific Configuration Notes

### AMD CPU Microcode

AMD microcode updates are automatically loaded by the kernel during boot. The `amd-ucode` package provides microcode updates that:

- **Security Fixes**: Address CPU security vulnerabilities (Spectre, Meltdown, etc.)
- **Stability**: Fix processor bugs and improve stability
- **Performance**: Optimize CPU performance in some cases

**Verification:**
```bash
# Check if microcode is loaded (after first boot)
dmesg | grep microcode

# Should show:
# microcode: microcode updated early to revision 0xXX, date = YYYY-MM-DD
```

### AMD Graphics Driver Configuration

**Early KMS (Kernel Mode Setting):**

For AMD graphics, early KMS enables graphics during boot (before user space starts). This is configured in `/etc/mkinitcpio.conf`:

```bash
# Edit /etc/mkinitcpio.conf
nano /etc/mkinitcpio.conf

# Find MODULES line:
MODULES=()

# Change to (add amdgpu for modern AMD graphics):
MODULES=(amdgpu)

# For older AMD GPUs (pre-GCN), use:
# MODULES=(radeon)

# Rebuild initramfs
mkinitcpio -P
```

**amdgpu** is the kernel module for modern AMD Radeon graphics (GCN architecture and newer). The Radeon RX Vega in Ryzen 3 5300U uses the **amdgpu** driver, which is included in the Linux kernel and does not require additional installation.

**GIGABYTE Brix 5300 Graphics Configuration:**
- The `amdgpu` kernel module is automatically loaded by the kernel
- Mesa drivers provide OpenGL and Vulkan support
- VA-API drivers provide hardware video acceleration
- All graphics drivers are installed in Phase 12.6 of this guide

**AMD GPU Hardware Support for GIGABYTE Brix 5300:**

- **amdgpu**: AMD GCN (Graphics Core Next) architecture and newer
  - **Radeon RX Vega** (integrated in Ryzen 3 5300U) - **FULLY SUPPORTED**
  - Radeon RX Vega uses 6 compute units (384 shader processors)
  - Based on Vega architecture (GCN 5.0)
  - Supports modern graphics APIs: OpenGL 4.6, Vulkan 1.2, DirectX 12
  - Hardware video acceleration: H.264, H.265 (HEVC), VP9, AV1 decode
  - Display outputs: HDMI 2.0, DisplayPort 1.4, USB-C (DisplayPort Alt Mode)

**GIGABYTE Brix 5300 Specific Notes:**
- The integrated Radeon RX Vega graphics are part of the Ryzen 3 5300U APU
- Uses system RAM for graphics memory (shared memory architecture)
- Recommended: Allocate 2-4 GB of system RAM for graphics (via BIOS/UEFI settings)
- For 8 GB total RAM: Allocate 2 GB for graphics (6 GB available for system)
- For 16 GB total RAM: Allocate 4 GB for graphics (12 GB available for system)

**Official Resources:**
- [ArchWiki AMDGPU](https://wiki.archlinux.org/title/AMDGPU)
- [AMD Open Source Driver Documentation](https://www.amd.com/en/support/kb/faq/gpu-57)
- [Mesa AMD Driver Documentation](https://docs.mesa3d.org/drivers/radeon.html)
- [GIGABYTE Brix 5300 Product Page](https://www.gigabyte.com/Mini-PcBarebone/GB-BRi3H-5300)
- [AMD Ryzen 3 5300U Specifications](https://www.amd.com/en/products/apu/amd-ryzen-3-5300u)
- [ArchWiki GIGABYTE Brix](https://wiki.archlinux.org/title/GIGABYTE_Brix) (general Brix series information)
