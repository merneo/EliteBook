# Browser Theme Deployment Guide

**Purpose:** Step-by-step guide to deploy Catppuccin Mocha Green themes for Firefox and Brave  
**Status:** ✅ Ready for Deployment  
**Date:** 2025-12-02

---

## Overview

This repository contains complete Catppuccin Mocha Green theme configurations for:
- **Firefox:** UI customization via `userChrome.css` and `user.js`
- **Brave:** Native theme via JSON configuration

---

## Firefox Theme Deployment

### Step 1: Enable Firefox Customization

Firefox requires a preference flag to enable `userChrome.css`:

1. Open Firefox
2. Navigate to: `about:config`
3. Search for: `toolkit.legacyUserProfileCustomizations.stylesheets`
4. Set to: `true` (double-click to toggle)

**Alternative (via user.js):**
The `user.js` file in this repository already sets this preference automatically.

### Step 2: Locate Firefox Profile Directory

```bash
# Find your Firefox profile
find ~/.mozilla/firefox -name "*.default*" -o -name "*.default-release*" | head -1
```

Common locations:
- `~/.mozilla/firefox/xxxxx.default-release/`
- `~/.mozilla/firefox/xxxxx.default/`

### Step 3: Create chrome Directory

```bash
# Replace PROFILE_PATH with your actual profile path
mkdir -p ~/.mozilla/firefox/PROFILE_PATH/chrome
```

### Step 4: Deploy Firefox Theme Files

**Method 1: Using GNU Stow (Recommended)**

```bash
cd ~/EliteBook/browsers/firefox
stow -t ~/.mozilla/firefox/PROFILE_PATH/chrome .
```

**Method 2: Manual Copy**

```bash
# Copy theme files
cp browsers/firefox/userChrome.css ~/.mozilla/firefox/PROFILE_PATH/chrome/
cp browsers/firefox/catppuccin-mocha-green.css ~/.mozilla/firefox/PROFILE_PATH/chrome/
cp browsers/firefox/user.js ~/.mozilla/firefox/PROFILE_PATH/
```

### Step 5: Restart Firefox

Close and reopen Firefox. The theme should be applied immediately.

### Step 6: Verify Theme

1. Check if `userChrome.css` is loaded:
   - Open Developer Tools (F12)
   - Check Console for any CSS errors
2. Visual verification:
   - Tab bar should have green accent color
   - Navigation bar should match Catppuccin Mocha Green palette
   - Scrollbars should be styled

---

## Brave Theme Deployment

### Step 1: Access Brave Theme Settings

1. Open Brave browser
2. Navigate to: `brave://settings/appearance`
3. Scroll to **"Themes"** section

### Step 2: Import Theme JSON

**Method 1: Via Brave Settings UI**

1. In `brave://settings/appearance`, click **"Get themes"**
2. This opens Chrome Web Store
3. For custom theme, use Method 2 below

**Method 2: Manual JSON Import (Custom Theme)**

Brave doesn't support direct JSON import. Use one of these methods:

**Option A: Create Extension (Recommended)**

1. Create extension directory:
   ```bash
   mkdir -p ~/.local/share/brave-theme
   cd ~/.local/share/brave-theme
   ```

2. Create `manifest.json`:
   ```json
   {
     "manifest_version": 3,
     "name": "Catppuccin Mocha Green",
     "version": "1.0",
     "theme": {
       "colors": {
         "frame": [24, 24, 37],
         "frame_inactive": [17, 17, 27],
         "background_tab": [30, 30, 46],
         "background_tab_inactive": [24, 24, 37],
         "toolbar": [30, 30, 46],
         "toolbar_text": [166, 227, 161],
         "toolbar_field": [24, 24, 37],
         "toolbar_field_text": [205, 214, 244],
         "button_background": [166, 227, 161],
         "ntp_background": [24, 24, 37],
         "ntp_text": [205, 214, 244]
       }
     }
   }
   ```

3. Load extension:
   - Navigate to `brave://extensions/`
   - Enable **"Developer mode"**
   - Click **"Load unpacked"**
   - Select `~/.local/share/brave-theme`

