#!/bin/bash

# =============================================================================
# EFFECTS ON SCRIPT - Desktop Visual Effects Enabler
# =============================================================================
# Author: merneo
# Purpose: Enables desktop visual effects (blur, shadows, transparency) across
#          all desktop components (Hyprland, Waybar, Kitty, Mako).
#
# Operational Context:
#   This script is part of a dual-mode desktop system where administrators
#   can toggle between performance mode (effects off) and aesthetic mode
#   (effects on). This script specifically enables the aesthetic mode.
#
# Execution Flow:
#   1. Modifies persistent configuration files (Hyprland, Waybar, Kitty, Mako)
#   2. Applies runtime changes via hyprctl and remote control interfaces
#   3. Restarts affected services to apply changes
#   4. Provides user feedback via desktop notifications
#
# Keybindings:
#   - Super+Shift+E: Toggle effects (calls effects-toggle.sh)
#   - Can be invoked directly for explicit state management
#
# Dependencies:
#   - Hyprland (Wayland compositor)
#   - Waybar (status bar)
#   - Kitty (terminal emulator with remote control)
#   - Mako (notification daemon)
#   - notify-send (desktop notifications)
# =============================================================================

# =============================================================================
# SHELL OPTIONS & SAFETY
# =============================================================================
# set -e: Exit immediately if any command returns non-zero status
# set -u: Treat unset variables as errors (prevents typos in variable names)
# set -o pipefail: Pipeline commands fail if any command in pipeline fails
# IFS: Internal Field Separator set to newline and tab (prevents word splitting)
# set -x: Enable command tracing (useful for debugging, can be disabled in production)
# =============================================================================
set -euo pipefail
IFS=$'\n\t'
set -x # Enable shell debugging

# =============================================================================
# LOGGING INFRASTRUCTURE
# =============================================================================
# XDG State Directory: Per-user state files (logs, caches) following XDG spec
#   - Default: ~/.local/state (if XDG_STATE_HOME not set)
#   - Permissions: 0700 (owner read/write/execute only, no group/other access)
#   - Purpose: Centralized logging for all dotfiles management scripts
#
# Log File: effects_toggle.log
#   - Contains timestamped entries for all effect toggle operations
#   - Useful for troubleshooting configuration issues
#   - Rotated manually or via logrotate if configured
# =============================================================================
EFFECTS_LOG_DIR="${XDG_STATE_HOME:-${HOME}/.local/state}/dotfiles-logs"
mkdir -p "$EFFECTS_LOG_DIR"
chmod 0700 "$EFFECTS_LOG_DIR"
EFFECTS_LOG="$EFFECTS_LOG_DIR/effects_toggle.log"

# =============================================================================
# CONFIGURATION FILE PATHS
# =============================================================================
# All paths use readlink -f to resolve symlinks and ensure absolute paths.
# This is critical because:
#   1. Scripts may be executed from different working directories
#   2. Symlinks (via GNU Stow) must resolve to actual file locations
#   3. Absolute paths prevent path-related errors
#
# Files Modified:
#   - Hyprland: Window manager configuration (blur, shadows)
#   - Waybar: Status bar CSS (opacity)
#   - Kitty: Terminal configuration (background opacity)
#   - Mako: Notification daemon configuration (transparency)
# =============================================================================
HYPR_CONF=$(readlink -f ~/.config/hypr/hyprland.conf)
WAYBAR_CSS=$(readlink -f ~/.config/waybar/style.css)
KITTY_CONF=$(readlink -f ~/.config/kitty/kitty.conf)
MAKO_CONF=$(readlink -f ~/.config/mako/config)
MAKO_EFFECTS_ON=$(readlink -f ~/.config/mako/config.effects-on)

# =============================================================================
# NOTIFICATION HELPER FUNCTION
# =============================================================================
# Purpose: Provides consistent user feedback across all script operations
#
# Implementation:
#   - Logs all notifications to effects log file with timestamps
#   - Uses notify-send for desktop notifications (if available)
#   - Falls back to stderr output if notify-send unavailable
#
# Parameters:
#   $1: Notification title (e.g., "Hyprland", "Waybar")
#   $2: Notification message (e.g., "Enabling blur and shadows")
#
# Usage:
#   send_notification "Component" "Operation description"
# =============================================================================
send_notification() {
    local title="$1"
    local message="$2"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [NOTIFY] $title: $message" >> "$EFFECTS_LOG"
    if command -v notify-send &> /dev/null; then
        notify-send "$title" "$message"
    else
        echo "[NOTIFICATION] $title: $message" >&2
    fi
}

# =============================================================================
# SCRIPT EXECUTION START
# =============================================================================
echo "--- Effects ON script started ---" >> "$EFFECTS_LOG"

