# AI Assistant Context - HP EliteBook x360 1030 G2 Installation

**Purpose:** This file provides context and instructions for AI assistants (Cursor CLI, Claude, ChatGPT) when helping with Arch Linux installation and configuration on HP EliteBook x360 1030 G2.

**Primary Documentation:** `~/Documents/README_COMPLETE.md` contains complete installation guide with all phases documented.

---

## Hardware Information

**Device:** HP EliteBook x360 1030 G2  
**CPU:** Intel Core i5-7300U (7th Gen)  
**RAM:** 8 GB  
**Storage:** NVMe SSD 238.5 GB  
**Graphics:** Intel HD 620 (integrated)  
**Fingerprint Sensor:** Validity Sensors 138a:0092  
**IR Camera:** Chicony IR Camera (04f2:b58e) - for face recognition  
**HD Camera:** HP HD Camera (04f2:b58f) - 720p for video calls  
**WiFi:** Intel Wireless 8265  
**Bluetooth:** Intel 8087:0a2b  

---

## Installation Status

**System:** Arch Linux with Hyprland window manager  
**Encryption:** LUKS2 (AES-XTS-PLAIN64, 512-bit, Argon2id)  
**Filesystem:** Btrfs with 5 subvolumes (@, @home, @log, @cache, @snapshots)  
**Bootloader:** GRUB with automatic LUKS decryption  
**Desktop Environment:** Hyprland (Wayland compositor, not full desktop environment)  
**Status Bar:** Waybar  
**Terminal:** Kitty  
**Login Manager:** SDDM  
**Audio:** PipeWire  

**Repository:** https://github.com/merneo/EliteBook  
**Dotfiles Location:** `~/EliteBook`  

---

## Quick Reference: Common Tasks

### Fingerprint Authentication Setup

**Context:** This has been done before and is documented in Phase 15 of README_COMPLETE.md.

**Hardware:** Validity Sensors 138a:0092 (requires device/0092 branch of python-validity)

**When user says:** "I need to install/setup fingerprint on HP notebook"

**Your response should:**
1. Reference that this is documented in `~/Documents/README_COMPLETE.md` Phase 15
2. Know that this requires:
   - `python-validity-git` from AUR
   - Device/0092 branch support (not in master)
   - `fprintd` and `libfprint`
   - PAM configuration for sudo and SDDM
3. Follow the exact steps from Phase 15 in README_COMPLETE.md
4. Use the AI prompt from Phase 15 if needed

**Key commands:**
```bash
# Install python-validity with device/0092 branch
yay -S python-validity-git
# Clone device/0092 branch and copy files
# Enroll fingerprint
fprintd-enroll $USER
# Configure PAM
sudo nano /etc/pam.d/sudo  # Add: auth sufficient pam_fprintd.so
```

**Documentation:** `~/Documents/README_COMPLETE.md` - Phase 15

---

### Face Recognition (Howdy) Setup

**Context:** This has been done before and is documented in Phase 15c of README_COMPLETE.md.

**Hardware:** Chicony IR Camera (04f2:b58e) at `/dev/video2`

**When user says:** "I need to setup face recognition/Howdy on HP notebook"

**Your response should:**
1. Reference that this is documented in `~/Documents/README_COMPLETE.md` Phase 15c
2. Know that this requires:
   - `howdy-bin` from AUR
   - `python-dlib` (CPU-only build recommended)
   - IR camera at `/dev/video2`
   - PAM configuration with `pam_python.so`
3. Follow the exact steps from Phase 15c in README_COMPLETE.md
4. Use the AI prompt from Phase 15c if needed

**Key commands:**
```bash
# Install howdy
yay -S howdy-bin
# Configure camera device
sudo howdy config  # Set device_path = /dev/video2
# Enroll face
sudo howdy add
# Configure PAM
sudo nano /etc/pam.d/sudo  # Add: auth sufficient pam_python.so /lib/security/howdy/pam.py
```

**Documentation:** `~/Documents/README_COMPLETE.md` - Phase 15c

---

### Window Manager (Hyprland) Configuration

**Context:** This has been done before and is documented in Phase 13 and Phase 17 of README_COMPLETE.md.

**When user says:** "I need to configure Hyprland/window manager on HP notebook"

**Your response should:**
1. Reference that this is documented in `~/Documents/README_COMPLETE.md` Phase 13 (installation) and Phase 17 (dotfiles deployment)
2. Know that:
   - Hyprland is a window manager (compositor), not a full desktop environment
   - Configuration is in `~/.config/hypr/hyprland.conf`
   - Dotfiles are in `~/EliteBook/hypr/`
   - Uses standalone applications: Waybar (status bar), Albert (launcher), Kitty (terminal)