**Option B: Use Chrome Web Store Theme**

If you have a Chrome Web Store developer account:
1. Package theme as Chrome extension
2. Upload to Chrome Web Store
3. Install from store in Brave

**Option C: Manual Color Application**

1. Open `brave://settings/appearance`
2. Manually set colors using Brave's built-in theme editor
3. Reference `catppuccin-mocha-green.json` for color values

### Step 3: Verify Theme

1. Check browser chrome (address bar, tabs)
2. Verify colors match Catppuccin Mocha Green palette
3. Test in both light and dark modes (if applicable)

---

## Automated Deployment Script

Create a deployment script for easier setup:

```bash
#!/bin/bash
# deploy-browser-themes.sh

# Firefox deployment
FIREFOX_PROFILE=$(find ~/.mozilla/firefox -name "*.default*" -o -name "*.default-release*" | head -1)
if [ -n "$FIREFOX_PROFILE" ]; then
    mkdir -p "$FIREFOX_PROFILE/chrome"
    cp browsers/firefox/*.css "$FIREFOX_PROFILE/chrome/"
    cp browsers/firefox/user.js "$FIREFOX_PROFILE/"
    echo "✅ Firefox theme deployed to: $FIREFOX_PROFILE"
else
    echo "⚠️ Firefox profile not found"
fi

# Brave deployment (manual steps required)
echo "ℹ️ Brave theme requires manual setup (see documentation)"
```

---

## Troubleshooting

### Firefox: Theme Not Applied

1. **Check `about:config`:**
   ```bash
   # Verify preference is set
   grep "toolkit.legacyUserProfileCustomizations.stylesheets" ~/.mozilla/firefox/*/prefs.js
   ```

2. **Verify file locations:**
   ```bash
   ls -la ~/.mozilla/firefox/*/chrome/userChrome.css
   ls -la ~/.mozilla/firefox/*/chrome/catppuccin-mocha-green.css
   ```

3. **Check Firefox console:**
   - Open Developer Tools (F12)
   - Check Console tab for CSS errors
   - Look for file loading errors

4. **Restart Firefox:**
   - Completely close Firefox (not just window)
   - Reopen to reload theme

### Brave: Theme Not Applied

1. **Check extension:**
   - Navigate to `brave://extensions/`
   - Verify theme extension is enabled
   - Check for errors

2. **Verify JSON syntax:**
   ```bash
   python3 -m json.tool browsers/brave/catppuccin-mocha-green.json
   ```

3. **Clear browser cache:**
   - Navigate to `brave://settings/clearBrowserData`
   - Clear cached images and files

---

## Color Palette Reference

Catppuccin Mocha Green colors used in themes:

- **Base:** `#1e1e2e` (RGB: 30, 30, 46)
- **Mantle:** `#181825` (RGB: 24, 24, 37)
- **Crust:** `#11111b` (RGB: 17, 17, 27)
- **Text:** `#cdd6f4` (RGB: 205, 214, 244)
- **Green:** `#a6e3a1` (RGB: 166, 227, 161)
- **Accent:** `#a6e3a1` (RGB: 166, 227, 161)

Full palette: https://github.com/catppuccin/catppuccin

---

## File Structure

```
browsers/
├── firefox/
│   ├── userChrome.css              # Main UI customization
│   ├── catppuccin-mocha-green.css  # Color theme definitions
│   └── user.js                      # Firefox preferences
├── brave/
│   └── catppuccin-mocha-green.json # Brave theme colors
└── THEME_DEPLOYMENT.md             # This file
```

---

## References

- **Catppuccin:** https://github.com/catppuccin/catppuccin
- **Firefox userChrome.css:** https://www.userchrome.org/
- **Brave Themes:** https://support.brave.com/hc/en-us/articles/360035488311-How-do-I-change-the-theme-in-Brave-
- **Chrome Extension Themes:** https://developer.chrome.com/docs/extensions/mv3/themes/

---

**Last Updated:** 2025-12-02  
**Status:** ✅ Ready for deployment
