#!/bin/bash
#
# Remove Fingerprint from PAM Configuration
#
# This script removes fingerprint authentication from PAM files,
# leaving only Howdy (face recognition) and password authentication.
# This eliminates fingerprint messages if they are too intrusive.
#
# Usage: sudo ./remove-fingerprint-from-pam.sh

set -euo pipefail

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    print_error "This script must be run as root (use sudo)"
    exit 1
fi

print_status "Removing fingerprint authentication from PAM configuration"

# Backup PAM configurations
print_status "Backing up PAM configurations..."

for pam_file in /etc/pam.d/sudo /etc/pam.d/sddm /etc/pam.d/system-login; do
    if [[ -f "$pam_file" ]]; then
        if [[ ! -f "${pam_file}.backup" ]]; then
            cp "$pam_file" "${pam_file}.backup"
            print_status "Backed up: $pam_file"
        fi
    fi
done

# Function to remove fingerprint from PAM file
remove_fingerprint() {
    local pam_file=$1
    local description=$2
    
    if [[ ! -f "$pam_file" ]]; then
        print_warning "File not found: $pam_file (skipping)"
        return
    fi
    
    print_status "Processing $description ($pam_file)..."
    
    # Check if fingerprint line exists
    if grep -q "pam_fprintd" "$pam_file"; then
        # Comment out fingerprint line
        sed -i 's/^auth.*pam_fprintd\.so/# &/' "$pam_file"
        print_status "Removed fingerprint authentication from $pam_file"
    else
        print_warning "Fingerprint not found in $pam_file (already removed or not configured)"
    fi
}

# Remove fingerprint from PAM files
remove_fingerprint "/etc/pam.d/sudo" "Sudo authentication"
remove_fingerprint "/etc/pam.d/sddm" "SDDM login"
remove_fingerprint "/etc/pam.d/system-login" "System login"

print_status "Configuration complete!"

echo ""
print_status "Summary of changes:"
echo "  - Fingerprint authentication removed from PAM configuration"
echo "  - Authentication now: Howdy (face recognition) → Password"
echo "  - No more fingerprint messages"
echo ""
print_status "To restore fingerprint authentication:"
echo "  sudo ~/EliteBook/scripts/configure-silent-fingerprint.sh"
echo ""
print_status "To test:"
echo "  1. Clear sudo cache: sudo -k"
echo "  2. Try sudo: sudo whoami"
echo "  3. Cover camera (Howdy fails)"
echo "  4. Password prompt should appear immediately (no fingerprint messages)"
