#!/bin/bash

# =============================================================================
# WALLPAPER CHANGE SCRIPT - Manual Wallpaper Rotation Trigger
# =============================================================================
# Author: merneo
# Purpose: Manually triggers immediate wallpaper change on all connected monitors,
#          selecting random wallpapers from the configured directory and applying
#          them with smooth fade transitions.
#
# Operational Context:
#   This script provides on-demand wallpaper rotation for server administrators
#   who want to change desktop appearance without waiting for automatic rotation
#   interval. Useful for presentations, demos, or personal preference changes.
#
# Execution Flow:
#   1. Validates dependencies (swww, jq)
#   2. Checks wallpaper directory existence
#   3. Detects active monitors via Hyprland
#   4. Finds all available wallpaper images
#   5. Randomly selects and applies wallpapers to each monitor
#   6. Provides user feedback on completion
#
# Keybinding:
#   - Super+Shift+W: Manual wallpaper change trigger
#   - Provides instant wallpaper rotation without waiting for automatic interval
#
# Relationship to wallpaper-rotate.sh:
#   - wallpaper-rotate.sh: Automatic daemon (runs every 3 minutes)
#   - wallpaper-change.sh: Manual trigger (on-demand rotation)
#   - Both scripts use same wallpaper directory and application logic
#
# Dependencies:
#   - swww: Wayland wallpaper daemon and client
#   - jq: JSON parser for monitor detection
#   - Hyprland: Wayland compositor (for monitor information)
#   - notify-send: Desktop notifications
# =============================================================================

# =============================================================================
# SHELL OPTIONS & SAFETY
# =============================================================================
# set -e: Exit immediately on command failure
# set -u: Treat unset variables as errors
# set -o pipefail: Pipeline commands fail if any command fails
# IFS: Internal Field Separator (newline and tab only)
# =============================================================================
# Exit on error
set -euo pipefail
IFS=$'\n\t'

# =============================================================================
# CONFIGURATION
# =============================================================================
# Purpose: Define wallpaper source directory
#
# Directory Structure:
#   - $HOME/Pictures/Wallpapers/walls/: Primary wallpaper storage location
#   - Supports recursive subdirectories (find command searches recursively)
#   - Accepts: .jpg, .jpeg, .png, .gif image formats
#
# Why This Location:
#   - Standard XDG user directory (Pictures)
#   - Organized structure (Wallpapers/walls subdirectory)
#   - Easy to manage (users can add/remove wallpapers)
#   - Follows Linux filesystem hierarchy conventions
# =============================================================================
WALLPAPER_DIR="$HOME/Pictures/Wallpapers/walls"

# =============================================================================
# DEPENDENCY VALIDATION
# =============================================================================
# Purpose: Ensure required external commands are available before execution
#
# Dependencies Checked:
#   - swww: Wayland wallpaper daemon (required for wallpaper application)
#   - jq: JSON parser (required for monitor detection from Hyprland JSON output)
#
# Error Handling:
#   - Exits with status code 1 if dependencies missing
#   - Provides user-friendly error messages via desktop notifications
#   - Prevents script execution with incomplete environment
#
# Why Check Dependencies:
#   - Prevents cryptic errors later in script execution
#   - Provides clear feedback on what's missing
#   - Helps users understand installation requirements
# =============================================================================
if ! command -v swww &> /dev/null; then
    notify-send "Error" "swww is not installed."
    exit 1
fi

if ! command -v jq &> /dev/null; then
    notify-send "Error" "jq is not installed."
    exit 1
fi

# =============================================================================
# DIRECTORY VALIDATION
# =============================================================================
# Purpose: Verify wallpaper directory exists and is accessible
#
# Validation:
#   - Checks if directory exists (-d test)
#   - Provides error notification if directory missing
#   - Exits with status code 1 if validation fails
#
# Why Validate:
#   - Prevents script failure when trying to find wallpapers
#   - Provides clear error message (directory path shown)
#   - Helps users understand configuration requirements
# =============================================================================
# CHECK DIRECTORY
if [ ! -d "$WALLPAPER_DIR" ]; then
    notify-send "Wallpaper Error" "Directory not found: $WALLPAPER_DIR"
    exit 1
fi

# =============================================================================
# MONITOR DETECTION
# =============================================================================
# Purpose: Detect all active monitors connected to the system
#
# Implementation:
#   - hyprctl monitors -j: Outputs monitor information as JSON
#   - jq -r '.[].name': Extracts monitor names from JSON array
#   - Array assignment: Stores monitor names in bash array
#
# Monitor Naming:
#   - eDP-1: Built-in laptop display (always present)
#   - HDMI-A-1: External monitor (when connected)
#   - DP-1, DP-2: DisplayPort monitors (if connected)
#
# Error Handling:
#   - Checks if any monitors detected (array length > 0)
#   - Provides error notification if no monitors found
#   - Exits with status code 1 if detection fails
#
# Why This Method:
#   - Hyprland provides authoritative monitor information
#   - JSON format is easy to parse with jq
#   - Works with any number of connected monitors
# =============================================================================
# GET MONITORS
# Uses hyprctl to fetch JSON data and jq to extract monitor names.
monitors=($(hyprctl monitors -j 2>/dev/null | jq -r '.[].name' 2>/dev/null))

