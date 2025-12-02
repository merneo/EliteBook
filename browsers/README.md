# Browser Configuration Repository

**Purpose:** Comprehensive browser configuration management for Arch Linux desktop environment  
**Status:** 🚧 In Development

---

## Overview

This directory contains configuration files and documentation for web browsers commonly used in Arch Linux environments. The configurations are designed to work seamlessly with the Hyprland Wayland compositor and provide a consistent, optimized browsing experience.

---

## Supported Browsers

### Primary Targets

1. **Firefox** - Open-source, privacy-focused browser
   - Configuration: `firefox/`
   - Profile management, extensions, user.js preferences

2. **Chromium** - Open-source Chromium-based browser
   - Configuration: `chromium/`
   - Flags, preferences, extension management

3. **Brave** - Privacy-focused Chromium fork
   - Configuration: `brave/`
   - Privacy settings, shields configuration

### Secondary Targets (Optional)

4. **Google Chrome** - Proprietary Chromium-based browser
5. **Microsoft Edge** - Chromium-based browser
6. **LibreWolf** - Firefox fork with enhanced privacy

---

## Directory Structure

```
browsers/
├── README.md                    # This file
├── firefox/
│   ├── user.js                  # Firefox preferences (user.js)
│   ├── userChrome.css          # Firefox UI customization
│   ├── extensions/              # Recommended extensions list
│   └── profiles/                # Profile templates
├── chromium/
│   ├── flags.conf              # Chromium command-line flags
│   ├── preferences.json        # Chromium preferences
│   └── extensions/             # Extension management
├── brave/
│   ├── preferences.json        # Brave-specific settings
│   └── shields-config.json     # Privacy shields configuration
└── shared/
    ├── bookmarks/              # Shared bookmark exports
    └── themes/                 # Cross-browser theme files
```

---

## Configuration Philosophy

### Privacy-First Approach

- **Minimal telemetry**: Disable data collection where possible
- **Enhanced tracking protection**: Enable strict privacy settings
- **Local-first**: Prefer local storage over cloud sync (optional)

### Performance Optimization

- **Hardware acceleration**: Enable GPU rendering for Wayland
- **Memory management**: Optimize for resource-constrained systems
- **Network optimization**: Configure DNS and connection settings

### Integration with Desktop Environment

- **Wayland support**: Native Wayland rendering where available
- **Hyprland integration**: Window management and keybindings
- **System theme**: Match browser appearance with desktop theme

---

## Deployment

### Firefox

```bash
# Deploy Firefox configuration
cd ~/EliteBook/browsers
stow firefox

# Or manually:
cp firefox/user.js ~/.mozilla/firefox/*.default-release/
cp firefox/userChrome.css ~/.mozilla/firefox/*.default-release/chrome/
```

### Chromium

```bash
# Deploy Chromium configuration
stow chromium

# Or manually:
cp chromium/flags.conf ~/.config/chromium-flags.conf
cp chromium/preferences.json ~/.config/chromium/Default/Preferences
```

---

## Documentation

- **Firefox Configuration**: See `firefox/README.md`
- **Chromium Configuration**: See `chromium/README.md`
- **Privacy Settings**: See `PRIVACY_GUIDE.md`
- **Performance Tuning**: See `PERFORMANCE_TUNING.md`

---

## Status

🚧 **Work in Progress**

This configuration is currently under development. Contributions and suggestions are welcome.

---

**Last Updated:** 2025-12-02  
**Maintainer:** merneo
