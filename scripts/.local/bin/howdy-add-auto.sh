#!/bin/bash

# =============================================================================
# HOWDY AUTO-ENROLLMENT WRAPPER SCRIPT
# =============================================================================
# Author: merneo
# Purpose: Automatically enroll face model with auto-generated name from
#          current date and time, eliminating the need for manual name input.
#
# Usage:
#   howdy-add-auto.sh [OPTIONS]
#
# Options:
#   -U, --user USER    Set the user account to use (default: current user)
#   -h, --help         Show this help message
#
# Example:
#   howdy-add-auto.sh
#   howdy-add-auto.sh -U username
#
# Generated Name Format:
#   YYYY-MM-DD_HH-MM-SS (e.g., "2025-12-02_16-30-45")
#
# Operational Context:
#   This script wraps the standard `sudo howdy add` command and automatically
#   provides a timestamp-based name when prompted, eliminating interactive
#   input requirements. The generated name includes date and time down to
#   seconds for uniqueness.
# =============================================================================

# =============================================================================
# SCRIPT CONFIGURATION
# =============================================================================
set -euo pipefail

# Script metadata
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
# NAME GENERATION
# =============================================================================
# Generate timestamp-based name: YYYY-MM-DD_HH-MM-SS
# Format ensures:
#   - Uniqueness: Includes seconds for precise timestamp
#   - Readability: Human-readable date/time format
#   - Compatibility: No special characters that could cause issues
#   - Sortability: Chronological sorting by name
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

# Execute howdy add with auto-generated name
# Try multiple methods for maximum compatibility
EXIT_CODE=1

# Method 1: Try expect if available (most reliable)
if command -v expect &> /dev/null; then
    expect << EOF
spawn $HOWDY_CMD
expect {
    "Enter a label for this new model" {
        send "$MODEL_NAME\r"
        exp_continue
    }
    eof
}
wait
EOF
    EXIT_CODE=$?
# Method 2: Try Python pexpect if available
elif python3 -c "import pexpect" 2>/dev/null; then
    python3 << PYEOF
import sys
import pexpect

cmd = "$HOWDY_CMD".split()
child = pexpect.spawn(cmd[0], cmd[1:], encoding='utf-8')
child.logfile = sys.stdout

try:
    child.expect("Enter a label for this new model", timeout=30)
    child.sendline("$MODEL_NAME")
    child.expect(pexpect.EOF, timeout=120)
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
# Method 3: Fallback to printf (may not work if howdy uses direct terminal input)
else
    echo "Warning: Neither 'expect' nor Python 'pexpect' available."
    echo "Attempting with printf (may require manual input if this fails)..."
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
