# =============================================================================
# FIRMWARE BLOB LOADER - Dynamic Device-Specific Blob Loading
# =============================================================================
# Author: merneo (based on python-validity project)
# Purpose: Dynamically loads device-specific firmware initialization blobs
#          based on detected USB device vendor/product IDs.
#
# Operational Context:
#   Different Validity Sensors device models require different initialization
#   sequences. This module provides a unified interface for loading the
#   correct blob data based on the connected device, enabling a single
#   codebase to support multiple device models.
#
# Device Detection:
#   - USB vendor ID 0x138a: Validity Sensors devices
#   - USB product IDs: 0090, 0092, 0097, 009d (different models)
#   - USB vendor ID 0x06cb: Synaptics devices (alternative vendor)
#   - USB product ID 009a: Synaptics device model
#
# Blob Types:
#   - init_hardcoded: Standard initialization (firmware already loaded)
#   - init_hardcoded_clean_slate: Clean slate initialization (no firmware)
#   - reset_blob: Device reset command
#   - db_write_enable: Database write enable command
#
# Lazy Loading:
#   - Blobs loaded on-demand (only when needed)
#   - Reduces memory usage (not all blobs loaded at once)
#   - Enables device-specific blob selection at runtime
# =============================================================================

# =============================================================================
# BLOB LOADER FUNCTION
# =============================================================================
# Purpose: Load device-specific firmware blob based on USB device IDs
#
# Implementation:
#   1. Detects USB device vendor/product IDs
#   2. Imports appropriate blob module (blobs_90, blobs_92, etc.)
#   3. Retrieves requested blob from module
#   4. Caches blob in globals() for subsequent access
#
# Device-Specific Modules:
#   - blobs_90: Product ID 0090 initialization blobs
#   - blobs_92: Product ID 0092 initialization blobs (HP EliteBook)
#   - blobs_97: Product ID 0097 initialization blobs
#   - blobs_9d: Product ID 009d initialization blobs
#   - blobs_9a: Product ID 009a initialization blobs (Synaptics)
#
# Return Value:
#   - bytes: Binary blob data ready for USB transmission
#   - Cached in globals() for performance (subsequent calls return cached value)
#
# Error Handling:
#   - Raises AttributeError if blob not found in module
#   - Raises ImportError if device-specific module not available
# =============================================================================
def __load_blob(blob: str) -> bytes:
    """
    Load device-specific firmware blob based on USB device IDs.
    
    Args:
        blob: Blob name to load (e.g., 'init_hardcoded', 'reset_blob')
        
    Returns:
        bytes: Binary blob data for USB transmission
        
    Raises:
        AttributeError: If blob not found in device-specific module
        ImportError: If device-specific module not available
    """
    from .usb import usb

    # Detect device and import appropriate blob module
    if usb.usb_dev().idVendor == 0x138a:  # Validity Sensors vendor ID
        if usb.usb_dev().idProduct == 0x0090:
            from . import blobs_90 as blobs
        elif usb.usb_dev().idProduct == 0x0092:  # HP EliteBook x360 1030 G2
            from . import blobs_92 as blobs
        elif usb.usb_dev().idProduct == 0x0097:
            from . import blobs_97 as blobs
        elif usb.usb_dev().idProduct == 0x009d:
            from . import blobs_9d as blobs
    elif usb.usb_dev().idVendor == 0x06cb:  # Synaptics vendor ID
        if usb.usb_dev().idProduct == 0x009a:
            from . import blobs_9a as blobs

    # Cache blob in globals() and return
    globals()[blob] = getattr(blobs, blob)
    return globals()[blob]

# =============================================================================
# BLOB ACCESS FUNCTIONS (Lambda Wrappers)
# =============================================================================
# Purpose: Provide convenient access to device-specific blobs
#
# Implementation:
#   - Lambda functions call __load_blob() with specific blob name
#   - Lazy loading: Blob loaded only when function is called
#   - Caching: Subsequent calls return cached blob (no re-loading)
#
# Available Blobs:
#   - init_hardcoded: Standard device initialization (firmware present)
#   - init_hardcoded_clean_slate: Clean slate initialization (no firmware)
#   - reset_blob: Device reset command (recovery/restart)
#   - db_write_enable: Enable fingerprint template database writes
#
# Usage:
#   - Called during device initialization sequence
#   - Device-specific blob automatically selected based on USB IDs
#   - No manual device model selection required
# =============================================================================
init_hardcoded = lambda: __load_blob('init_hardcoded')
init_hardcoded_clean_slate = lambda: __load_blob('init_hardcoded_clean_slate')
reset_blob = lambda: __load_blob('reset_blob')
db_write_enable = lambda: __load_blob('db_write_enable')
