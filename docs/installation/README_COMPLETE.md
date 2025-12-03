# Arch Linux Complete Installation Guide - HP EliteBook x360 1030 G2

**Version:** 2.0.0  
**Last Updated:** December 2, 2025  
**Complete installation procedure combining pre-reboot and post-reboot configuration steps.**

This document combines [INSTALL_PRE_REBOOT.md](../INSTALL_PRE_REBOOT.md) and [INSTALL_POST_REBOOT.md](../INSTALL_POST_REBOOT.md) into a single comprehensive guide.

**Estimated Total Time**: 3-5 hours  
**Restart Count**: 1 (first system reboot between pre-reboot and post-reboot phases)

---

## Usage Modes

This documentation can be used in three ways:

### 1. AI Knowledge Base
- **For AI Assistants**: AI assistants (Cursor CLI, Claude, ChatGPT) can automatically access this documentation to provide context-aware assistance
- **Context File**: AI assistants should first check `AI_ASSISTANT_CONTEXT.md` for hardware and system context
- **Reference**: AI assistants can reference specific phases in this document when helping users

### 2. AI Instructions
- **For AI Assistants**: This document provides detailed procedures that AI assistants can follow when helping users
- **Step-by-Step**: Each phase contains complete step-by-step instructions that AI assistants can provide to users
- **Hardware-Specific**: All procedures are documented for HP EliteBook x360 1030 G2 hardware

### 3. Manual Guide
- **For Manual Execution**: This document can be followed manually, command-by-command, without any AI assistant
- **Copy-Paste Ready**: All commands are provided in code blocks and can be copied directly into terminal
- **Sequential Execution**: Follow each phase sequentially, executing commands one by one
- **No AI Required**: Complete installation can be performed manually by following instructions

**Note:** All commands are provided in executable format. Simply copy commands from code blocks and execute them in your terminal.

---

# Part 1: Pre-Reboot Installation


## Table of Contents

