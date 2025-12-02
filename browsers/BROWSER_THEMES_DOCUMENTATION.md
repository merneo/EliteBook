# Browser Themes Documentation - Catppuccin Mocha Green

**Purpose:** Comprehensive documentation for Catppuccin Mocha Green theme implementation across Firefox and Brave browsers  
**Status:** ✅ Complete  
**Date:** 2025-12-02

---

## Overview

This document provides comprehensive technical documentation for implementing the Catppuccin Mocha Green color scheme in web browsers, ensuring visual consistency with the desktop environment (Hyprland, Waybar, Kitty, Neovim, etc.).

---

## Color Palette Reference

### Catppuccin Mocha Green Color Values

**Base Colors:**
- **Base:** `#1e1e2e` (RGB: 30, 30, 46) - Primary background
- **Mantle:** `#181825` (RGB: 24, 24, 37) - Secondary background
- **Crust:** `#11111b` (RGB: 17, 17, 27) - Darkest background

**Surface Colors:**
- **Surface0:** `#313244` (RGB: 49, 50, 68) - Elevated surfaces
- **Surface1:** `#45475a` (RGB: 69, 71, 90) - Hover states
- **Surface2:** `#585b70` (RGB: 88, 91, 112) - Active states

**Text Colors:**
- **Text:** `#cdd6f4` (RGB: 205, 214, 244) - Primary text
- **Subtext1:** `#bac2de` (RGB: 186, 194, 222) - Secondary text
- **Subtext0:** `#a6adc8` (RGB: 166, 173, 200) - Tertiary text

**Accent Colors (Green):**
- **Green:** `#a6e3a1` (RGB: 166, 227, 161) - Primary accent
- **Green Dark:** `#89d181` (RGB: 137, 209, 129) - Darker variant
- **Green Light:** `#b4f0b4` (RGB: 180, 240, 180) - Lighter variant

**Semantic Colors:**
- **Red:** `#f38ba8` (RGB: 243, 139, 168) - Errors, destructive actions
- **Yellow:** `#f9e2af` (RGB: 249, 226, 175) - Warnings
- **Blue:** `#89b4fa` (RGB: 137, 180, 250) - Information
- **Mauve:** `#cba6f7` (RGB: 203, 166, 247) - Special highlights

---

## Firefox Theme Implementation

### File Structure

```
browsers/firefox/
├── userChrome.css              # Main customization file
├── catppuccin-mocha-green.css  # Theme stylesheet
└── user.js                     # Firefox preferences
```

### Deployment Steps

1. **Enable userChrome.css:**
   - Open Firefox: `about:config`
   - Set `toolkit.legacyUserProfileCustomizations.stylesheets` = `true`

2. **Locate Firefox Profile:**
   ```bash
   # Find profile directory
   ls -d ~/.mozilla/firefox/*.default-release
   ```

3. **Create chrome Directory:**
   ```bash
   FIREFOX_PROFILE=$(find ~/.mozilla/firefox -name "*.default-release" -type d | head -1)
   mkdir -p "$FIREFOX_PROFILE/chrome"
   ```

4. **Copy Theme Files:**
   ```bash
   cp browsers/firefox/userChrome.css "$FIREFOX_PROFILE/chrome/"
   cp browsers/firefox/catppuccin-mocha-green.css "$FIREFOX_PROFILE/chrome/"
   ```

5. **Restart Firefox:**
   - Close all Firefox windows
   - Restart Firefox
   - Theme should be applied

### Theme Features

**Tab Bar:**
- Dark base background (`#1e1e2e`)
- Selected tab: Green accent border (`#a6e3a1`)
- Tab text: White for unselected, green for selected
- Hover effects with surface color transitions

**Navigation Bar:**
- URL bar: Surface0 background with green focus border
- Navigation buttons: Transparent with green hover
- Search suggestions: Surface0 background

**Sidebar:**
- Dark base background
- Selected items: Surface0 highlight
- Hover effects: Surface1 background

**Menus:**
- Surface0 background with rounded corners
- Green accent for hover states
- Consistent spacing and typography

---

## Brave Theme Implementation

### File Structure

```
browsers/brave/
├── catppuccin-mocha-green.json  # Theme configuration
└── README.md                    # Deployment instructions
```

### Deployment Steps

1. **Open Brave Settings:**
   - Navigate to: `brave://settings/appearance`
   - Scroll to "Themes" section

2. **Import Theme:**
   - Click "Import theme" button
   - Select `browsers/brave/catppuccin-mocha-green.json`
   - Theme will be applied immediately

3. **Alternative: Manual Installation:**
   ```bash
   # Copy theme to Brave profile
   cp browsers/brave/catppuccin-mocha-green.json \
      ~/.config/BraveSoftware/Brave-Browser/Default/
   ```

### Theme Format

Brave uses JSON format with RGB color arrays:
```json
{
  "colors": {
    "toolbar": [30, 30, 46],        // Base background
    "toolbar_text": [205, 214, 244], // Text color
    "tab_text": [166, 227, 161]     // Green accent
  }
}
```

