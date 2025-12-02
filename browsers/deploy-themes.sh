#!/bin/bash
# Browser Theme Deployment Script
# Deploys Catppuccin Mocha Green themes to Firefox and Brave

set -e

echo "🎨 Deploying browser themes..."

# Firefox deployment
FIREFOX_PROFILE=$(find ~/.mozilla/firefox -maxdepth 1 -type d \( -name "*.default*" -o -name "*.default-release*" \) 2>/dev/null | head -1)

if [ -n "$FIREFOX_PROFILE" ]; then
    echo "✅ Firefox profile found: $FIREFOX_PROFILE"
    mkdir -p "$FIREFOX_PROFILE/chrome"
    cp "$(dirname "$0")/firefox/"*.css "$FIREFOX_PROFILE/chrome/"
    cp "$(dirname "$0")/firefox/user.js" "$FIREFOX_PROFILE/"
    echo "✅ Firefox theme files deployed"
    echo ""
    echo "⚠️  IMPORTANT: Enable userChrome.css in Firefox:"
    echo "   1. Open Firefox"
    echo "   2. Navigate to: about:config"
    echo "   3. Search: toolkit.legacyUserProfileCustomizations.stylesheets"
    echo "   4. Set to: true"
    echo "   5. Restart Firefox"
else
    echo "⚠️  Firefox profile not found. Start Firefox at least once."
fi

# Brave deployment
echo ""
echo "✅ Brave theme extension created at: ~/.local/share/brave-theme"
echo ""
echo "To install Brave theme:"
echo "   1. Open Brave"
echo "   2. Navigate to: brave://extensions/"
echo "   3. Enable 'Developer mode' (toggle in top-right)"
echo "   4. Click 'Load unpacked'"
echo "   5. Select: ~/.local/share/brave-theme"
echo ""

echo "🎨 Theme deployment complete!"
