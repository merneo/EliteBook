# Howdy Fix - Installing pam_python from GitHub

**Date:** 2025-12-02  
**Problem:** pam_python cannot be compiled from AUR due to compiler errors  
**Solution:** Installation from GitHub fork with fixes for newer compilers

---

## Problem Statement

Howdy requires the `pam_python.so` PAM module for authentication. The AUR package `pam-python` fails to compile on Arch Linux with newer GCC versions due to errors:

```
error: assignment to 'char *' from 'int' makes pointer from integer without a cast
```

This is a known compatibility issue with newer compilers.

---

## Solution

Install `pam-python` from a GitHub fork that includes fixes for newer compilers and Python 3 support.

---

## Quick Installation

### Step 1: Run Installation Script

```bash
cd ~/EliteBook/scripts
./install-pam-python-from-github.sh
```

The script automatically:
- Installs dependencies
- Clones GitHub repository (default: `castlabs/pam-python`)
- Compiles pam-python
- Installs to `/usr/lib/security/pam_python.so`
- Verifies installation

### Step 2: Verify Installation

```bash
# Verify module exists
ls -lh /usr/lib/security/pam_python.so

# Verify PAM configuration
grep -i pam_python /etc/pam.d/sudo
```

### Step 3: Test Howdy

```bash
# Clear sudo cache
sudo -k

# Test authentication
sudo whoami
```

---

## Available GitHub Repositories

### 1. castlabs/pam-python (Recommended)
- **URL:** https://github.com/castlabs/pam-python
- **Stars:** 18
- **Last Updated:** 2025-07-31
- **Installation:**
  ```bash
  ./install-pam-python-from-github.sh castlabs/pam-python
  ```

### 2. aaron-riact/pam-python
- **URL:** https://github.com/aaron-riact/pam-python
- **Last Updated:** 2025-08-16
- **Installation:**
  ```bash
  ./install-pam-python-from-github.sh aaron-riact/pam-python
  ```

---

## Manual Installation

If the script does not work, you can install manually:

```bash
# 1. Install dependencies
sudo pacman -S --noconfirm base-devel pam python python-setuptools make gcc git

# 2. Clone repository
cd /tmp
git clone https://github.com/castlabs/pam-python.git
cd pam-python/src

# 3. Modify Makefile for Arch Linux
sed -i 's|LIBDIR ?= /lib/x86_64-linux-gnu/security|LIBDIR ?= /usr/lib/security|g' Makefile

# 4. Compile
make

# 5. Install
sudo make install PREFIX=/usr
```

---

## Troubleshooting

### Compilation Fails

**Problem:** Compiler errors still occur

**Solution:**
1. Try a different fork:
   ```bash
   ./install-pam-python-from-github.sh aaron-riact/pam-python
   ```

2. Check build.log for error details

3. Try with more relaxed compilation flags (script attempts this automatically)

### Module Not Installed

**Problem:** `/usr/lib/security/pam_python.so` does not exist

**Solution:**
```bash
# Find where it was installed
find /usr -name "pam_python.so" 2>/dev/null

# If elsewhere, create symlink
sudo ln -s /path/to/pam_python.so /usr/lib/security/pam_python.so
```

### Howdy Still Not Working

**Problem:** After installing pam-python, Howdy still does not work

**Verification:**
1. Verify PAM configuration:
   ```bash
   cat /etc/pam.d/sudo
   ```
   Should contain:
   ```
   auth      sufficient  pam_python.so /usr/lib/security/howdy/pam.py
   ```

2. Verify module exists:
   ```bash
   ls -la /usr/lib/security/pam_python.so
   ```

3. Verify Howdy PAM script:
   ```bash
   ls -la /usr/lib/security/howdy/pam.py
   ```

4. Check logs:
   ```bash
   sudo journalctl -u sudo -n 50
   sudo journalctl -u howdy -n 50
   ```

---

## Files

- **Installation script:** `~/EliteBook/scripts/install-pam-python-from-github.sh`
- **Documentation:** `~/EliteBook/PAM_PYTHON_INSTALLATION.md`
- **This file:** `~/EliteBook/HOWDY_PAM_PYTHON_FIX.md`

---

## Status

✅ **Script created:** `install-pam-python-from-github.sh`  
✅ **Documentation created:** `PAM_PYTHON_INSTALLATION.md`  
⏳ **Awaiting installation:** Run script to install pam-python

---

## Next Steps

1. **Run installation script:**
   ```bash
   cd ~/EliteBook/scripts
   ./install-pam-python-from-github.sh
   ```

2. **Verify installation:**
   ```bash
   ls -lh /usr/lib/security/pam_python.so
   ```

3. **Test Howdy:**
   ```bash
   sudo -k && sudo whoami
   ```

4. **If everything works:**
   - Face recognition should work with sudo
   - If not, check logs and configuration

---

**Last Updated:** 2025-12-02