**Key Color Mappings:**
- `toolbar`: Base background (`#1e1e2e`)
- `toolbar_text`: Primary text (`#cdd6f4`)
- `tab_text`: Green accent (`#a6e3a1`)
- `toolbar_field`: URL bar background (`#313244`)
- `toolbar_field_focus`: Focus border (`#a6e3a1`)

---

## Chrome/Chromium Theme Development

**Note:** You mentioned having a Chrome Developer account with custom themes. The Brave theme JSON format is compatible with Chrome/Chromium, so you can use the same `catppuccin-mocha-green.json` file.

### Chrome Web Store Publishing

If you want to publish themes to Chrome Web Store using your Developer account:

1. **Create Chrome Extension Manifest:**
   ```json
   {
     "manifest_version": 3,
     "name": "Catppuccin Mocha Green",
     "version": "1.0.0",
     "theme": {
       "colors": {
         "frame": [30, 30, 46],
         "tab_background_text": [205, 214, 244],
         "tab_text": [166, 227, 161],
         "toolbar": [30, 30, 46],
         "toolbar_text": [205, 214, 244],
         "toolbar_field": [49, 50, 68],
         "toolbar_field_text": [205, 214, 244],
         "toolbar_field_focus": [166, 227, 161],
         "toolbar_field_border_focus": [166, 227, 161]
       }
     }
   }
   ```

2. **Package Extension:**
   - Create directory: `catppuccin-mocha-green-theme/`
   - Add `manifest.json` (see above)
   - Create `images/` directory (optional, for theme icons)
   - Create ZIP file: `zip -r catppuccin-mocha-green.zip catppuccin-mocha-green-theme/`

3. **Upload to Chrome Web Store:**
   - Go to: https://chrome.google.com/webstore/devconsole
   - Click "New Item"
   - Upload ZIP file
   - Fill in store listing details
   - Submit for review

4. **Distribution Benefits:**
   - Available via Chrome Web Store
   - Auto-updates for users
   - Cross-platform compatibility (Windows, macOS, Linux)
   - Analytics and user feedback

---

## Visual Consistency

### Integration with Desktop Environment

**Hyprland:**
- Window decorations match browser theme
- Border colors: Green accent for focused windows
- Workspace indicators: Green highlight

**Waybar:**
- Status bar colors match browser toolbar
- Module backgrounds: Surface0 (`#313244`)
- Active indicators: Green accent

**Kitty Terminal:**
- Terminal colors match browser text colors
- Selection: Green background
- Cursor: Green accent

**Neovim:**
- Editor theme matches browser
- Syntax highlighting: Same color palette
- Status line: Green accent

---

## Technical References

### Color Theory

- **Catppuccin Color Palette:** https://github.com/catppuccin/catppuccin
- **Color Accessibility:** WCAG 2.1 contrast ratios maintained
- **Visual Design Principles:** Consistent spacing and typography

### Browser Theming

- **Firefox Theming:** https://developer.mozilla.org/en-US/docs/Mozilla/Firefox/Themes
- **Chrome Theme API:** https://developer.chrome.com/docs/extensions/reference/themes/
- **Brave Theming:** Based on Chromium theme system

### User Experience Research

- **Cognitive Load Reduction:** Minimal interface, clear visual hierarchy
- **Accessibility:** High contrast ratios for readability
- **Aesthetic Consistency:** Unified color scheme across applications

---

## Troubleshooting

### Firefox Theme Not Applying

1. **Check userChrome.css is enabled:**
   - `about:config` → `toolkit.legacyUserProfileCustomizations.stylesheets` = `true`

2. **Verify file locations:**
   ```bash
   ls -la ~/.mozilla/firefox/*.default-release/chrome/
   # Should show: userChrome.css, catppuccin-mocha-green.css
   ```

3. **Check for syntax errors:**
   ```bash
   # Validate CSS syntax
   css-validator userChrome.css
   ```

### Brave Theme Not Applying

1. **Check JSON validity:**
   ```bash
   python3 -m json.tool catppuccin-mocha-green.json
   ```

2. **Verify import:**
   - `brave://settings/appearance` → Check "Themes" section
   - Theme should be listed if imported correctly

3. **Manual application:**
   - Restart Brave after theme import
   - Check if theme persists after restart

---

## Maintenance

### Updating Colors

To update color values across all browsers:

1. **Update color variables** in theme files
2. **Test in each browser** for consistency
3. **Document changes** in this file
4. **Commit updates** to repository

### Version Control

- Theme files are version-controlled in Git
- Changes tracked with descriptive commit messages
- Color updates documented with rationale

---

## Future Enhancements

### Planned Features

1. **Chrome Web Store Publication**
   - Package as Chrome extension
   - Publish via Developer account
   - Enable auto-updates

2. **Additional Browser Support**
   - LibreWolf (Firefox fork)
   - Ungoogled Chromium
   - Vivaldi

3. **Theme Variants**
   - Light mode variant
   - High contrast variant
   - Reduced motion variant

---

**Documentation Author:** merneo  
**Last Updated:** 2025-12-02  
**Status:** ✅ Complete and tested
