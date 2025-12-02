# =============================================================================
# UTILITY FUNCTIONS - Helper Functions for Fingerprint Driver
# =============================================================================
# Author: merneo (based on python-validity project)
# Purpose: Provides utility functions for binary data processing, status
#          validation, and hexadecimal string conversion used throughout
#          the fingerprint driver stack.
#
# Operational Context:
#   These utility functions are used by multiple modules in the python-validity
#   driver stack for common operations like parsing device responses, converting
#   hexadecimal strings to binary data, and validating command status codes.
#
# Functions:
#   - assert_status(): Validates device command response status codes
#   - unhex(): Converts hexadecimal strings to binary data (removes whitespace)
# =============================================================================

import re
from binascii import unhexlify
from struct import unpack

# =============================================================================
# STATUS VALIDATION FUNCTION
# =============================================================================
# Purpose: Validate device command response status codes
#
# Implementation:
#   - Extracts first 2 bytes from response (little-endian unsigned short)
#   - Status code 0 indicates success
#   - Non-zero status codes indicate errors
#
# Error Handling:
#   - 0x44f: Signature validation failed (special error code)
#   - Other codes: Generic failure with error code displayed
#
# Usage:
#   - Called after every device command to ensure operation succeeded
#   - Raises exception if command failed (prevents silent failures)
#   - Provides clear error messages for troubleshooting
#
# Binary Format:
#   - <H: Little-endian unsigned short (2 bytes)
#   - First 2 bytes of response contain status code
#   - Remaining bytes contain response data (if any)
# =============================================================================
def assert_status(b: bytes):
    """
    Validate device command response status code.
    
    Args:
        b: Response bytes from device command
        
    Raises:
        Exception: If status code indicates failure (non-zero)
    """
    s, = unpack('<H', b[:2])  # Extract status code (first 2 bytes, little-endian)
    if s != 0:  # Status code 0 indicates success
        if s == 0x44f:
            raise Exception('Signature validation failed: %04x' % s)  # Special error: signature validation

        raise Exception('Failed: %04x' % s)  # Generic failure with error code

# =============================================================================
# HEXADECIMAL STRING CONVERSION FUNCTION
# =============================================================================
# Purpose: Convert hexadecimal string representation to binary data
#
# Implementation:
#   - Removes all non-word characters (whitespace, newlines, etc.)
#   - Converts cleaned hex string to binary bytes
#   - Handles multi-line hex strings (common in firmware blob definitions)
#
# Usage:
#   - Converts firmware blob hex strings to binary for USB transmission
#   - Processes configuration data stored as hex strings
#   - Used throughout driver for binary data preparation
#
# Example:
#   Input: "06 02 00 00\n01 4a 23 14"
#   Output: b'\x06\x02\x00\x00\x01\x4a\x23\x14'
#
# Why Remove Non-Word Characters:
#   - Hex strings often formatted with spaces/newlines for readability
#   - unhexlify() requires continuous hex string (no whitespace)
#   - Regex removes formatting while preserving hex digits
# =============================================================================
def unhex(x: str):
    """
    Convert hexadecimal string to binary data.
    
    Args:
        x: Hexadecimal string (may contain whitespace/newlines)
        
    Returns:
        bytes: Binary representation of hex string
        
    Example:
        unhex("06 02 00 00") -> b'\x06\x02\x00\x00'
    """
    return unhexlify(re.sub(r'\W', '', x))  # Remove non-word chars, then convert hex to bytes