3. Follow the exact steps from Phase 13 or Phase 17 in README_COMPLETE.md
4. Use the AI prompt from the relevant phase if needed

**Documentation:** `~/Documents/README_COMPLETE.md` - Phase 13, Phase 17

---

### Browser Theme Configuration

**Context:** This has been done before and is documented in the repository.

**When user says:** "I need to setup browser themes/Firefox theme/Brave theme"

**Your response should:**
1. Reference that browser configurations are in `~/EliteBook/browsers/`
2. Know that:
   - Firefox theme: `browsers/firefox/catppuccin-mocha-green.css`
   - Brave theme: `browsers/brave/manifest.json` (Chrome extension)
   - Deployment guide: `browsers/THEME_DEPLOYMENT.md`
3. Follow the deployment guide in `browsers/THEME_DEPLOYMENT.md`
4. Firefox requires `toolkit.legacyUserProfileCustomizations.stylesheets = true` in about:config

**Documentation:** `~/EliteBook/browsers/THEME_DEPLOYMENT.md`

---

### Dotfiles Deployment

**Context:** This has been done before and is documented in Phase 17 of README_COMPLETE.md.

**When user says:** "I need to deploy dotfiles/configuration files"

**Your response should:**
1. Reference that this is documented in `~/Documents/README_COMPLETE.md` Phase 17
2. Know that:
   - Repository is at `~/EliteBook`
   - Can use GNU Stow: `stow hypr kitty waybar nvim tmux scripts browsers -t ~/`
   - Or manual copy
3. Follow the exact steps from Phase 17 in README_COMPLETE.md
4. Use the AI prompt from Phase 17 if needed

**Documentation:** `~/Documents/README_COMPLETE.md` - Phase 17

---

## Important Notes for AI Assistants

### Terminology
- **Window Manager vs Desktop Environment:** This system uses Hyprland, which is a **window manager** (compositor), NOT a full desktop environment. Applications like Dolphin (file manager) are standalone applications, not part of a desktop environment.

### Documentation Style
- All documentation uses **technical US English** (not "academic" terminology)
- Comments in code use "Technical Context" (not "Academic Context")

### Installation Phases
- **Pre-Reboot (Phase 1-14):** Done in chroot environment from live USB
- **Post-Reboot (Phase 14.5-18):** Done in installed system after first boot

### Common Issues Already Solved
1. **Fingerprint 138a:0092:** Requires device/0092 branch of python-validity (not in master)
2. **Howdy IR Camera:** Uses `/dev/video2` (not `/dev/video0`)
3. **Desktop Entries:** Needed for Albert launcher even with window manager (not desktop environment)
4. **Browser Themes:** Firefox requires `userChrome.css` enabled in about:config

---

## How to Use This Context

**When user asks about installation/configuration:**

1. **Check this file first** for quick reference
2. **Reference README_COMPLETE.md** for complete documentation
3. **Use AI prompts** from README_COMPLETE.md if needed
4. **Remember:** This has been done before - you have the documentation

**Example workflow:**
```
User: "I need to setup fingerprint on my HP notebook"
You: "I see this is documented in your README_COMPLETE.md Phase 15. 
      Since you have HP EliteBook x360 1030 G2 with Validity 138a:0092 sensor,
      I'll guide you through the steps. This requires the device/0092 branch
      of python-validity. Let me extract the relevant steps from your documentation..."
```

---

## File Locations

**Main Documentation:**
- `~/Documents/README_COMPLETE.md` - Complete installation guide with AI prompts

**Repository:**
- `~/EliteBook/` - Dotfiles and configuration repository
- `~/EliteBook/browsers/` - Browser theme configurations
- `~/EliteBook/scripts/` - Helper scripts

**This Context File:**
- `~/Documents/AI_ASSISTANT_CONTEXT.md` - This file (instructions for AI assistants)

---

## Quick Command Reference

```bash
# Extract AI prompt for a phase
~/Documents/extract-phase-prompt.sh <phase_number>

# Find phase in documentation
grep -n "## Phase" ~/Documents/README_COMPLETE.md

# Open documentation
nvim ~/Documents/README_COMPLETE.md

# Open this context file
nvim ~/Documents/AI_ASSISTANT_CONTEXT.md
```

---

**Last Updated:** 2025-12-02  
**Purpose:** Provide AI assistants with context about this system's configuration and documentation