if [ ${#monitors[@]} -eq 0 ]; then
    notify-send "Wallpaper Error" "No monitors found"
    exit 1
fi

# =============================================================================
# WALLPAPER DISCOVERY
# =============================================================================
# Purpose: Find all available wallpaper images in the configured directory
#
# Implementation:
#   - find: Recursively searches directory tree
#   - File type filter: -type f (files only, excludes directories)
#   - Format filter: -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif"
#     (case-insensitive matching for common image formats)
#   - shuf: Randomizes order of found files
#   - Array assignment: Stores wallpaper paths in bash array
#
# Supported Formats:
#   - JPEG (.jpg, .jpeg): Common photo format, good compression
#   - PNG (.png): Lossless format, supports transparency
#   - GIF (.gif): Animated wallpapers supported
#
# Randomization:
#   - shuf: Ensures different wallpaper selection on each run
#   - Prevents predictable wallpaper sequence
#   - Provides variety in manual rotations
#
# Error Handling:
#   - Checks if any wallpapers found (array length > 0)
#   - Provides error notification if no wallpapers available
#   - Exits with status code 1 if discovery fails
# =============================================================================
# FIND WALLPAPERS
# Recursively finds image files.
all_walls=($(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \) 2>/dev/null | shuf))

if [ ${#all_walls[@]} -eq 0 ]; then
    notify-send "Wallpaper Error" "No wallpapers found in $WALLPAPER_DIR"
    exit 1
fi

# =============================================================================
# WALLPAPER APPLICATION
# =============================================================================
# Purpose: Apply randomly selected wallpapers to all detected monitors
#
# Implementation:
#   - Loops through each detected monitor
#   - Calculates wallpaper index using modulo arithmetic (wraps if more monitors than wallpapers)
#   - Executes swww img command in background for parallel application
#   - Uses fade transition for smooth visual change
#
# Parallel Execution:
#   - Background processes (&): All wallpapers applied simultaneously
#   - Faster than sequential application (important for multi-monitor setups)
#   - wait command: Ensures all processes complete before script exits
#
# Transition Settings:
#   - --transition-type fade: Smooth crossfade between old and new wallpaper
#   - --transition-duration 1: 1-second fade duration (fast but smooth)
#
# Monitor-to-Wallpaper Mapping:
#   - Each monitor receives a different wallpaper (if available)
#   - Modulo arithmetic ensures valid array index even with many monitors
#   - Example: 3 monitors, 2 wallpapers → Monitor 1 gets wallpaper 0, Monitor 2 gets wallpaper 1, Monitor 3 gets wallpaper 0
# =============================================================================
# APPLY WALLPAPERS
# Loops through detected monitors and assigns a unique random wallpaper to each.
for i in "${!monitors[@]}"; do
    # Wrap index if we have more monitors than wallpapers
    # Modulo arithmetic ensures valid array index
    wall_index=$((i % ${#all_walls[@]}))
    
    monitor="${monitors[$i]}"
    wallpaper="${all_walls[$wall_index]}"
    
    # Execute in background for speed
    # swww img: Applies wallpaper to specified monitor
    # -o "$monitor": Output monitor name (e.g., "eDP-1", "HDMI-A-1")
    # "$wallpaper": Absolute path to wallpaper image file
    # --transition-type fade: Smooth crossfade transition
    # --transition-duration 1: 1-second fade duration
    swww img -o "$monitor" "$wallpaper" --transition-type fade --transition-duration 1 &
done

# =============================================================================
# PROCESS SYNCHRONIZATION
# =============================================================================
# Purpose: Wait for all background wallpaper processes to complete
#
# Implementation:
#   - wait: Blocks until all background processes (started with &) finish
#   - Ensures script doesn't exit before wallpapers are fully applied
#   - Prevents race conditions with completion notification
#
# Why Wait:
#   - Background processes need time to complete wallpaper application
#   - Without wait, notification might appear before wallpapers change
#   - Ensures user sees completed wallpaper change
# =============================================================================
wait # Wait for all background processes to finish

# =============================================================================
# COMPLETION NOTIFICATION
# =============================================================================
# Purpose: Inform user that wallpaper change operation completed successfully
#
# Notification Content:
#   - Title: "Wallpaper Changed" (clear action confirmation)
#   - Message: "New wallpaper applied successfully" (operation status)
#
# User Feedback:
#   - Confirms successful wallpaper application
#   - Provides visual confirmation of change
#   - Helps users understand script execution completed
# =============================================================================
notify-send "Wallpaper Changed" "New wallpaper applied successfully"