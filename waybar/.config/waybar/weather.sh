#!/bin/bash

# =============================================================================
# WAYBAR WEATHER SCRIPT - Weather Data Fetcher and Formatter
# =============================================================================
# Author: merneo
# Purpose: Fetches current weather data from wttr.in API and formats it as JSON
#          for display in Waybar status bar, providing at-a-glance weather
#          information for server administrators.
#
# Operational Context:
#   This script is executed by Waybar's custom/weather module every 5 minutes
#   (restart-interval: 300). It provides real-time weather information without
#   requiring browser access or manual weather checking.
#
# Data Source:
#   - API: wttr.in (free, no API key required)
#   - Format: JSON (format=j1 parameter)
#   - Location: Auto-detected based on IP address
#   - Update frequency: Every 5 minutes (configured in Waybar)
#
# Output Format:
#   - JSON object with "text" and "tooltip" fields
#   - Text: Icon + temperature (e.g., "☀️ 22°C")
#   - Tooltip: Detailed information (city, description, humidity)
#
# Caching Strategy:
#   - Cache file: ~/.cache/waybar_weather.json
#   - Cache validity: 1 hour (3600 seconds)
#   - Fallback: Uses cached data if API unavailable
#   - Prevents Waybar from hanging on network failures
#
# Dependencies:
#   - curl: HTTP client for API requests
#   - jq: JSON parser for data extraction
#   - stat: File modification time checking (for cache validation)
# =============================================================================

# =============================================================================
# CONFIGURATION VARIABLES
# =============================================================================
# Purpose: Define caching and API interaction parameters
#
# CACHE_FILE: Location of cached weather data
#   - Path: ~/.cache/waybar_weather.json (XDG cache directory)
#   - Format: JSON (matches script output format)
#   - Purpose: Offline fallback and rate limiting protection
#
# CACHE_MAX_AGE: Maximum age of cached data before refresh required
#   - Value: 3600 seconds (1 hour)
#   - Rationale: Weather doesn't change rapidly, 1 hour is acceptable
#   - Balance: Freshness vs. API rate limiting and network usage
#
# Why Caching:
#   - Network resilience: Works offline or during network outages
#   - Rate limiting: Reduces API requests (wttr.in is free but has limits)
#   - Performance: Faster response (no network delay for cached data)
# =============================================================================
# Cache file location
CACHE_FILE="$HOME/.cache/waybar_weather.json"
CACHE_MAX_AGE=3600  # Cache valid for 1 hour (in seconds)

# =============================================================================
# DEPENDENCY VALIDATION
# =============================================================================
# Purpose: Ensure jq JSON parser is available before attempting data processing
#
# Validation:
#   - Checks if jq command exists (command -v)
#   - Provides error JSON output if jq missing
#   - Exits with status 0 (doesn't fail Waybar module)
#
# Error Output Format:
#   - JSON object: {"text": "Err: jq", "tooltip": "jq is missing. Please install it."}
#   - Waybar displays error message in status bar
#   - User can identify missing dependency
#
# Why Check Early:
#   - Prevents script failure during JSON parsing
#   - Provides clear error message to user
#   - Helps users understand installation requirements
# =============================================================================
# 1. Check for jq dependency
if ! command -v jq &> /dev/null; then
    echo '{"text": "Err: jq", "tooltip": "jq is missing. Please install it."}'
    exit 0
fi

# =============================================================================
# WEATHER DATA FETCHING
# =============================================================================
# Purpose: Retrieve current weather data from wttr.in API
#
# Implementation:
#   - curl: HTTP client for API request
#   - --max-time 15: Timeout after 15 seconds (prevents Waybar hanging)
#   - -s: Silent mode (suppresses progress output)
#   - URL: "https://wttr.in/?format=j1" (JSON format, auto-detect location)
#
# API Details:
#   - wttr.in: Free weather service, no API key required
#   - format=j1: Requests JSON output format
#   - Auto-location: Detects location based on IP address
#   - Alternative: Can specify location (e.g., "?Prague&format=j1")
#
# Timeout Rationale:
#   - 15 seconds: Sufficient for normal network conditions
#   - Prevents Waybar from hanging indefinitely
#   - Falls back to cache if timeout exceeded
#
# Error Handling:
#   - Exit code checked: $? contains curl exit status
#   - Empty data check: Verifies response is not empty
#   - Falls back to cache if fetch fails
# =============================================================================
# 2. Fetch weather data
# -s: Silent mode
# --max-time 15: Timeout after 15 seconds to prevent Waybar hanging
# format=j1: Request JSON output
# URL ends with /?format=j1 to auto-detect location based on IP
weather_data=$(curl --max-time 15 -s "https://wttr.in/?format=j1")

