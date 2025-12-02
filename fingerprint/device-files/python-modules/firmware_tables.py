# =============================================================================
# FIRMWARE TABLES - Device Firmware Download Information
# =============================================================================
# Author: merneo (based on python-validity project)
# Purpose: Defines firmware download URLs, checksums, and filenames for
#          supported Validity Sensors fingerprint devices.
#
# Operational Context:
#   This module provides metadata for firmware files that must be downloaded
#   and installed on fingerprint sensors during initial setup. The firmware
#   files are extracted from Windows driver packages (Lenovo/HP) and flashed
#   to the device's internal flash memory.
#
# Firmware Sources:
#   - Lenovo driver packages: Windows .exe installers containing firmware
#   - HP driver packages: Windows .exe installers (may not extract cleanly)
#   - Fallback: Lenovo firmware used for HP devices (compatible)
#
# Security:
#   - SHA-512 checksums: Verify firmware integrity before installation
#   - Prevents corrupted or tampered firmware from being installed
#   - Critical for device security (firmware controls authentication)
# =============================================================================
"""Defines various constants for firmware files"""

from .usb import SupportedDevices

# =============================================================================
# FIRMWARE DOWNLOAD URIS
# =============================================================================
# Purpose: URLs and checksums for firmware download sources
#
# Dictionary Structure:
#   - Key: SupportedDevices enum (device model)
#   - Value: Dictionary with driver URL, referral URL, and SHA-512 checksum
#
# Firmware Sources:
#   - driver: Direct download URL for Windows driver package (.exe)
#   - referral: Support page URL (for manual download if needed)
#   - sha512: SHA-512 checksum for firmware file verification
#
# Device-Specific Notes:
#   - DEV_90: Older model, different firmware file
#   - DEV_97, DEV_9a, DEV_9d, DEV_92: Newer models, shared firmware
#   - DEV_92 (HP EliteBook): Uses Lenovo firmware (HP archives don't extract)
#
# Why Lenovo Firmware for HP:
#   - HP driver packages use proprietary archive format (difficult to extract)
#   - Lenovo firmware is compatible (same Validity Sensors hardware)
#   - Firmware is hardware-specific, not vendor-specific
# =============================================================================
FIRMWARE_URIS = {
    SupportedDevices.DEV_90: {
        'driver': 'https://download.lenovo.com/pccbbs/mobiles/n1cgn08w.exe',
        'referral': 'https://support.lenovo.com/us/en/downloads/DS120491',
        'sha512': 'd839fa65adf4c952ecb4a5c4b2fc5b5bdedd8e02a421564bdc7fae1d281be4ea26fcde2333f2ab78d56cef0fdccce0a3cf429300b89544cdc9cfee6d0fe0db55'
    },
    SupportedDevices.DEV_97: {
        'driver': 'https://download.lenovo.com/pccbbs/mobiles/nz3gf07w.exe',
        'referral': 'https://download.lenovo.com/pccbbs/mobiles/nz3gf07w.exe',
        'sha512': 'a4a4e6058b1ea8ab721953d2cfd775a1e7bc589863d160e5ebbb90344858f147d695103677a8df0b2de0c95345df108bda97196245b067f45630038fb7c807cd'
    },
    SupportedDevices.DEV_9a: {
        'driver': 'https://download.lenovo.com/pccbbs/mobiles/nz3gf07w.exe',
        'referral': 'https://download.lenovo.com/pccbbs/mobiles/nz3gf07w.exe',
        'sha512': 'a4a4e6058b1ea8ab721953d2cfd775a1e7bc589863d160e5ebbb90344858f147d695103677a8df0b2de0c95345df108bda97196245b067f45630038fb7c807cd'
    },
    SupportedDevices.DEV_9d: {
        'driver': 'https://download.lenovo.com/pccbbs/mobiles/nz3gf07w.exe',
        'referral': 'https://download.lenovo.com/pccbbs/mobiles/nz3gf07w.exe',
        'sha512': 'a4a4e6058b1ea8ab721953d2cfd775a1e7bc589863d160e5ebbb90344858f147d695103677a8df0b2de0c95345df108bda97196245b067f45630038fb7c807cd'
    },
    SupportedDevices.DEV_92: {  # Use Lenovo firmware as fallback since HP archives don't extract
        'driver': 'https://download.lenovo.com/pccbbs/mobiles/nz3gf07w.exe',
        'referral': 'https://download.lenovo.com/pccbbs/mobiles/nz3gf07w.exe',
        'sha512': 'a4a4e6058b1ea8ab721953d2cfd775a1e7bc589863d160e5ebbb90344858f147d695103677a8df0b2de0c95345df108bda97196245b067f45630038fb7c807cd'
    }
}

# =============================================================================
# FIRMWARE FILENAMES
# =============================================================================
# Purpose: Expected firmware filenames after extraction from driver packages
#
# File Format:
#   - .xpfwext: Validity Sensors firmware extension format
#   - Contains binary firmware image for device flash memory
#   - Extracted from Windows driver package during installation
#
# Naming Convention:
#   - 6_07f: Firmware version identifier
#   - Lenovo/lenovo_mis_qm: Vendor/model identifier
#   - .xpfwext: Firmware file extension
#
# Device Mapping:
#   - DEV_90: '6_07f_Lenovo.xpfwext' (older firmware variant)
#   - DEV_97, DEV_9a, DEV_9d, DEV_92: '6_07f_lenovo_mis_qm.xpfwext' (newer firmware)
#
# Usage:
#   - Used to locate firmware file after driver package extraction
#   - Filename verified before flashing to device
#   - Ensures correct firmware is installed for device model
# =============================================================================
FIRMWARE_NAMES = {
    SupportedDevices.DEV_90: '6_07f_Lenovo.xpfwext',
    SupportedDevices.DEV_97: '6_07f_lenovo_mis_qm.xpfwext',
    SupportedDevices.DEV_9a: '6_07f_lenovo_mis_qm.xpfwext',
    SupportedDevices.DEV_9d: '6_07f_lenovo_mis_qm.xpfwext',
    SupportedDevices.DEV_92: '6_07f_lenovo_mis_qm.xpfwext'  # HP EliteBook uses Lenovo firmware
}
