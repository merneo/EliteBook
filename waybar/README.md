# Waybar v2 - Minimalist Design

This is the minimalist Waybar v2 configuration featuring a clean, distraction-free status bar with minimal visual elements.

## Features

- **Clean Workspace Display:** Plain numbers only, no backgrounds or decorations
- **Minimal Styling:** Only bold text and color distinguish active workspace
- **Focus-Friendly:** Reduces visual noise for keyboard-first workflow
- **Asymmetric Edge Spacing:** 0px left (workspaces flush to edge), 15px right (clock)
- **Zero Decorations:** No hover effects, borders, or transitions
- **Catppuccin Colors:** Green accent for active workspace, muted gray for inactive

## Preview

![Waybar v2 Minimalist Design](https://raw.githubusercontent.com/merneo/dotfiles/feat/waybar-v2/screenshot-waybar-v2.png)

*Waybar v2 showing clean workspace indicators (1 2 3 4 5) and minimal status bar layout*

## Workspace Indicator

```
1 2 3 4 5  (plain, gray, normal font)
↓          (active workspace: bold green)
1 **2** 3 4 5
```

### Design Details

- **Inactive:** Muted gray color (`#6c7086`), normal font weight
- **Active:** Bold green (`#a6e3a1`), no background or border
- **Spacing:** 0px from left edge, no decorative elements

## Module Layout

```
1 2 3 4 5  |  Weather  |  [VOL] [NET] [BAT]  |  Time [15px]
(0px left)                                     (15px right)
```

## Installation

```bash
# Checkout v2 branch
git checkout feat/waybar-v2

# Copy v2 configuration
cp -r waybar/.config/waybar ~/.config/

# Make scripts executable
chmod +x ~/.config/waybar/weather.sh

# Restart Waybar
pkill waybar && waybar &
```

## Configuration Files

- `config.jsonc` - Module configuration (same as v1)
- `style.css` - Minimalist styling for v2 design
- `weather.sh` - Weather data fetch script

## Weather Module

The weather module fetches real-time weather data from wttr.in and displays it in the Waybar.

### Features

- **Automatic Location Detection:** Uses your IP address to detect location (no configuration needed)
- **Weather Icons:** Shows emoji icons based on current conditions (☀️ ⛅ ☁️ 🌧️ ❄️ 🌨️ ⛈️)
- **Detailed Tooltip:** Hover to see city name, weather description, and humidity
- **Error Handling:** Gracefully handles offline state and API errors
- **Refresh Interval:** Updates every 5 minutes (configurable in `config.jsonc`)

### Dependencies

```bash
# Required packages
sudo pacman -S curl jq
```

### How It Works

The script (`weather.sh`) automatically detects your location based on your IP address by calling:
```
https://wttr.in/?format=j1
```

No city configuration is needed - it just works out of the box!

### Manual Location Override

If you want to force a specific city instead of auto-detection, edit `~/.config/waybar/weather.sh` line 21:

```bash
# Change this:
weather_data=$(curl --max-time 5 -s "https://wttr.in/?format=j1")

# To this (example for Brno):
weather_data=$(curl --max-time 5 -s "https://wttr.in/Brno?format=j1")
```

### Troubleshooting

**Weather shows "Offline":**
- Check internet connection
- Verify wttr.in is accessible: `curl wttr.in`

**Weather shows "Err: jq":**
- Install jq: `sudo pacman -S jq`

**Weather shows "API Error":**
- wttr.in might be temporarily unavailable
- Wait a few minutes for the next refresh cycle

## Customization

Key CSS selectors for v2:

```css
/* Workspace buttons */
#workspaces button {
  padding: 2px 8px;
  color: #6c7086;      /* Inactive color */
  background-color: transparent;
  font-weight: normal;
}

/* Active workspace */
#workspaces button.active {
  color: #a6e3a1;      /* Active green (Catppuccin Mocha) */
  font-weight: bold;   /* Only distinction */
}

/* Clock with right padding */
#clock {
  color: #a6e3a1;
  padding: 0;
  padding-right: 15px;
  font-weight: bold;
}
```

## Switching Back to v1

For the feature-rich design with visual effects:

```bash
# Checkout main branch
git checkout main

# Copy v1 configuration
cp -r waybar-v1/.config/waybar ~/.config/

# Restart Waybar
pkill waybar && waybar &
```

See `WAYBAR_VERSIONS.md` in main branch for detailed comparison.

## Design Philosophy

v2 prioritizes:
- **Simplicity:** Only essential information, no visual clutter
- **Efficiency:** Fast visual parsing - active workspace immediately obvious
- **Minimalism:** Zero decorative elements, maximum focus
- **Keyboard Workflow:** Works best with keyboard-driven usage

This design is ideal for users who:
- Prefer minimal UI and distraction-free environment
- Use keyboard shortcuts for workspace navigation
- Want maximum terminal/editor real estate
- Value clean aesthetics over visual polish
