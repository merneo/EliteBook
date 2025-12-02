# Chromium Configuration

**Purpose:** Chromium browser configuration for Arch Linux with Wayland support  
**Target:** Chromium 120+ on Arch Linux with Hyprland

---

## Configuration Files

### `flags.conf`

Chromium command-line flags for:
- Wayland support
- Hardware acceleration
- Performance optimizations
- Privacy settings

**Usage:** Set `CHROMIUM_FLAGS` environment variable or use wrapper script

### `preferences.json`

Chromium user preferences (Default/Preferences file):
- Privacy settings
- Appearance configuration
- Extension management
- Security preferences

**Location:** `~/.config/chromium/Default/Preferences`

---

## Key Features

### Wayland Support

- Native Wayland rendering (`--enable-features=UseOzonePlatform --ozone-platform=wayland`)
- Hardware acceleration
- Screen sharing support

### Privacy

- Enhanced tracking protection
- Minimal telemetry
- Secure DNS (DoH)

### Performance

- GPU acceleration
- Process optimization
- Memory management

---

## Deployment

```bash
# Set Chromium flags
export CHROMIUM_FLAGS="--enable-features=UseOzonePlatform --ozone-platform=wayland"

# Or create wrapper script
cp chromium/flags.conf ~/.config/chromium-flags.conf
```

---

**Status:** 🚧 In Development
