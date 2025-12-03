# PAM-Python Installation Guide for Howdy

**Date:** 2025-12-02  
**System:** Arch Linux  
**Purpose:** Install pam-python module for Howdy face recognition

---

## Problem

Howdy requires `pam_python.so` PAM module for authentication integration. The AUR package `pam-python` fails to compile on Arch Linux with newer GCC versions due to compiler errors:

```
error: assignment to 'char *' from 'int' makes pointer from integer without a cast
```

This is a known compatibility issue with newer compilers.

---

## Solution: Install from GitHub Fork

Several GitHub forks of pam-python exist that may have fixes for newer compilers. The recommended approach is to install from a GitHub fork that supports Python 3 and has been updated recently.

---

## Recommended GitHub Repositories

### Option 1: castlabs/pam-python (Recommended - Most Stars)

**Repository:** https://github.com/castlabs/pam-python  
**Stars:** 18  
**Features:**
- Python 3 support
- Maintained by castlabs
- Popular fork

**Installation:**
```bash
cd ~/EliteBook/scripts
./install-pam-python-from-github.sh castlabs/pam-python
```

### Option 2: aaron-riact/pam-python

**Repository:** https://github.com/aaron-riact/pam-python  
**Last Updated:** 2025-08-16  
**Features:**
- Python 3 support
- Recent updates
- Active development

**Installation:**
```bash
cd ~/EliteBook/scripts
./install-pam-python-from-github.sh aaron-riact/pam-python
```

### Option 2: Manual Installation

If the automated script doesn't work, you can install manually:

```bash
# Install dependencies
sudo pacman -S --noconfirm base-devel pam python python-setuptools make gcc git

# Clone repository
cd /tmp
git clone https://github.com/aaron-riact/pam-python.git
cd pam-python/src

# Modify Makefile for Arch Linux
sed -i 's|LIBDIR ?= /lib/x86_64-linux-gnu/security|LIBDIR ?= /usr/lib/security|g' Makefile

# Build
make

# Install
sudo make install PREFIX=/usr
```

---

## Automated Installation Script

A script is available at:
- `~/EliteBook/scripts/install-pam-python-from-github.sh`

**Usage:**
```bash
cd ~/EliteBook/scripts
chmod +x install-pam-python-from-github.sh
./install-pam-python-from-github.sh [github-repo]

# Example:
./install-pam-python-from-github.sh aaron-riact/pam-python
```

**What the script does:**
1. Installs build dependencies
2. Clones the GitHub repository
3. Modifies Makefile for Arch Linux paths
4. Compiles pam-python
5. Installs to `/usr/lib/security/pam_python.so`
6. Verifies installation

---

## Verification

After installation, verify that pam-python is installed:

```bash
# Check if module exists
ls -lh /usr/lib/security/pam_python.so

# Verify PAM configuration
grep -i pam_python /etc/pam.d/sudo

# Expected output:
# auth      sufficient  pam_python.so /usr/lib/security/howdy/pam.py
```

---

## Testing Howdy with pam-python

Once pam-python is installed, test Howdy authentication:

```bash
# Clear sudo cache
sudo -k

# Test authentication
sudo whoami

# Expected: Face recognition should work (or fallback to password)
```

---

## Troubleshooting

### Build Fails with Compiler Errors

**Problem:** Build fails with "assignment to 'char *' from 'int'" error

**Solutions:**
1. Try a different GitHub fork
2. Use older GCC version (not recommended)
3. Manually patch the source code
4. Check if there's an updated fork with fixes

### Module Not Found After Installation

**Problem:** `/usr/lib/security/pam_python.so` not found

**Check:**
```bash
# Find where it was installed
find /usr -name "pam_python.so" 2>/dev/null

# If found elsewhere, create symlink:
sudo ln -s /path/to/pam_python.so /usr/lib/security/pam_python.so
```

### PAM Configuration Not Working

**Problem:** Howdy still doesn't work after installing pam-python

**Check:**
1. Verify PAM configuration:
   ```bash
   cat /etc/pam.d/sudo
   ```

2. Check PAM module path:
   ```bash
   ls -la /usr/lib/security/pam_python.so
   ```

3. Check Howdy PAM script:
   ```bash
   ls -la /usr/lib/security/howdy/pam.py
   ```

4. Check system logs:
   ```bash
   sudo journalctl -u sudo -n 50
   sudo journalctl -u howdy -n 50
   ```

---

## Alternative Solutions

### Option 1: Use Pre-compiled Binary (if available)

Some distributions provide pre-compiled pam-python. You could try:
- Download from Ubuntu/Debian repositories (may not work on Arch)
- Use a Docker container with pre-compiled version

### Option 2: Wait for AUR Update

Monitor the AUR package for updates:
- https://aur.archlinux.org/packages/pam-python
- Check for patches or updated source

### Option 3: Use Different Authentication Method

If pam-python cannot be installed:
- Use password authentication (secure fallback)
- Consider alternative biometric authentication methods
- Use key-based authentication for SSH

---

## References

- [Howdy GitHub](https://github.com/boltgolt/howdy)
- [PAM-Python SourceForge](http://pam-python.sourceforge.net/)
- [ArchWiki Howdy](https://wiki.archlinux.org/title/Howdy)
- [AUR pam-python](https://aur.archlinux.org/packages/pam-python)

---

## Status

**Current Status:** ⚠️ Requires manual installation from GitHub  
**Recommended Action:** Use `install-pam-python-from-github.sh` script  
**Last Updated:** 2025-12-02
