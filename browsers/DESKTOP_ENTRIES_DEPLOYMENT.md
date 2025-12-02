# Browser Desktop Entries Deployment Guide

**Purpose:** Deploy desktop entry files for Firefox and Brave browsers to enable Albert launcher discovery  
**Status:** ✅ Ready for Deployment  
**Date:** 2025-12-02

---

## Problem

Albert launcher cannot find Firefox and Brave browsers because desktop entry files (`.desktop`) are missing or not in the correct location.

---

## Solution

Desktop entry files provide standardized application registration following the freedesktop.org Desktop Entry Specification. These files enable:
- Application launchers (Albert, rofi, dmenu) to discover applications
- Desktop environments to show applications in menus
- File managers to associate file types with applications

---

## Deployment

### Method 1: Using GNU Stow (Recommended)

```bash
cd ~/EliteBook/browsers
stow -t ~ .local
```

This creates symlinks:
- `~/.local/share/applications/firefox.desktop`
- `~/.local/share/applications/brave.desktop`

### Method 2: Manual Copy

```bash
# Create applications directory
mkdir -p ~/.local/share/applications

# Copy desktop entries
cp browsers/.local/share/applications/firefox.desktop ~/.local/share/applications/
cp browsers/.local/share/applications/brave.desktop ~/.local/share/applications/

# Update desktop database
update-desktop-database ~/.local/share/applications
```

### Method 3: System-Wide Installation (Requires Root)

```bash
# Copy to system-wide location
sudo cp browsers/.local/share/applications/firefox.desktop /usr/share/applications/
sudo cp browsers/.local/share/applications/brave.desktop /usr/share/applications/

# Update desktop database
sudo update-desktop-database
```

---

## Verification

### Check Desktop Entries

```bash
# List desktop entries
ls -la ~/.local/share/applications/*.desktop

# Validate entries
desktop-file-validate ~/.local/share/applications/firefox.desktop
desktop-file-validate ~/.local/share/applications/brave.desktop
```

### Test Albert Discovery

1. **Restart Albert:**
   ```bash
   pkill albert
   albert &
   ```

2. **Search for browsers:**
   - Press `Super+R` or `Alt+Space` to open Albert
   - Type "firefox" or "brave"
   - Browsers should appear in results

### Alternative: Update Desktop Database

```bash
# Update user database
update-desktop-database ~/.local/share/applications

# If command not found, install desktop-file-utils
sudo pacman -S desktop-file-utils
```

---

## Troubleshooting

### Albert Still Doesn't Find Browsers

1. **Check Exec Path:**
   ```bash
   # Verify Firefox executable
   which firefox
   
   # Verify Brave executable
   which brave
   ```

2. **Update Desktop Entry Exec Path:**
   - If browsers are in non-standard locations, edit `.desktop` files
   - Update `Exec=` line with full path
   - Example: `Exec=/opt/firefox/firefox %u`

3. **Restart Albert:**
   ```bash
   pkill albert
   sleep 1
   albert &
   ```

4. **Clear Albert Cache:**
   ```bash
   rm -rf ~/.cache/albert
   albert &
   ```

### Desktop Entry Validation Errors

```bash
# Install validation tool
sudo pacman -S desktop-file-utils

# Validate entries
desktop-file-validate ~/.local/share/applications/firefox.desktop
desktop-file-validate ~/.local/share/applications/brave.desktop
```

---

## Desktop Entry File Structure

### Key Fields

- **Name:** Display name in launcher
- **Exec:** Command to launch application
- **Icon:** Icon name or path
- **Categories:** Application categories (Network, WebBrowser)
- **MimeType:** File types handled by application
- **Keywords:** Search terms for launchers

### Exec Path Resolution

Desktop entries use PATH environment variable to resolve executable names:
- `Exec=firefox %u` → Searches PATH for `firefox` executable
- `Exec=/usr/bin/firefox %u` → Uses absolute path (more reliable)

---

## Integration with Hyprland

After deployment, browsers can be launched via:

1. **Albert Launcher:**
   - `Super+R` → Type "firefox" or "brave"
   - `Alt+Space` → Type browser name

2. **Hyprland Keybindings:**
   ```conf
   bind = $mainMod, B, exec, firefox    # Launch Firefox
   bind = $mainMod, Shift+B, exec, brave # Launch Brave
   ```

3. **Terminal:**
   ```bash
   firefox &
   brave &
   ```

---

## References

- **Desktop Entry Specification:** https://specifications.freedesktop.org/desktop-entry-spec/
- **Albert Launcher:** https://github.com/albertlauncher/albert
- **freedesktop.org:** https://www.freedesktop.org/

---

**Last Updated:** 2025-12-02  
**Status:** ✅ Ready for deployment
