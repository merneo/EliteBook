# Brave Browser Configuration

**Purpose:** Brave browser configuration for Arch Linux with Wayland support  
**Target:** Brave 120+ on Arch Linux with Hyprland  
**Theme:** Catppuccin Mocha Green

---

## Configuration Files

### `catppuccin-mocha-green.json`

Brave theme configuration file with Catppuccin Mocha Green color scheme.

**Color Palette:**
- Base: `#1e1e2e` (RGB: 30, 30, 46)
- Surface: `#313244` (RGB: 49, 50, 68)
- Text: `#cdd6f4` (RGB: 205, 214, 244)
- Accent: `#a6e3a1` (RGB: 166, 227, 161) - Green

---

## Deployment

### Method 1: Import Theme JSON

1. Open Brave: `brave://settings/appearance`
2. Scroll to "Themes" section
3. Click "Import theme"
4. Select `catppuccin-mocha-green.json`
5. Theme will be applied immediately

### Method 2: Manual Installation

```bash
# Copy theme file to Brave profile
cp catppuccin-mocha-green.json ~/.config/BraveSoftware/Brave-Browser/Default/

# Or use stow (if configured)
cd ~/EliteBook/browsers
stow brave
```

### Method 3: Chrome Web Store (Future)

If you have a Chrome Developer account, you can:
1. Package theme as Chrome extension
2. Upload to Chrome Web Store
3. Install from store

---

## Key Features

### Privacy Settings

- Enhanced tracking protection (Brave Shields)
- Minimal telemetry
- Secure DNS (DoH)

### Wayland Support

- Native Wayland rendering
- Hardware acceleration
- Screen sharing support

### Theme Integration

- Matches system Catppuccin Mocha Green theme
- Consistent with Hyprland, Waybar, Kitty
- Green accent color throughout

---

## Customization

Edit `catppuccin-mocha-green.json` to modify colors:
- All colors are in RGB format `[R, G, B]`
- Values range from 0-255
- Restart Brave to apply changes

---

**Status:** 🚧 In Development
