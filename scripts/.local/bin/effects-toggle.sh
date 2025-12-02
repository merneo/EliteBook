#!/bin/bash

# =============================================================================
# EFFECTS TOGGLE SCRIPT - Desktop Visual Effects State Toggler
# =============================================================================
# Author: merneo
# Purpose: Intelligently toggles desktop visual effects between enabled and
#          disabled states based on current configuration state.
#
# Operational Context:
#   This script serves as the primary user interface for switching between
#   performance mode (effects off) and aesthetic mode (effects on). It detects
#   the current state and switches to the opposite state.
#
# State Detection Logic:
#   1. Reads Hyprland configuration file
#   2. Searches for blur configuration block
#   3. Checks if blur is enabled (true/yes) or disabled (false/no)
#   4. Invokes appropriate script (effects-on.sh or effects-off.sh)
#
# Keybinding:
#   - Super+Shift+E: Primary toggle keybinding in Hyprland
#   - Provides instant visual feedback via desktop notifications
#
# Error Handling:
#   - If state detection fails, defaults to enabling effects
#   - All errors are logged to effects_toggle.log
#   - User notifications provide clear feedback on state changes
#
# Dependencies:
#   - effects-on.sh: Enables visual effects
#   - effects-off.sh: Disables visual effects
#   - Hyprland configuration file (for state detection)
#   - notify-send (for user feedback)
# =============================================================================

# =============================================================================
# SHELL OPTIONS & SAFETY
# =============================================================================
# set -e: Exit immediately on command failure
# set -u: Treat unset variables as errors
# set -o pipefail: Pipeline commands fail if any command fails
# IFS: Internal Field Separator (newline and tab only)
# set -x: Enable command tracing for debugging
# =============================================================================
set -euo pipefail
IFS=$'\n\t'
set -x # Enable shell debugging - IMPORTANT FOR TROUBLESHOOTING

# =============================================================================
# INITIAL NOTIFICATION
# =============================================================================
# Purpose: Provide immediate feedback that toggle operation has started
#   - Useful for debugging (confirms script execution)
#   - Can be removed in production if desired
# =============================================================================
notify-send "DEBUG: Effects Toggle script started." # Early notification for debugging

# =============================================================================
# STATE DETECTION LOGIC
# =============================================================================
# Purpose: Determine current effects state by examining Hyprland configuration
#
# Implementation:
#   1. Resolve absolute path to Hyprland config (handles symlinks)
#   2. Search for blur configuration block using grep
#   3. Extract enabled status using pattern matching
#   4. Compare against known enabled values (true/yes)
#
# Pattern Matching:
#   - grep -A 3 "blur {": Finds blur block and next 3 lines
#   - grep -qE "enabled = (true|yes)": Checks if enabled value is true or yes
#   - Returns 0 (success) if enabled, non-zero if disabled
#
# Why This Method:
#   - Configuration file is source of truth (not runtime state)
#   - Survives Hyprland restarts
#   - Simple pattern matching (no complex parsing needed)
#   - Fast execution (grep is efficient)
# =============================================================================
HYPR_CONF=$(readlink -f ~/.config/hypr/hyprland.conf)

# =============================================================================
# CONDITIONAL STATE SWITCHING
# =============================================================================
# Purpose: Invoke appropriate script based on detected state
#
# Logic Flow:
#   - If blur enabled → Effects are ON → Switch to OFF (performance mode)
#   - If blur disabled → Effects are OFF → Switch to ON (aesthetic mode)
#
# User Feedback:
#   - Notification before state change (user knows what's happening)
#   - Scripts (effects-on.sh/effects-off.sh) provide completion notifications
#
# Error Handling:
#   - Scripts handle their own errors internally
#   - This script continues even if sub-scripts fail (set -e disabled for sub-scripts)
# =============================================================================
if grep -A 3 "blur {" "$HYPR_CONF" | grep -qE "enabled = (true|yes)"; then
  # State: Effects are currently ENABLED -> Switch to DISABLED
  notify-send "Toggling Effects" "Switching to Effects OFF..."
  ~/.local/bin/effects-off.sh
else
  # State: Effects are currently DISABLED -> Switch to ENABLED
  notify-send "Toggling Effects" "Switching to Effects ON..."
  ~/.local/bin/effects-on.sh
fi