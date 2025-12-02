# Plymouth Splash Screen Configuration

This directory contains the configuration for Plymouth graphical boot splash screen and mkinitcpio settings.

## Overview

Plymouth provides a polished, graphical boot experience on Arch Linux. This configuration includes:

- **Graphical boot splash:** Replaces text-based boot messages
- **Graphics driver in initramfs:** Intel i915 module for proper video mode-setting
- **Encrypted root support:** Works seamlessly with LUKS encrypted disks
- **Theme:** bgrt (BIOS/UEFI firmware logo) or customizable themes

## Key Files

### mkinitcpio.conf

The `etc/mkinitcpio.conf` file includes:

- **MODULES:** `i915` (Intel GPU driver for video support)
- **HOOKS:** Plymouth hook positioned correctly (before encrypt) for boot prompts
- **FILES:** Cryptsetup key file for encrypted root

## Installation Steps

### 1. Install Plymouth

```bash
sudo pacman -S plymouth
```

### 2. Copy Configurations

```bash
# Copy mkinitcpio configuration
sudo cp plymouth/etc/mkinitcpio.conf /etc/mkinitcpio.conf

# Regenerate initramfs with Plymouth
sudo mkinitcpio -P
```

### 3. Update GRUB Configuration

```bash
# Copy GRUB configuration (see ../grub/README.md)
sudo cp grub/etc/default/grub /etc/default/grub

# Regenerate GRUB
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

### 4. Reboot

```bash
sudo reboot
```

## Customizing Plymouth Theme

### View Available Themes

```bash
# List installed themes
ls /usr/share/plymouth/themes/

# Show current theme
plymouth-set-default-theme
```

### Change Theme

```bash
# Set a different theme (e.g., spinner, glow, spinfinity)
sudo plymouth-set-default-theme spinner

# Regenerate initramfs to include new theme
sudo mkinitcpio -P

# Regenerate GRUB configuration
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

### Available Themes

- **bgrt:** BIOS/UEFI firmware logo (default)
- **spinner:** Spinning animation with progress
- **spinfinity:** Infinity symbol animation
- **glow:** Glowing animation
- **fade-in:** Fade-in animation
- **monoarch:** Arch Linux minimalist theme
- **solar:** Solar-themed animation
- **script:** Script-based custom animations
- **text:** Text-only theme
- **details:** Detailed boot information

## Troubleshooting

### Plymouth Doesn't Appear

1. **Check if Plymouth is installed:**
   ```bash
   pacman -Q plymouth
   ```

2. **Verify kernel parameters:**
   ```bash
   cat /proc/cmdline | grep -o "plymouth[^ ]*"
   ```
   Should show: `plymouth.enable=1`

3. **Check initramfs includes Plymouth:**
   ```bash
   lsinitrd /boot/initramfs-linux.img | grep -i plymouth
   ```

4. **Verify graphics driver is loaded:**
   ```bash
   lsinitrd /boot/initramfs-linux.img | grep -i i915
   ```

5. **Regenerate everything and reboot:**
   ```bash
   sudo mkinitcpio -P
   sudo grub-mkconfig -o /boot/grub/grub.cfg
   sudo reboot
   ```

### Plymouth Theme Not Showing

- Install the desired theme package
- Use `plymouth-set-default-theme` to set it
- Regenerate mkinitcpio: `sudo mkinitcpio -P`
- Regenerate GRUB: `sudo grub-mkconfig -o /boot/grub/grub.cfg`

### Encrypted Root Not Being Prompted

Ensure `plymouth` hook is positioned before `encrypt` in mkinitcpio.conf HOOKS array:

```
HOOKS=(base udev autodetect modconf block plymouth encrypt filesystems keyboard fsck)
```

## System Requirements

- **Arch Linux** with pacman
- **Intel GPU** (HD Graphics 620 or later) for i915 module
- **GRUB** bootloader
- **LUKS encryption** (optional, but recommended with this config)

## Related Configuration

See `../grub/` for GRUB bootloader configuration.
