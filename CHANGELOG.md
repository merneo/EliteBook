# Changelog - EliteBook Repository

**All notable changes to this repository will be documented in this file.**

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Planned
- Automated documentation validation
- Documentation versioning system
- Enhanced AI context with more examples

---

## [2.0.0] - 2025-12-02

### Added
- **Documentation Index** (`DOCUMENTATION_INDEX.md`): Complete index of all 54 documentation files
- **Changelog** (`CHANGELOG.md`): This file for tracking repository changes
- **AI Assistant Context Usage Documentation** (`docs/installation/AI_ASSISTANT_CONTEXT_USAGE.md`): Comprehensive academic documentation (386 lines)
- **Three Usage Modes Documentation**: Clear documentation of AI Knowledge Base, AI Instructions, and Manual Guide modes
- **Version Information**: Added version tracking to key documentation files

### Changed
- **Translation to US English**: All Czech text translated to US English (academic publication standard)
- **README.md**: Enhanced with better navigation and usage modes section
- **docs/installation/README.md**: Added Usage Modes section
- **docs/installation/HOW_TO_ASK_AI.md**: Complete translation from Czech to English, added Manual Usage section
- **docs/installation/AI_ASSISTANT_CONTEXT.md**: Added usage modes clarification, fixed Czech examples
- **docs/installation/README_COMPLETE.md**: Added Usage Modes section at beginning

### Improved
- **Documentation Structure**: Better organization and cross-referencing
- **AI Knowledge Base**: Enhanced context file with clearer instructions
- **Manual Guide**: Added explicit manual execution instructions
- **Navigation**: Improved file structure and navigation aids

### Security
- **Verified No Sensitive Data**: Confirmed no passwords, keys, or tokens in repository
- **Placeholder Usage**: All sensitive values use placeholders (`<YOUR_PASSWORD>`, etc.)

---

## [1.5.0] - 2025-11-XX

### Added
- **Browser Configuration**: Complete Catppuccin Mocha Green themes for Firefox and Brave
- **Desktop Entries**: Desktop entries for Albert launcher (Firefox, Brave)
- **Browser Documentation**: Comprehensive browser theme documentation

### Changed
- **Browser Themes**: Updated Firefox address bar styling to match Chrome theme
- **Desktop Entries**: Fixed terminology (window manager vs desktop environment)

---

## [1.4.0] - 2025-11-XX

### Added
- **AI Assistant Context System**: Complete knowledge base system for AI assistants
- **docs/installation/**: New directory for installation documentation
- **README_COMPLETE.md**: Combined installation guide (pre + post reboot)
- **AI_ASSISTANT_CONTEXT.md**: Primary knowledge base file
- **HOW_TO_ASK_AI.md**: User guide for AI interactions
- **extract-phase-prompt.sh**: Script to extract AI prompts

### Changed
- **Installation Documentation**: Reorganized into `docs/installation/` directory
- **Documentation Structure**: Better separation of installation vs configuration docs

---

## [1.3.0] - 2025-10-XX

### Added
- **Howdy Face Recognition**: Complete setup and configuration
- **SDDM Auto-Activation**: Automatic biometric activation at login
- **PAM Python Module**: Installation from GitHub with compilation fixes
- **NumPy Round Fix**: Fixed TypeError in Howdy enrollment

### Fixed
- **Howdy Camera**: IR camera configuration (`/dev/video2`)
- **Howdy IR Emitter**: IR emitter configuration
- **Howdy Add Command**: Automated face enrollment
- **PAM Integration**: Complete PAM configuration for Howdy

---

## [1.2.0] - 2025-09-XX

### Added
- **Fingerprint Authentication**: Complete setup for Validity Sensors 138a:0092
- **Device Files**: Python-Validity device/0092 branch support
- **PAM Configuration**: Fingerprint authentication for sudo and SDDM
- **Silent Configuration**: Removed fingerprint messages

### Fixed
- **Fingerprint Reader**: BIOS reset procedure
- **PAM Messages**: Clean authentication flow

---

## [1.1.0] - 2025-08-XX

### Added
- **Hyprland Configuration**: Complete window manager setup
- **Waybar**: Status bar configuration
- **Kitty**: Terminal emulator configuration
- **Neovim**: Text editor configuration with Lazy.nvim
- **Tmux**: Terminal multiplexer configuration
- **TLP**: Power management configuration
- **GRUB**: Bootloader configuration with automatic LUKS decryption
- **Plymouth**: Boot splash screen
- **SDDM**: Login manager with custom theme

---

## [1.0.0] - 2025-07-XX

### Added
- **Initial Repository**: Complete system configuration repository
- **Installation Guides**: INSTALL_PRE_REBOOT.md and INSTALL_POST_REBOOT.md
- **LUKS2 Encryption**: Full-disk encryption setup
- **Btrfs Filesystem**: Subvolumes and snapshots configuration
- **Base System**: Arch Linux installation procedures
- **Dual-Boot**: Windows 11 + Arch Linux setup

---

## Version History Summary

- **v2.0.0**: Documentation improvements, AI knowledge base system, US English translation
- **v1.5.0**: Browser configuration and themes
- **v1.4.0**: AI assistant context system
- **v1.3.0**: Howdy face recognition
- **v1.2.0**: Fingerprint authentication
- **v1.1.0**: Desktop environment components
- **v1.0.0**: Initial repository and installation guides

---

## Change Types

- **Added**: New features, documentation, or files
- **Changed**: Modifications to existing features or documentation
- **Deprecated**: Features that will be removed in future versions
- **Removed**: Removed features or files
- **Fixed**: Bug fixes
- **Security**: Security improvements or vulnerability fixes

---

**Repository:** https://github.com/merneo/EliteBook  
**Maintained By:** EliteBook Configuration Repository  
**Last Updated:** December 2, 2025
