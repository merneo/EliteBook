# =============================================================================
# TABLE TYPES - Fingerprint Sensor Type Information and Matching
# =============================================================================
# Author: merneo (based on python-validity project)
# Purpose: Defines data structures and matching algorithms for fingerprint
#          sensor type identification and firmware compatibility checking.
#
# Operational Context:
#   This module provides type information for different fingerprint sensor
#   models, allowing the driver to select appropriate firmware and calibration
#   data based on detected sensor hardware. Critical for device initialization
#   and fingerprint image processing.
#
# Key Components:
#   - SensorTypeInfo: Sensor-specific configuration data
#   - Fuzzy matching: Compatibility checking for firmware versions
#   - Metric calculation: Best-match selection algorithm
#
# Sensor Type Information:
#   - Sensor type ID: Hardware model identifier
#   - Calibration parameters: Image processing settings
#   - Firmware compatibility: Version matching logic
# =============================================================================

import typing
from binascii import hexlify, unhexlify

# =============================================================================
# SENSOR TYPE INFORMATION CLASS
# =============================================================================
# Purpose: Store sensor-specific configuration and calibration data
#
# Class Attributes:
#   - table: List of all known sensor type configurations
#   - Populated from generated_tables module (device-specific data)
#
# Instance Attributes:
#   - sensor_type: Hardware sensor type identifier
#   - bytes_per_line: Image data bytes per scan line
#   - repeat_multiplier: Calibration data repetition factor
#   - lines_per_calibration_data: Number of lines in calibration data
#   - line_width: Width of each scan line
#   - scale_mul/scale_div: Image scaling factors
#   - calibration_blob: Binary calibration data (hex string converted to bytes)
#
# Usage:
#   - get_by_type(): Look up sensor configuration by type ID
#   - Used during device initialization to select correct calibration data
# =============================================================================
class SensorTypeInfo:
    table: typing.List["SensorTypeInfo"] = []

    @classmethod
    def get_by_type(cls, sensor_type: int) -> typing.Optional["SensorTypeInfo"]:
        """
        Look up sensor type information by sensor type ID.
        
        Args:
            sensor_type: Hardware sensor type identifier
            
        Returns:
            SensorTypeInfo instance if found, None otherwise
        """
        # noinspection PyUnresolvedReferences
        from . import generated_tables
        for i in cls.table:
            if i.sensor_type == sensor_type:
                return i

    def __init__(self, sensor_type: int, bytes_per_line: int, repeat_multiplier: int,
                 lines_per_calibration_data: int, line_width: int, scale_mul: int, 
                 scale_div: int, calibration_blob: str):
        """
        Initialize sensor type information.
        
        Args:
            sensor_type: Hardware sensor type identifier
            bytes_per_line: Image data bytes per scan line
            repeat_multiplier: Calibration data repetition factor
            lines_per_calibration_data: Number of lines in calibration data
            line_width: Width of each scan line
            scale_mul: Image scaling multiplier
            scale_div: Image scaling divisor
            calibration_blob: Hexadecimal string of calibration data
        """
        self.sensor_type = sensor_type
        self.repeat_multiplier = repeat_multiplier
        self.lines_per_calibration_data = lines_per_calibration_data
        self.line_width = line_width
        self.bytes_per_line = bytes_per_line
        self.scale_mul = scale_mul
        self.scale_div = scale_div
        self.calibration_blob = unhexlify(calibration_blob)  # Convert hex string to binary

    def __repr__(self):
        """String representation for debugging."""
        calibration_blob = hexlify(self.calibration_blob).decode()
        return 'SensorTypeInfo(sensor_type=0x%04x, bytes_per_line=0x%x, repeat_multiplier=%d, lines_per_calibration_data=%d, line_width=%d, scale_mul=%d, scale_div=%d, calibration_blob=%s)' % (
            self.sensor_type, self.bytes_per_line, self.repeat_multiplier,
            self.lines_per_calibration_data, self.line_width, self.scale_mul, self.scale_div, repr(calibration_blob))

