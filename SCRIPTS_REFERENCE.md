# Scripts Reference - EliteBook Repository

**Complete reference for all automation scripts in the repository.**

**Version:** 2.0.0  
**Last Updated:** December 2, 2025  
**Location:** `scripts/.local/bin/` and `scripts/`

---

## Quick Navigation

- [Visual Effects Scripts](#visual-effects-scripts)
- [Window Manager Scripts](#window-manager-scripts)
- [Screenshot Scripts](#screenshot-scripts)
- [Wallpaper Scripts](#wallpaper-scripts)
- [Status Bar Scripts](#status-bar-scripts)
- [Authentication Scripts](#authentication-scripts)
- [Configuration Scripts](#configuration-scripts)

---

## Visual Effects Scripts

### `effects-on.sh`

**Purpose:** Enable visual effects (blur, shadows, transparency) in Hyprland.

**Usage:**
```bash
effects-on.sh
```

**What it does:**
- Enables blur effects for windows
- Enables shadows
- Enables transparency
- Reloads Hyprland configuration

**Keybinding:** (if configured in hyprland.conf)

---

### `effects-off.sh`

**Purpose:** Disable visual effects for better performance.

**Usage:**
```bash
effects-off.sh
```

**What it does:**
- Disables blur effects
- Disables shadows
- Disables transparency
- Reloads Hyprland configuration

**Keybinding:** (if configured in hyprland.conf)

---

### `effects-toggle.sh`

**Purpose:** Toggle visual effects on/off.

**Usage:**
```bash
effects-toggle.sh
```

**What it does:**
- Checks current state of effects
- Toggles between enabled/disabled
- Reloads Hyprland configuration

**Keybinding:** (if configured in hyprland.conf)

---

## Window Manager Scripts

### `hyprland-corner.sh`

**Purpose:** Switch Hyprland to corner-based window layout mode.

**Usage:**
```bash
hyprland-corner.sh
```

**What it does:**
- Configures window layout for corner-based tiling
- Reloads Hyprland configuration

---

### `hyprland-rounded.sh`

**Purpose:** Switch Hyprland to rounded window layout mode.

**Usage:**
```bash
hyprland-rounded.sh
```

**What it does:**
- Configures window layout for rounded corners
- Reloads Hyprland configuration

---

## Screenshot Scripts

### `screenshot-mode.sh`

**Purpose:** Prepare desktop for clean screenshots by replacing dynamic elements with static values.

**Usage:**
```bash
screenshot-mode.sh
```

**What it does:**
- Replaces Waybar clock with static "00:00 AM"
- Replaces Tmux status bar time with static time
- Reloads Kitty terminal
- Creates backup of configuration files

**Keybinding:** Super+Shift+S (if configured)

**Note:** Must be followed by `screenshot-mode-exit.sh` to restore normal operation.

---

### `screenshot-mode-exit.sh`

**Purpose:** Exit screenshot mode and restore dynamic time displays.

**Usage:**
```bash
screenshot-mode-exit.sh
```

**What it does:**
- Restores Waybar clock to dynamic time
- Restores Tmux status bar to dynamic time
- Reloads Kitty terminal
- Restores configuration from backup

**Keybinding:** Super+Shift+F (if configured)

---

## Wallpaper Scripts

### `wallpaper-rotate.sh`

**Purpose:** Automatic wallpaper rotation daemon (runs every 3 minutes).

**Usage:**
```bash
# Start daemon
wallpaper-rotate.sh &

# Or add to autostart (systemd user service)
```

**What it does:**
- Detects active monitors via Hyprland
- Finds all wallpapers in configured directory
- Randomly selects and applies wallpapers to each monitor
- Uses smooth fade transitions (swww)
- Runs continuously with 3-minute intervals

**Dependencies:**
- `swww`: Wayland wallpaper daemon
- `jq`: JSON parser
- `hyprctl`: Hyprland control utility

---

### `wallpaper-change.sh`

**Purpose:** Manual wallpaper change trigger (on-demand rotation).

**Usage:**
```bash
wallpaper-change.sh
```

**What it does:**
- Immediately changes wallpapers on all monitors
- Randomly selects from available wallpapers
- Applies with smooth fade transitions
- Provides user notification on completion

**Keybinding:** Super+Shift+W (if configured)

**Relationship to wallpaper-rotate.sh:**
- `wallpaper-rotate.sh`: Automatic daemon (every 3 minutes)
- `wallpaper-change.sh`: Manual trigger (on-demand)

---

## Status Bar Scripts

### `waybar-theme-switch.sh`

**Purpose:** Switch between Waybar theme variants.

**Usage:**
```bash
waybar-theme-switch.sh
```

**What it does:**
- Switches between theme variants (v1, v2)
- Reloads Waybar configuration
- Provides user feedback

**Available Themes:**
- `v1`: Original theme
- `v2`: Updated theme

---

## Authentication Scripts

### `howdy-add-auto.sh`

**Purpose:** Automate Howdy face model enrollment with auto-generated timestamp names.

**Usage:**
```bash
# Enroll for current user
howdy-add-auto.sh

# Enroll for specific user
howdy-add-auto.sh -U username
```

**What it does:**
- Generates timestamp-based model name (YYYY-MM-DD_HH-MM-SS)
- Automates Howdy's interactive enrollment process
- Uses expect/pexpect for automation
- Eliminates manual input requirements

**Generated Name Format:**
- Example: `2025-12-02_16-30-45`
- ISO 8601-inspired format
- Ensures uniqueness and chronological sorting

**Dependencies:**
- `howdy`: Face recognition system
- `expect`: Automation tool (recommended)
- `pexpect`: Python library (optional fallback)

**Location:** `scripts/.local/bin/howdy-add-auto.sh`

**Reference:** See script header for complete documentation.

---

## Script Locations

### User Scripts (in PATH)

All scripts in `scripts/.local/bin/` are automatically in PATH when deployed:
- `~/.local/bin/effects-on.sh`
- `~/.local/bin/effects-off.sh`
- `~/.local/bin/effects-toggle.sh`
- `~/.local/bin/hyprland-corner.sh`
- `~/.local/bin/hyprland-rounded.sh`
- `~/.local/bin/screenshot-mode.sh`
- `~/.local/bin/screenshot-mode-exit.sh`
- `~/.local/bin/wallpaper-change.sh`
- `~/.local/bin/wallpaper-rotate.sh`
- `~/.local/bin/waybar-theme-switch.sh`
- `~/.local/bin/howdy-add-auto.sh`

---

## Deployment

### Automatic Deployment

Scripts are deployed automatically when using GNU Stow:
```bash
cd ~/EliteBook
stow scripts -t ~/
```

This creates symlinks from `scripts/.local/bin/` to `~/.local/bin/`.

### Manual Deployment

```bash
# Copy scripts to local bin
cp -r scripts/.local/bin/* ~/.local/bin/

# Make executable
chmod +x ~/.local/bin/*.sh
```

---

## Script Documentation

All scripts include comprehensive header documentation:
- Purpose and operational context
- Usage examples
- Dependencies
- Technical approach
- References

**View script documentation:**
```bash
head -100 ~/.local/bin/script-name.sh
```

---

## Keybindings

Scripts can be bound to keyboard shortcuts in `hyprland.conf`:

```hyprland
# Example keybindings
bind = SUPER SHIFT, S, exec, screenshot-mode.sh
bind = SUPER SHIFT, F, exec, screenshot-mode-exit.sh
bind = SUPER SHIFT, W, exec, wallpaper-change.sh
```

---

## Troubleshooting

### Script Not Found

```bash
# Check if script is in PATH
which script-name.sh

# If not found, verify deployment:
ls -la ~/.local/bin/script-name.sh

# Re-deploy if needed:
cd ~/EliteBook
stow scripts -t ~/
```

### Script Permission Denied

```bash
# Make script executable
chmod +x ~/.local/bin/script-name.sh
```

### Script Fails to Execute

```bash
# Check script syntax
bash -n ~/.local/bin/script-name.sh

# Run with debug output
bash -x ~/.local/bin/script-name.sh
```

---

**Repository:** https://github.com/merneo/EliteBook  
**Last Updated:** December 2, 2025  
**Version:** 2.0.0
