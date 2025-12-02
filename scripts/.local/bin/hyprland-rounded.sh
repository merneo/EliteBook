#!/bin/bash

# =============================================================================
# HYPRLAND ROUNDED MODE SCRIPT - Aesthetic Mode Activator
# =============================================================================
# Author: merneo
# Purpose: Switches desktop environment to aesthetic mode with rounded corners
#          (12px radius) and enabled animations for a modern, polished appearance.
#
# Operational Context:
#   This script is the counterpart to hyprland-corner.sh, providing aesthetic
#   mode for presentations, screenshots, and users who prefer modern visual
#   design. Trades some performance for visual appeal.
#
# Visual Characteristics:
#   - Corner radius: 12px (rounded, modern appearance)
#   - Animations: Enabled (smooth window transitions)
#   - GPU load: ~5-10% (moderate rendering overhead)
#   - Response time: Slight delay (animation duration)
#
# Components Modified:
#   1. Hyprland: Window manager (corner radius, animations)
#   2. Albert: Application launcher (rounded theme variant)
#   3. Mako: Notification daemon (rounded corners)
#
# Keybindings:
#   - Super+Shift+R: Primary activation keybinding
#   - Super+Ctrl+R: Alternative keybinding
#
# Performance Trade-offs:
#   - Increased GPU load: ~3-5% compared to corner mode
#   - Animation delays: ~100-200ms per window operation
#   - Higher memory usage: Animation state tracking
#   - Better for: Presentations, aesthetic preferences, photography
# =============================================================================

# =============================================================================
# SHELL OPTIONS & SAFETY
# =============================================================================
# set -e: Exit on error
# set -u: Treat unset variables as errors
# set -o pipefail: Pipeline commands fail if any command fails
# IFS: Internal Field Separator (newline and tab)
# =============================================================================
set -euo pipefail
IFS=$'\n\t'

