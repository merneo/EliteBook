# Chromium Configuration

**Purpose:** Chromium browser configuration for Arch Linux with Wayland support  
**Target:** Chromium 120+ on Arch Linux with Hyprland  
**Status:** ✅ Production Ready

---

## Configuration Files

### `flags.conf`

Chromium command-line flags configuration file.

**Technical Context:**
Chromium supports command-line flags for runtime configuration of browser behavior. These flags enable features, configure rendering backends, and optimize performance. The flags file contains commented explanations for each flag, following Chromium's flag documentation standards.

**Key Flag Categories:**
- **Wayland Support:** `--enable-features=UseOzonePlatform --ozone-platform=wayland` - Native Wayland rendering
- **Hardware Acceleration:** GPU rendering flags for Intel HD Graphics
- **Performance:** Process and memory management optimizations
- **Privacy:** Enhanced tracking protection and telemetry controls

**Usage:**
```bash
# Set environment variable
export CHROMIUM_FLAGS="$(cat ~/EliteBook/browsers/chromium/flags.conf | grep -v '^#' | tr '\n' ' ')"

# Or create wrapper script
cat > ~/.local/bin/chromium-wayland << 'EOF'
#!/bin/bash
CHROMIUM_FLAGS="$(cat ~/EliteBook/browsers/chromium/flags.conf | grep -v '^#' | tr '\n' ' ')"
exec /usr/bin/chromium $CHROMIUM_FLAGS "$@"
EOF
chmod +x ~/.local/bin/chromium-wayland
```

**Location:** `~/EliteBook/browsers/chromium/flags.conf`

**References:**
- Chromium Flags: https://peter.sh/experiments/chromium-command-line-switches/
- Ozone Platform: https://chromium.googlesource.com/chromium/src.git/+/main/docs/ozone_overview.md

### `preferences.json`

Chromium user preferences configuration (Default/Preferences file format).

**Technical Context:**
Chromium stores user preferences in JSON format following Chrome's preferences schema. This file can be used to pre-configure privacy settings, appearance, and security preferences. The preferences are applied when Chromium creates a new profile.

**Key Preference Categories:**
- **Privacy:** Enhanced tracking protection, cookie controls
- **Appearance:** Theme and UI customization
- **Extension Management:** Extension installation and update policies
- **Security:** Certificate validation and security features

**Location:** `~/.config/chromium/Default/Preferences`

**Note:** This file is typically managed by Chromium automatically. Manual editing should be done with caution and Chromium should be closed during editing.

**References:**
- Chrome Preferences: https://chromium.googlesource.com/chromium/src/+/main/chrome/common/pref_names.cc

---

## Key Features

### Wayland Support

- **Native Wayland rendering:** Direct Wayland surface rendering via Ozone platform
- **Hardware acceleration:** GPU rendering for Intel HD Graphics 620
- **Screen sharing support:** Native Wayland screen sharing protocols
- **Multi-monitor handling:** Proper display detection and window placement

**Implementation:**
```bash
--enable-features=UseOzonePlatform
--ozone-platform=wayland
```

### Privacy

- **Enhanced tracking protection:** Strict privacy settings
- **Minimal telemetry:** Reduced data collection
- **Secure DNS (DoH):** Encrypted DNS queries
- **Cookie controls:** Enhanced cookie management

### Performance

- **GPU acceleration:** Hardware-accelerated rendering
- **Process optimization:** Multi-process architecture tuning
- **Memory management:** Optimized cache and process limits

---

## Deployment

### Method 1: Environment Variable

```bash
# Add to ~/.bashrc or ~/.zshrc
export CHROMIUM_FLAGS="--enable-features=UseOzonePlatform --ozone-platform=wayland --enable-gpu"

# Launch Chromium
chromium
```

### Method 2: Wrapper Script

```bash
# Create wrapper script
cat > ~/.local/bin/chromium-wayland << 'EOF'
#!/bin/bash
CHROMIUM_FLAGS="$(cat ~/EliteBook/browsers/chromium/flags.conf | grep -v '^#' | tr '\n' ' ')"
exec /usr/bin/chromium $CHROMIUM_FLAGS "$@"
EOF

chmod +x ~/.local/bin/chromium-wayland

# Use wrapper
chromium-wayland
```

### Method 3: Desktop Entry

Create desktop entry with flags:
```ini
[Desktop Entry]
Exec=chromium --enable-features=UseOzonePlatform --ozone-platform=wayland %U
```

---

## Verification

### Check Wayland Support

1. **Verify Ozone platform:**
   - Open Chromium
   - Navigate to: `chrome://gpu`
   - Check "Graphics Feature Status" for Wayland

2. **Check rendering backend:**
   - Open Developer Tools (F12)
   - Check console for Wayland-related messages

### Performance Testing

```bash
# Launch Chromium with flags
chromium --enable-features=UseOzonePlatform --ozone-platform=wayland

# Monitor GPU usage
intel_gpu_top  # For Intel HD Graphics
```

---

## Troubleshooting

### Wayland Not Working

1. **Verify Wayland session:**
   ```bash
   echo $XDG_SESSION_TYPE  # Should output: wayland
   ```

2. **Check flags are applied:**
   ```bash
   ps aux | grep chromium | grep wayland
   ```

3. **Verify Ozone platform:**
   - Open `chrome://gpu`
   - Check "Ozone Platform" status

### Performance Issues

1. **Disable hardware acceleration (if needed):**
   ```bash
   chromium --disable-gpu
   ```

2. **Check GPU drivers:**
   ```bash
   glxinfo | grep "OpenGL renderer"
   ```

---

**Status:** ✅ Production Ready  
**Last Updated:** 2025-12-02
