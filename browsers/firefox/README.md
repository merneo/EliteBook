# Firefox Configuration

**Purpose:** Comprehensive Firefox configuration for Arch Linux with Wayland support and Catppuccin Mocha Green theme  
**Target:** Firefox 120+ on Arch Linux with Hyprland  
**Theme:** Catppuccin Mocha Green (based on Google Chrome theme)

---

## Configuration Files

### `user.js`

Firefox user preferences file implementing privacy, security, and performance optimizations.

**Technical Context:**
This file contains Firefox preference settings following Mozilla's `user.js` specification. Preferences are set using the `user_pref()` function and override default Firefox settings. The configuration emphasizes privacy-first principles, performance optimization for Wayland environments, and integration with the desktop environment.

**Key Configuration Areas:**
- **Privacy and Security:** Enhanced tracking protection, telemetry disabled, strict cookie controls
- **Performance:** Hardware acceleration for Wayland, memory management, network optimization
- **Wayland Integration:** Native Wayland rendering, clipboard integration (wl-clipboard), screen sharing
- **UI Customization:** Theme integration, userChrome.css enablement

**Location:** `~/.mozilla/firefox/*.default-release/user.js`

**References:**
- Mozilla user.js Specification: https://github.com/arkenfox/user.js
- Firefox Preferences: https://kb.mozillazine.org/About:config

### `userChrome.css`

Firefox UI customization stylesheet implementing Catppuccin Mocha Green theme.

**Technical Context:**
This stylesheet imports the main theme file and provides additional UI customizations. Firefox's userChrome.css system allows complete UI customization following CSS standards. The file uses `@import` to load the comprehensive theme stylesheet.

**Location:** `~/.mozilla/firefox/*.default-release/chrome/userChrome.css`

**References:**
- Firefox CSS Reference: https://developer.mozilla.org/en-US/docs/Mozilla/Tech/XUL/Tutorial/Modifying_the_Default_Skin
- userChrome.css Guide: https://www.userchrome.org/

### `catppuccin-mocha-green.css`

Complete Catppuccin Mocha Green theme implementation for Firefox, based on Google Chrome theme configuration.

**Technical Context:**
This stylesheet implements the Catppuccin color palette, a community-driven pastel color scheme designed for eye comfort and aesthetic consistency. The theme matches the Google Chrome Catppuccin Mocha Green theme exactly, ensuring visual consistency across browsers.

**Color Implementation:**
- Frame: Crust (#11111b, RGB 17,17,27) - matching Chrome frame
- Toolbar: Base (#1e1e2e, RGB 30,30,46) - matching Chrome toolbar
- Omnibox: Crust background (#11111b) with green text (#a6e3a1) - matching Chrome omnibox
- Tab text: White (#cdd6f4) - matching Chrome tab_text
- Accent: Green (#a6e3a1, RGB 166,227,161) - matching Chrome toolbar_button_icon

**Location:** `~/.mozilla/firefox/*.default-release/chrome/catppuccin-mocha-green.css`

**References:**
- Catppuccin: https://github.com/catppuccin/catppuccin
- Chrome Theme Source: `~/catppuccin-extension-mocha-green/manifest.json`

---

## Key Features

### Privacy Enhancements

- **Strict tracking protection:** Enhanced privacy settings blocking third-party trackers
- **Telemetry disabled:** Minimal data collection for improved privacy
- **Enhanced cookie controls:** Strict cookie policies and automatic deletion
- **DNS-over-HTTPS (DoH):** Encrypted DNS queries for privacy

### Performance Optimizations

- **Hardware acceleration:** GPU rendering for Wayland environments
- **Memory management:** Optimized cache and process management
- **Network optimization:** Connection pooling and prefetching controls
- **Process management:** Multi-process architecture optimization

### Wayland Integration

- **Native Wayland rendering:** Direct Wayland surface rendering (no X11 fallback)
- **Clipboard integration:** wl-clipboard support for Wayland clipboard
- **Screen sharing:** Native Wayland screen sharing support
- **Multi-monitor handling:** Proper display detection and window placement

### Theme Integration

- **Catppuccin Mocha Green:** Complete theme matching Chrome theme
- **Address bar:** Crust background with green text (matching Chrome omnibox)
- **Tab bar:** Base background with green accent borders
- **Visual consistency:** Matches Hyprland, Waybar, Kitty, and other desktop components

---

## Deployment

### Automated Deployment

```bash
# Use deployment script
cd ~/EliteBook/browsers
./deploy-themes.sh
```

### Manual Deployment

```bash
# Find Firefox profile directory
FIREFOX_PROFILE=$(find ~/.mozilla/firefox -name "*.default-release" -type d | head -1)

# Create chrome directory
mkdir -p "$FIREFOX_PROFILE/chrome"

# Copy configuration files
cp user.js "$FIREFOX_PROFILE/"
cp userChrome.css "$FIREFOX_PROFILE/chrome/"
cp catppuccin-mocha-green.css "$FIREFOX_PROFILE/chrome/"

# Enable userChrome.css (required)
# Open Firefox: about:config
# Set: toolkit.legacyUserProfileCustomizations.stylesheets = true

# Restart Firefox to apply changes
```

### Verification

1. **Check userChrome.css is enabled:**
   - Open Firefox: `about:config`
   - Verify: `toolkit.legacyUserProfileCustomizations.stylesheets` = `true`

2. **Visual verification:**
   - Address bar should have Crust background (#11111b) with green text (#a6e3a1)
   - Tab bar should have Base background (#1e1e2e)
   - Selected tab should have green bottom border
   - Navigation buttons should be green

---

## Customization

### Modifying Preferences

Edit `user.js` to modify preferences:
- **Privacy settings:** `privacy.*` preferences
- **Performance:** `browser.cache.*` settings
- **UI:** `browser.uidensity` and appearance settings

### Modifying Theme

Edit `catppuccin-mocha-green.css` to modify theme colors:
- All colors use exact hex values matching Chrome theme
- Color variables defined in `:root` for consistency
- CSS selectors target specific Firefox UI elements

---

## Troubleshooting

### Theme Not Applied

1. **Verify userChrome.css is enabled:**
   ```bash
   grep "toolkit.legacyUserProfileCustomizations.stylesheets" ~/.mozilla/firefox/*/prefs.js
   ```

2. **Check file locations:**
   ```bash
   ls -la ~/.mozilla/firefox/*/chrome/userChrome.css
   ls -la ~/.mozilla/firefox/*/chrome/catppuccin-mocha-green.css
   ```

3. **Restart Firefox completely:**
   - Close all Firefox windows
   - Verify no Firefox processes running: `ps aux | grep firefox`
   - Restart Firefox

### Address Bar Colors Incorrect

If address bar shows incorrect colors:
1. Verify CSS selectors are correct
2. Check for Firefox version compatibility
3. Clear Firefox cache: `rm -rf ~/.cache/mozilla/firefox/*`

---

**Status:** ✅ Production Ready  
**Last Updated:** 2025-12-02