# =============================================================================
# CONNECTION ERROR HANDLING & CACHE FALLBACK
# =============================================================================
# Purpose: Handle network failures gracefully using cached data
#
# Error Conditions:
#   - curl exit code non-zero: Network failure, DNS error, timeout
#   - Empty weather_data: API returned no data
#
# Cache Validation:
#   - Checks if cache file exists
#   - Calculates cache age: Current time - file modification time
#   - Validates cache is within MAX_AGE limit
#   - Uses cache if valid, otherwise shows offline message
#
# Cache Age Calculation:
#   - date +%s: Current Unix timestamp (seconds since epoch)
#   - stat -c %Y: File modification time as Unix timestamp
#   - Difference: Age in seconds
#   - Comparison: Age < CACHE_MAX_AGE (3600 seconds)
#
# Fallback Behavior:
#   - Valid cache: Returns cached data (seamless user experience)
#   - Invalid/missing cache: Shows "Offline" message (informs user of issue)
#
# Why This Approach:
#   - Network resilience: Works during internet outages
#   - User experience: No error spam in status bar
#   - Informative: "Offline" message indicates network issue
# =============================================================================
# 3. Handle connection errors - use cache if available
if [ $? -ne 0 ] || [ -z "$weather_data" ]; then
    # Check if cache exists and is recent enough
    if [ -f "$CACHE_FILE" ]; then
        cache_age=$(($(date +%s) - $(stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0)))
        if [ $cache_age -lt $CACHE_MAX_AGE ]; then
            # Use cached data
            cat "$CACHE_FILE"
            exit 0
        fi
    fi
    # No valid cache available
    echo '{"text": "Offline", "tooltip": "Cannot reach wttr.in. Check internet connection."}'
    exit 0
fi

# =============================================================================
# JSON DATA PARSING
# =============================================================================
# Purpose: Extract relevant weather information from API JSON response
#
# Data Extracted:
#   - temp: Current temperature in Celsius
#   - desc: Weather description (e.g., "Sunny", "Partly cloudy")
#   - humidity: Relative humidity percentage
#   - city: Location name (auto-detected or specified)
#   - weather_code: WMO weather code (used for icon selection)
#
# JSON Path Extraction:
#   - jq -r: Raw output (no JSON quotes)
#   - Path syntax: .current_condition[0].temp_C (nested object access)
#   - Array access: [0] selects first element
#   - Fallback operator: // "Unknown Loc" (default if value missing)
#
# Error Suppression:
#   - 2>/dev/null: Suppresses jq error messages
#   - Prevents Waybar from displaying parse errors
#   - Validation step checks for null/empty values
# =============================================================================
# 4. Parse JSON Data
temp=$(echo "$weather_data" | jq -r '.current_condition[0].temp_C' 2>/dev/null)
desc=$(echo "$weather_data" | jq -r '.current_condition[0].weatherDesc[0].value' 2>/dev/null)
humidity=$(echo "$weather_data" | jq -r '.current_condition[0].humidity' 2>/dev/null)
# Try to get city name, fallback to "Unknown" if missing
city=$(echo "$weather_data" | jq -r '.nearest_area[0].areaName[0].value // "Unknown Loc"' 2>/dev/null)
weather_code=$(echo "$weather_data" | jq -r '.current_condition[0].weatherCode' 2>/dev/null)

# =============================================================================
# DATA VALIDATION
# =============================================================================
# Purpose: Verify API returned valid weather data before processing
#
# Validation Checks:
#   - Temperature not empty: Ensures temp_C field exists
#   - Temperature not null: Ensures temp_C has valid value
#   - Other fields may be null/empty (handled gracefully)
#
# Error Output:
#   - JSON error message: {"text": "API Error", "tooltip": "..."}
#   - Waybar displays error in status bar
#   - User can identify API issues
#
# Why Validate:
#   - Prevents displaying invalid data (e.g., "null°C")
#   - Handles API response format changes gracefully
#   - Provides clear error indication to users
# =============================================================================
# 5. Validate Data
if [ -z "$temp" ] || [ "$temp" = "null" ]; then
    echo '{"text": "API Error", "tooltip": "Received invalid JSON from wttr.in"}'
    exit 0
