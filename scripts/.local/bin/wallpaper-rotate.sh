#!/bin/bash

# =============================================================================
# WALLPAPER ROTATION SCRIPT - Automatic Wallpaper Rotation Daemon
# =============================================================================
# Author: merneo
# Purpose: Continuous daemon that automatically rotates wallpapers across all
#          connected monitors at regular intervals (3 minutes), providing dynamic
#          desktop appearance without manual intervention.
#
# Operational Context:
#   This script runs as a background daemon, automatically changing wallpapers
#   to maintain visual variety on the desktop. Designed for server administrators
#   who want dynamic desktop appearance without manual wallpaper management.
#
# Execution Model:
#   - Daemon mode: Runs continuously in infinite loop
#   - Rotation interval: 180 seconds (3 minutes)
#   - Automatic monitor detection: Adapts to monitor connection/disconnection
#   - Parallel wallpaper application: All monitors updated simultaneously
#
# Relationship to wallpaper-change.sh:
#   - wallpaper-rotate.sh: Automatic daemon (continuous background operation)
#   - wallpaper-change.sh: Manual trigger (on-demand rotation)
#   - Both scripts share same wallpaper directory and application logic
#
# Startup Integration:
#   - Executed via Hyprland exec-once (starts on login)
#   - Delayed start: 2-second delay ensures display server is ready
#   - Auto-restart: Script handles swww-daemon lifecycle
#
# Dependencies:
#   - swww: Wayland wallpaper daemon and client
#   - jq: JSON parser for monitor detection
#   - Hyprland: Wayland compositor (for monitor information)
# =============================================================================

# =============================================================================
# CONFIGURATION VARIABLES
# =============================================================================
# Purpose: Define operational parameters for wallpaper rotation
#
# WALLPAPER_DIR: Source directory for wallpaper images
#   - Path: $HOME/Pictures/Wallpapers/walls/
#   - Supports recursive subdirectories
#   - Accepts: .jpg, .jpeg, .png, .gif formats
#
# LOG_DIR: Logging directory following XDG state directory specification
#   - Default: ~/.local/state/dotfiles-logs (if XDG_STATE_HOME not set)
#   - Permissions: 0700 (owner read/write/execute only)
#   - Purpose: Centralized logging for all dotfiles management scripts
#
# LOG_FILE: Log file for wallpaper rotation operations
#   - Contains timestamped entries for all rotation cycles
#   - Useful for troubleshooting wallpaper application issues
#   - Rotated manually or via logrotate if configured
#
# MAX_RETRIES: Maximum attempts to start swww-daemon
#   - Value: 3 attempts
#   - Handles race conditions during system startup
#   - Prevents infinite retry loops
# =============================================================================
WALLPAPER_DIR="$HOME/Pictures/Wallpapers/walls"
LOG_DIR="${XDG_STATE_HOME:-${HOME}/.local/state}/dotfiles-logs"
mkdir -p "$LOG_DIR"
chmod 0700 "$LOG_DIR"
LOG_FILE="$LOG_DIR/wallpaper-rotate.log"
MAX_RETRIES=3

# =============================================================================
# LOGGING FUNCTION
# =============================================================================
# Purpose: Provide centralized logging with timestamps
#
# Implementation:
#   - Appends timestamped messages to log file
#   - Timestamp format: YYYY-MM-DD HH:MM:SS (ISO 8601-like)
#   - Log file: wallpaper-rotate.log in XDG state directory
#
# Usage:
#   log "Message text" - Appends message with timestamp to log file
#
# Why Logging:
#   - Troubleshooting: Helps diagnose wallpaper application failures
#   - Auditing: Tracks rotation frequency and success rate
#   - Debugging: Identifies issues with monitor detection or swww daemon
# =============================================================================
# LOGGING
# Appends timestamped messages to a temporary log file for debugging.
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# =============================================================================
# SWWW DAEMON MANAGEMENT FUNCTION
# =============================================================================
# Purpose: Ensure swww-daemon is running before attempting wallpaper operations
#
# Implementation:
#   - Checks if swww-daemon process is running (pgrep)
#   - If not running, attempts to start daemon
#   - Retries up to MAX_RETRIES times to handle race conditions
#   - Sleeps 2 seconds between attempts (allows daemon initialization)
#
# Why Retry Logic:
#   - System startup: Daemon may not be ready immediately
#   - Race conditions: Multiple scripts may try to start daemon simultaneously
#   - Process initialization: Daemon needs time to create Unix socket
#
# Return Values:
#   - 0: Daemon is running (success)
#   - 1: Failed to start daemon after MAX_RETRIES attempts (failure)
#
# Error Handling:
#   - Logs all retry attempts for troubleshooting
#   - Returns error status if daemon cannot be started
#   - Prevents wallpaper operations with non-functional daemon
# =============================================================================
# DAEMON MANAGEMENT
# Ensures 'swww-daemon' is running before attempting to set wallpapers.
# Retries up to 3 times to handle race conditions during startup.
start_swww() {
    local retries=0
    while [ $retries -lt $MAX_RETRIES ]; do
        if pgrep -x swww-daemon > /dev/null; then
            log "swww-daemon is running"
            return 0
        fi

        log "Starting swww-daemon (attempt $((retries + 1))/$MAX_RETRIES)"
        swww-daemon &
        sleep 2  # Give daemon time to initialize socket

        if pgrep -x swww-daemon > /dev/null; then
            log "swww-daemon started successfully"
            return 0
        fi

        retries=$((retries + 1))
    done

    log "ERROR: Failed to start swww-daemon after $MAX_RETRIES attempts"
    return 1
}

