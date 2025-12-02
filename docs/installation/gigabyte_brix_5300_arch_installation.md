# Arch Linux Installation Guide - GIGABYTE Brix 5300

**Version:** 1.0.0  
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
- **Minimal Window Manager**: Wayland compositor setup with AMD Radeon RX Vega graphics drivers
- **AMD Ryzen 3 5300U Microcode**: AMD processor microcode updates for security and stability
- **AMD Radeon RX Vega Graphics Drivers**: Mesa, Vulkan, and VA-API drivers for integrated Radeon RX Vega graphics
- **Academic Documentation**: Comprehensive theoretical foundations, references, and citations

**System Specifications:**
- **Model**: GIGABYTE Brix 5300 barebone
- **Processor**: AMD Ryzen™ 3 5300U (4C/8T, 2.6-3.8 GHz, Zen 2, 15W TDP)
- **Graphics**: AMD Radeon™ RX Vega (6 compute units, integrated)
- **Memory**: Kingston FURY Impact 2×32GB DDR4 3200MHz CL20 SO-DIMM (64 GB total)
- **Storage**: M.2 NVMe SSD (user-installed, PCIe 3.0 ×4)
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
2. [Disk Partitioning Strategy](#disk-partitioning-strategy)
3. [Phase 1: Arch Linux Live USB Preparation](#phase-1-arch-linux-live-usb-preparation)
4. [Phase 2: Remote Installation via SSH (Optional)](#phase-2-remote-installation-via-ssh-optional)
5. [Phase 3: Disk Partitioning](#phase-3-disk-partitioning)
6. [Phase 4: LUKS2 Encryption Setup](#phase-4-luks2-encryption-setup)
7. [Phase 5: Btrfs Filesystem Creation](#phase-5-btrfs-filesystem-creation)
8. [Phase 6: Base System Installation](#phase-6-base-system-installation)
9. [Phase 7: System Configuration (Chroot)](#phase-7-system-configuration-chroot)
10. [Phase 8: Bootloader Installation (GRUB)](#phase-8-bootloader-installation-grub)
11. [Phase 9: Automatic LUKS Decryption Setup (Optional)](#phase-9-automatic-luks-decryption-setup-optional)
12. [Phase 10: User Account Creation](#phase-10-user-account-creation)
13. [Phase 11: Network Configuration](#phase-11-network-configuration)
14. [Phase 12: Window Manager Setup](#phase-12-window-manager-setup)
15. [Phase 13: Exit Chroot and System Reboot](#phase-13-exit-chroot-and-system-reboot)
16. [References](#references)

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
- **SUCCESS:** Minimal window manager setup with full graphics acceleration
- **SUCCESS:** Complete system ready for customization

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
| `/dev/nvme0n1p2` | 53% | ~265 GB | Microsoft basic data | NTFS | N/A | Windows 11 system partition | **No** |
| `/dev/nvme0n1p3` | 0.2% | ~1 GB | Microsoft recovery | NTFS | N/A | Windows Recovery Environment | **No** |
| `/dev/nvme0n1p4` | 45% | ~225 GB | Linux filesystem | Btrfs | `/` | Arch Linux root (encrypted) | **Yes (LUKS2)** |
| `/dev/nvme0n1p5` | 1.6% | ~8 GB | Linux swap | swap | `[SWAP]` | Encrypted swap partition | **Yes (LUKS2)** |
| **Unallocated** | 0% | 0 GB | - | - | - | **Full disk utilized** | - |

**Total Disk Usage:**
- **Windows 11:** ~266 GB (53.2%)
- **Arch Linux:** ~233 GB (46.6%)
- **Unallocated:** 0 GB (0%)
- **Total Used:** ~500 GB (100%) - **Full disk utilized**

**Detailed Breakdown:**

**Windows 11 Partitions (created during Windows installation):**
- **EFI System Partition (p1):** 512 MB
  - Shared between Windows 11 and Arch Linux
  - Contains Windows Boot Manager and GRUB bootloader
  - FAT32 filesystem (required for UEFI)

- **Windows 11 System Partition (p2):** ~265 GB (53%)
  - Windows 11 installation files
  - User data, applications, system files
  - NTFS filesystem
  - **Increased from 250 GB to 265 GB** (utilizes unallocated space)

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

**Unallocated Space: 0 GB (0%)**
- **Full disk utilization** - no unallocated space
- All 500 GB disk space is allocated to partitions
- Windows 11 partition increased to utilize remaining space

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

**TIME:** Estimated Time: 10-15 minutes  
**NEXT:** Restart Count: 0 (preparation only)

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

**NEXT:** Next: Setup SSH for remote installation (Phase 2) or proceed to disk partitioning (Phase 3)

---

## Phase 2: Remote Installation via SSH (Optional)

**TIME:** Estimated Time: 5-10 minutes  
**NEXT:** Restart Count: 0

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

**NEXT:** Next: Partition the disk (Phase 3)

---

## Phase 3: Disk Partitioning

**TIME:** Estimated Time: 5-10 minutes  
**NEXT:** Restart Count: 0

**WARNING:** CRITICAL WARNING: Double-check every command before pressing Enter

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
# Open cfdisk for your disk (replace /dev/sdX with your actual device)
cfdisk /dev/sdX

# For NVMe drives:
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
- Windows 11: ~266 GB (53%)
- Remaining: ~234 GB
- Arch Linux root: 225 GB (45% of total, ~96% of remaining)
- Swap: 8 GB (1.6% of total)
- Unallocated: 0 GB (0% - full disk utilized)

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
/dev/nvme0n1p2   ...         ...        ... 265.0G Microsoft basic data (Windows 11)
/dev/nvme0n1p3   ...         ...        ...  1.0G Microsoft reserved (Windows Recovery)
/dev/nvme0n1p4   ...         ...        ... 225.0G Linux filesystem (NEW - Arch Linux)
/dev/nvme0n1p5   ...         ...        ...  8.0G Linux swap (NEW)
```

**SUCCESS:** Verify:
- Total partitions: **5**
- nvme0n1p1: **512 MB EFI System** (Windows 11 - shared with GRUB)
- nvme0n1p2: **265.0 GB Microsoft basic data** (Windows 11 system partition) - **INCREASED from 250 GB**
- nvme0n1p3: **1.0 GB Microsoft reserved** (Windows Recovery Environment)
- nvme0n1p4: **225.0 GB Linux filesystem** (NEW - Arch Linux root, encrypted)
- nvme0n1p5: **8.0 GB Linux swap** (NEW - encrypted swap)

**Total Disk Usage Summary:**
- **Windows 11 partitions:** ~266.5 GB (53.3%) - **INCREASED from 251.5 GB**
- **Arch Linux partitions:** ~233 GB (46.6%)
- **Unallocated space:** 0 GB (0%) - **FULL DISK UTILIZED**
- **Total used:** ~500 GB (100%)

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
partprobe /dev/sdX

# List partitions again
lsblk -f

# Should now show:
# sdX
# ├─sdX1  vfat   FAT32  (EFI System)
# ├─sdX2          (Linux root - empty, will be encrypted)
# └─sdX3          (Linux swap - empty, will be encrypted)
```

**SUCCESS:** Phase 3 Complete: Disk partitioned successfully

**NEXT:** Next: Encrypt Linux partitions with LUKS2 (Phase 4)

---

## Phase 4: LUKS2 Encryption Setup

**TIME:** Estimated Time: 10-15 minutes  
**NEXT:** Restart Count: 0

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
# Replace /dev/sdX2 with your actual root partition
cryptsetup luksFormat --type luks2 \
  --cipher aes-xts-plain64 \
  --key-size 512 \
  --pbkdf argon2id \
  --iter-time 5000 \
  /dev/sdX2
```

**Prompt 1: Confirmation**
```
WARNING!
========
This will overwrite data on /dev/sdX2 irrevocably.

Are you sure? (Type 'yes' in capital letters):
```

**Type exactly:** `YES` (uppercase) and press **Enter**

**Prompt 2: Passphrase**
```
Enter passphrase for /dev/sdX2:
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

### Step 4.2: Open Encrypted Root Partition

```bash
# Unlock LUKS container and map to /dev/mapper/cryptroot
cryptsetup open /dev/sdX2 cryptroot
```

**Prompt:**
```
Enter passphrase for /dev/sdX2:
```

**Enter the passphrase** you just created and press **Enter**

**Should show:** (no output = success)

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
# Replace /dev/sdX3 with your actual swap partition
cryptsetup luksFormat --type luks2 \
  --cipher aes-xts-plain64 \
  --key-size 512 \
  --pbkdf argon2id \
  --iter-time 5000 \
  /dev/sdX3
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

### Step 4.5: Open Encrypted Swap Partition

```bash
# Unlock swap container and map to /dev/mapper/cryptswap
cryptsetup open /dev/sdX3 cryptswap
```

**Enter the SAME passphrase** as before.

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
cryptsetup luksDump /dev/sdX2 | head -20

# Should show:
# LUKS header information for /dev/sdX2
# Version:        2
# Cipher name:    aes
# Cipher mode:    xts-plain64
# Hash spec:      sha512
# Key Slot 0: ENABLED
```

**SUCCESS:** Phase 4 Complete: Both Linux partitions encrypted with LUKS2

**NEXT:** Next: Create Btrfs filesystem with subvolumes (Phase 5)

---

## Phase 5: Btrfs Filesystem Creation

**TIME:** Estimated Time: 5-10 minutes  
**NEXT:** Restart Count: 0

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
mount /dev/sdX1 /mnt/boot

# Replace /dev/sdX1 with your actual EFI partition
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

**NEXT:** Next: Install base Arch Linux system (Phase 6)

---

## Phase 6: Base System Installation

**TIME:** Estimated Time: 15-30 minutes (depends on internet speed)  
**NEXT:** Restart Count: 0

**Download Size: ~800 MB - 1.2 GB**

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

**SUCCESS:** Base system installation complete

### Step 6.3: Verify Installation

```bash
# Check that critical files were installed
ls /mnt/bin /mnt/etc /mnt/usr

# Should show directories with files
```

**SUCCESS:** Phase 6 Complete: Base Arch Linux system installed to /mnt

**NEXT:** Next: Configure system (timezone, locale, hostname) in chroot (Phase 7)

---

## Phase 7: System Configuration (Chroot)

**TIME:** Estimated Time: 10-15 minutes  
**NEXT:** Restart Count: 0

**What is chroot?**
- Change root into the new system
- Allows configuration as if you're booted into the installed system
- All following commands run inside the new Arch installation

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

### Step 7.3: Set Timezone

```bash
# Set timezone (replace with your timezone)
# Examples:
#   Europe/London
#   America/New_York
#   Asia/Tokyo
ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime

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
# Set hostname (replace "archlinux" with your desired hostname)
echo "archlinux" > /etc/hostname
```

**Configure hosts file:**
```bash
# Create /etc/hosts
cat > /etc/hosts << EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   archlinux.localdomain archlinux
EOF
```

**Verify hosts file:**
```bash
cat /etc/hosts

# Should show:
# 127.0.0.1   localhost
# ::1         localhost
# 127.0.1.1   archlinux.localdomain archlinux
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

**NEXT:** Next: Install and configure GRUB bootloader (Phase 8)

---

## Phase 8: Bootloader Installation (GRUB)

**TIME:** Estimated Time: 5-10 minutes  
**NEXT:** Restart Count: 0

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
# Replace /dev/sdX2 with your actual root partition
blkid /dev/sdX2

# Alternative: Filter only UUID value
blkid -s UUID -o value /dev/sdX2
```

**Expected output:**
```
/dev/sdX2: UUID="a1b2c3d4-e5f6-7890-abcd-ef1234567890" TYPE="crypto_LUKS" PARTUUID="..."
```

**Steps to copy UUID:**
1. Run: `blkid /dev/sdX2`
2. Look for `UUID="..."` in the output
3. Copy the value between quotes (format: `XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX`)
4. Example: `a1b2c3d4-e5f6-7890-abcd-ef1234567890`

**WARNING:** You will need this UUID in the next step (Step 8.3)

**Tip:** Write down the UUID or keep this terminal window open for reference.

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

Change to:
```bash
GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet"
```

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
Found Windows Boot Manager on /dev/sdX1@/EFI/Microsoft/Boot/bootmgfw.efi
Adding boot menu entry for UEFI Firmware Settings ...
done
```

**SUCCESS:** Phase 8 Complete: GRUB bootloader installed and configured

**NEXT:** Next: Setup automatic LUKS decryption with keyfile (Phase 9, optional)

---

## Phase 9: Automatic LUKS Decryption Setup (Optional)

**TIME:** Estimated Time: 10-15 minutes  
**NEXT:** Restart Count: 0

**What This Does:**
- Creates a keyfile for LUKS decryption
- Embeds keyfile in initramfs (boot image)
- Configures boot to auto-decrypt without password prompt
- Maintains full encryption security (data encrypted at rest)

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
# Replace /dev/sdX2 with your actual root partition
cryptsetup luksAddKey /dev/sdX2 /etc/cryptsetup.d/root.key
```

**Prompt:**
```
Enter any existing passphrase:
```

**Enter the LUKS passphrase** you created earlier during encryption.

**Should show:** (no output = success)

**Verify keyfile was added:**
```bash
cryptsetup luksDump /dev/sdX2 | grep "Key Slot"

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
# Replace /dev/sdX3 with your actual swap partition
cryptsetup luksAddKey /dev/sdX3 /etc/cryptsetup.d/root.key

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
cat > /etc/crypttab << EOF
# <name>       <device>                             <keyfile>                          <options>
cryptswap      /dev/sdX3                            /etc/cryptsetup.d/root.key         luks
EOF
```

**Replace `/dev/sdX3` with your actual swap partition**

**Verify crypttab:**
```bash
cat /etc/crypttab

# Should show:
# cryptswap /dev/sdX3 /etc/cryptsetup.d/root.key luks
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

**Note:** You can toggle this on/off anytime by modifying `/etc/mkinitcpio.conf` and rebuilding initramfs.

---

## Phase 10: User Account Creation

**TIME:** Estimated Time: 5 minutes  
**NEXT:** Restart Count: 0

### Step 10.1: Create User Account

```bash
# Create user with home directory and group memberships
# Replace "username" with your desired username
useradd -m -G wheel,video,audio,storage,input,power,network -s /bin/zsh username

# Explanation:
# -m: Create home directory (/home/username)
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
passwd username
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
id username

# Should show:
# uid=1000(username) gid=1000(username) groups=1000(username),wheel,video,audio,storage,input,power,network
```

**SUCCESS:** User created with groups and sudo access

**SUCCESS:** Phase 10 Complete: User account created

**NEXT:** Next: Configure network (Phase 11)

---

## Phase 11: Network Configuration

**TIME:** Estimated Time: 5 minutes  
**NEXT:** Restart Count: 0

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

**NEXT:** Next: Install window manager and utilities (Phase 12)

---

## Phase 12: Window Manager Setup

**TIME:** Estimated Time: 20-40 minutes (depends on internet speed)  
**NEXT:** Restart Count: 0

**Download Size: ~1.5 GB - 2 GB**

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

**Official Resources:**
- [PipeWire Website](https://pipewire.org/)
- [ArchWiki PipeWire](https://wiki.archlinux.org/title/PipeWire)

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

**SUCCESS:** Phase 12 Complete: Window manager and essential software installed, SSH enabled for remote access

**NEXT:** Next: Exit chroot and prepare for first boot (Phase 13)

---

## Phase 13: Exit Chroot and System Reboot

**TIME:** Estimated Time: 10 minutes  
**NEXT:** Restart Count: 1 (FIRST SYSTEM RESTART)

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

**NEXT:** After reboot, log in and verify system functionality

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

**Document Version:** 1.0.0  
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
