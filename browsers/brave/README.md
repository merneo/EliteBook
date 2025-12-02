# Brave Browser Configuration

**Purpose:** Brave browser configuration for Arch Linux with Wayland support and Catppuccin Mocha Green theme  
**Target:** Brave 120+ on Arch Linux with Hyprland  
**Theme:** Catppuccin Mocha Green  
**Status:** ✅ Production Ready

---

## Configuration Files

### `manifest.json`

Chrome extension manifest file for Brave theme installation.

**Academic Context:**
Brave uses Chromium's theme system, which requires a Chrome extension manifest (manifest.json) following the Chrome Extension Manifest V3 specification. The manifest defines theme colors using RGB arrays, which are applied to various browser UI elements.

**Manifest Structure:**
- `manifest_version: 3` - Chrome Extension Manifest V3
- `name`: Theme display name
- `theme.colors`: RGB color arrays for UI elements
- All colors specified as `[R, G, B]` arrays (0-255 range)

**Location:** `~/EliteBook/browsers/brave/manifest.json`

**References:**
- Chrome Extension Manifest: https://developer.chrome.com/docs/extensions/mv3/manifest/
- Chrome Theme API: https://developer.chrome.com/docs/extensions/reference/themes/

### `catppuccin-mocha-green.json`

Legacy theme configuration file (for reference).

**Note:** This file is maintained for reference but the active theme configuration is in `manifest.json`. The JSON format matches Chrome theme color specification.

**Location:** `~/EliteBook/browsers/brave/catppuccin-mocha-green.json`

---

## Color Palette

**Base Colors:**
- **Base:** `#1e1e2e` (RGB: 30, 30, 46) - Primary background
- **Crust:** `#11111b` (RGB: 17, 17, 27) - Darkest background
- **Surface0:** `#313244` (RGB: 49, 50, 68) - Elevated surfaces

**Text Colors:**
- **Text:** `#cdd6f4` (RGB: 205, 214, 244) - Primary text
- **Subtext1:** `#bac2de` (RGB: 186, 194, 222) - Secondary text
- **Subtext0:** `#a6adc8` (RGB: 166, 173, 200) - Tertiary text

**Accent Colors:**
- **Green:** `#a6e3a1` (RGB: 166, 227, 161) - Primary accent color
- Used for: Tab text, toolbar field borders, bookmarks, buttons

**Full Palette Reference:**
See `../BROWSER_THEMES_DOCUMENTATION.md` for complete color palette documentation.

---

## Deployment

### Method 1: Load Unpacked Extension (Recommended)

1. **Open Brave Extensions:**
   - Navigate to: `brave://extensions/`

2. **Enable Developer Mode:**
   - Toggle "Developer mode" switch in top-right corner

3. **Load Extension:**
   - Click "Load unpacked" button
   - Select directory: `~/EliteBook/browsers/brave`
   - Theme will be applied immediately

4. **Verify Installation:**
   - Theme should appear in extensions list as "Catppuccin Mocha Green"
   - Browser UI should reflect theme colors

### Method 2: Manual Installation

```bash
# Create extension directory
mkdir -p ~/.local/share/brave-theme

# Copy manifest.json
cp ~/EliteBook/browsers/brave/manifest.json ~/.local/share/brave-theme/

# Load from ~/.local/share/brave-theme in Brave extensions
```

### Method 3: Chrome Web Store (Future)

If you have a Chrome Developer account:
1. Package theme as Chrome extension (ZIP file)
2. Upload to Chrome Web Store Developer Dashboard
3. Install from Chrome Web Store in Brave

**Benefits:**
- Auto-updates for users
- Cross-platform compatibility
- Analytics and user feedback

---

## Key Features

### Privacy Settings

- **Enhanced tracking protection:** Brave Shields blocking third-party trackers
- **Minimal telemetry:** Reduced data collection compared to Chrome
- **Secure DNS (DoH):** Encrypted DNS queries for privacy
- **Built-in ad blocking:** Brave's native ad blocker

### Wayland Support

- **Native Wayland rendering:** Direct Wayland surface rendering
- **Hardware acceleration:** GPU rendering for smooth performance
- **Screen sharing support:** Native Wayland screen sharing
- **Multi-monitor handling:** Proper display detection

### Theme Integration

- **Catppuccin Mocha Green:** Complete theme matching system-wide color scheme
- **Visual consistency:** Matches Hyprland, Waybar, Kitty, Neovim
- **Green accent color:** Consistent green (#a6e3a1) throughout interface
- **Professional appearance:** Dark theme optimized for eye comfort

---

## Theme Color Mapping

**Frame and Window:**
- `frame`: Base background (#1e1e2e)
- `frame_inactive`: Mantle background (#181825)
- `frame_incognito`: Surface1 background (#45475a)

**Toolbar:**
- `toolbar`: Base background (#1e1e2e)
- `toolbar_text`: Primary text (#cdd6f4)
- `toolbar_field`: Surface0 background (#313244)
- `toolbar_field_border`: Green accent (#a6e3a1)
- `toolbar_button_icon`: Green accent (#a6e3a1)

**Tabs:**
- `tab_text`: Green accent (#a6e3a1)
- `tab_background_text`: Subtext1 (#bac2de)
- `background_tab`: Surface0 (#313244)

**Bookmarks and Links:**
- `bookmark_text`: Green accent (#a6e3a1)
- `ntp_link`: Green accent (#a6e3a1)
- `ntp_header`: Green accent (#a6e3a1)

**Complete Color Reference:**
See `manifest.json` for all color mappings.

---

## Customization

### Modifying Theme Colors

Edit `manifest.json` to modify colors:
- All colors are in RGB format: `[R, G, B]`
- Values range from 0-255
- Restart Brave or reload extension to apply changes

**Example:**
```json
"colors": {
  "toolbar": [30, 30, 46],        // Base background
  "toolbar_text": [205, 214, 244], // Primary text
  "tab_text": [166, 227, 161]     // Green accent
}
```

### Reloading Extension

After modifying `manifest.json`:
1. Open `brave://extensions/`
2. Find "Catppuccin Mocha Green" extension
3. Click reload icon (circular arrow)
4. Theme will update immediately

---

## Troubleshooting

### Extension Not Loading

1. **Verify manifest.json syntax:**
   ```bash
   python3 -m json.tool ~/EliteBook/browsers/brave/manifest.json
   ```

2. **Check extension errors:**
   - Open `brave://extensions/`
   - Look for error messages under extension

3. **Verify directory structure:**
   ```bash
   ls -la ~/EliteBook/browsers/brave/manifest.json
   ```

### Theme Not Applied

1. **Check extension is enabled:**
   - Open `brave://extensions/`
   - Verify "Catppuccin Mocha Green" is enabled

2. **Reload extension:**
   - Click reload icon on extension card

3. **Restart Brave:**
   - Completely close Brave (all windows)
   - Restart to ensure theme is loaded

---

**Status:** ✅ Production Ready  
**Last Updated:** 2025-12-02
