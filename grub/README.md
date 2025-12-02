# GRUB Bootloader Configuration

This directory contains the GRUB bootloader configuration with Plymouth splash screen support.

## Key Configuration

The `etc/default/grub` file includes:

- **Splash screen:** `splash` parameter for graphical boot
- **Plymouth support:** `plymouth.enable=1` to activate Plymouth graphical boot
- **VT handoff:** `vt.handoff=7` for proper terminal handoff from initramfs to desktop
- **Cryptographic disk:** Support for LUKS encrypted root with `cryptdevice` and `cryptkey`
- **USB optimization:** `usbcore.autosuspend=-1` and `usbcore.initial_descriptor_timeout=5000`

## Installation

```bash
# Copy GRUB configuration
sudo cp grub/etc/default/grub /etc/default/grub

# Regenerate GRUB configuration
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

## Troubleshooting

If Plymouth doesn't appear during boot:
1. Ensure Plymouth is installed: `pacman -S plymouth`
2. Check mkinitcpio configuration is updated (see `../plymouth/README.md`)
3. Verify kernel parameters: `cat /proc/cmdline | grep plymouth`
4. Regenerate GRUB: `sudo grub-mkconfig -o /boot/grub/grub.cfg`
5. Reboot to apply changes: `sudo reboot`

## Related Configuration

See `../plymouth/` for initramfs and Plymouth theme configuration.
