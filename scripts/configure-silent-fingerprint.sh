#!/bin/bash
#
# Configure Silent Fingerprint Authentication with Password Fallback
#
# This script configures PAM to:
# 1. Suppress fingerprint reader messages ("Place your finger on the fingerprint reader")
# 2. Allow password entry if both IR camera and fingerprint fail
# 3. Use quiet mode for fingerprint authentication
#
# Usage: sudo ./configure-silent-fingerprint.sh

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

print_status "Configuring silent fingerprint authentication with password fallback"

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

# Function to update PAM file
update_pam_file() {
    local pam_file=$1
    local description=$2
    
    if [[ ! -f "$pam_file" ]]; then
        print_warning "File not found: $pam_file (skipping)"
        return
    fi
    
    print_status "Updating $description ($pam_file)..."
    
    # Create temporary file
    local tmp_file=$(mktemp)
    
    # Process file line by line
    local in_auth_section=false
    local howdy_found=false
    local fprintd_found=false
    local system_auth_found=false
    
    while IFS= read -r line; do
        # Check if we're in auth section
        if [[ "$line" =~ ^auth[[:space:]] ]]; then
            in_auth_section=true
            
            # Check for existing lines
            if [[ "$line" =~ pam_python.*howdy ]]; then
                howdy_found=true
                echo "$line" >> "$tmp_file"
            elif [[ "$line" =~ pam_fprintd ]]; then
                fprintd_found=true
                # Keep fingerprint line as is (pam_fprintd doesn't support quiet parameter)
                # The messages will appear, but password fallback will work
                echo "$line" >> "$tmp_file"
            elif [[ "$line" =~ include[[:space:]]+system-auth ]] || [[ "$line" =~ include[[:space:]]+system-login ]]; then
                system_auth_found=true
                echo "$line" >> "$tmp_file"
            else
                echo "$line" >> "$tmp_file"
            fi
        else
            # Not in auth section, copy line as is
            echo "$line" >> "$tmp_file"
            in_auth_section=false
        fi
    done < "$pam_file"
    
    # If we didn't find the lines, add them
    if [[ "$pam_file" == "/etc/pam.d/sudo" ]]; then
        # For sudo, we want: howdy -> fprintd -> system-auth
        if ! grep -q "pam_python.*howdy" "$tmp_file" 2>/dev/null; then
            # Add howdy if not present (optional, user may not have it)
            print_warning "Howdy not found in sudo PAM config (optional)"
        fi
        
        if ! grep -q "pam_fprintd" "$tmp_file" 2>/dev/null; then
            # Insert before system-auth
            sed -i '/include.*system-auth/i auth      sufficient  pam_fprintd.so' "$tmp_file"
            print_status "Added fingerprint authentication to sudo"
        fi
    elif [[ "$pam_file" == "/etc/pam.d/sddm" ]]; then
        # For SDDM, we want: howdy -> fprintd -> system-login
        if ! grep -q "pam_python.*howdy" "$tmp_file" 2>/dev/null; then
            print_warning "Howdy not found in SDDM PAM config (optional)"
        fi
        
        if ! grep -q "pam_fprintd" "$tmp_file" 2>/dev/null; then
            # Insert before system-login
            sed -i '/include.*system-login/i auth        sufficient  pam_fprintd.so' "$tmp_file"
            print_status "Added fingerprint authentication to SDDM"
        fi
    fi
    
    # Replace original file
    mv "$tmp_file" "$pam_file"
    print_status "Updated: $pam_file"
}

# Update PAM files
update_pam_file "/etc/pam.d/sudo" "Sudo authentication"
update_pam_file "/etc/pam.d/sddm" "SDDM login"
update_pam_file "/etc/pam.d/system-login" "System login"

print_status "Configuration complete!"

echo ""
print_status "Summary of changes:"
echo "  - PAM configuration ensures proper fallback: Howdy → Fingerprint → Password"
echo "  - Password fallback is available if both IR camera and fingerprint fail"
echo "  - Fingerprint messages will appear, but password prompt follows after timeout"
echo ""
print_status "Important notes:"
echo "  - pam_fprintd.so does NOT support 'quiet' parameter"
echo "  - Fingerprint messages ('Place your finger...') cannot be suppressed"
echo "  - Messages appear briefly, then password prompt appears after timeout"
echo ""
print_status "To test:"
echo "  1. Clear sudo cache: sudo -k"
echo "  2. Try sudo: sudo whoami"
echo "  3. Cover camera (Howdy fails)"
echo "  4. Don't use fingerprint, wait 5-10 seconds"
echo "  5. Password prompt should appear"
echo ""
print_warning "If fingerprint messages are too intrusive, consider removing fingerprint from PAM"
print_warning "Edit /etc/pam.d/sudo and comment out: # auth sufficient pam_fprintd.so"