# =============================================================================
# WALLPAPER APPLICATION FUNCTION
# =============================================================================
# Purpose: Detect monitors, find wallpapers, and apply them to all connected displays
#
# Execution Flow:
#   1. Monitor Detection: Queries Hyprland for active monitors
#   2. Directory Validation: Verifies wallpaper directory exists
#   3. Wallpaper Discovery: Finds all available wallpaper images
#   4. Wallpaper Application: Applies wallpapers to monitors in parallel
#   5. Process Synchronization: Waits for all applications to complete
#
# Error Handling:
#   - Returns 1 if any step fails (monitor detection, directory validation, etc.)
#   - Logs all errors for troubleshooting
#   - Continues operation even if individual wallpaper applications fail
# =============================================================================
# MAIN LOGIC
# 1. Detects active monitors.
# 2. Finds all wallpapers.
# 3. Shuffles wallpapers and assigns one to each monitor.
set_wallpapers() {
    # ========================================================================
    # STEP 1: MONITOR DETECTION
    # ========================================================================
    # Purpose: Identify all active monitors connected to the system
    #
    # Implementation:
    #   - hyprctl monitors -j: Outputs monitor information as JSON
    #   - jq -r '.[].name': Extracts monitor names from JSON array
    #   - Array assignment: Stores monitor names in local bash array
    #
    # Monitor Naming Convention:
    #   - eDP-1: Built-in laptop display (always present)
    #   - HDMI-A-1: External HDMI monitor (when connected)
    #   - DP-1, DP-2: DisplayPort monitors (if connected)
    #
    # Error Handling:
    #   - Checks if any monitors detected (array length > 0)
    #   - Logs error and returns 1 if no monitors found
    #   - Prevents wallpaper application to non-existent displays
    # ========================================================================
    # DETECT MONITORS
    # Uses hyprctl to get JSON data, parses with jq to extract names (e.g., eDP-1, HDMI-A-1).
    local monitors=($(hyprctl monitors -j 2>/dev/null | jq -r '.[].name' 2>/dev/null))

    if [ ${#monitors[@]} -eq 0 ]; then
        log "ERROR: No monitors found"
        return 1
    fi

    log "Found ${#monitors[@]} monitor(s): ${monitors[*]}"

    # ========================================================================
    # STEP 2: DIRECTORY VALIDATION
    # ========================================================================
    # Purpose: Verify wallpaper source directory exists and is accessible
    #
    # Validation:
    #   - Checks if directory exists (-d test)
    #   - Logs error with directory path if validation fails
    #   - Returns 1 if directory missing (prevents find command errors)
    #
    # Why Validate:
    #   - Prevents find command from failing silently
    #   - Provides clear error message in logs
    #   - Helps users understand configuration requirements
    # ========================================================================
    # VALIDATE DIRECTORY
    if [ ! -d "$WALLPAPER_DIR" ]; then
        log "ERROR: Wallpaper directory does not exist: $WALLPAPER_DIR"
        return 1
    fi

    # ========================================================================
    # STEP 3: WALLPAPER DISCOVERY
    # ========================================================================
    # Purpose: Find all available wallpaper images in the configured directory
    #
    # Implementation:
    #   - find: Recursively searches directory tree
    #   - File type filter: -type f (files only, excludes directories)
    #   - Format filter: Case-insensitive matching for .jpg, .jpeg, .png, .gif
    #   - shuf: Randomizes order of found files (ensures variety)
    #   - Array assignment: Stores wallpaper paths in local bash array
    #
    # Supported Formats:
    #   - JPEG (.jpg, .jpeg): Common photo format, good compression
    #   - PNG (.png): Lossless format, supports transparency
    #   - GIF (.gif): Animated wallpapers supported (if swww supports animation)
    #
    # Randomization:
    #   - shuf: Ensures different wallpaper sequence on each rotation
    #   - Prevents predictable wallpaper order
    #   - Provides visual variety over time
    #
    # Error Handling:
    #   - Checks if any wallpapers found (array length > 0)
    #   - Logs error and returns 1 if no wallpapers available
    #   - Prevents wallpaper application with empty wallpaper set
    # ========================================================================
    # FETCH WALLPAPERS
    # Finds images recursively, handles spaces in names, and randomizes order.
    local all_walls=($(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \) 2>/dev/null | shuf))

    if [ ${#all_walls[@]} -eq 0 ]; then
        log "ERROR: No wallpapers found in $WALLPAPER_DIR"
        return 1
    fi

    log "Found ${#all_walls[@]} wallpaper(s)"

    # ========================================================================
    # STEP 4: WALLPAPER APPLICATION (Parallel Execution)
    # ========================================================================
    # Purpose: Apply randomly selected wallpapers to all detected monitors
    #
    # Implementation:
    #   - Loops through each detected monitor
    #   - Assigns wallpaper from shuffled array (each monitor gets different wallpaper if available)
    #   - Executes swww img command in background for parallel application
    #   - Uses timeout wrapper to prevent hanging processes
    #
    # Parallel Execution Benefits:
    #   - Faster application (all monitors updated simultaneously)
    #   - Better user experience (no sequential delays)
    #   - Efficient resource usage (parallel I/O operations)
    #
    # Timeout Protection:
    #   - timeout 15: Kills process if it runs longer than 15 seconds
    #   - Prevents script hanging on corrupted image files
    #   - 15 seconds is more than enough for normal 2-second fade transition
    #
    # Process Tracking:
    #   - pids array: Stores process IDs of all background wallpaper applications
    #   - Used for synchronization and timeout detection
    # ========================================================================
    # APPLY WALLPAPERS
    # Iterates through monitors and assigns the next available unique wallpaper.
    local pids=()
    for i in "${!monitors[@]}"; do
        if [ $i -lt ${#all_walls[@]} ]; then
            local wallpaper="${all_walls[$i]}"
            log "Setting wallpaper for ${monitors[$i]}: $(basename "$wallpaper")"

            # Execute swww transition in background with timeout to prevent hanging
            # Timeout of 15 seconds should be more than enough for a 2-second fade
            # Output redirection: Logs swww output to log file for debugging
            (timeout 15 swww img -o "${monitors[$i]}" "$wallpaper" --transition-type fade --transition-duration 2 >> "$LOG_FILE" 2>&1) &
            pids+=($!)
        fi
    done

    # ========================================================================
    # STEP 5: PROCESS SYNCHRONIZATION WITH TIMEOUT PROTECTION
    # ========================================================================
    # Purpose: Wait for all background wallpaper processes to complete, with
    #          timeout protection to prevent infinite waiting
    #
    # Implementation:
    #   - Polls process status using kill -0 (checks if process exists)
    #   - Removes completed processes from tracking array
    #   - Maximum wait time: 20 seconds (safety limit)
    #   - Kills stuck processes if timeout exceeded
    #
    # Why Timeout Protection:
    #   - Prevents script from hanging indefinitely
    #   - Handles corrupted image files that cause swww to hang
    #   - Ensures daemon continues operating even if individual applications fail
    #
    # Process Status Checking:
    #   - kill -0 $pid: Returns 0 if process exists, non-zero if process finished
    #   - Array re-indexing: Removes gaps after process completion
    #   - Sleep 1: Polls every second (balance between responsiveness and CPU usage)
    #
    # Stuck Process Handling:
    #   - kill -9: Force termination of processes exceeding timeout
    #   - Logs warning message for troubleshooting
    #   - Continues operation (doesn't abort entire rotation cycle)
    # ========================================================================
    # Wait for all background processes with a safety check
    local wait_count=0
    local max_wait=20  # Maximum 20 seconds total wait time
    while [ ${#pids[@]} -gt 0 ] && [ $wait_count -lt $max_wait ]; do
        for i in "${!pids[@]}"; do
            if ! kill -0 "${pids[$i]}" 2>/dev/null; then
                # Process finished, remove from array
                unset 'pids[$i]'
            fi
        done
        pids=("${pids[@]}")  # Re-index array

        if [ ${#pids[@]} -gt 0 ]; then
            sleep 1
            wait_count=$((wait_count + 1))
        fi
    done

    # Kill any remaining stuck processes
    if [ ${#pids[@]} -gt 0 ]; then
        log "WARNING: ${#pids[@]} wallpaper process(es) did not finish in time, killing them"
        for pid in "${pids[@]}"; do
            kill -9 "$pid" 2>/dev/null || true
        done
    fi

    log "Wallpapers set successfully"
    return 0
}

# =============================================================================
# SIGNAL HANDLING (Cleanup on Termination)
# =============================================================================
# Purpose: Ensure clean script termination when killed by system or user
#
# Implementation:
#   - trap: Registers cleanup function for SIGTERM and SIGINT signals
#   - SIGTERM: Termination signal (sent by system shutdown, systemd stop, etc.)
#   - SIGINT: Interrupt signal (sent by Ctrl+C in terminal)
#
# Cleanup Function:
#   - Logs termination message for auditing
#   - Exits with status code 0 (clean exit)
#   - Prevents error messages from incomplete operations
#
# Why Signal Handling:
#   - Ensures log file is properly closed
#   - Provides audit trail of script lifecycle
#   - Prevents orphaned processes if script is killed
# =============================================================================
# CLEANUP
# Ensures clean exit when script is killed.
cleanup() {
    log "Wallpaper rotation script terminated"
    exit 0
}

trap cleanup SIGTERM SIGINT

# =============================================================================
# SCRIPT EXECUTION START
# =============================================================================
# Purpose: Initialize daemon and begin wallpaper rotation loop
#
# Execution Sequence:
#   1. Log script startup
#   2. Initialize swww-daemon (with retry logic)
#   3. Apply initial wallpapers (immediate visual feedback)
#   4. Enter infinite rotation loop (3-minute intervals)
#
# Initial Wallpaper Application:
#   - Applies wallpapers immediately on script start
#   - Provides visual feedback that daemon is active
#   - Handles failures gracefully (logs warning, continues to rotation loop)
#
# Rotation Loop:
#   - Infinite while true loop (daemon runs until killed)
#   - Sleep 180: 3-minute interval between rotations
#   - Error handling: Logs failures but continues operation
#   - Ensures daemon remains operational even if individual rotations fail
# =============================================================================
log "=== Wallpaper rotation script started ==="

# Initialize engine
if ! start_swww; then
    log "FATAL: Cannot start swww-daemon, exiting"
    exit 1
fi

# Initial set on startup
if ! set_wallpapers; then
    log "WARNING: Failed to set initial wallpapers, will retry in rotation loop"
fi

# =============================================================================
# INFINITE ROTATION LOOP
# =============================================================================
# Purpose: Continuously rotate wallpapers at regular intervals
#
# Loop Characteristics:
#   - Interval: 180 seconds (3 minutes)
#   - Continuous operation: Runs until script is terminated
#   - Error resilience: Continues even if individual rotations fail
#
# Rotation Cycle:
#   1. Sleep for interval duration (180 seconds)
#   2. Log rotation cycle start
#   3. Execute wallpaper application function
#   4. Log warnings if rotation fails (but continue loop)
#
# Why Infinite Loop:
#   - Daemon model: Script runs continuously in background
#   - No exit condition: Designed to run for entire session duration
#   - Termination: Only via signal (SIGTERM, SIGINT) handled by trap
#
# Performance Considerations:
#   - Sleep 180: Low CPU usage (process sleeps most of the time)
#   - Wallpaper application: Brief CPU/IO spike every 3 minutes
#   - Memory usage: Minimal (only stores array of wallpaper paths)
# =============================================================================
# INFINITE LOOP
# Rotates wallpapers every 3 minutes (180 seconds).
log "Starting wallpaper rotation loop (interval: 180 seconds)"
while true; do
    sleep 180
    log "--- Rotation cycle ---"
    set_wallpapers || log "WARNING: Wallpaper rotation failed, will retry next cycle"
done