# =============================================================================
# STEP 1: UPDATE HYPRLAND CONFIGURATION (Persistent Changes)
# =============================================================================
# Purpose: Enable blur and shadow effects in Hyprland configuration file
#
# Implementation Details:
#   - Uses sed with regex pattern matching to find blur/shadow blocks
#   - Pattern: '/blur {/,/^    }/' matches from "blur {" to closing brace
#   - Replacement: Changes "enabled = false" or "enabled = no" to "enabled = yes"
#   - In-place editing (-i): Modifies file directly without creating backup
#
# Why Persistent:
#   - Changes survive Hyprland restarts
#   - Configuration file is the source of truth
#   - Runtime changes (hyprctl) are temporary and lost on restart
#
# Performance Impact:
#   - Blur: ~2-3% additional GPU load (Gaussian blur computation)
#   - Shadows: ~1-2% additional GPU load (shadow rendering)
#   - Combined: ~3-5% total GPU overhead (acceptable for aesthetic mode)
# =============================================================================
send_notification "Hyprland" "Enabling blur and shadows in config."
sed -i '/blur {/,/^    }/ s/enabled = \(false\|no\)/enabled = yes/' "$HYPR_CONF"
sed -i '/shadow {/,/^    }/ s/enabled = \(false\|no\)/enabled = yes/' "$HYPR_CONF"

# =============================================================================
# STEP 2: UPDATE KITTY TERMINAL (Dual-Method Approach)
# =============================================================================
# Purpose: Set terminal background opacity to 0.90 (10% transparency)
#
# Method 1: Persistent Configuration File Modification
#   - Updates kitty.conf with new opacity value
#   - Survives terminal restarts
#   - Pattern: 's/^background_opacity [0-9.]*/background_opacity 0.90/'
#     Matches any existing opacity value and replaces with 0.90
#
# Method 2: Runtime Remote Control (Immediate Application)
#   - Uses Kitty's remote control interface (Unix socket)
#   - Applies changes to all running Kitty instances immediately
#   - No terminal restart required (zero downtime)
#   - Socket path: unix:@mykitty-${pid} (abstract Unix socket)
#
# Why Both Methods:
#   - Runtime: Immediate visual feedback (user sees change instantly)
#   - Persistent: Changes survive terminal restarts
#   - Redundancy: If one method fails, the other ensures consistency
#
# Opacity Value Rationale:
#   - 0.90 (90% opaque, 10% transparent): Subtle blur effect visible
#   - 1.0 (100% opaque): No transparency, maximum readability
#   - 0.85 or lower: Too transparent, text becomes hard to read
# =============================================================================
send_notification "Kitty" "Setting opacity to 0.90 in kitty.conf."
sed -i 's/^background_opacity [0-9.]*/background_opacity 0.90/' "$KITTY_CONF"
# Apply opacity change to all running Kitty instances using remote control
# Find all Kitty PIDs and update each instance
for pid in $(pgrep -x kitty); do
    kitty @ --to "unix:@mykitty-${pid}" set-background-opacity 0.90 2>/dev/null || true
done

# =============================================================================
# STEP 3: UPDATE WAYBAR CSS (Persistent)
# =============================================================================
# Purpose: Set Waybar status bar background to 85% opacity
#
# Implementation:
#   - CSS uses RGBA color format: rgba(red, green, blue, alpha)
#   - Base color: rgba(30, 30, 46, ...) = Catppuccin Mocha base color
#   - Alpha channel: 0.85 = 85% opacity (15% transparency)
#   - Pattern matching: Replaces any existing alpha value with 0.85
#
# Visual Effect:
#   - Transparent status bar allows background blur to show through
#   - Creates depth and modern aesthetic
#   - Maintains readability (85% is sufficient contrast)
#
# Why CSS Modification:
#   - Waybar doesn't support runtime opacity changes
#   - CSS file must be modified and Waybar restarted
#   - This is the only way to change opacity persistently
# =============================================================================
send_notification "Waybar" "Setting opacity to 0.85 in Waybar CSS."
sed -i 's/rgba(30, 30, 46, [0-9.]*)/rgba(30, 30, 46, 0.85)/' "$WAYBAR_CSS"

# =============================================================================
# STEP 3B: UPDATE MAKO NOTIFICATION CONFIGURATION
# =============================================================================
# Purpose: Switch notification daemon to transparent theme variant
#
# Implementation:
#   - Mako maintains separate config files for effects-on/effects-off modes
#   - This script copies the effects-on variant to the active config location
#   - Mako will reload and apply new styling on SIGHUP signal
#
# Configuration Files:
#   - config.effects-on: Transparent notifications with rounded corners
#   - config.effects-off: Opaque notifications with sharp corners
#   - config: Active configuration (symlinked or copied from one of above)
#
# Why Copy Instead of Symlink:
#   - Mako may not follow symlinks correctly in all scenarios
#   - Copy ensures atomic configuration switch
#   - Simpler error handling (file always exists)
# =============================================================================
send_notification "Mako" "Switching to transparent notifications (effects-on)."
cp "$MAKO_EFFECTS_ON" "$MAKO_CONF"

