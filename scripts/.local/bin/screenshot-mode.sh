#!/bin/bash

# =============================================================================
# SCREENSHOT MODE SCRIPT - Desktop Preparation for Clean Screenshots
# =============================================================================
# Author: merneo
# Purpose: Prepares the desktop environment for aesthetic screenshots by
#          replacing dynamic elements (time, dates) with static, consistent values.
#
# Operational Context:
#   This script is designed for server administrators who need to create
#   documentation screenshots, presentation materials, or promotional content
#   where consistent timestamps are important for professional appearance.
#
# Execution Flow:
#   1. Creates backup copies of configuration files (safety)
#   2. Replaces dynamic time displays with static "00:00 AM"
#   3. Restarts affected services to apply changes
#   4. Provides user feedback on completion
#
# Components Modified:
#   - Waybar: Status bar clock (replaced with static time)
#   - Tmux: Status bar time (replaced with static time)
#   - Kitty: Terminal (reloaded to ensure consistency)
#
# Keybinding:
#   - Super+Shift+S: Enter screenshot mode
#   - Must be followed by Super+Shift+F to exit screenshot mode
#
# Use Cases:
#   - Documentation screenshots (consistent appearance)
#   - Presentation materials (professional look)
#   - Repository README images (static timestamps)
#   - Tutorial screenshots (no time-based distractions)
#
# Dependencies:
#   - Waybar (status bar)
#   - Tmux (terminal multiplexer)
#   - Kitty (terminal emulator)
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
# CONFIGURATION BACKUP
# =============================================================================
# Purpose: Preserve original configuration states before modification
#
# Implementation:
#   - Creates .bak backup files for all modified configurations
#   - Backup files are used by screenshot-mode-exit.sh to restore original state
#   - Error suppression (2>/dev/null): Continues if backup already exists
#
# Why Backup:
#   - Allows restoration of original dynamic time displays
#   - Prevents permanent loss of configuration
#   - Enables idempotent operation (safe to run multiple times)
#
# Backup Files:
#   - ~/.config/waybar/config.jsonc.bak: Waybar configuration backup
#   - ~/.tmux.conf.bak: Tmux configuration backup
# =============================================================================
# Prevents data loss by saving the original configuration states.
cp ~/.config/waybar/config.jsonc ~/.config/waybar/config.jsonc.bak 2>/dev/null
cp ~/.tmux.conf ~/.tmux.conf.bak 2>/dev/null

# =============================================================================
# STATIC TIME OVERRIDE (Configuration Modification)
# =============================================================================
# Purpose: Replace dynamic time displays with static "00:00 AM" value
#
# Implementation Strategy:
#   - Uses sed for in-place file editing (no temporary files)
#   - Pattern matching: Finds time format strings and replaces with static value
#   - Multiple components updated: Waybar clock, Tmux status bar
#
# Why Static Time:
#   - Screenshots taken at different times look identical
#   - Professional appearance (no distracting timestamps)
#   - Consistent documentation (all screenshots match)
#   - Easier to create tutorial materials
#
# Static Value Rationale:
#   - "00:00 AM": Midnight (neutral, doesn't imply any specific time of day)
#   - Easy to recognize as placeholder (not real time)
#   - Short format (doesn't break UI layout)
# =============================================================================
# Uses sed to modify the config files in-place.
# Goal: Ensure screenshots look consistent regardless of when they are taken.

# Waybar: Replace clock format
# Pattern: Matches JSON format string "{:%I:%M %p}" and replaces with static "00:00 AM"
sed -i 's/"format": "{:%I:%M %p}"/"format": "00:00 AM"/' ~/.config/waybar/config.jsonc

# Tmux: Replace status bar time
# Pattern: Matches tmux status-right format with date command and replaces with static time
# Escape sequences: #[fg=#a6e3a1] preserves color formatting
sed -i "s/status-right '#\[fg=#a6e3a1\] #(date.*/status-right '#[fg=#a6e3a1] 00:00 AM '/" ~/.tmux.conf

# =============================================================================
# SERVICE RESTART (Apply Changes)
# =============================================================================
# Purpose: Restart affected services to render static time changes
#
# Execution Order:
#   1. Waybar: Restart status bar (applies new clock format)
#   2. Kitty: Reload terminal config (ensures consistency)
#   3. Tmux: Reload multiplexer config (applies status bar change)
#
# Why Restart:
#   - Services read configuration files on startup
#   - Runtime changes don't affect already-loaded configs
#   - Restart ensures all components display static time
# =============================================================================
# Reloads the affected applications to render the static changes.

# Waybar: Full restart required (no reload mechanism)
# Process: Kill existing instance, brief delay, start new instance
pkill waybar
sleep 0.5
waybar &

# Kitty (Terminal): Config reload via signal
# SIGUSR1: User-defined signal that triggers Kitty config reload
# More efficient than restart (preserves terminal sessions)
# Error suppression: Continues if no Kitty instances running
killall -SIGUSR1 kitty 2>/dev/null

# Tmux: Source config and refresh client
# source-file: Reloads configuration from file
# refresh-client: Forces client to redraw status bar
# Error suppression: Continues if Tmux not running
tmux source-file ~/.tmux.conf 2>/dev/null
tmux refresh-client 2>/dev/null

# =============================================================================
# COMPLETION FEEDBACK
# =============================================================================
# Purpose: Inform user that screenshot mode is active
#
# Output:
#   - Console message: Confirms mode activation
#   - Static time: "00:00 AM" now displayed in all components
#
# Next Steps:
#   - User can now take screenshots with consistent timestamps
#   - Run screenshot-mode-exit.sh to restore dynamic time
# =============================================================================
echo "✓ Screenshot mode activated - time set to 00:00 AM"