# =============================================================================
# HYPRLAND INSTANCE DETECTION
# =============================================================================
# Purpose: Ensure hyprctl commands target the correct active Hyprland session
#
# Implementation:
#   - Each Hyprland session has unique instance signature (UUID)
#   - Stored in: /run/user/$(id -u)/hypr/
#   - Auto-detection finds most recent session
#   - Export ensures child processes inherit the signature
# =============================================================================
if [ -z "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
    export HYPRLAND_INSTANCE_SIGNATURE=$(ls -t /run/user/$(id -u)/hypr/ | head -1)
fi

# =============================================================================
# CONFIGURATION FILE PATHS
# =============================================================================
# Purpose: Define absolute paths to all configuration files that will be modified
#
# Files:
#   - HYPR_CONF: Hyprland window manager configuration
#   - ALBERT_CONFIG: Application launcher configuration
#   - MAKO_CONF: Notification daemon configuration
#
# Path Resolution:
#   - readlink -f: Resolves symlinks to absolute paths
#   - Ensures script works regardless of working directory
# =============================================================================
HYPR_CONF=$(readlink -f ~/.config/hypr/hyprland.conf)
ALBERT_CONFIG="$HOME/.config/albert/config"
MAKO_CONF="$HOME/.config/mako/config"

# =============================================================================
# STEP 1: APPLY HYPRLAND CHANGES (Runtime + Persistent)
# =============================================================================
# Purpose: Set window corner radius to 12px and enable animations
#
# Method 1: Runtime Changes (Immediate Application)
#   - hyprctl keyword: Applies changes immediately
#   - decoration:rounding 12: Sets corner radius to 12px (rounded corners)
#   - animations:enabled 1: Enables all window animations
#
# Method 2: Persistent Config Changes (Survives Restarts)
#   - sed -i: In-place file editing
#   - 's/rounding = .*/rounding = 12/': Replaces any rounding value with 12
#   - '/^animations {/,/^}/ s/enabled = .*/enabled = yes/': Enables animations block
#
# Corner Radius Rationale:
#   - 12px: Modern, polished appearance without excessive rounding
#   - Large enough to be noticeable, small enough to preserve window content
#   - Matches common design system standards (iOS, Material Design)
#
# Animation Benefits:
#   - Smooth window transitions (professional appearance)
#   - Visual continuity (reduces jarring state changes)
#   - Better for presentations and screenshots
# =============================================================================
# Immediate Runtime Changes:
# - Set rounding to 12px (Rounded)
hyprctl keyword decoration:rounding 12 > /dev/null
# - Enable animations for fluid window movement
hyprctl keyword animations:enabled 1 > /dev/null

# Persistent Config Changes (sed):
# - Update 'rounding' parameter in hyprland.conf
sed -i 's/rounding = .*/rounding = 12/' "$HYPR_CONF"
# - Enable 'animations' block in hyprland.conf
sed -i '/^animations {/,/^}/ s/enabled = .*/enabled = yes/' "$HYPR_CONF"

# =============================================================================
# STEP 2: APPLY ALBERT LAUNCHER CHANGES
# =============================================================================
# Purpose: Switch application launcher to rounded corner theme variant
#
# Implementation:
#   - Albert supports theme variants: "Catppuccin Mocha Rounded" (rounded)
#   - Updates all theme references in config file
#   - Pattern matching: Replaces any existing theme with rounded variant
#
# Theme Variants:
#   - "Catppuccin Mocha Rounded": Rounded corners, matches Hyprland rounded mode
#   - "Catppuccin Mocha": Sharp corners, matches Hyprland corner mode
# =============================================================================
if [ -f "$ALBERT_CONFIG" ]; then
    # Switch to the rounded variant of the Catppuccin theme
    sed -i 's/^theme=.*/theme=Catppuccin Mocha Rounded/' "$ALBERT_CONFIG"
    sed -i 's/^darkTheme=.*/darkTheme=Catppuccin Mocha Rounded/' "$ALBERT_CONFIG"
    sed -i 's/^lightTheme=.*/lightTheme=Catppuccin Mocha Rounded/' "$ALBERT_CONFIG"
fi

# =============================================================================
# STEP 3: APPLY MAKO NOTIFICATION CHANGES
# =============================================================================
# Purpose: Update notification daemon to use rounded corners (12px border radius)
#
# Implementation:
#   - Mako uses border-radius CSS property for corner rounding
#   - sed replaces any existing border-radius value with 12
#   - Process restart required to apply changes
#
# Process Management:
#   - pkill: Terminates existing Mako process
#   - sleep 0.5: Brief delay for process cleanup
#   - mako &: Starts new instance in background
# =============================================================================
if [ -f "$MAKO_CONF" ]; then
    # Update border radius for notifications
    sed -i 's/border-radius=.*/border-radius=12/' "$MAKO_CONF"
    # Reload mako to apply changes immediately
    pkill -u "$(id -u)" mako
    sleep 0.5
    mako &
fi

# =============================================================================
# STEP 4: RESTART ALBERT LAUNCHER
# =============================================================================
# Purpose: Apply theme changes by restarting the launcher process
#
# Implementation:
#   - Albert reads theme from config file on startup only
#   - Config file changes require process restart
#   - pkill -f "albert": Matches full command line
#   - sleep 0.5: Allows process cleanup
#   - albert &: Starts new instance in background
# =============================================================================
# Restarting is required for Albert to pick up the theme change from the config file.
pkill -f "albert" 2>/dev/null || true
sleep 0.5
albert &

# =============================================================================
# COMPLETION NOTIFICATION
# =============================================================================
# Purpose: Inform user that rounded mode has been successfully activated
#
# Notification Content:
#   - Title: "Mode: Rounded" (clear mode identification)
#   - Message: "Rounded corners enabled (12px) | Animations ON" (state summary)
# =============================================================================
notify-send "Mode: Rounded" "Rounded corners enabled (12px) | Animations ON"
