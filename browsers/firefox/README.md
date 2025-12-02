# Firefox Configuration

**Purpose:** Comprehensive Firefox configuration for Arch Linux with Wayland support  
**Target:** Firefox 120+ on Arch Linux with Hyprland

---

## Configuration Files

### `user.js`

Firefox user preferences file. Contains:
- Privacy and security settings
- Performance optimizations
- Wayland-specific configurations
- UI customizations

**Location:** `~/.mozilla/firefox/*.default-release/user.js`

### `userChrome.css`

Firefox UI customization stylesheet. Customizes:
- Tab bar appearance
- Navigation bar styling
- Window decorations
- Theme integration

**Location:** `~/.mozilla/firefox/*.default-release/chrome/userChrome.css`

---

## Key Features

### Privacy Enhancements

- Strict tracking protection
- Disabled telemetry
- Enhanced cookie controls
- DNS-over-HTTPS (DoH) configuration

### Performance Optimizations

- Hardware acceleration for Wayland
- Memory management settings
- Network optimization
- Process management

### Wayland Integration

- Native Wayland rendering
- Clipboard integration (wl-clipboard)
- Screen sharing support
- Multi-monitor handling

---

## Deployment

```bash
# Find Firefox profile directory
FIREFOX_PROFILE=$(find ~/.mozilla/firefox -name "*.default-release" -type d | head -1)

# Copy configuration files
cp user.js "$FIREFOX_PROFILE/"
mkdir -p "$FIREFOX_PROFILE/chrome"
cp userChrome.css "$FIREFOX_PROFILE/chrome/"

# Restart Firefox to apply changes
```

---

## Customization

Edit `user.js` to modify preferences:
- Privacy settings: `privacy.*` preferences
- Performance: `browser.cache.*` settings
- UI: `browser.uidensity` and appearance settings

---

**Status:** 🚧 In Development
