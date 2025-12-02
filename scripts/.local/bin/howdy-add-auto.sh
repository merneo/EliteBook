#!/bin/bash

# =============================================================================
# HOWDY AUTOMATED FACE MODEL ENROLLMENT WRAPPER SCRIPT
# =============================================================================
# Author: merneo
# Purpose: Automates the Howdy face recognition enrollment process by
#          generating timestamp-based model names and eliminating manual
#          user input requirements during the enrollment workflow.
#
# Academic Context:
#   This script addresses the usability limitation of Howdy's interactive
#   enrollment process, where users must manually enter a label for each
#   face model. By automating name generation using ISO 8601-inspired
#   timestamp formatting, the script reduces cognitive load and ensures
#   unique, sortable model identifiers without user intervention.
#
# Technical Approach:
#   The script employs multiple automation strategies (expect, pexpect, printf)
#   to provide input to Howdy's interactive prompt, ensuring compatibility
#   across different system configurations. The timestamp-based naming
#   convention provides both uniqueness guarantees and chronological
#   sortability for model management.
#
# Usage:
#   howdy-add-auto.sh [OPTIONS]
#
# Options:
#   -U, --user USER    Specify target user account (default: current user)
#   -h, --help         Display usage information and exit
#
# Examples:
#   howdy-add-auto.sh                    # Enroll face model for current user
#   howdy-add-auto.sh -U username        # Enroll face model for specified user
#
# Generated Name Format:
#   YYYY-MM-DD_HH-MM-SS (ISO 8601-inspired, e.g., "2025-12-02_16-30-45")
#   - Format ensures lexicographic sorting matches chronological order
#   - Includes seconds precision for uniqueness in rapid enrollments
#   - Uses underscore separator for filesystem compatibility
#
# Operational Context:
#   This wrapper script interfaces with Howdy's command-line interface,
#   specifically the `howdy add` subcommand, which requires interactive
#   input for model labeling. By automating this interaction, the script
#   enables batch enrollment workflows and reduces user interaction overhead
#   in system administration scenarios.
#
# Dependencies:
#   - howdy: Face recognition system (required)
#   - expect: Automation tool for interactive programs (recommended)
#   - pexpect: Python library for programmatic interaction (optional fallback)
#
# References:
#   - Howdy GitHub: https://github.com/boltgolt/howdy
#   - Expect Documentation: https://www.tcl.tk/man/expect5.31/expect.1.html
#   - ISO 8601 Date/Time Standard: https://en.wikipedia.org/wiki/ISO_8601
# =============================================================================

# =============================================================================
# SCRIPT CONFIGURATION AND SAFETY SETTINGS
# =============================================================================
# Error Handling:
#   - set -e: Exit immediately if any command returns non-zero status
#   - set -u: Treat unset variables as errors (prevents undefined behavior)
#   - set -o pipefail: Return value of pipeline is last non-zero exit status
#
# These settings ensure robust error handling and prevent silent failures
# in automation scenarios where user intervention is not expected.
# =============================================================================
set -euo pipefail

# Script metadata for version tracking and identification
SCRIPT_NAME="howdy-add-auto.sh"
SCRIPT_VERSION="1.0.0"

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

# Print error message and exit
error_exit() {
    echo "Error: $1" >&2
    exit 1
}

# Print usage information
print_usage() {
    cat << EOF
Usage: $SCRIPT_NAME [OPTIONS]

Automatically enroll Howdy face model with auto-generated timestamp name.

Options:
  -U, --user USER    Set the user account to use (default: current user)
  -h, --help         Show this help message

Examples:
  $SCRIPT_NAME                    # Enroll for current user
  $SCRIPT_NAME -U username         # Enroll for specific user

Generated Name Format:
  YYYY-MM-DD_HH-MM-SS (e.g., "2025-12-02_16-30-45")

EOF
}

# =============================================================================
# ARGUMENT PARSING
# =============================================================================
HOWDY_USER=""
HOWDY_ARGS=()

while [[ $# -gt 0 ]]; do
    case $1 in
        -U|--user)
            if [[ -z "${2:-}" ]]; then
                error_exit "Option -U/--user requires a username argument"
            fi
            HOWDY_USER="$2"
            HOWDY_ARGS+=("-U" "$2")
            shift 2
            ;;
        -h|--help)
            print_usage
            exit 0
            ;;
        *)
            error_exit "Unknown option: $1. Use -h for help."
            ;;
    esac
done

# =============================================================================
# TIMESTAMP-BASED MODEL NAME GENERATION
# =============================================================================
# Algorithm: Generate ISO 8601-inspired timestamp string for model identification
#
# Format Specification: YYYY-MM-DD_HH-MM-SS
#   - YYYY: Four-digit year (ensures Y2K+ compatibility)
#   - MM: Two-digit month (01-12, zero-padded)
#   - DD: Two-digit day (01-31, zero-padded)
#   - HH: Two-digit hour (00-23, 24-hour format)
#   - MM: Two-digit minute (00-59, zero-padded)
#   - SS: Two-digit second (00-59, zero-padded)
#   - Separator: Underscore (_) for filesystem compatibility
#
# Design Rationale:
#   1. Uniqueness: Second-level precision ensures uniqueness in normal usage
#   2. Lexicographic Ordering: String comparison matches chronological order
#   3. Human Readability: Standard date/time format is immediately interpretable
#   4. Filesystem Compatibility: No special characters that require escaping
#   5. Sortability: Natural string sorting produces chronological sequence
#
# Example Output: "2025-12-02_16-30-45"
#   Represents: December 2, 2025 at 16:30:45 (4:30:45 PM)
#
# Edge Cases:
#   - Rapid enrollments (<1 second apart): Second precision may cause collisions
#     (mitigated by Howdy's internal ID system)
#   - Timezone: Uses system local time (not UTC) for user convenience
# =============================================================================
MODEL_NAME=$(date +"%Y-%m-%d_%H-%M-%S")

