#!/bin/bash

# =============================================================================
# SCREENSHOT MODE EXIT SCRIPT - Dynamic Time Restoration
# =============================================================================
# Author: merneo
# Purpose: Restores dynamic time displays and original system configurations
#          after screenshot mode has been used, returning desktop to normal
#          operational state with live timestamps.
#
# Operational Context:
#   This script is the counterpart to screenshot-mode.sh, restoring the desktop
#   to its normal state where time displays update in real-time. Essential for
#   returning to productive work after creating documentation screenshots.
#
# Execution Flow:
#   1. Restores configuration files from backup (if available)
#   2. Falls back to sed replacement if backups missing
#   3. Restarts affected services to apply restored configurations
#   4. Provides user feedback via desktop notification
#
# Restoration Strategy:
#   - Primary: Restore from .bak backup files (preserves exact original state)
#   - Fallback: sed replacement (reconstructs dynamic time format)
#   - Ensures script works even if backup files are missing
#
# Keybinding:
#   - Super+Shift+F: Exit screenshot mode
#   - Must be run after screenshot-mode.sh to restore normal operation
#
# Dependencies:
#   - Waybar (status bar)
#   - Tmux (terminal multiplexer)
#   - Kitty (terminal emulator)
#   - notify-send (desktop notifications)
# =============================================================================

# =============================================================================
# SHELL OPTIONS & SAFETY
# =============================================================================
# set -e: Exit immediately on command failure
# set -u: Treat unset variables as errors
# set -o pipefail: Pipeline commands fail if any command fails
# IFS: Internal Field Separator (newline and tab only)
# =============================================================================
set -euo pipefail
IFS=$'\n\t'

# =============================================================================
# CONFIGURATION FILE PATHS
# =============================================================================
# Purpose: Define paths to configuration files that need restoration
#
# Files:
#   - WAYBAR_CONFIG: Status bar configuration (clock format)
#   - TMUX_CONFIG: Terminal multiplexer configuration (status bar time)
#
# Path Strategy:
#   - Uses $HOME variable for portability across different user accounts
#   - Absolute paths ensure script works from any directory
# =============================================================================
WAYBAR_CONFIG="$HOME/.config/waybar/config.jsonc"
TMUX_CONFIG="$HOME/.tmux.conf"

# =============================================================================
# STEP 1: RESTORE WAYBAR CONFIGURATION
# =============================================================================
# Purpose: Restore dynamic clock format in Waybar status bar
#
# Restoration Method 1: Backup File (Preferred)
#   - Checks if backup file exists (${WAYBAR_CONFIG}.bak)
#   - Copies backup to original location (restores exact original state)
#   - Removes backup file (cleanup, prevents accumulation)
#
# Restoration Method 2: Fallback sed Replacement
#   - Used if backup file is missing (safety net)
#   - Replaces static "00:00 AM" with dynamic format "{:%I:%M %p}"
#   - Ensures script works even if backup was deleted
#
# Why Both Methods:
#   - Backup: Preserves exact original configuration (most reliable)
#   - Fallback: Ensures script always succeeds (robust error handling)
# =============================================================================
if [ -f "${WAYBAR_CONFIG}.bak" ]; then
    # Primary method: Restore from backup file
    cp "${WAYBAR_CONFIG}.bak" "$WAYBAR_CONFIG"
    rm "${WAYBAR_CONFIG}.bak"
else
    # Fallback: sed replacement if backup is missing
    # Pattern: Replaces static time with dynamic format string
    sed -i 's/"format": "00:00 AM"/"format": "{:%I:%M %p}"/' "$WAYBAR_CONFIG"
fi

# =============================================================================
# STEP 2: RESTORE TMUX CONFIGURATION
# =============================================================================
# Purpose: Restore dynamic time display in Tmux status bar
#
# Restoration Method 1: Backup File (Preferred)
#   - Checks if backup file exists (${TMUX_CONFIG}.bak)
#   - Copies backup to original location
#   - Removes backup file
#
# Restoration Method 2: Fallback sed Replacement
#   - Used if backup file is missing
#   - Replaces static "00:00 AM" with dynamic date command
#   - Preserves color formatting (#[fg=#a6e3a1])
#
# Tmux Status Bar Format:
#   - Original: '#[fg=#a6e3a1] #(date +"%I:%M %p") '
#   - Static: '#[fg=#a6e3a1] 00:00 AM '
#   - Restored: Dynamic date command executes on each status bar update
# =============================================================================
if [ -f "${TMUX_CONFIG}.bak" ]; then
    # Primary method: Restore from backup file
    cp "${TMUX_CONFIG}.bak" "$TMUX_CONFIG"
    rm "${TMUX_CONFIG}.bak"
else
    # Fallback: sed replacement
    # Pattern: Replaces static time with dynamic date command
    # Escape sequences: Preserves tmux color codes and command substitution
    sed -i "s/status-right '#[fg=#a6e3a1] 00:00 AM '/status-right '#[fg=#a6e3a1] #(date +\"%I:%M %p\") '/" "$TMUX_CONFIG"
fi

# =============================================================================
# STEP 3: RESTART SERVICES (Apply Restored Configurations)
# =============================================================================
# Purpose: Restart affected services to apply restored dynamic time displays
#
# Execution Order:
#   1. Waybar: Restart status bar (applies restored clock format)
#   2. Kitty: Reload terminal config (ensures consistency)
#   3. Tmux: Reload multiplexer config (applies restored status bar)
#
# Error Handling:
#   - All commands use || true to continue even if services not running
#   - Conditional checks prevent errors on missing processes
#   - Output redirection suppresses unnecessary messages
# =============================================================================

# Restart Waybar
# Process: Kill existing instance, brief delay, start new instance
# Error suppression: Continues if Waybar not running
pkill waybar || true
sleep 0.5
waybar > /dev/null 2>&1 &

# Reload Kitty (force config reload)
# SIGUSR1: User-defined signal triggers config reload
# More efficient than full restart (preserves terminal sessions)
killall -SIGUSR1 kitty 2>/dev/null || true

# Reload Tmux
# Conditional: Only reloads if Tmux is actually running
# source-file: Reloads configuration from file
# refresh-client: Forces client to redraw status bar with new time
if pgrep tmux > /dev/null; then
    tmux source-file "$TMUX_CONFIG" > /dev/null 2>&1
    tmux refresh-client > /dev/null 2>&1
fi

# =============================================================================
# COMPLETION NOTIFICATION
# =============================================================================
# Purpose: Inform user that screenshot mode has been exited and dynamic time restored
#
# Notification Content:
#   - Title: "✓ Screenshot Mode OFF" (clear state indication)
#   - Message: "Dynamic time and configs restored." (confirmation of restoration)
#
# User Feedback:
#   - Confirms successful restoration
#   - Provides visual confirmation that desktop is back to normal
#   - Helps users understand current system state
# =============================================================================
notify-send "✓ Screenshot Mode OFF" "Dynamic time and configs restored."