fi

# =============================================================================
# WEATHER ICON MAPPING (WMO Weather Codes)
# =============================================================================
# Purpose: Map WMO (World Meteorological Organization) weather codes to
#          Unicode emoji icons for visual weather representation
#
# WMO Code System:
#   - Standardized weather condition codes (0-999 range)
#   - Used by meteorological services worldwide
#   - wttr.in returns WMO codes in weatherCode field
#
# Icon Mapping Logic:
#   - case statement: Matches weather_code against known code ranges
#   - Multiple codes per icon: Groups similar weather conditions
#   - Fallback: Default icon (🌤️) for unmapped codes
#
# Icon Categories:
#   - 113: Clear sky (☀️)
#   - 116-122: Partly cloudy (⛅)
#   - 143-150: Overcast (☁️)
#   - 248-260: Fog/mist (🌫️)
#   - 176-299: Rain (🌧️)
#   - 308-338: Snow (❄️)
#   - 350-395: Mixed precipitation (🌨️)
#   - 200-395: Thunderstorms (⛈️)
#
# Why Emoji Icons:
#   - Universal recognition (works across cultures)
#   - No font dependencies (standard Unicode)
#   - Compact display (fits in status bar)
#   - Visual appeal (better than text codes)
# =============================================================================
# 6. Map Icons based on WMO Weather Codes
case "$weather_code" in
    113) icon="☀️" ;;
    116|119|122) icon="⛅" ;;
    143|144|150) icon="☁️" ;;
    248|260) icon="FOG" ;;
    176|179|182|185) icon="🌧️" ;;
    200|227|230|233|263|266|269|272|275|278|281|284|293|296|299) icon="🌧️" ;;
    308|311|314|317|320|323|326|329|332|335|338) icon="❄️" ;;
    179|182|185|227|230|233|350|353|356|359|362|365|368|371|374|377|386|389|392|395) icon="🌨️" ;;
    200|386|389|392|395) icon="⛈️" ;;
    *) icon="🌤️" ;;
esac

# =============================================================================
# JSON OUTPUT GENERATION
# =============================================================================
# Purpose: Format weather data as JSON for Waybar module consumption
#
# Output Structure:
#   - text: Primary display (icon + temperature)
#     Format: "$icon ${temp}°C" (e.g., "☀️ 22°C")
#   - tooltip: Detailed information (shown on hover)
#     Format: Multi-line string with city, description, humidity
#
# JSON Formatting:
#   - Manual JSON construction (no jq needed for output)
#   - Escaped quotes: \" for JSON string delimiters
#   - Newline in tooltip: \n for multi-line tooltip display
#
# Display Strategy:
#   - Text: Minimal (icon + temp) for status bar space efficiency
#   - Tooltip: Detailed (city, description, humidity) for information on demand
#   - Balance: Essential info always visible, details available on hover
# =============================================================================
# 7. Output JSON
# Text: Icon + Temp
# Tooltip: City, Description, Humidity
output="{\"text\": \"$icon ${temp}°C\", \"tooltip\": \"$city\n$desc\nHumidity: ${humidity}%\"}"

# =============================================================================
# CACHE UPDATE
# =============================================================================
# Purpose: Save current weather data to cache for offline fallback
#
# Implementation:
#   - Writes output JSON to cache file
#   - Overwrites previous cache (always stores latest data)
#   - Cache used if API unavailable on next execution
#
# Why Cache After Success:
#   - Ensures cache is always up-to-date when API works
#   - Provides fresh fallback data for network outages
#   - Reduces stale data issues
# =============================================================================
# 8. Save to cache for future use
echo "$output" > "$CACHE_FILE"

# =============================================================================
# OUTPUT DISPLAY
# =============================================================================
# Purpose: Send formatted JSON to Waybar module
#
# Output Destination:
#   - stdout: Waybar reads script output via exec directive
#   - JSON format: Parsed by Waybar's return-type: json configuration
#   - Display: Rendered in status bar according to Waybar config
#
# Why Echo:
#   - Simple output method (no complex formatting needed)
#   - Waybar reads stdout directly
#   - Fast execution (minimal overhead)
# =============================================================================
# 9. Display output
echo "$output"