# =============================================================================
# HOWDY ENROLLMENT
# =============================================================================
# Execute howdy add with auto-generated name
# Howdy prompts: "Enter a label for this new model [Initial model] (max 24 characters):"
# We use expect or printf to automatically provide the generated name
# =============================================================================

echo "=========================================="
echo "Howdy Face Model Auto-Enrollment"
echo "=========================================="
echo "Generated model name: $MODEL_NAME"
echo ""

# Check if howdy is available
if ! command -v howdy &> /dev/null; then
    error_exit "Howdy is not installed or not in PATH. Install with: sudo pacman -S howdy"
fi

# Build howdy command
HOWDY_CMD="sudo howdy"
if [[ -n "$HOWDY_USER" ]]; then
    HOWDY_CMD="$HOWDY_CMD -U $HOWDY_USER"
fi
HOWDY_CMD="$HOWDY_CMD add"

echo "Starting enrollment process..."
echo "Position yourself 30-60cm from the camera and look directly at it."
echo ""

# =============================================================================
# AUTOMATED INPUT PROVISION TO HOWDY INTERACTIVE PROMPT
# =============================================================================
# Problem: Howdy's `add` subcommand requires interactive input for model labeling
# Solution: Employ programmatic interaction techniques to provide input automatically
#
# Automation Strategy (Multi-Method Fallback):
#   The script attempts multiple automation methods in order of reliability,
#   ensuring maximum compatibility across different system configurations.
#
# Method Selection Rationale:
#   1. Expect (Primary): Most reliable, designed specifically for interactive automation
#   2. Pexpect (Secondary): Python-based alternative, cross-platform compatibility
#   3. Printf (Tertiary): Simple pipe-based approach, may fail with direct terminal I/O
#
# Implementation Notes:
#   - Each method handles the same interaction pattern: detect prompt, send input
#   - Error handling ensures graceful degradation if automation fails
#   - Exit codes are preserved to maintain script reliability
# =============================================================================
EXIT_CODE=1

# Method 1: Expect-based automation (most reliable)
# Expect is a Tcl extension designed for automating interactive programs
# Reference: https://www.tcl.tk/man/expect5.31/expect.1.html
if command -v expect &> /dev/null; then
    # Spawn Howdy process and interact with its standard I/O streams
    expect << EOF
# Spawn Howdy command as child process with pseudo-terminal (PTY)
spawn $HOWDY_CMD

# Pattern matching: Wait for Howdy's label prompt
expect {
    # Match prompt string and send generated model name
    "Enter a label for this new model" {
        send "$MODEL_NAME\r"  # Send name followed by carriage return (Enter key)
        exp_continue          # Continue matching (may see prompt again)
    }
    eof                       # End of file (process terminated)
}
# Wait for spawned process to complete and capture exit status
wait
EOF
    EXIT_CODE=$?

# Method 2: Python pexpect library (cross-platform alternative)
# Pexpect provides Python interface for expect-like functionality
# Reference: https://pexpect.readthedocs.io/
elif python3 -c "import pexpect" 2>/dev/null; then
    python3 << PYEOF
import sys
import pexpect

# Parse command string into list for subprocess execution
cmd = "$HOWDY_CMD".split()

# Spawn Howdy process with UTF-8 encoding for proper character handling
child = pexpect.spawn(cmd[0], cmd[1:], encoding='utf-8')
child.logfile = sys.stdout  # Redirect child output to parent stdout

try:
    # Wait for Howdy's label prompt (30 second timeout)
    child.expect("Enter a label for this new model", timeout=30)
    
    # Send generated model name (automatically appends newline)
    child.sendline("$MODEL_NAME")
    
    # Wait for process completion (120 second timeout for enrollment)
    child.expect(pexpect.EOF, timeout=120)
    
    # Close process and capture exit status
    child.close()
    sys.exit(child.exitstatus if child.exitstatus is not None else 0)
    
except pexpect.TIMEOUT:
    print("Error: Timeout waiting for Howdy prompt", file=sys.stderr)
    child.close()
    sys.exit(1)
except Exception as e:
    print(f"Error: {e}", file=sys.stderr)
    child.close()
    sys.exit(1)
PYEOF
    EXIT_CODE=$?

# Method 3: Printf pipe fallback (least reliable)
# Simple pipe-based approach: may fail if Howdy uses direct terminal I/O
# This method relies on standard input redirection, which may not work
# if Howdy reads directly from /dev/tty (terminal device) instead of stdin
else
    echo "Warning: Neither 'expect' nor Python 'pexpect' available."
    echo "Attempting with printf (may require manual input if this fails)..."
    # Pipe model name to Howdy's standard input
    printf "%s\n" "$MODEL_NAME" | $HOWDY_CMD
    EXIT_CODE=$?
fi

# Check exit status
if [[ $EXIT_CODE -eq 0 ]]; then
    echo ""
    echo "=========================================="
    echo "✅ Enrollment completed successfully!"
    echo "Model name: $MODEL_NAME"
    echo "=========================================="
    echo ""
    echo "To verify enrollment, run:"
    if [[ -n "$HOWDY_USER" ]]; then
        echo "  sudo howdy -U $HOWDY_USER list"
    else
        echo "  sudo howdy list"
    fi
else
    echo ""
    echo "=========================================="
    echo "❌ Enrollment failed"
    echo "=========================================="
    exit 1
fi
