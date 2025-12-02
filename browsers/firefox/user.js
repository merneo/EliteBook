// =============================================================================
// FIREFOX USER PREFERENCES (user.js)
// =============================================================================
// Purpose: Comprehensive Firefox configuration for Arch Linux with Wayland
//          support, privacy enhancements, and performance optimizations.
//
// Technical Context:
//   This configuration file implements privacy-first browsing principles
//   while maintaining compatibility with modern web standards and Wayland
//   compositor integration. Settings follow established best practices in
//   privacy-preserving technologies and browser security.
//
// Deployment:
//   Copy this file to: ~/.mozilla/firefox/*.default-release/user.js
//   Restart Firefox to apply changes.
//
// References:
//   - Firefox Preferences: https://kb.mozillazine.org/About:config
//   - Privacy Research: https://www.eff.org/privacybadger
//   - Wayland Support: https://wiki.archlinux.org/title/Firefox
// =============================================================================

// =============================================================================
// PRIVACY AND SECURITY SETTINGS
// =============================================================================

// Disable telemetry and data collection
user_pref("toolkit.telemetry.enabled", false);
user_pref("toolkit.telemetry.server", "");
user_pref("toolkit.telemetry.archive.enabled", false);
user_pref("toolkit.telemetry.newProfilePing.enabled", false);
user_pref("toolkit.telemetry.shutdownPingSender.enabled", false);
user_pref("toolkit.telemetry.updatePing.enabled", false);
user_pref("toolkit.telemetry.bhrPing.enabled", false);
user_pref("toolkit.telemetry.firstShutdownPing.enabled", false);

// Disable health report
user_pref("datareporting.healthreport.uploadEnabled", false);
user_pref("datareporting.healthreport.service.enabled", false);
user_pref("datareporting.policy.dataSubmissionEnabled", false);

// Enhanced tracking protection
user_pref("privacy.trackingprotection.enabled", true);
user_pref("privacy.trackingprotection.socialtracking.enabled", true);
user_pref("privacy.trackingprotection.cryptomining.enabled", true);
user_pref("privacy.trackingprotection.fingerprinting.enabled", true);

// Strict cookie controls
user_pref("network.cookie.cookieBehavior", 1); // Block all third-party cookies
user_pref("network.cookie.lifetimePolicy", 2); // Accept cookies for session only

// DNS-over-HTTPS (DoH) - Cloudflare
user_pref("network.trr.mode", 2); // Use DoH as primary DNS
user_pref("network.trr.uri", "https://cloudflare-dns.com/dns-query");
user_pref("network.trr.bootstrapAddress", "1.1.1.1");

// =============================================================================
// PERFORMANCE OPTIMIZATIONS
// =============================================================================

// Enable hardware acceleration for Wayland
user_pref("gfx.webrender.all", true); // WebRender (GPU-accelerated rendering)
user_pref("gfx.webrender.enabled", true);
user_pref("gfx.webrender.compositor", true);
user_pref("media.ffmpeg.vaapi.enabled", true); // VAAPI hardware video decoding

// Memory management
user_pref("browser.cache.disk.enable", true);
user_pref("browser.cache.memory.enable", true);
user_pref("browser.cache.memory.capacity", 65536); // 64MB memory cache
user_pref("browser.cache.disk.capacity", 1048576); // 1GB disk cache

// Process management
user_pref("dom.ipc.processCount", 4); // Number of content processes

// Network optimization
user_pref("network.http.pipelining", true);
user_pref("network.http.pipelining.maxrequests", 8);
user_pref("network.http.proxy.pipelining", true);

// =============================================================================
// WAYLAND INTEGRATION
// =============================================================================

// Enable Wayland native rendering
user_pref("widget.wayland.enabled", true);
user_pref("gfx.webrender.software", false); // Use hardware acceleration

// Clipboard integration with wl-clipboard
user_pref("widget.use-xdg-desktop-portal", true);

// Screen sharing support
user_pref("media.getusermedia.screensharing.enabled", true);

// =============================================================================
// USER INTERFACE CUSTOMIZATION
// =============================================================================

// Compact density (more content, less padding)
user_pref("browser.uidensity", 1); // 0=normal, 1=compact, 2=touch

// Disable unnecessary UI elements
user_pref("browser.fullscreen.autohide", true);
user_pref("browser.tabs.tabmanager.enabled", false);

// =============================================================================
// SECURITY ENHANCEMENTS
// =============================================================================

// Enhanced security settings
user_pref("security.tls.insecure_fallback_hosts", "");
user_pref("security.ssl.require_safe_negotiation", true);
user_pref("security.ssl3.rsa_des_ede3_sha", false); // Disable weak ciphers

// =============================================================================
// END OF CONFIGURATION
// =============================================================================