# =============================================================================
# FUZZY MATCHING FUNCTION
# =============================================================================
# Purpose: Calculate compatibility score between expected and actual values
#
# Return Values:
#   - 2: Exact match (best compatibility)
#   - 1: Wildcard match (expected is 0xffff, matches any value)
#   - 0: No match (incompatible)
#
# Usage:
#   - Used in metric calculation for firmware version matching
#   - Allows flexible matching (exact or wildcard)
#   - Enables firmware compatibility across minor version differences
# =============================================================================
def fuzzy(expected, actual):
    """
    Calculate fuzzy match score between expected and actual values.
    
    Args:
        expected: Expected value (0xffff = wildcard)
        actual: Actual value from device
        
    Returns:
        2 if exact match, 1 if wildcard match, 0 if no match
    """
    if expected == actual:
        return 2  # Exact match (best)
    elif expected == 0xffff:
        return 1  # Wildcard match (acceptable)
    else:
        return 0  # No match (incompatible)

# =============================================================================
# METRIC CALCULATION FUNCTION
# =============================================================================
# Purpose: Calculate compatibility metric for firmware version matching
#
# Implementation:
#   - Compares major, minor, and build version numbers
#   - Uses fuzzy matching for each component
#   - Combines scores into single metric value
#   - Higher metric = better compatibility match
#
# Metric Calculation:
#   - Each component (major, minor, build) contributes 2 bits
#   - Metric = (major_score << 4) | (minor_score << 2) | build_score
#   - Maximum metric: 0b111111 = 63 (all exact matches)
#   - Minimum metric: 0b000000 = 0 (no matches)
#
# Usage:
#   - Used to select best-matching firmware from available options
#   - Higher metric indicates better compatibility
#   - Enables automatic firmware selection based on device version
# =============================================================================
def metric(i, rominfo):
    """
    Calculate compatibility metric between firmware info and device ROM info.
    
    Args:
        i: SensorTypeInfo or SensorCaptureProg instance
        rominfo: Device ROM information (from device)
        
    Returns:
        Compatibility metric (0-63, higher = better match)
    """
    metric = 0
    metric |= fuzzy(i.major, rominfo.major)      # Major version match (2 bits)
    metric <<= 2                                # Shift left for next component
    metric |= fuzzy(i.minor, rominfo.minor)      # Minor version match (2 bits)
    metric <<= 2                                # Shift left for next component
    metric |= fuzzy(i.build, rominfo.build)      # Build version match (2 bits)
    metric <<= 2
    metric |= fuzzy(i.u1, rominfo.u1)

    return metric


class SensorCaptureProg:
    table: typing.List["SensorCaptureProg"] = []

    @classmethod
    def get(cls, rominfo, sensor_type: int, a0: int, a1: int):
        # noinspection PyUnresolvedReferences
        from . import generated_tables

        maximum = 0
        found = None
        for i in SensorCaptureProg.table:
            if i.major != 0xffff and i.major != rominfo.major:
                continue

            if i.dev_type != 0xffff and i.dev_type != sensor_type:
                continue

            if i.a0 != 0xffff and i.a0 != a0:
                continue

            if i.a1 != 0xffff and i.a1 != a1:
                continue

            m = metric(i, rominfo)

            if m > maximum:
                found = i
                maximum = m

        if found is not None:
            return b''.join(found.blobs)

    def __init__(self, major: int, minor: int, build: int, u1: int, dev_type: int, a0: int, a1: int,
                 blobs: typing.Sequence[str]):
        self.major = major
        self.minor = minor
        self.build = build
        self.u1 = u1
        self.dev_type = dev_type
        self.a0 = a0
        self.a1 = a1
        self.blobs = [unhexlify(b) for b in blobs]

    def __repr__(self):
        blobs = [hexlify(b).decode() for b in self.blobs]

        return 'SensorCaptureProg(major=0x%x, minor=0x%x, build=0x%x, u1=0x%x, dev_type=0x%x, a0=0x%x, a1=0x%x, blobs=%s)' % (
            self.major, self.minor, self.build, self.u1, self.dev_type, self.a0, self.a1,
            repr(blobs))
