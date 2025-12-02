#!/bin/bash

# =============================================================================
# WAYBAR THEME SWITCHER - Status Bar Theme Management Script
# =============================================================================
# Author: merneo
# Purpose: Provides interactive interface for switching between Waybar status
#          bar theme variants, allowing server administrators to choose between
#          minimal (v1) and feature-rich (v2) status bar configurations.
#
# Operational Context:
#   This script enables runtime theme switching for Waybar without manual
#   file editing. Useful for administrators who want to adapt the status bar
#   to different workflow requirements (minimal vs. information-rich).
#
# Theme Variants:
#   - V1 (Original): Minimal top bar with essential information only
#     - Workspaces, basic system info
#     - Lower resource usage
#     - Clean, uncluttered appearance
#   - V2 (New): Modular top bar with extended features
#     - Workspaces, weather, network, battery, clock
#     - More informative (better for monitoring)
#     - Slightly higher resource usage
#
# Execution Flow:
#   1. Validates theme directory existence
#   2. Presents interactive menu for theme selection
#   3. Copies selected theme files to active configuration location
#   4. Restarts Waybar to apply new theme
#   5. Provides user feedback on completion
#
# Usage:
#   - Run interactively: ./waybar-theme-switch.sh
#   - User selects theme variant from menu
#   - Script applies changes and restarts Waybar
#
# Dependencies:
#   - Waybar (status bar)
#   - Hyprland (Wayland compositor, for process detection)
#   - Theme files in ~/dotfiles/waybar/themes/ directory
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
# DIRECTORY PATHS
# =============================================================================
# Purpose: Define paths to theme storage and active configuration locations
#
# Directory Structure:
#   - THEME_DIR: Storage location for theme variants (v1, v2)
#     Path: ~/dotfiles/waybar/themes/
#   - CONFIG_DIR: Active configuration location (where Waybar reads from)
#     Path: ~/dotfiles/waybar/.config/waybar/
#
# Why These Paths:
#   - dotfiles directory: Centralized configuration management
#   - themes subdirectory: Organized theme storage
#   - .config/waybar: Standard XDG configuration location
#
# Note: These paths assume GNU Stow deployment structure
# =============================================================================
THEME_DIR="$HOME/dotfiles/waybar/themes"
CONFIG_DIR="$HOME/dotfiles/waybar/.config/waybar"

# =============================================================================
# DIRECTORY VALIDATION
# =============================================================================
# Purpose: Verify theme directory exists before attempting theme switching
#
# Validation:
#   - Checks if THEME_DIR exists (-d test)
#   - Provides error message if directory missing
#   - Exits with status code 1 if validation fails
#
# Why Validate:
#   - Prevents script failure when trying to copy theme files
#   - Provides clear error message (directory path shown)
#   - Helps users understand configuration requirements
# =============================================================================
# Ensure directories exist
if [ ! -d "$THEME_DIR" ]; then
    echo "Error: Theme directory $THEME_DIR not found."
    exit 1
fi

# =============================================================================
# INTERACTIVE THEME SELECTION MENU
# =============================================================================
# Purpose: Present user with theme options and capture selection
#
# Menu Design:
#   - Clear descriptions of each theme variant
#   - Numbered options for easy selection
#   - Descriptive text explaining differences
#
# Theme Descriptions:
#   - V1: Minimal, essential information only
#   - V2: Feature-rich, includes weather and extended system info
#
# User Input:
#   - read -p: Prompts user for choice
#   - Stores input in $choice variable
#   - Used in case statement for theme selection
# =============================================================================
echo "Select Waybar Style:"
echo "1) V1 (Original - Top Bar, minimal)"
echo "2) V2 (New - Top Bar, modular, weather, extra info)"
echo ""
read -p "Enter choice [1-2]: " choice

# =============================================================================
# THEME APPLICATION (Case Statement)
# =============================================================================
# Purpose: Apply selected theme by copying theme files to active configuration
#
# Implementation:
#   - case statement: Matches user input against theme options
#   - File copying: cp command copies theme files to config directory
#   - Files copied: config.jsonc (module configuration), style.css (styling)
#
# Theme Files:
#   - config.jsonc: Defines Waybar modules and their configuration
#   - style.css: Defines visual styling (colors, fonts, layout)
#
# Error Handling:
#   - Default case: Invalid input triggers error message and exit
#   - Exits with status code 1 if invalid choice provided
#
# Why Copy Instead of Symlink:
#   - Ensures files are in expected location (Waybar may not follow symlinks)
#   - Simpler error handling (file always exists)
#   - Atomic operation (copy is fast and reliable)
# =============================================================================
case $choice in
    1)
        echo "Switching to V1 (Original)..."
        cp "$THEME_DIR/v1/config.jsonc" "$CONFIG_DIR/config.jsonc"
        cp "$THEME_DIR/v1/style.css" "$CONFIG_DIR/style.css"
        ;;
    2)
        echo "Switching to V2 (New)..."
        cp "$THEME_DIR/v2/config.jsonc" "$CONFIG_DIR/config.jsonc"
        cp "$THEME_DIR/v2/style.css" "$CONFIG_DIR/style.css"
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

# =============================================================================
# WAYBAR RESTART
# =============================================================================
# Purpose: Restart Waybar to apply new theme configuration
#
# Process:
#   1. Kill existing Waybar process (graceful termination)
#   2. Brief sleep (0.5s) to allow process cleanup
#   3. Check if Hyprland is running (Waybar requires compositor)
#   4. Start new Waybar instance if Hyprland active
#
# Hyprland Detection:
#   - pgrep -x "Hyprland": Checks if Hyprland compositor is running
#   - Waybar requires active Wayland compositor to function
#   - Conditional start prevents errors if compositor not available
#
# Error Handling:
#   - pkill || true: Continues even if Waybar not running
#   - Conditional start: Only starts if Hyprland available
#   - Output redirection: Suppresses stdout/stderr (clean execution)
#
# User Feedback:
#   - Console messages indicate restart status
#   - Different messages for success vs. Hyprland unavailable
# =============================================================================
echo "Restarting Waybar..."
pkill waybar || true
sleep 0.5
# Attempt to start waybar if Hyprland is running
if pgrep -x "Hyprland" > /dev/null; then
    waybar > /dev/null 2>&1 &
    echo "Waybar restarted."
else
    echo "Hyprland not running. Waybar config updated but not started."
fi
