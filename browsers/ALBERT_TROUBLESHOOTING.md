# Albert Launcher Browser Discovery Troubleshooting

**Purpose:** Troubleshooting guide for Albert launcher not finding Firefox and Brave browsers  
**Status:** 🔧 Active Troubleshooting  
**Date:** 2025-12-02

---

## Problem

Albert launcher cannot find or launch Firefox and Brave browsers, even after desktop entries are created and deployed.

---

## Root Cause Analysis

### Issue 1: Browsers Not Installed

Desktop entries reference executables (`firefox`, `brave`) that are not in PATH:
- `which firefox` → not found
- `which brave` → not found
- `pacman -Q firefox brave-bin` → packages not installed

**Impact:** Desktop entries are valid but cannot launch applications because executables don't exist.

### Issue 2: Albert Indexing

Albert may not have re-indexed applications after desktop entries were added. Albert caches application metadata for performance.

---

## Solutions

### Solution 1: Install Browsers (Required)

Desktop entries are useless without installed browsers:

```bash
# Install Firefox (official repositories)
sudo pacman -S firefox

# Install Brave (AUR)
yay -S brave-bin
```

After installation, browsers will be in PATH and desktop entries will work.

### Solution 2: Force Albert Re-index

```bash
# Clear Albert cache
rm -rf ~/.cache/albert

# Restart Albert
pkill albert
albert &

# Wait a few seconds for indexing to complete
sleep 5
```

### Solution 3: Verify Desktop Entries

```bash
# Validate desktop entries
desktop-file-validate ~/.local/share/applications/firefox.desktop
desktop-file-validate ~/.local/share/applications/brave.desktop

# Update desktop database
update-desktop-database ~/.local/share/applications

# Check if entries are registered
grep -E "firefox|brave" ~/.local/share/applications/mimeinfo.cache
```

### Solution 4: Check Albert Configuration

Albert uses the `applications` plugin to index desktop entries. Verify it's enabled:

1. Open Albert settings: `albert settings` (or right-click system tray icon)
2. Navigate to **Plugins** → **Applications**
3. Ensure plugin is **enabled**
4. Check **Index paths** include:
   - `~/.local/share/applications`
   - `/usr/share/applications`

### Solution 5: Manual Desktop Entry Test

Test if desktop entries work outside Albert:

```bash
# Test with gtk-launch (requires desktop entry name without .desktop)
gtk-launch firefox 2>&1
gtk-launch brave 2>&1

# Test with desktop-file-install (if needed)
desktop-file-install --dir=~/.local/share/applications \
  ~/.local/share/applications/firefox.desktop
```

---

## Desktop Entry Structure

### TryExec Field

Desktop entries now include `TryExec` field:

```ini
TryExec=firefox
Exec=firefox %u
```

**Purpose:** `TryExec` checks if executable exists before showing entry in launchers. If `firefox` is not found, the entry may be hidden from Albert.

**Solution:** Install browsers to satisfy `TryExec` requirement.

---

## Verification Steps

### Step 1: Verify Browsers Installed

```bash
which firefox brave
pacman -Q firefox brave-bin
```

**Expected:** Executables found, packages installed.

### Step 2: Verify Desktop Entries

```bash
ls -la ~/.local/share/applications/*.desktop | grep -E "firefox|brave"
desktop-file-validate ~/.local/share/applications/firefox.desktop
```

**Expected:** Files exist, validation passes.

### Step 3: Verify Desktop Database

```bash
update-desktop-database ~/.local/share/applications
grep -E "firefox|brave" ~/.local/share/applications/mimeinfo.cache
```

**Expected:** Entries appear in cache.

### Step 4: Verify Albert Index

1. Open Albert (`Super+R` or `Alt+Space`)
2. Type "firefox" or "brave"
3. Browsers should appear in results

**Expected:** Browsers visible in Albert search results.

---

## Common Issues

### Issue: Desktop Entry Not Visible in Albert

**Causes:**
- Browser not installed (`TryExec` fails)
- Albert cache not cleared
- Applications plugin disabled
- Desktop database not updated

**Fix:**
```bash
# Install browser
sudo pacman -S firefox

# Clear cache and restart
rm -rf ~/.cache/albert
pkill albert && albert &
```

### Issue: Desktop Entry Visible But Won't Launch

**Causes:**
- Executable not in PATH
- Wrong Exec path in desktop entry
- Permission issues

**Fix:**
```bash
# Check executable
which firefox

# If not found, update desktop entry with full path
# Edit ~/.local/share/applications/firefox.desktop
# Change: Exec=firefox %u
# To: Exec=/usr/bin/firefox %u (or actual path)
```

### Issue: Albert Shows Entry But Launch Fails

**Causes:**
- Executable exists but has errors
- Missing dependencies
- Wayland/X11 compatibility issues

**Fix:**
```bash
# Test launch from terminal
firefox &
brave &

# Check for errors
journalctl --user -f | grep -E "firefox|brave"
```

---

## Albert Configuration Reference

### Applications Plugin Settings

Location: `~/.config/albert/config`

Key settings:
- `applications/indexPaths`: Directories to index
- `applications/enabled`: Plugin enabled/disabled
- `applications/useKeywords`: Use Keywords field for search

### Manual Configuration Edit

```bash
# Edit Albert config
nvim ~/.config/albert/config

# Look for [applications] section
# Ensure indexPaths includes:
#   ~/.local/share/applications
#   /usr/share/applications
```

---

## Alternative: Wrapper Scripts

If browsers are installed in non-standard locations, create wrapper scripts:

```bash
# Create wrapper for Firefox
cat > ~/.local/bin/firefox-wrapper << 'EOF'
#!/bin/bash
# Firefox wrapper script
if command -v firefox &> /dev/null; then
    exec firefox "$@"
else
    echo "Firefox is not installed. Install with: sudo pacman -S firefox"
    exit 1
fi
EOF

chmod +x ~/.local/bin/firefox-wrapper

# Update desktop entry Exec to use wrapper
# Exec=~/.local/bin/firefox-wrapper %u
```

---

## References

- **Albert Documentation:** https://albertlauncher.github.io/docs/
- **Desktop Entry Spec:** https://specifications.freedesktop.org/desktop-entry-spec/
- **Arch Linux Firefox:** https://wiki.archlinux.org/title/Firefox
- **Arch Linux Brave:** https://wiki.archlinux.org/title/Brave

---

**Last Updated:** 2025-12-02  
**Status:** 🔧 Troubleshooting in progress