1. [Pre-Installation Requirements](#pre-installation-requirements)
2. [Disk Partitioning Strategy](#disk-partitioning-strategy)
3. [Phase 1: Windows 11 Installation via Windows 10 Upgrade Path](#phase-1-windows-11-installation-via-windows-10-upgrade-path)
4. [Phase 2: Arch Linux Live USB Preparation](#phase-2-arch-linux-live-usb-preparation)
5. [Phase 3: Remote Installation via SSH](#phase-3-remote-installation-via-ssh)
6. [Phase 4: Disk Partitioning with cfdisk](#phase-4-disk-partitioning-with-cfdisk)
7. [Phase 5: LUKS2 Encryption Setup](#phase-5-luks2-encryption-setup)
8. [Phase 6: Btrfs Filesystem Creation](#phase-6-btrfs-filesystem-creation)
9. [Phase 7: Base System Installation](#phase-7-base-system-installation)
10. [Phase 8: System Configuration (Chroot)](#phase-8-system-configuration-chroot)
11. [Phase 9: Bootloader Installation (GRUB)](#phase-9-bootloader-installation-grub)
12. [Phase 10: Automatic LUKS Decryption Setup (OPTIONAL)](#phase-10-automatic-luks-decryption-setup-optional)
13. [Phase 11: User Account Creation](#phase-11-user-account-creation)
14. [Phase 12: Network Configuration](#phase-12-network-configuration)
15. [Phase 13: Window Manager Setup (Hyprland)](#phase-13-window-manager-setup-hyprland)
16. [Phase 14: Exit Chroot and System Reboot](#phase-14-exit-chroot-and-system-reboot)

---

## Pre-Installation Requirements

**Hardware Prerequisites:**
- HP EliteBook x360 1030 G2 (7th Gen Intel Core i5-7300U)
- 8 GB RAM minimum
- NVMe SSD 238.5 GB total capacity
- USB flash drive (8 GB minimum) for Arch Linux ISO
- Second computer for remote SSH installation (highly recommended)
- Validity Sensors 138a:0092 fingerprint reader (built-in)

**Downloaded Files:**
- [Arch Linux ISO (latest)](https://archlinux.org/download/) - Official download page with mirrors
- [Rufus](https://rufus.ie/) - USB bootable media creation tool (Windows)
- [Windows 10 Media Creation Tool](https://www.microsoft.com/software-download/windows10) - Windows installation media
- [Windows 11 ISO](https://www.microsoft.com/software-download/windows11) - Windows 11 installation media (if not using upgrade path)

**Network Access:**
- Ethernet cable (recommended for fastest installation) OR
- WiFi credentials (SSID + password) for Intel Wireless 8265

**Important Pre-Installation Notes:**

**WARNING:** **Critical Information:**
- This guide assumes **Windows 11 is installed FIRST** (standard dual-boot scenario)
- UEFI boot mode **REQUIRED** (not legacy BIOS - verify in BIOS settings)
- Secure Boot should be **DISABLED** during Arch installation (can re-enable later with signed bootloader)
- Fast Startup in Windows 11 **MUST BE DISABLED** (prevents filesystem corruption)
- BitLocker encryption in Windows **MUST BE DISABLED** before proceeding

**What You Will Have After Installation:**
- **SUCCESS:** Dual-boot system: Windows 11 + Arch Linux with GRUB menu
- **SUCCESS:** LUKS2 full-disk encryption (AES-XTS-PLAIN64, 512-bit key)
- **SUCCESS:** Optional automatic LUKS decryption on boot (can be toggled for security)
- **SUCCESS:** Btrfs filesystem with automatic snapshots ([Timeshift](https://github.com/teejee2008/timeshift))
- **SUCCESS:** Fingerprint authentication for sudo and login
- **SUCCESS:** [Hyprland](https://hyprland.org/) Wayland compositor with dynamic effects
- **SUCCESS:** [Plymouth](https://www.freedesktop.org/wiki/Software/Plymouth) boot splash screen
- **SUCCESS:** Complete window manager (Hyprland) and essential applications ready to use

---

## Disk Partitioning Strategy

**Final Partition Layout (NVMe SSD 238.5 GB):**

| Partition | Size | Type | Filesystem | Mount Point | Purpose | Encrypted |
|-----------|------|------|------------|-------------|---------|-----------|
| `/dev/nvme0n1p1` | 512 MB | EFI System | FAT32 | `/boot` | UEFI bootloader (GRUB) | **No** |
| `/dev/nvme0n1p2` | 159.2 GB | Microsoft basic data | NTFS | N/A | Windows 11 system partition | **No** |
| `/dev/nvme0n1p3` | 826 MB | Microsoft recovery | NTFS | N/A | Windows Recovery Environment | **No** |
| `/dev/nvme0n1p4` | 70 GB | Linux filesystem | Btrfs | `/` | Arch Linux root (encrypted) | **SUCCESS:** Yes (LUKS2) |
| `/dev/nvme0n1p5` | 8 GB | Linux swap | swap | `[SWAP]` | Encrypted swap partition | **SUCCESS:** Yes (LUKS2) |

**Encryption Details:**
- Algorithm: AES-XTS-PLAIN64
- Key size: 512-bit (maximum security)
- Key derivation: Argon2id (LUKS2 default, memory-hard)
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

## Phase 1: Windows 11 Installation via Windows 10 Upgrade Path

****TIME:** Estimated Time: 60-90 minutes** (includes Windows 10 installation + upgrade to Windows 11)

****NEXT:** Restart Count: 4-5 automatic restarts** (2-3 during Windows 10 installation, 1-2 during Windows 11 upgrade)

**Installation Strategy:**
This guide uses a **Windows 10 → Windows 11 upgrade path** to preserve OEM drivers for HP EliteBook x360 1030 G2. Installing Windows 10 first ensures that manufacturer-specific drivers (touchscreen, fingerprint sensor, IR camera, power management) are automatically included in the installation media, eliminating the need for manual driver installation after Windows 11 upgrade.

**Why This Approach:**
- **HP EliteBook x360 1030 G2** requires specific OEM drivers for full hardware functionality
- Windows 10 Media Creation Tool includes device-specific drivers when created on the target hardware
- Upgrading to Windows 11 with "Keep personal files and apps" preserves all installed drivers
- Alternative (direct Windows 11 installation) would require manual driver installation from HP Support website

---

### Step 1.1: Prepare BIOS Settings

1. **Power on HP EliteBook x360 1030 G2**
2. **Press F10 repeatedly** during HP logo to enter BIOS Setup
3. **Navigate to Boot Options**
4. **Verify UEFI Boot Mode**:
   - Boot Mode: **UEFI Native (Without CSM)**
   - If set to "Legacy", change to UEFI
5. **Disable Secure Boot** (temporarily):
   - Security → Secure Boot Configuration
   - Secure Boot: **Disabled**
6. **Save and Exit** (F10 → Yes)

---

### Step 1.2: Create Windows 10 Installation Media with OEM Drivers

**On a Windows computer (can be the HP EliteBook itself if Windows is already installed):**

1. **Download Windows 10 Media Creation Tool**:
   - Visit: https://www.microsoft.com/software-download/windows10
   - Click **"Download tool now"**
   - Save `MediaCreationTool.exe` to desktop

2. **Run Media Creation Tool**:
   - Right-click `MediaCreationTool.exe` → **Run as administrator**
   - Accept license terms
   - Select **"Create installation media (USB flash drive, DVD, or ISO file)"**
   - Click **Next**

3. **Configure Installation Media**:
   - **Language**: Select your language (e.g., English)
   - **Edition**: Select **Windows 10** (Home or Pro, matching your license)
   - **Architecture**: Select **64-bit (x64)**
   - Click **Next**

4. **Select Media Type**:
   - Choose **"USB flash drive"**
   - Insert **USB flash drive** (8 GB minimum, will be formatted)
   - Select the USB drive from the list
   - Click **Next**

5. **Media Creation Process**:
   - Tool downloads Windows 10 ISO (~4-5 GB)
   - Tool creates bootable USB with Windows 10 installation files
   - **Important**: If running on HP EliteBook x360 1030 G2, the tool automatically includes device-specific drivers in the installation media
   - Process takes 15-30 minutes depending on internet speed
   - Click **Finish** when complete

**Result**: USB flash drive contains Windows 10 installation with HP EliteBook x360 1030 G2 drivers pre-included.

---

### Step 1.3: Boot from Windows 10 Installation Media

1. **Insert Windows 10 USB** installation media into HP EliteBook
2. **Power on and press F9** (Boot Device Options)
3. **Select USB drive** from boot menu
4. Windows 10 Setup should load (~30 seconds)

---

### Step 1.4: Windows 10 Installation Wizard

1. **Language, Time, Keyboard**: Select your preferences
2. Click **Install Now**
3. **Product Key**:
   - Enter Windows 10 product key OR
   - Select "I don't have a product key" (activate later)
4. **Select Windows 10 Edition**:
   - Choose: Home, Pro, or Enterprise (matching your license)
5. **Accept License Terms** → Check box → Next
6. **Installation Type**: Select **Custom: Install Windows only (advanced)**

---

### Step 1.5: Partition Windows Manually (Critical Step)

****WARNING:** IMPORTANT: This step determines dual-boot success**

In the Windows partition screen:

1. **Delete all existing partitions** (if this is a fresh install):
   - Select each partition
   - Click **Delete**
   - Confirm deletion
   - You should now have "Unallocated Space: 238.5 GB"

2. **Create Windows partition**:
   - Click **New**
   - Size: Enter `163000` MB (159.2 GB + overhead)
   - Click **Apply**
   - Windows will create 3 partitions automatically:
     - **System** (EFI): 512 MB
     - **MSR** (Reserved): 16 MB
     - **Primary**: 159.2 GB (Windows installation target)
     - **Recovery**: 826 MB

3. **Verify free space**:
   - You should see **~78 GB unallocated space** remaining
   - This is for Arch Linux (70 GB root + 8 GB swap)

4. **Select Windows Primary partition** (largest one, ~159 GB)
5. Click **Next**
6. **Wait for installation** (15-25 minutes)
   - Windows 10 will copy files
   - **OEM drivers are automatically installed** during this phase
   - System will restart 2-3 times automatically
   - **Do not touch USB or keyboard during this phase**

---

### Step 1.6: Windows 10 OOBE (Out of Box Experience)

After automatic restarts, Windows 10 setup wizard appears:

1. **Region**: Select your country
2. **Keyboard Layout**: Select your layout
3. **Network**: Connect to WiFi OR click "I don't have internet" (skip for now)
4. **Account Setup**:
   - **Option 1**: Create local account (recommended for privacy)
   - **Option 2**: Sign in with Microsoft account
5. **Privacy Settings**:
   - Disable all telemetry options (recommended)
   - Location: Off
   - Diagnostics: Required only
   - Inking: Off
   - Advertising: Off
6. **Skip OneDrive** setup
7. **Wait for desktop** to load

---

### Step 1.7: Verify OEM Drivers Installation

1. **Open Device Manager**:
   - Press **Win+X** → **Device Manager**

2. **Verify critical devices** (should show no yellow warning triangles):
   - **Display adapters**: Intel HD Graphics 620 (driver installed)
   - **Human Interface Devices**: Touchscreen, trackpad (drivers installed)
   - **Biometric devices**: Validity Sensors 138a:0092 (if visible)
   - **Cameras**: HP HD Camera, HP IR Camera (drivers installed)
   - **Network adapters**: Intel Wireless 8265 (driver installed)
   - **Bluetooth**: Intel Bluetooth (driver installed)

3. **Test hardware functionality**:
   - Touchscreen: Tap screen (should respond)
   - Trackpad: Move cursor (should work)
   - Camera: Open Camera app (should detect cameras)
   - WiFi: Connect to network (should work)

****SUCCESS:** If all devices show proper drivers, proceed to Windows 11 upgrade**

---

### Step 1.8: Upgrade Windows 10 to Windows 11

**Method 1: Windows Update (Recommended)**

1. **Open Windows Update**:
   - Press **Win+I** → **Update & Security** → **Windows Update**
   - Click **Check for updates**

2. **Install Windows 11 Upgrade**:
   - If Windows 11 upgrade is available, it will appear as "Windows 11, version 22H2" or similar
   - Click **Download and install**
   - **Important**: During upgrade, select **"Keep personal files and apps"** (this preserves OEM drivers)
   - Wait for download and installation (20-40 minutes)
   - System will restart 1-2 times automatically

**Method 2: HP Support Assistant (Alternative)**

1. **Install HP Support Assistant** (if not already installed):
   - Download from: https://support.hp.com/us-en/help/hp-support-assistant
   - Install and launch HP Support Assistant

2. **Check for Windows 11 Upgrade**:
   - HP Support Assistant may offer Windows 11 upgrade option
   - Follow on-screen instructions
   - **Important**: Ensure "Keep personal files and apps" is selected

**Method 3: Windows 11 Installation Assistant (Manual)**

1. **Download Windows 11 Installation Assistant**:
   - Visit: https://www.microsoft.com/software-download/windows11
   - Click **"Download Now"** under Windows 11 Installation Assistant
   - Run `Windows11InstallationAssistant.exe`

2. **Run Installation Assistant**:
   - Accept license terms
   - **Critical**: Select **"Change what to keep"** → **"Keep personal files and apps"**
   - Click **Install**
   - Wait for upgrade process (20-40 minutes)
   - System will restart 1-2 times automatically

****WARNING:** CRITICAL: Always select "Keep personal files and apps" during upgrade to preserve OEM drivers**

---

### Step 1.9: Verify Windows 11 Installation and Drivers

1. **Check Windows version**:
   - Press **Win+R** → Type `winver` → Press Enter
   - Should show: "Windows 11 Version 22H2" or later

2. **Verify drivers are preserved**:
   - Open **Device Manager** (Win+X → Device Manager)
   - Check that all devices still show proper drivers (no yellow triangles)
   - Test hardware: touchscreen, trackpad, cameras, WiFi

3. **If drivers are missing**:
   - Download HP Support Assistant: https://support.hp.com/us-en/help/hp-support-assistant
   - Run driver updates through HP Support Assistant
   - OR manually download drivers from: https://support.hp.com/us-en/drivers/hp-elitebook-x360-1030-g2-notebook-pc

---

### Step 1.10: Disable Fast Startup (Prevents Filesystem Corruption)

****WARNING:** CRITICAL: Skipping this will cause data corruption in dual-boot**

1. **Right-click Start** → **Power Options**
2. Click **Additional power settings**
3. Click **Choose what the power buttons do**
4. Click **Change settings that are currently unavailable**
5. **Uncheck "Turn on fast startup (recommended)"**
6. Click **Save changes**

---

### Step 1.11: Verify Disk Layout in Windows 11

1. **Press Win+X** → **Disk Management**
2. Verify partition layout:
   - EFI System Partition: 512 MB
   - Windows (C:): 159.2 GB (NTFS)
   - Recovery: 826 MB
   - **Unallocated**: ~78 GB (critical - this is for Arch)
3. If unallocated space is missing, **DO NOT PROCEED** - redo partitioning

---

### Step 1.12: Shut Down Windows Completely

1. **Click Start** → **Power** → **Shut down** (NOT Restart)
2. Wait for system to power off completely
3. **Remove Windows 10 USB** installation media (if still inserted)

****SUCCESS:** Phase 1 Complete: Windows 11 is installed via upgrade path, OEM drivers preserved, Fast Startup disabled, ~78 GB free for Arch**

****NEXT:** Next: Insert Arch Linux USB and proceed to Phase 2**

---

## Phase 2: Arch Linux Live USB Preparation

****TIME:** Estimated Time: 10-15 minutes**

****NEXT:** Restart Count: 0 (preparation only)**

### Step 2.1: Download Arch Linux ISO

On your **second computer** (preparation machine):

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

### Step 2.2: Create Bootable USB

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
9. **Cluster size**: 4096 bytes (default)
10. Click **START**
11. **Write mode**: Select "DD Image" (important!)
12. Click **OK** to confirm
13. Wait for completion (3-5 minutes)
14. Click **CLOSE**

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

### Step 2.3: Boot into Arch Linux Live Environment

1. **Shut down HP EliteBook** completely
2. **Insert Arch Linux USB** into HP EliteBook
3. **Power on** and **press F9 repeatedly** (Boot Device Options)
4. **Select USB drive** from boot menu
5. **GRUB menu** appears:
   - Select: **Arch Linux install medium (x86_64, UEFI)** (first option)
   - Press **Enter**
6. **Wait for boot** to complete (~30-60 seconds)
7. **You should see**:
   ```
   Arch Linux 6.x.x-arch1-1 (tty1)

   archiso login: root (automatic login)
   root@archiso ~ #
   ```

****SUCCESS:** You are now in Arch Linux live environment**

### Step 2.4: Verify UEFI Boot Mode

```bash
# Verify UEFI mode (not BIOS)
ls /sys/firmware/efi/efivars

# If this directory exists and shows files, you are in UEFI mode **SUCCESS:**
# If error "No such file or directory", you booted in BIOS mode ❌ (restart and fix BIOS settings)
```

### Step 2.5: Set Larger Console Font (Optional, for readability)

```bash
# Increase console font size for easier reading
setfont ter-132b
```

****SUCCESS:** Phase 2 Complete: Booted into Arch Linux live USB in UEFI mode**

****NEXT:** Next: Setup SSH for remote installation (Phase 3)**

---

## Phase 3: Remote Installation via SSH

****TIME:** Estimated Time: 5-10 minutes**

****NEXT:** Restart Count: 0**

**Why Remote SSH Installation?**

Installing via SSH from a second computer provides:
- **SUCCESS:** Ability to copy-paste commands from this guide (zero typing errors)
- **SUCCESS:** Reference documentation on second screen while installing
- **SUCCESS:** More comfortable than working on laptop keyboard
- **SUCCESS:** Ability to save command history for future reference

### Step 3.1: Set Root Password on Live USB

On the **Arch Linux live environment** (HP EliteBook console):

```bash
# Set temporary root password for SSH access
passwd

# Enter new password: (choose temporary password, e.g., "install123")
# Retype new password: (confirm)
```

**Note:** This password is **temporary** and only for SSH access during installation.

### Step 3.2: Start SSH Server

```bash
# Start SSH daemon
systemctl start sshd

# Verify SSH is running
systemctl status sshd

# Should show: "active (running)" in green
# Press 'q' to exit status view
```

### Step 3.3: Connect to WiFi (Intel Wireless 8265)

**Skip this step if using Ethernet cable**

```bash
# Launch iwctl (interactive WiFi tool)
iwctl

# You are now in iwctl prompt: [iwd]#
```

**Inside iwctl prompt, execute:**

```bash
# List WiFi devices
device list
# Should show: wlp58s0 (HP EliteBook x360 1030 G2)

# Scan for networks
station wlp58s0 scan

# Wait 3 seconds for scan to complete

# List available networks
station wlp58s0 get-networks
# Shows list of SSIDs with signal strength

# Connect to your network (replace "YourSSID" with your actual WiFi name)
station wlp58s0 connect "YourSSID"

# Enter passphrase: (type your WiFi password)

# Exit iwctl
exit
```

**Verify internet connection:**

```bash
# Test internet connectivity
ping -c 3 archlinux.org

# Should show successful replies:
# 64 bytes from archlinux.org (95.217.163.246): icmp_seq=1 ttl=54 time=12.3 ms
# If timeout, troubleshoot WiFi connection before continuing
```

### Step 3.4: Find IP Address of Laptop

```bash
# Get IP address assigned to WiFi interface
ip -brief addr show wlp58s0

# Example output (HP EliteBook x360 1030 G2):
# wlp58s0          UP             192.168.0.39/24 fe80::f416:ffe7:fa47:67c5/64

# If using Ethernet (eth0 or enp2s0):
ip -brief addr show

# Note the IP address (e.g., 192.168.0.39)
```

### Step 3.5: Connect from Second Computer

On your **second computer** (the one you'll use for installation):

**Linux/macOS:**
```bash
# SSH into the HP EliteBook
ssh root@192.168.0.39

# Replace 192.168.0.39 with actual IP from previous step
```

**Windows (PowerShell or Windows Terminal):**
```powershell
# SSH into the HP EliteBook
ssh root@192.168.0.39
```

**First connection warning:**
```
The authenticity of host '192.168.0.39' can't be established.
ED25519 key fingerprint is SHA256:XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
```

Type `yes` and press Enter.

**Enter password:** (the temporary password you set earlier)

**You should now see:**
```
root@archiso ~ #
```

****SUCCESS:** You are now connected via SSH and ready to install**

**All remaining commands will be executed on your second computer via SSH.**

****SUCCESS:** Phase 3 Complete: SSH connection established to HP EliteBook**

****NEXT:** Next: Partition the disk with cfdisk (Phase 4)**

---

## Phase 4: Disk Partitioning with cfdisk

****TIME:** Estimated Time: 5-10 minutes**

****NEXT:** Restart Count: 0**

****WARNING:** CRITICAL WARNING: Double-check every command before pressing Enter**

### Step 4.1: Verify Existing Windows Partitions

```bash
# List all block devices and partitions
lsblk

# Expected output:
# NAME        MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
# nvme0n1     259:0    0 238.5G  0 disk
# ├─nvme0n1p1 259:1    0   512M  0 part  (EFI System)
# ├─nvme0n1p2 259:2    0 159.2G  0 part  (Windows 11)
# ├─nvme0n1p3 259:3    0   826M  0 part  (Windows Recovery)
# └─(free space ~78 GB - not shown yet)
```

**Verify:**
- **SUCCESS:** Three partitions exist (p1, p2, p3)
- **SUCCESS:** Total used space: ~160 GB
- **SUCCESS:** Free space: ~78 GB remaining

If partition count is wrong, **STOP** and verify Windows installation.

### Step 4.2: Launch cfdisk Partition Editor

```bash
# Open cfdisk for /dev/nvme0n1
cfdisk /dev/nvme0n1

# Partition table type should already be: gpt
# If asked "Select label type", choose: gpt
```

**cfdisk Text UI appears with partition table**

### Step 4.3: Navigate cfdisk Interface

**cfdisk Keyboard Controls:**
- **↑ ↓ Arrow Keys**: Select partition
- **← → Arrow Keys**: Select menu option (New, Delete, Type, Write, Quit)
- **Enter**: Execute selected menu option
- **Esc**: Cancel current operation

**Current partition list should show:**
```
Device          Start        End    Sectors  Size Type
/dev/nvme0n1p1   2048    1050623    1048576  512M EFI System
/dev/nvme0n1p2   ...         ...        ... 159.2G Microsoft basic data
/dev/nvme0n1p3   ...         ...        ...  826M Microsoft reserved
Free space       ...         ...        ...   ~78G
```

### Step 4.4: Create Linux Root Partition (70 GB)

1. **Use arrow keys** to navigate to **Free space** row (~78 GB)
2. **Press Enter** on **[ New ]** menu option
3. **Partition size**: Type `70G` and press **Enter**
4. Partition type will default to **Linux filesystem** (correct, do not change)

**New partition created: /dev/nvme0n1p4 (70 GB, Linux filesystem)**

### Step 4.5: Create Linux Swap Partition (8 GB)

1. **Use arrow keys** to navigate to remaining **Free space** row (~8 GB)
2. **Press Enter** on **[ New ]** menu option
3. **Partition size**: Type `8G` and press **Enter**
4. **Navigate to the newly created 8 GB partition** (should be /dev/nvme0n1p5)
5. **Press Enter** on **[ Type ]** menu option
6. **Scroll down** to find **Linux swap** (type code 19 or 82)
7. **Press Enter** to select Linux swap

**New partition created: /dev/nvme0n1p5 (8 GB, Linux swap)**

### Step 4.6: Verify Final Partition Layout

**Your partition table should now look exactly like this:**

```
Device          Start        End    Sectors  Size Type
/dev/nvme0n1p1   2048    1050623    1048576  512M EFI System
/dev/nvme0n1p2   ...         ...        ... 159.2G Microsoft basic data
/dev/nvme0n1p3   ...         ...        ...  826M Microsoft reserved
/dev/nvme0n1p4   ...         ...        ...   70G Linux filesystem
/dev/nvme0n1p5   ...         ...        ...    8G Linux swap
```

****SUCCESS:** Verify:**
- Total partitions: **5**
- nvme0n1p1: **512M EFI System**
- nvme0n1p2: **159.2G Microsoft basic data**
- nvme0n1p3: **826M Microsoft reserved**
- nvme0n1p4: **70G Linux filesystem** (NEW)
- nvme0n1p5: **8G Linux swap** (NEW)

**If anything is wrong, DO NOT WRITE. Press 'q' to quit without saving and start over.**

### Step 4.7: Write Changes to Disk

****WARNING:** FINAL WARNING: This step is IRREVERSIBLE**

1. **Navigate to** **[ Write ]** menu option
2. **Press Enter**
3. **Confirmation prompt**: `Are you sure you want to write the partition table to disk? (yes or no):`
4. **Type exactly**: `yes` (lowercase, no quotes)
5. **Press Enter**
6. **Should show**: `The partition table has been altered.`
7. **Navigate to** **[ Quit ]** menu option
8. **Press Enter** to exit cfdisk

### Step 4.8: Verify Partition Table Was Written

```bash
# Force kernel to re-read partition table
partprobe /dev/nvme0n1

# List partitions again
lsblk -f

# Should now show:
# nvme0n1
# ├─nvme0n1p1  vfat   FAT32  (EFI System)
# ├─nvme0n1p2  ntfs          (Windows 11)
# ├─nvme0n1p3  ntfs          (Recovery)
# ├─nvme0n1p4                (Linux root - empty, will be encrypted)
# └─nvme0n1p5                (Linux swap - empty, will be encrypted)
```

****SUCCESS:** Phase 4 Complete: Disk partitioned successfully (5 partitions)**

****NEXT:** Next: Encrypt Linux partitions with LUKS2 (Phase 5)**

---

## Phase 5: LUKS2 Encryption Setup

****TIME:** Estimated Time: 10-15 minutes**

****NEXT:** Restart Count: 0**

### 5.1 Theoretical Foundation of Disk Encryption

#### 5.1.1 Introduction to LUKS

The Linux Unified Key Setup (LUKS) specification, first introduced in 2005, establishes a standardized format for encrypted disk partitions on Linux systems [1]. LUKS addresses the fundamental challenge of transparent disk encryption: providing strong cryptographic protection while maintaining compatibility across different Linux distributions and tools.

The LUKS specification defines a header structure that contains all necessary metadata for encryption, including cipher specifications, key derivation parameters, and key slot information. This header-based approach enables interoperability—a LUKS-encrypted partition created on one distribution can be decrypted on another, provided the necessary tools are available.

#### 5.1.2 LUKS2 Architecture and Design Principles

LUKS2, introduced in 2016 as part of cryptsetup 2.0.0, represents a significant evolution from LUKS1. The design addresses several limitations of the original specification while maintaining backward compatibility where possible.

**Key Architectural Improvements:**

1. **Multiple Key Slots**: LUKS2 supports up to 32 key slots (compared to 8 in LUKS1), enabling more flexible key management strategies. Each key slot can contain either a passphrase-derived key or a keyfile-derived key, allowing for multiple authentication methods on a single encrypted volume.

2. **Modern Key Derivation Functions**: LUKS2 adopts Argon2id as the default Password-Based Key Derivation Function (PBKDF), replacing the PBKDF2 algorithm used in LUKS1. Argon2, the winner of the Password Hashing Competition (2015), provides superior resistance to both time-memory trade-off attacks and side-channel attacks [2].

3. **Metadata Integrity Protection**: LUKS2 includes integrity protection for metadata structures, preventing tampering with encryption headers. This is achieved through cryptographic checksums embedded in the header structure.

4. **Per-Segment Encryption**: LUKS2 supports segment-based encryption, allowing different encryption parameters for different regions of the disk. This enables optimization for specific use cases, such as using different ciphers for different data types.

5. **Active Development**: LUKS2 is actively maintained and receives new features, while LUKS1 is in maintenance mode with only security updates.

#### 5.1.3 Cryptographic Primitives and Algorithm Selection

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

The "PLAIN64" designation refers to 64-bit sector addressing, which enables encryption of disks larger than 2TB. This is essential for modern storage devices, including the NVMe SSDs used in this configuration.

#### 5.1.4 Key Derivation: Argon2id Analysis

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

#### 5.1.5 Security Model and Threat Analysis

**Threat Model:**

The encryption configuration addresses the following threat scenarios:

1. **Physical Theft**: Protection against unauthorized access when the device is stolen or lost. The encrypted data remains inaccessible without the passphrase or keyfile.

2. **Unauthorized Physical Access**: Protection against access by individuals with temporary physical access to the device (e.g., device left unattended).

3. **Data Recovery After Disposal**: Protection against data recovery from disposed or sold hardware.

**Security Trade-offs:**

**Automatic Decryption via Keyfile:**

The implementation uses a keyfile embedded in the initramfs to enable passwordless boot. This design decision involves a security trade-off:

- **Convenience**: Eliminates the need for passphrase entry during every boot, improving user experience.
- **Security Reduction**: If an attacker gains physical access to the `/boot` partition (which is unencrypted, as required by UEFI), they can extract the keyfile from the initramfs and decrypt the data.

**Risk Assessment:**

For a personal laptop deployment under the user's physical control, this trade-off is considered acceptable because:
- The device remains encrypted when powered off (protection against theft).
- The keyfile extraction requires physical access and technical expertise.
- The passphrase remains valid as a backup authentication method (key slot 0).
- The convenience benefit significantly outweighs the marginal security reduction for this use case.

For higher-security deployments (e.g., corporate laptops, systems with sensitive data), passphrase-only authentication or TPM-based key management should be considered.

#### 5.1.6 Performance Characteristics

**Hardware Acceleration:**

Modern x86-64 processors (including the Intel Core i5-7300U in this configuration) include AES-NI (AES New Instructions), which provide dedicated CPU instructions for AES encryption and decryption operations.

**Performance Impact:**

Empirical measurements on similar hardware configurations indicate:
- **Encryption/Decryption Overhead**: 1-3% CPU utilization during active disk I/O operations.
- **Sequential Read Performance**: Negligible impact (< 1% reduction) due to hardware acceleration.
- **Random Access Performance**: Minimal impact (< 2% reduction) due to XTS mode's random-access optimization.
- **Boot Time Impact**: Keyfile-based decryption adds approximately 0.5-1 second to boot time.

These performance characteristics make full-disk encryption practical for daily use without noticeable degradation in system responsiveness.

**References:**

[1] Fruhwirth, C. (2005). "New Methods in Hard Disk Encryption." Vienna University of Technology.  
[2] Biryukov, A., Dinu, D., & Khovratovich, D. (2015). "Argon2: the memory-hard function for password hashing and other applications." Password Hashing Competition.  
[3] IEEE Computer Society. (2007). "IEEE Standard for Cryptographic Protection of Data on Block-Oriented Storage Devices." IEEE Std 1619-2007.  
[4] National Institute of Standards and Technology. (2012). "Recommendation for Block Cipher Modes of Operation: Methods for Key Wrapping." NIST Special Publication 800-38F.

---

### Step 5.1: Encrypt Root Partition (/dev/nvme0n1p4)

****WARNING:** You will create a LUKS passphrase - choose a STRONG passphrase (minimum 20 characters recommended)**

```bash
# Create LUKS2 encrypted container on root partition
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

****WARNING:** CRITICAL: Memorize this passphrase or store in password manager - if lost, data is UNRECOVERABLE**

**Prompt 3: Verify passphrase**
```
Verify passphrase:
```

**Re-type the EXACT SAME passphrase** and press **Enter**

**Wait for completion** (30-60 seconds - shows progress bar)

**Should show:** `Command successful.`

### Step 5.2: Open Encrypted Root Partition

```bash
# Unlock LUKS container and map to /dev/mapper/cryptroot
cryptsetup open /dev/nvme0n1p4 cryptroot
```

**Prompt:**
```
Enter passphrase for /dev/nvme0n1p4:
```

**Enter the passphrase** you just created and press **Enter**

**Should show:** (no output = success)

### Step 5.3: Verify Encrypted Root Volume

```bash
# Check that cryptroot is available
ls -la /dev/mapper/

# Should show:
# total 0
# crw------- 1 root root 10, 236 Dec  1 15:00 control
# lrwxrwxrwx 1 root root       7 Dec  1 15:01 cryptroot -> ../dm-0
```

****SUCCESS:** cryptroot is now unlocked and ready**

### Step 5.4: Encrypt Swap Partition (/dev/nvme0n1p5)

```bash
# Create LUKS2 encrypted container on swap partition
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

****WARNING:** IMPORTANT: Use the SAME passphrase as root partition** (for simplicity during boot)

**Enter the SAME passphrase** twice.

**Wait for completion** (30-60 seconds)

### Step 5.5: Open Encrypted Swap Partition

```bash
# Unlock swap container and map to /dev/mapper/cryptswap
cryptsetup open /dev/nvme0n1p5 cryptswap
```

**Enter the SAME passphrase** as before.

### Step 5.6: Verify Both Encrypted Volumes

```bash
# List all mapped devices
ls -la /dev/mapper/

# Should show:
# control
# cryptroot -> ../dm-0
# cryptswap -> ../dm-1
```

****SUCCESS:** Both partitions are now encrypted and unlocked**

### Step 5.7: Verify Encryption Details

```bash
# Display LUKS header information for root partition
cryptsetup luksDump /dev/nvme0n1p4 | head -20

# Should show:
# LUKS header information for /dev/nvme0n1p4
# Version:        2
# Cipher name:    aes
# Cipher mode:    xts-plain64
# Hash spec:      sha512
# Key Slot 0: ENABLED
```

****SUCCESS:** Phase 5 Complete: Both Linux partitions encrypted with LUKS2**

****NEXT:** Next: Create Btrfs filesystem with subvolumes (Phase 6)**

---

## Phase 6: Btrfs Filesystem Creation

****TIME:** Estimated Time: 5-10 minutes**

****NEXT:** Restart Count: 0**

### 6.1 Theoretical Foundation of Copy-on-Write Filesystems

#### 6.1.1 Introduction to Btrfs

Btrfs (B-tree filesystem) is a modern copy-on-write (CoW) filesystem developed for Linux, first merged into the mainline kernel in 2009. The filesystem was designed to address fundamental limitations of traditional filesystems (ext4, XFS) while providing advanced features such as built-in snapshots, checksums, and compression [5].

The B-tree data structure, from which Btrfs derives its name, provides efficient indexing and enables the filesystem to scale to very large sizes (up to 16 exbibytes) while maintaining consistent performance characteristics. Btrfs represents a paradigm shift from traditional in-place modification filesystems to a copy-on-write architecture that fundamentally changes how data integrity and system recovery are achieved.

#### 6.1.2 Copy-on-Write Architecture: Principles and Implementation

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

**Mathematical Foundation:**

The copy-on-write operation can be represented as:

```
Original State: F = {B₁, B₂, ..., Bₙ}
Modify Block Bᵢ → B'ᵢ

CoW Operation:
1. Allocate new block B'ᵢ
2. Write new data to B'ᵢ
3. Update pointer: P(Bᵢ) → P(B'ᵢ)
4. Original Bᵢ remains until no references exist

New State: F' = {B₁, B₂, ..., B'ᵢ, ..., Bₙ}
```

This mechanism ensures that the filesystem can always revert to a previous consistent state, as the original blocks remain available until explicitly freed.

#### 6.1.3 Snapshot Mechanism and Space Efficiency

**Snapshot Creation:**

Btrfs snapshots are implemented through reference counting and shared block allocation. When a snapshot is created:

1. **Instant Creation**: The snapshot creation is effectively instantaneous (typically < 1 second) regardless of filesystem size, as it only involves creating new metadata structures that reference existing data blocks.

2. **Shared Blocks**: The snapshot and the original filesystem share all data blocks initially. Only when a block is modified in either the original or the snapshot does Btrfs allocate a new block (copy-on-write).

3. **Space Efficiency**: The space overhead of a snapshot is proportional to the amount of data that differs between the snapshot and the current state, not the total filesystem size.

**Space Efficiency Analysis:**

The space efficiency of Btrfs snapshots can be quantified as:

```
Space_Used = Original_Data + Σ(Modified_Blocks_in_Snapshot_i)

For N snapshots with average modification rate r:
Space_Overhead ≈ N × r × Original_Data

Typical values: r = 0.05-0.15 (5-15% of data changes between snapshots)
```

This contrasts with traditional snapshot mechanisms (e.g., LVM snapshots) where:

```
Space_Used = Original_Data + N × Original_Data (full copy required)
```

#### 6.1.4 Data Integrity: Checksums and Error Detection

**Checksum Implementation:**

Btrfs stores cryptographic checksums (CRC32C by default, with optional SHA-256) for all data and metadata blocks. This enables:

1. **Silent Corruption Detection**: Btrfs can detect data corruption that occurs during storage or transmission, even if the corruption doesn't cause immediate filesystem errors.

2. **Automatic Repair**: When Btrfs is configured with redundancy (mirrors or RAID), it can automatically repair corrupted blocks using the redundant copies.

3. **Verification**: Users can verify filesystem integrity at any time using the `btrfs scrub` command, which reads all data blocks and verifies their checksums.

**Error Detection Probability:**

For a filesystem using CRC32C checksums (32-bit), the probability of undetected corruption is approximately 2⁻³² ≈ 2.3 × 10⁻¹⁰ per block. For a 1TB filesystem with 4KB blocks (approximately 2.68 × 10⁸ blocks), the expected number of undetected corruptions is less than 0.1, making checksum-based detection highly reliable.

#### 6.1.5 Compression: Algorithms and Performance Trade-offs

**Transparent Compression:**

Btrfs supports transparent compression, where data is compressed before being written to disk and decompressed when read. The compression is transparent to applications—they read and write data normally, unaware of the compression layer.

**Compression Algorithms:**

Btrfs supports three compression algorithms:

1. **zlib**: Traditional DEFLATE-based compression. Provides good compression ratios (typically 2:1 to 3:1) but higher CPU overhead.

2. **lzo**: Fast compression algorithm optimized for speed. Provides moderate compression (typically 1.5:1 to 2:1) with minimal CPU overhead.

3. **zstd (Zstandard)**: Modern compression algorithm developed by Facebook. Provides compression ratios similar to zlib (2:1 to 3:1) with performance closer to lzo.

**Performance Analysis:**

Empirical measurements on typical workloads indicate:

- **zstd Compression Ratio**: 20-30% space savings on average (varies significantly by data type).
- **CPU Overhead**: 5-15% during write operations, negligible during read operations (decompression is faster than disk I/O).
- **I/O Reduction**: 20-30% reduction in disk I/O operations, which can improve performance on I/O-bound workloads.

**Selection Rationale:**

zstd is selected for this configuration because:
- **Performance**: zstd provides the best balance between compression ratio and CPU overhead.
- **Modern Design**: zstd is actively developed and optimized for modern CPUs.
- **Standard Practice**: zstd has become the recommended default for Btrfs in recent kernel versions.

#### 6.1.6 Subvolume Architecture and Organizational Strategy

**Subvolume Concept:**

Btrfs subvolumes are independent filesystem roots within a single Btrfs filesystem. Each subvolume can be:
- Mounted independently with different options
- Snapshotted independently
- Assigned independent quotas
- Managed with different policies

**Subvolume Layout Rationale:**

The selected subvolume structure (`@`, `@home`, `@log`, `@cache`, `@snapshots`) is designed to optimize snapshot management and system recovery:

1. **@ (root subvolume)**: Contains system files (`/bin`, `/etc`, `/usr`, `/var`, etc.). Including this in snapshots enables complete system state restoration, allowing rollback to a previous system configuration.

2. **@home**: Contains user home directories. Including this in snapshots preserves user data along with system state, enabling complete system restoration including user files.

3. **@log**: Contains system logs (`/var/log`). Excluded from snapshots because:
   - Logs are transient and change frequently
   - Historical log versions are rarely needed for system recovery
   - Excluding logs reduces snapshot size and improves snapshot creation speed

4. **@cache**: Contains package cache (`/var/cache`). Excluded from snapshots because:
   - Cache can be regenerated (downloaded packages can be re-downloaded)
   - Cache changes frequently, increasing snapshot overhead
   - Excluding cache significantly reduces snapshot size

5. **@snapshots**: Dedicated subvolume for Timeshift snapshots. Separating snapshots into their own subvolume prevents recursive snapshot issues and simplifies snapshot management.

**Mount Options Rationale:**

- **compress=zstd**: Enables transparent compression for all subvolumes, providing space savings without application changes.
- **noatime**: Disables access time updates, reducing write operations and improving performance, especially on SSDs where write endurance is a consideration.

#### 6.1.7 Comparison with Alternative Filesystems

**Btrfs vs. ext4:**

| Feature | ext4 | Btrfs |
|---------|------|-------|
| Maximum Filesystem Size | 1 EiB | 16 EiB |
| Built-in Snapshots | No | Yes |
| Data Checksums | No | Yes |
| Transparent Compression | No | Yes |
| Copy-on-Write | No | Yes |
| Maturity | Very High | High |
| Performance (Sequential) | Excellent | Excellent |
| Performance (Random) | Excellent | Very Good |

**Btrfs vs. ZFS:**

ZFS (Zettabyte File System) provides similar features to Btrfs but has different characteristics:

- **Licensing**: ZFS uses CDDL license, which is incompatible with GPL. This creates licensing concerns for Linux kernel integration.
- **Memory Requirements**: ZFS has higher memory requirements, making it less suitable for systems with limited RAM.
- **Linux Integration**: Btrfs is natively integrated into the Linux kernel, while ZFS requires external kernel modules.

**Selection Justification:**

Btrfs is selected for this configuration because:
- Native Linux kernel integration (no licensing concerns)
- Lower memory requirements (suitable for 8GB RAM system)
- Excellent snapshot support (critical for system recovery)
- Built-in compression (important for limited storage: 238.5 GB)
- Active development and strong community support

**References:**

[5] Rodeh, O., Bacik, J., & Mason, C. (2013). "BTRFS: The Linux B-Tree Filesystem." ACM Transactions on Storage, 9(3), 9:1-9:32.  
[6] Collet, Y., & Kucherawy, M. (2016). "Zstandard Compression and the 'application/zstd' Media Type." RFC 8878.

---

### Step 6.1: Format Root Partition with Btrfs

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

### Step 6.2: Mount Btrfs Root Temporarily

```bash
# Mount encrypted Btrfs partition to /mnt
mount /dev/mapper/cryptroot /mnt
```

### Step 6.3: Create Btrfs Subvolumes

****WARNING:** Subvolume names MUST match exactly (@ symbol is critical)**

```bash
# Create @ subvolume (root filesystem)
btrfs subvolume create /mnt/@

# Create @home subvolume (user home directories)
btrfs subvolume create /mnt/@home

# Create @log subvolume (system logs)
btrfs subvolume create /mnt/@log

# Create @cache subvolume (package cache)
btrfs subvolume create /mnt/@cache

# Create @snapshots subvolume (Timeshift snapshots)
btrfs subvolume create /mnt/@snapshots
```

**Each command should output:**
```
Create subvolume '/mnt/@'
Create subvolume '/mnt/@home'
...
```

### Step 6.4: Verify Subvolumes Were Created

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

****SUCCESS:** All 5 subvolumes created successfully**

### Step 6.5: Unmount and Remount with Subvolumes

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

### Step 6.6: Create Mount Point Directories

```bash
# Create directories for mount points
mkdir -p /mnt/{home,var/log,var/cache,boot,.snapshots}
```

### Step 6.7: Mount All Btrfs Subvolumes

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

### Step 6.8: Mount EFI Boot Partition

```bash
# Mount existing EFI partition (created by Windows)
mount /dev/nvme0n1p1 /mnt/boot
```

****WARNING:** This partition is SHARED between Windows and Linux bootloaders**

### Step 6.9: Format and Enable Swap

```bash
# Create swap filesystem on encrypted swap partition
mkswap /dev/mapper/cryptswap

# Output:
# Setting up swapspace version 1, size = 8 GiB (8589930496 bytes)
# no label, UUID=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX

# Enable swap
swapon /dev/mapper/cryptswap
```

### Step 6.10: Verify All Mounts

```bash
# Check complete mount hierarchy
lsblk -f

# Should show:
# nvme0n1
# ├─nvme0n1p1
# │ vfat        FAT32                                    /mnt/boot
# ├─nvme0n1p2
# │ ntfs
# ├─nvme0n1p3
# │ ntfs
# ├─nvme0n1p4
# │ crypto_LUKS 2
# │ └─cryptroot
# │   btrfs           Arch Linux                         /mnt/.snapshots
# │                                                       /mnt/var/cache
# │                                                       /mnt/var/log
# │                                                       /mnt/home
# │                                                       /mnt
# └─nvme0n1p5
#   crypto_LUKS 2
#   └─cryptswap
#     swap                                                [SWAP]
```

****SUCCESS:** Verify:**
- /mnt - mounted (@ subvolume)
- /mnt/home - mounted (@home subvolume)
- /mnt/var/log - mounted (@log subvolume)
- /mnt/var/cache - mounted (@cache subvolume)
- /mnt/.snapshots - mounted (@snapshots subvolume)
- /mnt/boot - mounted (EFI partition)
- SWAP - active (cryptswap)

****SUCCESS:** Phase 6 Complete: Btrfs filesystem with 5 subvolumes + swap active**

****NEXT:** Next: Install base Arch Linux system (Phase 7)**

---

## Phase 7: Base System Installation

****TIME:** Estimated Time: 15-30 minutes (depends on internet speed)**

****NEXT:** Restart Count: 0**

**Download Size: ~800 MB - 1.2 GB**

### Step 7.1: Update Pacman Mirror List (for faster downloads)

```bash
# Backup original mirrorlist
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup

# Sort mirrors by speed using reflector
reflector --country US,Germany,France,Czechia \
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

### Step 7.2: Install Base System and Essential Packages

****WARNING:** This is a LARGE command - copy entire block carefully**

```bash
pacstrap /mnt \
  base \
  base-devel \
  linux \
  linux-firmware \
  linux-headers \
  intel-ucode \
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
- `intel-ucode` - Intel CPU microcode updates
  - [ArchWiki Microcode](https://wiki.archlinux.org/title/Microcode)
  - [Intel Microcode Updates](https://github.com/intel/Intel-Linux-Processor-Microcode-Data-Files)

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
- `os-prober` - Detect other operating systems (Windows 11)
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

****SUCCESS:** Base system installation complete**

### Step 7.3: Verify Installation

```bash
# Check that critical files were installed
ls /mnt/bin /mnt/etc /mnt/usr

# Should show directories with files
```

****SUCCESS:** Phase 7 Complete: Base Arch Linux system installed to /mnt**

****NEXT:** Next: Configure system (timezone, locale, hostname) in chroot (Phase 8)**

---

## Phase 8: System Configuration (Chroot)

****TIME:** Estimated Time: 10-15 minutes**

****NEXT:** Restart Count: 0**

**What is chroot?**
- Change root into the new system
- Allows configuration as if you're booted into the installed system
- All following commands run inside the new Arch installation

### Step 8.1: Generate Fstab (Filesystem Table)

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

****SUCCESS:** Fstab generated successfully**

### Step 8.2: Chroot into New System

```bash
# Change root into the new Arch installation
arch-chroot /mnt
```

**Prompt changes to:**
```
[root@archiso /]#
```

****SUCCESS:** You are now INSIDE the new Arch system**

****WARNING:** ALL REMAINING COMMANDS RUN INSIDE CHROOT (until we exit later)**

### Step 8.3: Set Timezone

```bash
# Set timezone to Prague (Czechia)
ln -sf /usr/share/zoneinfo/Europe/Prague /etc/localtime

# Generate /etc/adjtime
hwclock --systohc
```

**Verify timezone:**
```bash
timedatectl status

# Should show:
# Time zone: Europe/Prague (CET, +0100)
```

### Step 8.4: Set Locale (Language and Character Encoding)

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

### Step 8.5: Set Hostname

```bash
# Set hostname to "elitebook"
echo "elitebook" > /etc/hostname
```

**Configure hosts file:**
```bash
# Create /etc/hosts
cat > /etc/hosts << EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   elitebook.localdomain elitebook
EOF
```

**Verify hosts file:**
```bash
cat /etc/hosts

# Should show:
# 127.0.0.1   localhost
# ::1         localhost
# 127.0.1.1   elitebook.localdomain elitebook
```

### Step 8.6: Set Root Password

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

****SUCCESS:** Root password set**

### Step 8.7: Configure Pacman (Enable Multilib and Parallel Downloads)

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

****SUCCESS:** Phase 8 Complete: System configured (timezone, locale, hostname, root password)**

****NEXT:** Next: Install and configure GRUB bootloader (Phase 9)**

---

## Phase 9: Bootloader Installation (GRUB)

****TIME:** Estimated Time: 5-10 minutes**

****NEXT:** Restart Count: 0**

**[GRUB](https://www.gnu.org/software/grub/) (GRand Unified Bootloader):**
- Manages dual-boot menu (Arch Linux + Windows 11)
- Handles LUKS decryption parameters
- Displays boot options with 5-second timeout
- **Official Resources:**
  - [GNU GRUB Website](https://www.gnu.org/software/grub/)
  - [ArchWiki GRUB](https://wiki.archlinux.org/title/GRUB)
  - [GRUB Manual](https://www.gnu.org/software/grub/manual/)

### Step 9.1: Install GRUB to EFI Partition

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

****SUCCESS:** GRUB installed to EFI partition**

### Step 9.2: Get UUID of Encrypted Root Partition

**What is UUID?**
UUID (Universally Unique Identifier) is a permanent identifier for disk partitions. GRUB needs the UUID to locate the encrypted partition during boot.

```bash
# Display ALL partition UUIDs
blkid

# Display only encrypted root partition UUID
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

****WARNING:** You will need this UUID in the next step (Step 9.3)**

**Tip:** Write down the UUID or keep this terminal window open for reference.


### Step 9.3: Configure GRUB for LUKS Encryption

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
GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet splash vt.handoff=7 plymouth.enable=1 usbcore.autosuspend=-1"
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

Uncomment (remove #):
```bash
GRUB_DISABLE_OS_PROBER=false
```

**Parameter Explanation:**
- `cryptdevice=UUID=...:cryptroot` - Decrypt LUKS partition and name it "cryptroot"
- `root=/dev/mapper/cryptroot` - Use decrypted device as root
- `rootflags=subvol=@` - Mount Btrfs @ subvolume as root
- `GRUB_DISABLE_OS_PROBER=false` - Allow detection of Windows 11

**Save and exit** (Ctrl+O, Enter, Ctrl+X)

### Step 9.4: Generate GRUB Configuration

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
Warning: os-prober will be executed to detect other bootable partitions.
Found Windows Boot Manager on /dev/nvme0n1p1@/EFI/Microsoft/Boot/bootmgfw.efi
Adding boot menu entry for UEFI Firmware Settings ...
done
```

****SUCCESS:** Verify "Found Windows Boot Manager" appears** - this confirms dual-boot will work

**If Windows is NOT detected:**
```bash
# Manually run os-prober
os-prober

# Should show:
# /dev/nvme0n1p2@/EFI/Microsoft/Boot/bootmgfw.efi:Windows Boot Manager:Windows:efi

# Then regenerate GRUB config
grub-mkconfig -o /boot/grub/grub.cfg
```

****SUCCESS:** Phase 9 Complete: GRUB bootloader installed and configured for dual-boot**

****NEXT:** Next: Setup automatic LUKS decryption with keyfile (Phase 10)**

---

## Phase 10: Automatic LUKS Decryption Setup

****TIME:** Estimated Time: 10-15 minutes**

****NEXT:** Restart Count: 0**

**What This Does:**
- Creates a keyfile for LUKS decryption
- Embeds keyfile in initramfs (boot image)
- Configures boot to auto-decrypt without password prompt
- Maintains full encryption security (data encrypted at rest)

**Security Note:**
- Keyfile is in `/boot` (unencrypted partition)
- Physical access to `/boot` allows decryption
- Acceptable for personal laptop under your control
- If higher security needed, keep password prompt enabled

### Step 10.1: Create Keyfile Directory

```bash
# Create directory for LUKS keyfile
mkdir -p /etc/cryptsetup.d

# Set strict permissions (root-only access)
chmod 700 /etc/cryptsetup.d
```

### Step 10.2: Generate LUKS Keyfile

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

### Step 10.3: Add Keyfile to LUKS Key Slot

```bash
# Add keyfile to LUKS key slot 1 (slot 0 has your passphrase)
cryptsetup luksAddKey /dev/nvme0n1p4 /etc/cryptsetup.d/root.key
```

**Prompt:**
```
Enter any existing passphrase:
```

**Enter the LUKS passphrase** you created earlier during encryption.

**Should show:** (no output = success)

**Verify keyfile was added:**
```bash
cryptsetup luksDump /dev/nvme0n1p4 | grep "Key Slot"

# Should show:
# Key Slot 0: ENABLED
# Key Slot 1: ENABLED
# Key Slot 2: DISABLED
# ...
```

****SUCCESS:** Keyfile added to LUKS**

### Step 10.4: Add Keyfile to Swap Partition (Same Process)

```bash
# Add keyfile to encrypted swap partition
cryptsetup luksAddKey /dev/nvme0n1p5 /etc/cryptsetup.d/root.key

# Enter existing passphrase: (same as before)
```

### Step 10.5: Configure Initramfs to Include Keyfile

```bash
# Edit /etc/mkinitcpio.conf
nano /etc/mkinitcpio.conf
```

**Find and modify these lines:**

**Line 1: MODULES**

Find:
```bash
MODULES=()
```

Change to:
```bash
MODULES=(i915)
```

**i915** = Intel graphics driver (enables early KMS - Kernel Mode Setting)

**Line 2: FILES**

Find:
```bash
FILES=()
```

Change to:
```bash
FILES=(/etc/cryptsetup.d/root.key)
```

**This embeds the keyfile into initramfs**

**Line 3: HOOKS**

Find:
```bash
HOOKS=(base udev autodetect modconf block filesystems keyboard fsck)
```

Change to:
```bash
HOOKS=(base udev autodetect modconf block encrypt filesystems keyboard fsck)
```

**Added:** `encrypt` hook (handles LUKS decryption at boot)

****WARNING:** CRITICAL: Order matters:**
- `block` MUST come BEFORE `encrypt`
- `encrypt` MUST come BEFORE `filesystems`
- `keyboard` should come AFTER `filesystems`

**Save and exit** (Ctrl+O, Enter, Ctrl+X)

### Step 10.6: Update GRUB for Keyfile

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

****WARNING:** REPLACE UUID with your actual UUID from blkid**

**Parameter added:** `cryptkey=rootfs:/etc/cryptsetup.d/root.key`

**Save and exit** (Ctrl+O, Enter, Ctrl+X)

### Step 10.7: Configure Encrypted Swap Auto-Unlock

```bash
# Create /etc/crypttab for swap
cat > /etc/crypttab << EOF
# <name>       <device>                             <keyfile>                          <options>
cryptswap      /dev/nvme0n1p5                       /etc/cryptsetup.d/root.key         luks
EOF
```

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

### Step 10.8: Rebuild Initramfs and GRUB

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

# Should show "Found Windows Boot Manager" again
```

### Step 10.9: Verify Keyfile is in Initramfs

```bash
# List contents of initramfs
lsinitcpio /boot/initramfs-linux.img | grep root.key

# Should show:
# etc/cryptsetup.d/root.key
```

****SUCCESS:** Keyfile is embedded in initramfs**

****SUCCESS:** Phase 10 Complete: Automatic LUKS decryption configured**

**Note:** You can toggle this on/off anytime using instructions in Step 10.10 below.

---

### Step 10.10: How to Toggle Automatic Decryption (Security Management)

#### 10.10.1 Security Management Rationale

**Dynamic Security Posture:**

Modern security best practices recommend adapting security measures based on threat context. For laptop systems, the threat model changes significantly between:
- **Home/Office Environment**: Controlled physical access, lower theft risk
- **Mobile/Travel Environment**: Uncontrolled physical access, higher theft risk

**Security Trade-off Analysis:**

| Scenario | Automatic Decryption | Password Prompt | Risk Level |
|----------|---------------------|-----------------|------------|
| Home/Office | ✅ Convenient | ⚠️ Inconvenient | Low |
| Travel/Public | ❌ High Risk | ✅ Secure | High |
| Development | ✅ Efficient | ⚠️ Slows workflow | Low |

**Official Resources:**
- [ArchWiki Dm-crypt/Device Encryption](https://wiki.archlinux.org/title/Dm-crypt/Device_encryption)
- [ArchWiki Dm-crypt/System Configuration](https://wiki.archlinux.org/title/Dm-crypt/System_configuration)
- [cryptsetup Manual](https://gitlab.com/cryptsetup/cryptsetup/-/wikis/DMCrypt)
- [mkinitcpio Documentation](https://wiki.archlinux.org/title/Mkinitcpio)

**After completing Phase 10, you can easily enable/disable automatic decryption based on your security needs.**

#### 10.10.2 Disable Automatic Decryption (Enable Password Prompt)

**When to disable:**
- Taking laptop outside (travel, coffee shop, etc.)
- High-security environments
- Shared or public spaces

**Method 1: Remove keyfile from initramfs (Recommended)**

This method removes the keyfile from the initramfs image, requiring passphrase entry at boot:

```bash
# Edit /etc/mkinitcpio.conf
sudo nano /etc/mkinitcpio.conf

# Find FILES line:
FILES=(/etc/cryptsetup.d/root.key)

# Change to (remove keyfile):
FILES=()

# Save and exit (Ctrl+O, Enter, Ctrl+X)

# Rebuild initramfs (without keyfile)
sudo mkinitcpio -P

# Verify keyfile is NOT in initramfs
lsinitcpio /boot/initramfs-linux.img | grep root.key
# Should show: (no output = keyfile removed)
```

**Result:** System will prompt for LUKS passphrase at boot (key slot 0)

**Advantages:**
- Keyfile remains in LUKS key slot (can be re-enabled quickly)
- No need to re-add keyfile to LUKS
- Reversible without passphrase entry

**Method 2: Remove keyfile from LUKS key slot**

This method removes the keyfile from the LUKS key slot entirely:

```bash
# Remove keyfile from LUKS key slot 1
sudo cryptsetup luksRemoveKey /dev/nvme0n1p4 /etc/cryptsetup.d/root.key

# Also remove from swap partition
sudo cryptsetup luksRemoveKey /dev/nvme0n1p5 /etc/cryptsetup.d/root.key

# Verify key slot 1 is disabled
sudo cryptsetup luksDump /dev/nvme0n1p4 | grep "Key Slot"
# Should show: Key Slot 1: DISABLED
```

**Result:** Keyfile cannot unlock partition (only passphrase works)

**Advantages:**
- More secure (keyfile cannot be used even if extracted)
- Prevents keyfile-based attacks

**Disadvantages:**
- Requires passphrase to re-add keyfile
- More permanent (requires re-running Phase 10 steps)

**Official Resources:**
- [cryptsetup luksRemoveKey Manual](https://man.archlinux.org/man/cryptsetup.8#luksRemoveKey)
- [ArchWiki Dm-crypt/Device Encryption#Keyfiles](https://wiki.archlinux.org/title/Dm-crypt/Device_encryption#Keyfiles)

#### 10.10.3 Re-enable Automatic Decryption

**When to re-enable:**
- Back at home/secure location
- Development/testing phase
- Frequent reboots needed

**If you used Method 1 (removed from initramfs):**

```bash
# Edit /etc/mkinitcpio.conf
sudo nano /etc/mkinitcpio.conf

# Find FILES line:
FILES=()

# Change to (add keyfile back):
FILES=(/etc/cryptsetup.d/root.key)

# Save and exit

# Rebuild initramfs (with keyfile)
sudo mkinitcpio -P

# Verify keyfile is in initramfs
lsinitcpio /boot/initramfs-linux.img | grep root.key
# Should show: etc/cryptsetup.d/root.key
```

**If you used Method 2 (removed key slot):**

```bash
# Re-add keyfile to LUKS key slot 1
sudo cryptsetup luksAddKey /dev/nvme0n1p4 /etc/cryptsetup.d/root.key

# Enter passphrase when prompted

# Also add to swap partition
sudo cryptsetup luksAddKey /dev/nvme0n1p5 /etc/cryptsetup.d/root.key

# Verify key slot 1 is enabled
sudo cryptsetup luksDump /dev/nvme0n1p4 | grep "Key Slot"
# Should show: Key Slot 1: ENABLED

# Rebuild initramfs to include keyfile
sudo mkinitcpio -P
```

**Result:** System will boot automatically without password prompt

**Official Resources:**
- [cryptsetup luksAddKey Manual](https://man.archlinux.org/man/cryptsetup.8#luksAddKey)
- [ArchWiki Mkinitcpio#FILES](https://wiki.archlinux.org/title/Mkinitcpio#FILES)

#### 10.10.4 Quick Toggle Script (Optional)

**Convenience Script Architecture:**

For frequent toggling, a convenience script automates the process:

```bash
# Create toggle script
sudo nano /usr/local/bin/toggle-luks-auto

# Paste this content:
#!/bin/bash
# Toggle automatic LUKS decryption
# Based on: ArchWiki Dm-crypt/Device Encryption

CONFIG_FILE="/etc/mkinitcpio.conf"
KEYFILE_PATH="/etc/cryptsetup.d/root.key"

if grep -q "FILES=($KEYFILE_PATH)" "$CONFIG_FILE"; then
    # Currently enabled, disable it
    echo "Disabling automatic LUKS decryption..."
    sudo sed -i "s|FILES=($KEYFILE_PATH)|FILES=()|" "$CONFIG_FILE"
    sudo mkinitcpio -P
    echo "✓ Automatic decryption DISABLED (password prompt enabled)"
else
    # Currently disabled, enable it
    echo "Enabling automatic LUKS decryption..."
    sudo sed -i "s|FILES=()|FILES=($KEYFILE_PATH)|" "$CONFIG_FILE"
    sudo mkinitcpio -P
    echo "✓ Automatic decryption ENABLED (no password prompt)"
fi

# Make executable
sudo chmod +x /usr/local/bin/toggle-luks-auto
```

**Usage:**
```bash
# Toggle automatic decryption on/off
sudo toggle-luks-auto
```

**Script Design Rationale:**
- Uses `grep` to detect current state (more reliable than file comparison)
- Uses `sed` for in-place editing (preserves file structure)
- Calls `mkinitcpio -P` to rebuild initramfs immediately
- Provides clear feedback on state change

**Security Best Practice:**
- **Before travel**: Run `sudo toggle-luks-auto` to disable automatic decryption
- **After returning**: Run `sudo toggle-luks-auto` to re-enable (if desired)

**References:**

[34] Arch Linux Developers. (2002-2025). "Dm-crypt/Device Encryption." ArchWiki.  
[35] cryptsetup Contributors. (2005-2025). "cryptsetup - Disk Encryption Setup." cryptsetup Documentation.  
[36] Arch Linux Developers. (2002-2025). "Mkinitcpio - Arch Linux initramfs generator." ArchWiki.

---

****NEXT:** Next: Create user account (Phase 11)**

---

## Phase 11: User Account Creation

****TIME:** Estimated Time: 5 minutes**

****NEXT:** Restart Count: 0**

### Step 11.1: Create User Account "hp"

```bash
# Create user 'hp' with home directory and group memberships
useradd -m -G wheel,video,audio,storage,input,power,network -s /bin/zsh hp

# Explanation:
# -m: Create home directory (/home/hp)
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

### Step 11.2: Set User Password

```bash
# Set password for user hp
passwd hp
```

**Prompt:**
```
New password:
```

**Enter:** `<YOUR_PASSWORD>`

**Retype password:** `<YOUR_PASSWORD>`

****SUCCESS:** User password set**

### Step 11.3: Configure Sudo Access

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

### Step 11.4: Verify User Was Created

```bash
# Check user information
id hp

# Should show:
# uid=1000(hp) gid=1000(hp) groups=1000(hp),wheel,video,audio,storage,input,power,network
```

****SUCCESS:** User "hp" created with groups and sudo access**

****SUCCESS:** Phase 11 Complete: User account "hp" created with password <YOUR_PASSWORD>**

****NEXT:** Next: Configure network (Phase 12)**

---

## Phase 12: Network Configuration

****TIME:** Estimated Time: 5 minutes**

****NEXT:** Restart Count: 0**

### Step 12.1: Enable NetworkManager Service

```bash
# Enable NetworkManager to start on boot
systemctl enable NetworkManager

# Output:
# Created symlink /etc/systemd/system/multi-user.target.wants/NetworkManager.service → /usr/lib/systemd/system/NetworkManager.service
# Created symlink /etc/systemd/system/dbus-org.freedesktop.nm-dispatcher.service → /usr/lib/systemd/system/NetworkManager-dispatcher.service
# Created symlink /etc/systemd/system/network-online.target.wants/NetworkManager-wait-online.service → /usr/lib/systemd/system/NetworkManager-wait-online.service
```

****SUCCESS:** NetworkManager will start automatically on boot**

### Step 12.2: Install Bluetooth Packages

```bash
# Install Bluetooth stack
pacman -S bluez bluez-utils

# bluez: Bluetooth protocol stack
# bluez-utils: bluetoothctl and other tools
```

**Prompt:**
```
Proceed with installation? [Y/n]
```

**Press Enter** (default is Yes)

### Step 12.3: Enable Bluetooth Service

```bash
# Enable Bluetooth daemon to start on boot
systemctl enable bluetooth

# Output:
# Created symlink /etc/systemd/system/dbus-org.bluez.service → /usr/lib/systemd/system/bluetooth.service
# Created symlink /etc/systemd/system/bluetooth.target.wants/bluetooth.service → /usr/lib/systemd/system/bluetooth.service
```

****SUCCESS:** Phase 12 Complete: NetworkManager and Bluetooth enabled**

****NEXT:** Next: Install window manager (Hyprland) and utilities (Phase 13)**

---

## Phase 13: Window Manager Setup (Hyprland)

****TIME:** Estimated Time: 20-40 minutes (depends on internet speed)**

****NEXT:** Restart Count: 0**

**Download Size: ~1.5 GB - 2 GB**

### Step 13.1: Install Hyprland Window Manager

### 13.1 Theoretical Foundation of Wayland and Compositors

#### 13.1.1 Introduction to Display Servers

A display server is the software component responsible for managing input devices (keyboard, mouse, touchscreen) and output devices (monitors, displays) and coordinating communication between applications and graphics hardware. The display server architecture has evolved significantly since the introduction of the X Window System in 1984.

**X11 Architecture:**

The X Window System (X11) employs a client-server model:

```
Applications (X Clients)
    ↓ (X Protocol)
X Server
    ↓
Graphics Driver
    ↓
Hardware (GPU)
```

**X11 Limitations:**

1. **Security Model**: X11 has no built-in security model. Any X client can:
   - Capture keyboard input from other applications (keylogging)
   - Capture screen content from other windows
   - Inject input events into other applications
   - Monitor window events (focus, movement, etc.)

2. **Network Transparency**: While network transparency was a design goal, it introduces security vulnerabilities and complexity.

3. **Legacy Code**: X11 contains decades of legacy code, making it difficult to maintain and optimize.

4. **Multi-Monitor Support**: X11's multi-monitor support is limited, especially with mixed refresh rates and resolutions.

5. **Performance**: The client-server architecture introduces latency, and the protocol is not optimized for modern GPU-accelerated rendering.

**Wayland Architecture:**

Wayland is a modern display server protocol introduced in 2008. Unlike X11, Wayland uses a different architecture:

```
Applications (Wayland Clients)
    ↓ (Wayland Protocol)
Compositor (Display Server + Window Manager + Compositor)
    ↓
Graphics Driver (via EGL/GBM)
    ↓
Hardware (GPU)
```

**Wayland Advantages:**

1. **Security**: Each application can only access its own windows. Screen capture and input injection require explicit permission.

2. **Simplified Architecture**: The compositor handles everything (display server, window manager, compositor) in a single process, reducing complexity.

3. **Modern Design**: Wayland is designed for modern graphics stacks (OpenGL, Vulkan) and GPU acceleration.

4. **Multi-Monitor**: Excellent support for different resolutions, refresh rates, and display configurations.

5. **Performance**: Lower latency, better GPU utilization, more efficient rendering pipeline.

**Official Resources:**
- [Wayland Website](https://wayland.freedesktop.org/)
- [Wayland Architecture](https://wayland.freedesktop.org/architecture.html)
- [Wayland Protocol Specification](https://wayland.freedesktop.org/docs/html/)
- [ArchWiki Wayland](https://wiki.archlinux.org/title/Wayland)
- [Wayland on Wikipedia](https://en.wikipedia.org/wiki/Wayland_(protocol))

#### 13.1.2 Compositor Architecture

**What is a Compositor?**

In Wayland, the compositor combines the roles of:
- **Display Server**: Manages input/output devices
- **Window Manager**: Controls window placement, sizing, and behavior
- **Compositor**: Combines application windows into final display output

**Compositing Process:**

The compositing process involves:

1. **Window Rendering**: Each application renders its window content to an off-screen buffer (using EGL/GBM or similar APIs).

2. **Compositor Processing**: The compositor receives window buffers and applies:
   - Window positioning and sizing
   - Visual effects (transparency, blur, shadows)
   - Animation and transitions
   - Damage tracking (only redraw changed regions)

3. **Final Output**: The compositor combines all windows into a single frame and presents it to the display.

**Performance Considerations:**

Modern compositors use GPU acceleration for:
- **Blending**: Combining multiple windows with transparency
- **Effects**: Blur, shadows, and other visual effects
- **Animation**: Smooth window transitions and animations

#### 13.1.3 Hyprland: Architecture and Design

**[Hyprland](https://hyprland.org/)** is a dynamic tiling Wayland compositor written in C++, first released in 2021. It combines the efficiency of tiling window managers (like i3wm) with modern visual effects and GPU acceleration.

**Design Philosophy:**

Hyprland is designed around several core principles:

1. **Performance First**: Written in C++ for speed, uses modern GPU features, optimized rendering pipeline
2. **Keyboard-Driven**: Primary interaction via keyboard, minimal mouse usage
3. **Highly Configurable**: Extensive configuration options via text file
4. **Modern Effects**: Built-in support for blur, shadows, transparency, animations
5. **Dynamic Tiling**: Automatic window tiling with manual override capability

**Architecture Components:**

```
┌─────────────────────────────────────┐
│         Applications                │
│  (Kitty, Firefox, Neovim, etc.)     │
└──────────────┬──────────────────────┘
               │ Wayland Protocol
┌──────────────▼──────────────────────┐
│         Hyprland Compositor         │
│  (Window Management + Compositing)  │
│  - Dynamic Tiling Engine            │
│  - Effect Pipeline (blur, shadows)  │
│  - Animation System                 │
│  - Input Handling                   │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│      Wayland Protocol (wlroots)     │
│  - wlroots: Wayland compositor      │
│    foundation library               │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│      Graphics Driver (Mesa)        │
│      (Intel HD Graphics 620)        │
│  - EGL/GBM for GPU access          │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│         Hardware (GPU)               │
└─────────────────────────────────────┘
```

**wlroots Foundation:**

Hyprland is built on [wlroots](https://gitlab.freedesktop.org/wlroots/wlroots), a modular Wayland compositor library that provides:
- **DRM/KMS Backend**: Direct Rendering Manager/Kernel Mode Setting for display management
- **Input Handling**: Keyboard, mouse, touchscreen, tablet support
- **EGL/GBM Integration**: OpenGL ES and Generic Buffer Management for GPU access
- **Wayland Protocol Implementation**: Core Wayland protocol support

**Official Resources:**
- [Hyprland Website](https://hyprland.org/)
- [Hyprland GitHub](https://github.com/hyprwm/Hyprland)
- [Hyprland Wiki](https://wiki.hyprland.org/)
- [ArchWiki Hyprland](https://wiki.archlinux.org/title/Hyprland)
- [wlroots Documentation](https://gitlab.freedesktop.org/wlroots/wlroots)

#### 13.1.4 Compositor Selection: Hyprland vs. Alternatives

**sway:**

sway is an i3wm-compatible Wayland compositor, also built on wlroots:

**Advantages:**
- **i3wm Compatibility**: Configuration files and keybindings compatible with i3wm
- **Mature**: More established, larger user base
- **Stability**: Very stable, battle-tested

**Limitations:**
- **Effects**: Limited built-in effects (blur, animations require patches)
- **Performance**: Written in C (slower than C++)
- **Features**: More minimal, fewer built-in features

**Note on Desktop Environments vs Window Managers:**

This configuration uses **Hyprland**, which is a **window manager** (compositor), not a full desktop environment. Desktop environments like KDE Plasma or GNOME include:
- Window manager
- File manager
- Panel/status bar
- Application launcher
- System settings
- Default applications suite

Hyprland is a standalone window manager, so we install individual applications as needed:
- **File manager**: Dolphin (standalone KDE application)
- **Status bar**: Waybar (standalone application)
- **Application launcher**: Albert (standalone application)
- **Terminal**: Kitty (standalone application)

This modular approach provides:
- **Lightweight**: Only install what you need
- **Flexibility**: Choose best application for each task
- **Performance**: Lower resource usage than full desktop environments

**Hyprland Selection Rationale:**

Hyprland is selected for this configuration because:

1. **Performance**: C++ implementation and GPU optimization provide excellent performance
2. **Modern Effects**: Built-in blur, shadows, and animations without performance penalty
3. **Keyboard-Driven**: Perfect for vim-style navigation workflow
4. **Laptop Optimized**: Excellent power management, touchscreen support, trackpad gestures
5. **Active Development**: Rapid development, new features regularly
6. **Configuration**: Highly configurable via text file
7. **Lightweight**: Lower resource usage than full desktop environments

**References:**

[9] Høgsberg, K. (2008). "Wayland - A New Display Server Protocol." freedesktop.org.  
[10] Hyprland Contributors. (2021-2025). "Hyprland - A Wayland Compositor." GitHub Repository.

---

### Understanding Hyprland and Wayland

**What is Wayland?**

Wayland is a modern display server protocol that replaces X11 (X Window System). Think of it as the communication protocol between applications and your graphics hardware.

**Why Wayland (instead of X11)?**

**X11 Limitations:**
- **Security**: X11 has no security model - any application can spy on other applications (keyloggers, screen capture)
- **Performance**: X11 is old (1984) and has accumulated decades of legacy code
- **Complexity**: X11 architecture is complex (X server, X client, window manager, compositor are separate)
- **Multi-Monitor**: X11 has poor multi-monitor support, especially with different refresh rates

**Wayland Advantages:**
- **Security**: Each application can only see its own windows (no keylogging, no screen capture without permission)
- **Performance**: Modern architecture, better GPU utilization, lower latency
- **Simplicity**: Compositor handles everything (display server + window manager + compositor in one)
- **Multi-Monitor**: Excellent support for different resolutions and refresh rates
- **Touch/Gestures**: Better support for touchscreens and trackpad gestures
- **Future-Proof**: X11 is in maintenance mode, all new development is on Wayland

**What is a Compositor?**

A compositor is responsible for:
- Drawing windows on screen
- Managing window positions and sizes
- Handling input (keyboard, mouse, touch)
- Compositing effects (transparency, blur, animations)

In Wayland, the compositor replaces both the X server and window manager.

**What is [Hyprland](https://hyprland.org/)?**

Hyprland is a dynamic tiling Wayland compositor written in C++. It's inspired by i3wm and sway, but with modern features:

**Key Features:**
1. **Dynamic Tiling**: Windows automatically tile (arrange themselves), but you can also float windows when needed
2. **Performance**: Written in C++ for speed, uses modern GPU features
3. **Customizable**: Highly configurable via text file (`hyprland.conf`)
4. **Modern Effects**: Built-in support for blur, shadows, transparency, animations
5. **Vim-Style Navigation**: Keyboard-driven workflow, minimal mouse usage
6. **Multi-Monitor**: Excellent support for multiple displays with different configurations

**Why Hyprland (instead of other compositors)?**

**Alternatives Considered:**

- **sway**: i3wm for Wayland, very popular, but:
  - Less modern effects (blur, animations require patches)
  - More minimal (fewer built-in features)
  - Written in C (slower than C++)
- **KDE Plasma (Wayland)**: Full desktop environment, but:
  - Heavy (many dependencies, full desktop environment)
  - Less keyboard-driven
  - More resource-intensive
  - **Note:** Not selected because we want a lightweight window manager, not a full desktop environment
- **GNOME (Wayland)**: Full desktop environment, but:
  - Less customizable
  - More mouse-oriented
  - Different workflow philosophy
  - **Note:** Not selected because we want a lightweight window manager, not a full desktop environment

**For Our Use Case:**

Hyprland is ideal because:
- **Laptop Optimized**: Excellent power management, touchscreen support, trackpad gestures
- **Performance**: Fast and efficient (important for battery life)
- **Customizable**: We can configure it exactly how we want
- **Modern**: Active development, new features regularly
- **Keyboard-Driven**: Perfect for our vim-style navigation philosophy
- **Beautiful**: Built-in effects (blur, shadows) without performance penalty

**Hyprland Architecture:**

```
┌─────────────────────────────────────┐
│         Applications                │
│  (Kitty, Firefox, Neovim, etc.)     │
└──────────────┬──────────────────────┘
               │ Wayland Protocol
┌──────────────▼──────────────────────┐
│         Hyprland Compositor         │
│  (Window Management + Compositing)  │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│      Wayland Protocol (wlroots)     │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│      Graphics Driver (Mesa)        │
│      (Intel HD Graphics 620)        │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│         Hardware (GPU)               │
└─────────────────────────────────────┘
```

**Official Resources:**
- [Hyprland Website](https://hyprland.org/)
- [GitHub Repository](https://github.com/hyprwm/Hyprland)
- [Wiki Documentation](https://wiki.hyprland.org/)
- [ArchWiki](https://wiki.archlinux.org/title/Hyprland)

```bash
# Install Hyprland Wayland compositor
pacman -S hyprland
```

**Proceed with installation: [Y/n]** - Press Enter

### Step 13.2: Install Terminal Emulator (Kitty)

### 13.2 Theoretical Foundation of Terminal Emulators

#### 13.2.1 Historical Context and Evolution

Terminal emulators trace their origins to physical terminals (VT100, VT220) that connected to mainframe computers via serial connections. These terminals provided:
- **Text Display**: Character-based display (typically 80×24 or 80×25 characters)
- **Keyboard Input**: Direct keyboard input to the computer
- **Escape Sequences**: Control sequences for cursor movement, colors, etc.

Modern terminal emulators emulate these physical terminals while adding graphical capabilities:
- **Font Rendering**: TrueType/OpenType fonts with ligatures and emoji
- **GPU Acceleration**: Hardware-accelerated text rendering
- **Image Display**: Inline image support
- **Tabs and Splits**: Multiple terminal sessions in one window

#### 13.2.2 Rendering Architectures

**CPU-Based Rendering:**

Traditional terminal emulators (xterm, gnome-terminal, konsole) use CPU-based rendering:

```
Application Output
    ↓
Terminal Emulator (CPU)
    ↓
Text Rendering (CPU)
    ↓
Display Buffer (RAM)
    ↓
X11/Wayland Compositor
    ↓
Display
```

**Limitations:**
- **Performance**: Slower with large output or complex Unicode
- **Scrolling**: Noticeable lag with thousands of lines
- **Unicode**: Limited support for complex Unicode characters

**GPU-Accelerated Rendering:**

Modern terminal emulators (Kitty, Alacritty, wezterm) use GPU acceleration:

```
Application Output
    ↓
Terminal Emulator
    ↓
Text Rendering (GPU Shaders)
    ↓
GPU Memory
    ↓
Direct Display Output
```

**Advantages:**
- **Performance**: Smooth scrolling even with thousands of lines
- **Unicode**: Excellent support for emoji, international characters
- **Effects**: Can apply visual effects (blur, transparency) efficiently

#### 13.2.3 Kitty: Architecture and Features

**[Kitty](https://sw.kovidgoyal.net/kitty/)** is a GPU-accelerated terminal emulator written in Python and C, first released in 2017. Kitty uses OpenGL for text rendering, providing exceptional performance.

**Key Features:**

1. **GPU Acceleration**: Uses OpenGL shaders for text rendering
2. **Image Support**: Can display images inline (useful for image previews, diagrams)
3. **Ligatures**: Font ligatures (fi, fl, etc. rendered as single characters)
4. **Remote Control**: Can be controlled via scripts (change colors, fonts dynamically)
5. **Cross-Platform**: Works on Linux, macOS, Windows
6. **Minimal**: Lightweight, fast startup
7. **Configurable**: Extensive configuration options

**Architecture:**

Kitty's architecture separates concerns:

- **Frontend (Python)**: Handles configuration, window management, input
- **Backend (C)**: Handles rendering, GPU operations, performance-critical code
- **GPU Shaders**: OpenGL shaders for text rendering and effects

**Official Resources:**
- [Kitty Website](https://sw.kovidgoyal.net/kitty/)
- [Kitty Documentation](https://sw.kovidgoyal.net/kitty/overview/)
- [Kitty GitHub](https://github.com/kovidgoyal/kitty)
- [ArchWiki Kitty](https://wiki.archlinux.org/title/Kitty)
- [Terminal Emulator Comparison](https://wiki.archlinux.org/title/List_of_applications#Terminal_emulators)

#### 13.2.4 Terminal Emulator Comparison

**Alacritty:**

Alacritty is a minimal, GPU-accelerated terminal written in Rust:

**Advantages:**
- **Very Fast**: Extremely fast rendering
- **Minimal**: Minimal resource usage
- **Rust**: Memory-safe implementation

**Limitations:**
- **Features**: Fewer features (no image support, no remote control)
- **Configuration**: Less configurable
- **Ligatures**: Limited ligature support

**foot:**

foot is a Wayland-native terminal emulator:

**Advantages:**
- **Wayland Native**: Designed specifically for Wayland
- **Fast**: Good performance
- **Lightweight**: Low resource usage

**Limitations:**
- **Maturity**: Less mature, smaller community
- **Features**: Fewer features than Kitty
- **Platform**: Wayland-only (no X11 support)

**wezterm:**

wezterm is a feature-rich terminal written in Rust:

**Advantages:**
- **Features**: Extensive feature set
- **Cross-Platform**: Works on multiple platforms
- **Modern**: Modern design and features

**Limitations:**
- **Size**: Larger binary size (Rust overhead)
- **Complexity**: More complex configuration
- **Performance**: Slightly slower than Alacritty

**Selection Rationale:**

Kitty is selected for this configuration because:

1. **Performance**: Excellent performance with GPU acceleration
2. **Features**: Rich feature set (images, ligatures, remote control)
3. **Remote Control**: Script-based configuration changes (for visual effects toggle)
4. **Wayland**: Works well with Hyprland
5. **Maturity**: Mature, well-tested, large community
6. **Configuration**: Extensive configuration options

**References:**

[13] Kovid Goyal. (2017-2025). "Kitty - GPU-accelerated Terminal Emulator." GitHub Repository.

---

### Understanding Terminal Emulators

**What is a Terminal Emulator?**

A terminal emulator is a program that provides a text-based interface (command line) in a graphical environment. It's the modern equivalent of physical terminals that connected to mainframe computers.

**Why [Kitty](https://sw.kovidgoyal.net/kitty/) (instead of other terminals)?**

**Traditional Terminals (xterm, gnome-terminal, konsole):**
- **CPU Rendering**: Text rendering done by CPU
- **Slower**: Noticeable lag with large output or complex Unicode
- **Limited Features**: Basic functionality, limited customization

**Modern GPU-Accelerated Terminals:**

**Kitty Advantages:**
1. **GPU Acceleration**: Uses GPU for text rendering (much faster)
2. **Performance**: Smooth scrolling even with thousands of lines
3. **Unicode Support**: Excellent support for emoji, international characters
4. **Image Support**: Can display images inline (useful for image previews)
5. **Remote Control**: Can be controlled via scripts (change colors, fonts dynamically)
6. **Ligatures**: Font ligatures (fi, fl, etc. rendered as single characters)
7. **Minimal**: Lightweight, fast startup
8. **Cross-Platform**: Works on Linux, macOS, Windows

**Alternatives Considered:**

- **Alacritty**: Very fast, but:
  - Less features (no image support, no remote control)
  - Less customizable
- **foot**: Wayland-native, but:
  - Less mature
  - Fewer features
- **wezterm**: Feature-rich, but:
  - Written in Rust (larger binary)
  - More complex configuration

**For Our Use Case:**

Kitty is ideal because:
- **Performance**: Fast rendering (important for vim/neovim users)
- **Remote Control**: We can change opacity/colors via scripts (for visual effects toggle)
- **Wayland**: Works well with Hyprland
- **Features**: Image support, ligatures enhance development experience

**Official Resources:**
- [Kitty Website](https://sw.kovidgoyal.net/kitty/)
- [GitHub Repository](https://github.com/kovidgoyal/kitty)
- [ArchWiki](https://wiki.archlinux.org/title/Kitty)

```bash
# Install Kitty GPU-accelerated terminal
pacman -S kitty
```

### Step 13.3: Install Status Bar (Waybar)

### 13.3 Theoretical Foundation of Status Bars

#### 13.3.1 Introduction to Status Bars

A status bar (also called a system tray or panel) is a graphical element that displays system information and provides quick access to system functions. Status bars are essential components of desktop environments and window managers.

**Historical Context:**

Status bars have been part of graphical user interfaces since early windowing systems:
- **1980s**: Early window managers included simple status displays
- **1990s**: Desktop environments (GNOME, KDE) introduced comprehensive status bars
- **2000s**: Tiling window managers (i3, dwm) popularized minimal status bars
- **2010s-Present**: Modern status bars with extensive customization and modules

**Core Functionality:**

Status bars typically display:
- **Workspace/Window Information**: Current workspace, active window
- **System Information**: CPU, memory, disk usage
- **Network Status**: WiFi, Ethernet connection status
- **Audio**: Volume level, audio device
- **Battery**: Battery level, charging status (for laptops)
- **Clock**: Current time and date
- **Notifications**: System notifications and alerts

#### 13.3.2 Waybar: Architecture and Design

**[Waybar](https://github.com/Alexays/Waybar)** is a status bar specifically designed for Wayland compositors, first released in 2018. Waybar provides a modern, customizable status bar with extensive module support.

**Key Features:**

1. **Wayland Native**: Designed specifically for Wayland (no X11 dependencies)
2. **Modular**: Extensive module system (workspaces, network, battery, clock, etc.)
3. **Customizable**: JSON configuration, CSS styling
4. **Performance**: Efficient rendering, low resource usage
5. **Extensible**: Custom modules can be written in any language

**Architecture:**

```
Waybar Process
    ↓
Module System
    ↓
┌──────┬──────┬──────┬──────┬──────┐
│Works │Net   │Battery│Clock │Custom│
│paces │work  │       │      │      │
└──────┴──────┴──────┴──────┴──────┘
    ↓
Wayland Protocol
    ↓
Hyprland Compositor
    ↓
Display
```

**Module Types:**

1. **Built-in Modules**: Workspaces, network, battery, clock (included in Waybar)
2. **Custom Scripts**: External scripts that output JSON or text
3. **IPC Modules**: Inter-process communication modules (e.g., MPRIS for media control)

**Configuration:**

Waybar uses JSON for configuration and CSS for styling:
- **config.jsonc**: Module definitions, positions, formats
- **style.css**: Visual styling, colors, fonts, layout

**Official Resources:**
- [Waybar GitHub Repository](https://github.com/Alexays/Waybar)
- [Waybar Wiki](https://github.com/Alexays/Waybar/wiki)
- [ArchWiki Waybar](https://wiki.archlinux.org/title/Waybar)
- [Font Awesome Icons](https://fontawesome.com/)

**References:**

[33] Alexays. (2018-2025). "Waybar - Wayland status bar." GitHub Repository.

---

**[Waybar](https://github.com/Alexays/Waybar)** is a status bar for Wayland compositors.

**Official Resources:**
- [GitHub Repository](https://github.com/Alexays/Waybar)
- [ArchWiki](https://wiki.archlinux.org/title/Waybar)

```bash
# Install Waybar with dependencies
pacman -S waybar otf-font-awesome ttf-font-awesome
```

### Step 13.4: Install Application Launcher and Utilities

```bash
# Install core utilities
pacman -S wofi grim slurp wl-clipboard mako polkit-kde-agent xdg-desktop-portal-hyprland
```

**Package breakdown:**
- `wofi` - Application launcher (dmenu replacement for Wayland)
  - [wofi GitHub](https://github.com/hyprwm/wofi)
  - [ArchWiki Wofi](https://wiki.archlinux.org/title/Wofi)
- `grim` - Screenshot tool
  - [grim GitHub](https://github.com/emersion/grim)
  - [ArchWiki Screenshots](https://wiki.archlinux.org/title/Screen_capture#grim)
- `slurp` - Region selection tool (for screenshots)
  - [slurp GitHub](https://github.com/emersion/slurp)
- `wl-clipboard` - Wayland clipboard utilities (wl-copy, wl-paste)
  - [wl-clipboard GitHub](https://github.com/bugaevc/wl-clipboard)
  - [ArchWiki Clipboard](https://wiki.archlinux.org/title/Clipboard#Wayland)
- `mako` - Notification daemon
  - [mako GitHub](https://github.com/emersion/mako)
  - [ArchWiki Desktop Notifications](https://wiki.archlinux.org/title/Desktop_notifications)
- `polkit-kde-agent` - Authentication agent (for password prompts)
  - [Polkit Website](https://www.freedesktop.org/wiki/Software/polkit/)
  - [ArchWiki Polkit](https://wiki.archlinux.org/title/Polkit)
- `xdg-desktop-portal-hyprland` - Desktop portal for Hyprland
  - [XDG Desktop Portal](https://github.com/flatpak/xdg-desktop-portal)
  - [ArchWiki XDG Desktop Portal](https://wiki.archlinux.org/title/Xdg-desktop-portal)

### Step 13.5: Install Fonts

```bash
# Install JetBrainsMono Nerd Font and other fonts
pacman -S \
  ttf-jetbrains-mono-nerd \
  noto-fonts \
  noto-fonts-emoji \
  noto-fonts-cjk
```

**Font breakdown:**
- `ttf-jetbrains-mono-nerd` - Primary font for terminal and UI (with icons)
  - [JetBrains Mono Website](https://www.jetbrains.com/lp/mono/)
  - [Nerd Fonts Project](https://www.nerdfonts.com/)
  - [ArchWiki Fonts](https://wiki.archlinux.org/title/Fonts)
- `noto-fonts` - Google Noto fonts (Latin, Cyrillic, Greek)
  - [Google Noto Fonts](https://fonts.google.com/noto)
  - [Noto Fonts GitHub](https://github.com/googlefonts/noto-fonts)
- `noto-fonts-emoji` - Emoji support
  - [Noto Emoji GitHub](https://github.com/googlefonts/noto-emoji)
- `noto-fonts-cjk` - Chinese, Japanese, Korean fonts
  - [Noto CJK GitHub](https://github.com/googlefonts/noto-cjk)

### Step 13.6: Install Graphics Drivers (Intel HD Graphics 620)

#### 13.6.1 Theoretical Foundation of Graphics Drivers

**Graphics Stack Architecture:**

The Linux graphics stack consists of multiple layers:

```
Applications (OpenGL, Vulkan, X11, Wayland)
    ↓
Graphics API (Mesa, Vulkan)
    ↓
Kernel Graphics Driver (i915 for Intel)
    ↓
Hardware (GPU)
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
- [Intel Graphics on ArchWiki](https://wiki.archlinux.org/title/Intel_graphics)

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
- **Codec Support**: H.264, H.265, VP8, VP9, etc.
- **Applications**: Video players, browsers, video conferencing

**Official Resources:**
- [VA-API GitHub](https://github.com/intel/libva)
- [ArchWiki Hardware Video Acceleration](https://wiki.archlinux.org/title/Hardware_video_acceleration)

```bash
# Install Intel graphics drivers
pacman -S \
  mesa \
  lib32-mesa \
  vulkan-intel \
  lib32-vulkan-intel \
  intel-media-driver \
  libva-intel-driver
```

**Driver breakdown:**
- `mesa` - [OpenGL implementation](https://www.mesa3d.org/)
  - [ArchWiki Mesa](https://wiki.archlinux.org/title/Mesa)
- `lib32-mesa` - 32-bit OpenGL (for games/Wine)
  - [ArchWiki 32-bit Applications](https://wiki.archlinux.org/title/Architecture#Multilib)
- `vulkan-intel` - [Vulkan API](https://www.vulkan.org/) (modern graphics)
  - [ArchWiki Vulkan](https://wiki.archlinux.org/title/Vulkan)
- `lib32-vulkan-intel` - 32-bit Vulkan
- `intel-media-driver` - Hardware video acceleration (VA-API)
  - [Intel Media Driver GitHub](https://github.com/intel/media-driver)
  - [ArchWiki Hardware Video Acceleration](https://wiki.archlinux.org/title/Hardware_video_acceleration)
- `libva-intel-driver` - Legacy VA-API driver
  - [VA-API Documentation](https://github.com/intel/libva)

### Step 13.7: Install Audio Server (PipeWire)

### 13.7 Theoretical Foundation of Audio Servers

#### 13.7.1 Introduction to Linux Audio Architecture

Linux audio systems have evolved through several generations, each addressing limitations of previous approaches:

**ALSA (Advanced Linux Sound Architecture):**

ALSA, introduced in the early 2000s, provides direct kernel-level audio drivers. While powerful, ALSA has limitations:
- **Single Application Access**: Only one application can access a sound card at a time
- **No Mixing**: Applications must handle audio mixing themselves
- **Complexity**: Direct ALSA programming is complex

**PulseAudio:**

PulseAudio, introduced in 2004, provides a user-space audio server that:
- **Multiple Applications**: Allows multiple applications to play audio simultaneously
- **Automatic Mixing**: Mixes audio from multiple sources
- **Network Audio**: Supports network audio streaming
- **Per-Application Volume**: Individual volume control per application

**PulseAudio Limitations:**

Despite its widespread adoption, PulseAudio has several limitations:
- **Age**: Designed in 2004, showing architectural limitations
- **Latency**: Higher latency (not ideal for gaming or professional audio)
- **Video Support**: Limited video handling capabilities
- **Security**: Less secure sandboxing
- **Complexity**: Complex configuration, sometimes unreliable

**JACK (JACK Audio Connection Kit):**

JACK, designed for professional audio, provides:
- **Low Latency**: Very low latency (critical for professional audio)
- **Routing**: Flexible audio routing between applications
- **Synchronization**: Precise timing and synchronization

**JACK Limitations:**
- **Complexity**: Complex setup and configuration
- **Desktop Integration**: Not well-integrated with desktop environments
- **Resource Usage**: Higher resource usage

#### 13.7.2 PipeWire: Unified Multimedia Framework

**[PipeWire](https://pipewire.org/)** is a modern multimedia framework introduced in 2018 that unifies audio and video handling. PipeWire was designed to replace both PulseAudio and JACK while providing superior capabilities.

**Design Goals:**

1. **Low Latency**: Designed from the ground up for low latency (important for gaming, video calls, professional audio)
2. **Unified**: Handles both audio (PulseAudio replacement) and video (screen sharing, webcam)
3. **Security**: Better sandboxing and security model
4. **Compatibility**: Drop-in replacement for PulseAudio (applications don't need changes)
5. **Professional Audio**: Can replace JACK for professional audio work
6. **Modern**: Active development, designed for modern Linux
7. **Wayland Integration**: Better integration with Wayland compositors

**Architecture:**

```
Applications
    │
    ├─► ALSA apps ──► pipewire-alsa ──┐
    ├─► PulseAudio apps ──► pipewire-pulse ──┤
    └─► JACK apps ──► pipewire-jack ──┘
                        │
                    ┌───▼────┐
                    │PipeWire │
                    │  Server │
                    │(Session  │
                    │ Manager) │
                    └───┬────┘
                        │
            ┌───────────┼───────────┐
            │           │           │
        ┌───▼───┐   ┌───▼───┐   ┌───▼───┐
        │Speaker│   │Headset│   │Webcam │
        └───────┘   └───────┘   └───────┘
```

**Key Components:**

- **pipewire**: Core PipeWire server
- **pipewire-alsa**: ALSA compatibility layer (for applications using ALSA directly)
- **pipewire-pulse**: PulseAudio compatibility layer (for applications expecting PulseAudio)
- **pipewire-jack**: JACK compatibility layer (for professional audio applications)
- **wireplumber**: Session manager (handles device routing, policy, permissions)
- **pavucontrol**: GUI volume control (familiar interface for PulseAudio users)

**Official Resources:**
- [PipeWire Website](https://pipewire.org/)
- [PipeWire Documentation](https://docs.pipewire.org/)
- [PipeWire GitHub](https://gitlab.freedesktop.org/pipewire/pipewire)
- [ArchWiki PipeWire](https://wiki.archlinux.org/title/PipeWire)
- [PipeWire on Wikipedia](https://en.wikipedia.org/wiki/PipeWire)

#### 13.7.3 Performance Characteristics

**Latency Comparison:**

Empirical measurements on similar hardware configurations:

| Audio Server | Typical Latency | Use Case |
|--------------|----------------|----------|
| ALSA (direct) | 5-10 ms | Low-level applications |
| PulseAudio | 20-50 ms | Desktop audio |
| JACK | 2-5 ms | Professional audio |
| PipeWire | 5-15 ms | Universal (configurable) |

**PipeWire Advantages:**

1. **Configurable Latency**: PipeWire can be configured for low latency (gaming, professional audio) or higher latency (desktop audio) depending on use case
2. **GPU Acceleration**: Can leverage GPU for video processing
3. **Memory Efficiency**: More efficient memory usage than PulseAudio
4. **CPU Usage**: Lower CPU overhead than PulseAudio

#### 13.7.4 Selection Rationale

**Why PipeWire (not PulseAudio)?**

For this configuration, PipeWire is selected because:

1. **Future-Proof**: PulseAudio is in maintenance mode, PipeWire is actively developed
2. **Low Latency**: Better for video calls, gaming, and real-time applications
3. **Wayland Integration**: Better integration with Hyprland compositor
4. **Unified**: Handles both audio and video (screen sharing, webcam)
5. **Compatibility**: All existing applications work without changes
6. **Professional**: Can handle professional audio if needed later

**References:**

[11] PipeWire Contributors. (2018-2025). "PipeWire - Multimedia Framework." freedesktop.org.  
[12] Lennart Poettering. (2004). "PulseAudio - A Cross-Platform Sound Server." freedesktop.org.

---

### Understanding PipeWire

**What is PipeWire?**

[PipeWire](https://pipewire.org/) is a modern multimedia framework that replaces both PulseAudio (for desktop audio) and JACK (for professional audio). It provides a unified audio/video server for Linux.

**Why PipeWire (instead of PulseAudio)?**

**PulseAudio Limitations:**
- **Old Architecture**: Designed in 2006, showing its age
- **Latency**: Higher latency (not ideal for gaming or professional audio)
- **Video Support**: Limited video handling capabilities
- **Security**: Less secure sandboxing
- **Complexity**: Complex configuration, sometimes unreliable

**PipeWire Advantages:**
1. **Low Latency**: Designed from the ground up for low latency (important for gaming, video calls)
2. **Unified**: Handles both audio (PulseAudio replacement) and video (screen sharing, webcam)
3. **Security**: Better sandboxing, more secure
4. **Compatibility**: Drop-in replacement for PulseAudio (applications don't need changes)
5. **Professional Audio**: Can replace JACK for professional audio work
6. **Modern**: Active development, designed for modern Linux
7. **Wayland Integration**: Better integration with Wayland compositors

**Why These Specific Packages?**

- **pipewire**: Core PipeWire server
- **pipewire-alsa**: ALSA compatibility layer (for applications that use ALSA directly)
- **pipewire-pulse**: PulseAudio compatibility layer (for applications expecting PulseAudio)
- **pipewire-jack**: JACK compatibility layer (for professional audio applications)
- **wireplumber**: Session manager (handles device routing, policy)
- **pavucontrol**: GUI volume control (familiar interface for PulseAudio users)

**How PipeWire Works:**

```
Applications
    │
    ├─► ALSA apps ──► pipewire-alsa ──┐
    ├─► PulseAudio apps ──► pipewire-pulse ──┤
    └─► JACK apps ──► pipewire-jack ──┘
                        │
                    ┌───▼────┐
                    │PipeWire │
                    │  Server │
                    └───┬────┘
                        │
            ┌───────────┼───────────┐
            │           │           │
        ┌───▼───┐   ┌───▼───┐   ┌───▼───┐
        │Speaker│   │Headset│   │Webcam │
        └───────┘   └───────┘   └───────┘
```

**For Our Use Case:**

PipeWire is ideal because:
- **Modern**: Future-proof choice (PulseAudio is in maintenance mode)
- **Low Latency**: Better for video calls, gaming
- **Wayland**: Better integration with Hyprland
- **Compatibility**: All existing applications work without changes
- **Professional**: Can handle professional audio if needed later

**Official Resources:**
- [PipeWire Website](https://pipewire.org/)
- [GitHub Repository](https://gitlab.freedesktop.org/pipewire/pipewire)
- [ArchWiki](https://wiki.archlinux.org/title/PipeWire)

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

**Audio breakdown:**
- `pipewire` - Modern audio server (low-latency)
- `pipewire-alsa` - ALSA compatibility
- `pipewire-pulse` - PulseAudio compatibility
- `pipewire-jack` - JACK audio support (pro audio)
- `wireplumber` - PipeWire session manager
- `pavucontrol` - PulseAudio volume control GUI

### Step 13.8: Install Plymouth (Boot Splash)

### 13.8 Theoretical Foundation of Boot Splash Screens

#### 13.8.1 Introduction to Boot Splash Screens

A boot splash screen is a graphical display shown during system boot, replacing the traditional text-based boot messages. Boot splash screens serve both aesthetic and functional purposes:

1. **User Experience**: Provides visual feedback during boot (more pleasant than text output)
2. **Branding**: Can display logos, branding, or custom graphics
3. **Progress Indication**: Can show boot progress (loading bars, animations)
4. **Password Prompts**: Can display password prompts for encrypted systems (though we use automatic decryption)

**Historical Context:**

Boot splash screens have evolved:
- **Early Systems**: Text-only boot messages
- **1990s**: Simple graphical boot screens (LILO, GRUB)
- **2000s**: Advanced boot splash systems (Plymouth, usplash)
- **2010s-Present**: Modern boot splash with animations and effects

#### 13.8.2 Plymouth: Architecture and Design

**[Plymouth](https://www.freedesktop.org/wiki/Software/Plymouth)** is a boot splash system for Linux, first introduced in 2008. Plymouth provides a graphical boot experience while the kernel and initramfs are loading.

**Key Features:**

1. **Early Graphics**: Displays graphics very early in boot process (from initramfs)
2. **Theme Support**: Supports various themes (text, graphical, animations)
3. **BGRT Support**: Can use UEFI Boot Graphics Resource Table (uses firmware graphics)
4. **Password Prompts**: Can display password prompts for encrypted systems
5. **Progress Indication**: Can show boot progress

**Architecture:**

```
UEFI Firmware
    ↓
GRUB (displays GRUB menu)
    ↓
Kernel + Initramfs (includes Plymouth)
    ↓
Plymouth Splash Screen
    ↓
Systemd (takes over from Plymouth)
    ↓
Desktop Environment
```

**BGRT Theme:**

The BGRT (Boot Graphics Resource Table) theme uses graphics provided by the UEFI firmware:
- **Firmware Graphics**: Uses the same graphics shown during UEFI boot
- **Seamless Transition**: Smooth transition from UEFI to Plymouth
- **Hardware-Specific**: Graphics are specific to the hardware (HP logo for HP EliteBook)

**Official Resources:**
- [Plymouth Website](https://www.freedesktop.org/wiki/Software/Plymouth)
- [Plymouth GitHub](https://gitlab.freedesktop.org/plymouth/plymouth)
- [ArchWiki Plymouth](https://wiki.archlinux.org/title/Plymouth)
- [UEFI BGRT Specification](https://uefi.org/specs/ACPI/6.4/05_ACPI_Software_Programming_Model/ACPI_Software_Programming_Model.html#boot-graphics-resource-table-bgrt)

#### 13.8.3 Initramfs Integration

**Plymouth in Initramfs:**

Plymouth is integrated into the initramfs through mkinitcpio hooks:

1. **plymouth Hook**: Adds Plymouth binaries and themes to initramfs
2. **Early Start**: Plymouth starts very early in the boot process
3. **Kernel Messages**: Plymouth can hide kernel messages (quiet boot)
4. **Handoff**: Plymouth hands off to systemd when boot completes

**Hook Order:**

The hook order in mkinitcpio is critical:

```
base → udev → autodetect → modconf → block → plymouth → encrypt → filesystems
```

- **block**: Loads block device drivers (needed before encryption)
- **plymouth**: Starts Plymouth splash screen
- **encrypt**: Handles LUKS decryption (Plymouth can show password prompt)
- **filesystems**: Mounts filesystems

**References:**

[31] Red Hat. (2008-2025). "Plymouth - Boot Splash System." freedesktop.org.  
[32] UEFI Forum. (2020). "ACPI Specification - Boot Graphics Resource Table." uefi.org.

---

**[Plymouth](https://www.freedesktop.org/wiki/Software/Plymouth)** provides a graphical boot splash screen.

**Official Resources:**
- [Plymouth Website](https://www.freedesktop.org/wiki/Software/Plymouth)
- [ArchWiki](https://wiki.archlinux.org/title/Plymouth)

```bash
# Install Plymouth boot splash
pacman -S plymouth
```

### Step 13.9: Configure Plymouth in Initramfs

```bash
# Edit /etc/mkinitcpio.conf
nano /etc/mkinitcpio.conf
```

**Find HOOKS line:**
```bash
HOOKS=(base udev autodetect modconf block encrypt filesystems keyboard fsck)
```

**Change to (add plymouth AFTER block, BEFORE encrypt):**
```bash
HOOKS=(base udev autodetect modconf block plymouth encrypt filesystems keyboard fsck)
```

****WARNING:** Order:** `block` → `plymouth` → `encrypt` → `filesystems`

**Save and exit** (Ctrl+O, Enter, Ctrl+X)

**Create Plymouth configuration:**
```bash
# Create Plymouth config directory
mkdir -p /etc/plymouth

# Set BGRT theme (uses UEFI boot graphics)
cat > /etc/plymouth/plymouthd.conf << EOF
[Daemon]
Theme=bgrt
EOF
```

**Rebuild initramfs:**
```bash
mkinitcpio -P
```

### Step 13.10: Install Display Manager (SDDM)

### 13.10 Theoretical Foundation of Display Managers

#### 13.10.1 Introduction to Display Managers

A display manager (also called a login manager) is a program that provides a graphical login interface and manages user sessions. The display manager runs before the user logs in and is responsible for:

1. **User Authentication**: Verifying user credentials (password, fingerprint, etc.)
2. **Session Management**: Starting and managing user sessions
3. **Session Selection**: Allowing users to choose desktop environment/window manager
4. **Display Configuration**: Managing multiple displays and monitors

**Historical Context:**

Display managers evolved from text-based login prompts:
- **getty/login**: Text-based login (still used in servers)
- **XDM (X Display Manager)**: First graphical display manager (1988)
- **GDM (GNOME Display Manager)**: GNOME's display manager
- **KDM (KDE Display Manager)**: KDE's display manager (deprecated)
- **LightDM**: Lightweight, desktop-agnostic display manager
- **SDDM**: Modern, Qt-based display manager

#### 13.10.2 SDDM: Architecture and Design

**[SDDM](https://github.com/sddm/sddm)** (Simple Desktop Display Manager) is a modern display manager written in C++ and Qt, first released in 2013. SDDM was designed to replace KDM (which was deprecated) and provide a lightweight, themeable display manager.

**Key Features:**

1. **Wayland Support**: Native support for both X11 and Wayland sessions
2. **Themeable**: Qt-based theming system (QML themes)
3. **Lightweight**: Lower resource usage than GDM
4. **PAM Integration**: Full PAM support for authentication (passwords, fingerprints, etc.)
5. **Multi-Session**: Supports multiple concurrent sessions
6. **Auto-Login**: Optional automatic login support

**Architecture:**

```
SDDM Display Manager
    ↓
PAM (Authentication)
    ↓
Session Launcher
    ↓
Desktop Environment / Window Manager
    ↓
User Session
```

**Official Resources:**
- [SDDM GitHub Repository](https://github.com/sddm/sddm)
- [SDDM Documentation](https://github.com/sddm/sddm/wiki)
- [ArchWiki SDDM](https://wiki.archlinux.org/title/SDDM)
- [SDDM on Wikipedia](https://en.wikipedia.org/wiki/SDDM)

#### 13.10.3 Display Manager Comparison

**GDM (GNOME Display Manager):**

GDM is GNOME's display manager:

**Advantages:**
- **Integration**: Excellent integration with GNOME
- **Features**: Rich feature set
- **Accessibility**: Strong accessibility support

**Limitations:**
- **GNOME-Specific**: Tightly coupled to GNOME
- **Resource Usage**: Higher resource usage
- **Wayland**: Primarily designed for GNOME on Wayland

**LightDM:**

LightDM is a lightweight, desktop-agnostic display manager:

**Advantages:**
- **Lightweight**: Very low resource usage
- **Desktop-Agnostic**: Works with any desktop environment
- **Configurable**: Highly configurable

**Limitations:**
- **Theming**: Less themeable than SDDM
- **Features**: Fewer built-in features
- **Development**: Slower development pace

**SDDM Selection Rationale:**

SDDM is selected for this configuration because:

1. **Wayland Support**: Excellent support for Wayland sessions (Hyprland)
2. **Lightweight**: Lower resource usage than GDM
3. **Themeable**: Qt-based theming (can match desktop theme)
4. **PAM Integration**: Full PAM support (works with fingerprint authentication)
5. **Modern**: Active development, modern codebase
6. **Flexibility**: Works with any desktop environment/window manager

**References:**

[29] SDDM Contributors. (2013-2025). "SDDM - Simple Desktop Display Manager." GitHub Repository.  
[30] freedesktop.org. (2010-2025). "LightDM - Cross-desktop display manager." freedesktop.org.

---

**[SDDM](https://github.com/sddm/sddm)** (Simple Desktop Display Manager) is a display manager for X11 and Wayland.

**Official Resources:**
- [GitHub Repository](https://github.com/sddm/sddm)
- [ArchWiki](https://wiki.archlinux.org/title/SDDM)

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

### Step 13.11: Install Web Browsers and File Manager

```bash
# Install Firefox and file manager
pacman -S firefox dolphin ark

# Install Brave from AUR (requires yay)
# Note: If yay is not installed yet, install Brave after yay setup
# yay -S brave-bin
```

**Package breakdown:**
- `firefox` - Open-source web browser
  - [Firefox Website](https://www.mozilla.org/firefox/)
  - [Firefox Developer Documentation](https://developer.mozilla.org/en-US/docs/Mozilla/Firefox)
  - [ArchWiki Firefox](https://wiki.archlinux.org/title/Firefox)
  - **Theme Configuration:** Catppuccin Mocha Green theme available in repository (`browsers/firefox/`)
- `brave-bin` - Privacy-focused Chromium-based browser (AUR package)
  - [Brave Website](https://brave.com/)
  - [Brave GitHub](https://github.com/brave/brave-browser)
  - [ArchWiki Brave](https://wiki.archlinux.org/title/Brave)
  - **Theme Configuration:** Catppuccin Mocha Green theme extension available in repository (`browsers/brave/`)
- `dolphin` - File manager (standalone KDE application, works with Hyprland)
  - [Dolphin Website](https://apps.kde.org/dolphin/)
  - [ArchWiki Dolphin](https://wiki.archlinux.org/title/KDE#Dolphin)
  - **Note:** Dolphin is a standalone application that works independently of KDE desktop environment. It provides full Wayland support and integrates well with Hyprland.
- `ark` - Archive manager (zip, tar, 7z) - standalone KDE application
  - [Ark Website](https://apps.kde.org/ark/)
  - [ArchWiki File Archivers](https://wiki.archlinux.org/title/List_of_applications#File_archivers)
  - **Note:** Ark works independently of desktop environment and integrates with Hyprland.

**Alternative File Managers (Optional):**
If you prefer lighter alternatives, you can install:
- `thunar` - Lightweight file manager (XFCE)
- `pcmanfm` - Minimal file manager (LXDE)
- `ranger` - Terminal-based file manager (vim-style navigation)

**Browser Theme Configuration:**
After system installation, browser themes can be deployed from the repository:
- **Firefox Theme:** See `browsers/THEME_DEPLOYMENT.md` for deployment instructions
- **Brave Theme:** See `browsers/THEME_DEPLOYMENT.md` for extension installation
- **Documentation:** Complete browser configuration documentation in `browsers/` directory

### Step 13.12: Install System Utilities

```bash
# Install essential utilities
pacman -S \
  unzip \
  p7zip \
  htop \
  btop \
  neofetch \
  fastfetch
```

**Utility breakdown:**
- `unzip` - Extract ZIP archives
  - [Info-ZIP Website](http://infozip.sourceforge.net/)
  - [ArchWiki Archive Managers](https://wiki.archlinux.org/title/List_of_applications#File_archivers)
- `p7zip` - 7-Zip archive support
  - [7-Zip Website](https://www.7-zip.org/)
  - [p7zip GitHub](https://github.com/jinfeihan57/p7zip)
- `htop` - Interactive process viewer
  - [htop Website](https://htop.dev/)
  - [htop GitHub](https://github.com/htop-dev/htop)
  - [ArchWiki Process Management](https://wiki.archlinux.org/title/Process_management)
- `btop` - Modern resource monitor
  - [btop GitHub](https://github.com/aristocratos/btop)
  - [ArchWiki System Monitoring](https://wiki.archlinux.org/title/List_of_applications#System_monitoring)
- `neofetch` - System information tool
  - [neofetch GitHub](https://github.com/dylanaraps/neofetch)
  - [ArchWiki Neofetch](https://wiki.archlinux.org/title/Neofetch)
- `fastfetch` - Fast system information (alternative to neofetch)
  - [fastfetch GitHub](https://github.com/fastfetch-cli/fastfetch)

### Step 13.13: Install Brightness and OSD Controls

****WARNING:** CRITICAL: These packages were missing from original guide**

```bash
# Install brightness control
pacman -S brightnessctl

# Install SwayOSD (on-screen display for volume/brightness)
pacman -S swayosd
```

**Package breakdown:**
- `brightnessctl` - Control screen brightness (required for laptop)
- `swayosd` - On-screen display for volume, brightness, caps lock notifications

**Note:** swayosd might not be in official repos. If installation fails:

```bash
# Install swayosd from AUR (will do later with yay)
# For now, skip if not available
```

### Step 13.14: Install Additional Required Packages

```bash
# Install wallpaper daemon and other utilities
pacman -S \
  swaybg \
  qt5-wayland \
  qt6-wayland \
  xdg-utils \
  xdg-user-dirs
```

**Package breakdown:**
- `swaybg` - Wallpaper utility for Wayland
  - [swaybg GitHub](https://github.com/swaywm/swaybg)
  - [ArchWiki Wallpapers](https://wiki.archlinux.org/title/List_of_applications#Wallpaper_setters)
- `qt5-wayland` + `qt6-wayland` - Qt Wayland support
  - [Qt Website](https://www.qt.io/)
  - [Qt Wayland Documentation](https://doc.qt.io/qt-6/wayland.html)
  - [ArchWiki Qt](https://wiki.archlinux.org/title/Qt)
- `xdg-utils` - Desktop integration utilities
  - [XDG Utils Specification](https://www.freedesktop.org/wiki/Software/xdg-utils/)
  - [ArchWiki XDG](https://wiki.archlinux.org/title/XDG_Base_Directory)
- `xdg-user-dirs` - User directory management (Documents, Downloads, etc.)
  - [XDG User Dirs Specification](https://www.freedesktop.org/wiki/Software/xdg-user-dirs/)

### Step 13.15: Install Power Management (TLP + thermald)

#### 13.15.1 Theoretical Foundation of Power Management

**Power Management Challenges:**

Laptop power management involves balancing:
- **Performance**: Maximum performance when needed
- **Battery Life**: Extended battery life when on battery
- **Thermal Management**: Preventing overheating and throttling
- **User Experience**: Automatic adaptation to power state (AC vs. battery)

**Power Management Layers:**

1. **Hardware Level**: CPU frequency scaling, GPU power states, device power management
2. **Kernel Level**: CPU governors, thermal throttling, ACPI events
3. **User Space**: TLP, thermald, power profiles

**TLP (TLP - Advanced Linux Power Management):**

[TLP](https://linrunner.de/tlp/) is a comprehensive power management tool that automatically adjusts system settings based on power source (AC vs. battery):

**Key Features:**
- **CPU Scaling**: Automatic CPU governor selection (performance on AC, powersave on battery)
- **WiFi Power Management**: WiFi power save mode control
- **USB Autosuspend**: Automatic USB device suspension
- **PCIe ASPM**: PCI Express Active State Power Management
- **Platform Profiles**: System power profile management (balanced, performance, low-power)

**Official Resources:**
- [TLP Website](https://linrunner.de/tlp/)
- [TLP Documentation](https://linrunner.de/tlp/tlp.html)
- [TLP GitHub](https://github.com/linrunner/TLP)
- [ArchWiki TLP](https://wiki.archlinux.org/title/TLP)

**thermald (Thermal Daemon):**

[thermald](https://github.com/intel/thermal_daemon) is Intel's thermal management daemon:

**Purpose:**
- **Thermal Protection**: Prevents CPU overheating and throttling
- **Performance Optimization**: Maintains performance while managing temperature
- **Hardware Integration**: Works with Intel CPU thermal sensors and controls

**Official Resources:**
- [thermald GitHub](https://github.com/intel/thermal_daemon)
- [ArchWiki Power Management](https://wiki.archlinux.org/title/Power_management)

**acpid (ACPI Daemon):**

acpid handles ACPI (Advanced Configuration and Power Interface) events:

**Events Handled:**
- **Lid Switch**: Laptop lid open/close
- **Power Button**: Power button press
- **Battery Events**: Battery insertion/removal, low battery
- **AC Adapter**: AC adapter connection/disconnection

**Official Resources:**
- [ArchWiki ACPI](https://wiki.archlinux.org/title/ACPI)
- [ACPI Specification](https://uefi.org/specs/ACPI)

```bash
# Install power management tools
pacman -S tlp thermald acpid

# Enable services
systemctl enable tlp
systemctl enable thermald
systemctl enable acpid
```

**Package breakdown:**
- `tlp` - Advanced power management for Linux
  - [TLP Website](https://linrunner.de/tlp/)
  - [ArchWiki TLP](https://wiki.archlinux.org/title/TLP)
- `thermald` - Intel CPU thermal management daemon
  - [thermald GitHub](https://github.com/intel/thermal_daemon)
  - [ArchWiki Power Management](https://wiki.archlinux.org/title/Power_management)
- `acpid` - ACPI event daemon (lid switch, power button)
  - [ArchWiki ACPI](https://wiki.archlinux.org/title/ACPI)

### Step 13.16: Configure TLP for HP EliteBook

#### 13.16.1 TLP Configuration Rationale

**CPU Scaling Governors:**

CPU scaling governors control how the CPU adjusts its frequency:

- **performance**: CPU runs at maximum frequency (best performance, higher power consumption)
- **powersave**: CPU runs at minimum frequency (lower power consumption, reduced performance)
- **ondemand**: CPU scales frequency based on load (balanced approach)
- **conservative**: Similar to ondemand but more gradual frequency changes

**Selection Rationale:**
- **AC Power**: `performance` governor ensures maximum performance when power is unlimited
- **Battery**: `powersave` governor extends battery life by reducing CPU frequency

**CPU Energy Policy:**

Intel CPUs support energy performance policies that control power/performance balance:

- **balance_performance**: Optimized for performance with power considerations
- **balance_power**: Optimized for power with performance considerations

**Platform Profiles:**

Modern systems support platform profiles that control overall system power behavior:

- **balanced**: Balanced power/performance
- **performance**: Maximum performance
- **low-power**: Maximum power savings

**WiFi Power Management:**

WiFi adapters can enter power save mode to reduce power consumption:

- **AC Power**: Power save disabled for maximum stability and performance
- **Battery**: Power save enabled to extend battery life

**PCIe ASPM (Active State Power Management):**

PCIe devices can enter low-power states when idle:

- **AC Power**: Default ASPM (balanced)
- **Battery**: PowerSuperSave (maximum power savings)

**USB Autosuspend:**

USB devices can automatically suspend when idle:

- **Disabled (0)**: Prevents USB device disconnection issues
- **Trade-off**: Slightly higher power consumption but better device stability

**Official Resources:**
- [TLP Configuration Documentation](https://linrunner.de/tlp/settings/)
- [ArchWiki TLP Configuration](https://wiki.archlinux.org/title/TLP#Configuration)
- [CPU Frequency Scaling](https://wiki.archlinux.org/title/CPU_frequency_scaling)

Create optimized TLP configuration:

```bash
# Create TLP config directory
mkdir -p /etc/tlp.d

# Create HP EliteBook configuration
cat > /etc/tlp.d/01-elitebook.conf << 'EOF'
# HP EliteBook x360 1030 G2 - Power Optimization

# CPU scaling governor
CPU_SCALING_GOVERNOR_ON_AC=performance
CPU_SCALING_GOVERNOR_ON_BAT=powersave

# CPU energy policy (intel_pstate)
CPU_ENERGY_PERF_POLICY_ON_AC=balance_performance
CPU_ENERGY_PERF_POLICY_ON_BAT=balance_power

# Platform profile
PLATFORM_PROFILE_ON_AC=balanced
PLATFORM_PROFILE_ON_BAT=low-power

# WiFi power save (off on AC for stability)
WIFI_PWR_ON_AC=off
WIFI_PWR_ON_BAT=on

# PCIe ASPM
PCIE_ASPM_ON_AC=default
PCIE_ASPM_ON_BAT=powersupersave

# USB autosuspend disabled (prevents device disconnects)
USB_AUTOSUSPEND=0

# NMI watchdog (disable to save power)
NMI_WATCHDOG=0
EOF
```

### Step 13.14: Enable SSH Service for Post-Installation Remote Access

****WARNING:** CRITICAL: Enable SSH before exiting chroot to allow remote access after first boot**

**Purpose:** After the first system reboot, you may need to continue configuration remotely via SSH. Enabling SSH service in chroot ensures that the SSH daemon starts automatically on first boot, allowing remote access without physical access to the laptop.

**Note:** The `openssh` package was already installed in Phase 7 (base system installation). This step only enables the SSH service to start automatically on boot.

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
- NetworkManager must be running for SSH to accept connections (enabled in Phase 12)

**Security Considerations:**
- After first boot, consider disabling root SSH login: Edit `/etc/ssh/sshd_config` and set `PermitRootLogin no`
- Configure firewall rules if needed: `ufw allow 22/tcp` or `iptables` rules
- Use SSH keys instead of passwords for better security

****SUCCESS:** SSH service enabled and will start automatically on first boot**

---

****SUCCESS:** Phase 13 Complete: Window manager (Hyprland) and all essential software installed, SSH enabled for remote access**

****NEXT:** Next: Exit chroot and prepare for first boot (Phase 14)**

---

## Phase 14: First Boot and Verification

****TIME:** Estimated Time: 10 minutes**

****NEXT:** Restart Count: 1 (FIRST SYSTEM RESTART)**

### Step 14.1: Exit Chroot Environment

```bash
# Exit chroot
exit
```

**Prompt changes back to:**
```
root@archiso ~ #
```

****SUCCESS:** You are now back in Arch Linux live USB environment**

### Step 14.2: Unmount All Partitions

```bash
# Unmount all mounted filesystems recursively
umount -R /mnt
```

**If error "target is busy":**
```bash
# Force unmount
umount -lR /mnt
```

### Step 14.3: Close Encrypted Volumes

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

### Step 14.4: Reboot System
---

**Continue with [INSTALL_POST_REBOOT.md](INSTALL_POST_REBOOT.md) after first system reboot.**
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


---

# Part 2: Post-Reboot Configuration

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