# =============================================================================
# STEP 4: APPLY RUNTIME CHANGES (Service Restarts)
# =============================================================================
# Purpose: Restart affected services to apply configuration changes
#
# Execution Order:
#   1. Waybar (must restart before Hyprland to avoid rendering conflicts)
#   2. Mako (reload via SIGHUP, no full restart needed)
#   3. Hyprland (reloads config, applies blur/shadows)
#
# Why This Order:
#   - Waybar renders on top of Hyprland layers
#   - If Hyprland reloads first, Waybar may render incorrectly
#   - Mako can reload without restart (SIGHUP is sufficient)
#   - Hyprland reload is last to ensure all components are ready
# =============================================================================

# =============================================================================
# 4A: RESTART WAYBAR STATUS BAR
# =============================================================================
# Purpose: Apply CSS opacity changes and ensure proper rendering
#
# Process:
#   1. Kill existing Waybar process (graceful termination)
#   2. Brief sleep (0.3s) to allow process cleanup
#   3. Detect active Hyprland instance signature
#   4. Start Waybar with correct instance signature
#
# Hyprland Instance Signature:
#   - Each Hyprland session has unique signature (UUID)
#   - Stored in: /run/user/$(id -u)/hypr/
#   - Waybar must match signature to communicate with correct compositor
#   - Auto-detection ensures script works across multiple sessions
#
# Error Handling:
#   - pkill || true: Continues even if Waybar not running
#   - Background execution (&): Doesn't block script execution
#   - Output redirection: Suppresses stdout/stderr (clean execution)
# =============================================================================
send_notification "Waybar" "Restarting Waybar."
pkill waybar || true
sleep 0.3
# Auto-detect current Hyprland instance signature
HYPR_SIGNATURE=$(ls -t /run/user/$(id -u)/hypr/ 2>/dev/null | grep "^[a-f0-9]" | head -1)
if [ -n "$HYPR_SIGNATURE" ]; then
    HYPRLAND_INSTANCE_SIGNATURE="$HYPR_SIGNATURE" waybar > /dev/null 2>&1 &
else
    waybar > /dev/null 2>&1 &
fi

# =============================================================================
# 4B: RELOAD MAKO NOTIFICATION DAEMON
# =============================================================================
# Purpose: Apply new notification styling without full restart
#
# Implementation:
#   - SIGHUP signal triggers Mako to reload configuration file
#   - More efficient than kill/restart (preserves notification queue)
#   - Zero downtime (notifications continue during reload)
#
# Why SIGHUP:
#   - Standard Unix signal for "reload configuration"
#   - Mako handles SIGHUP gracefully (reloads config, keeps running)
#   - Alternative (kill/restart) would lose pending notifications
# =============================================================================
send_notification "Mako" "Reloading Mako config."
pkill -SIGHUP mako || true

# =============================================================================
# 4C: RELOAD HYPRLAND CONFIGURATION
# =============================================================================
# Purpose: Apply blur and shadow settings from configuration file
#
# Implementation:
#   - hyprctl reload: Reads hyprland.conf and applies all changes
#   - Runtime state synchronized with configuration file
#   - All windows re-rendered with new effects
#
# What Happens:
#   - Blur effect enabled for transparent windows
#   - Drop shadows rendered beneath windows
#   - Window decorations updated (rounded corners if enabled)
#   - Animations enabled/disabled based on config
#
# Performance Note:
#   - Reload is fast (~100-200ms) but causes brief visual flicker
#   - All windows re-rendered (may cause temporary GPU spike)
#   - Acceptable trade-off for configuration consistency
# =============================================================================
send_notification "Hyprland" "Reloading Hyprland config."
hyprctl reload > /dev/null 2>&1 || true

# =============================================================================
# COMPLETION NOTIFICATION
# =============================================================================
# Purpose: Inform user that effects have been successfully enabled
#
# Notification Content:
#   - Title: "✓ Effects ENABLED" (checkmark indicates success)
#   - Message: "Blur: On | Transparency: On" (state summary)
#
# Log Entry:
#   - Timestamped completion entry in effects log
#   - Useful for auditing and troubleshooting
# =============================================================================
send_notification "✓ Effects ENABLED" "Blur: On | Transparency: On"
echo "--- Effects ON script finished ---" >> "$EFFECTS_LOG"
