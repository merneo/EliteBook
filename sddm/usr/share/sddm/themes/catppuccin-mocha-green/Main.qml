// =============================================================================
// SDDM LOGIN SCREEN - MAIN QML FILE
// =============================================================================
// Author: merneo
// Theme: Catppuccin Mocha Green
// Purpose: Entry point for the SDDM (Simple Desktop Display Manager) login theme.
//          This file orchestrates the visual composition of the login screen,
//          including background rendering, clock display, and login panel placement.
//
// Technical Stack:
//   - Qt Quick 2.15: Declarative UI framework for rendering
//   - SDDM API: Provides session management and authentication hooks
//   - QML Components: Modular UI elements in ./Components/ directory
//
// File Dependencies:
//   - Components/Clock.qml: Time display widget (top-right corner)
//   - Components/LoginPanel.qml: User/password input and session controls
//   - backgrounds/wall.png: Custom background image (when enabled)
//   - theme.conf: Configuration file for customizable settings
//
// Configuration Options (theme.conf):
//   - CustomBackground: "true"/"false" - Use custom wallpaper vs solid color
//   - Background: Path to wallpaper image relative to theme directory
//   - ClockEnabled: "true"/"false" - Show/hide clock widget
//   - LoginBackground: "true"/"false" - Show semi-transparent login panel background
//   - UserIcon: "true"/"false" - Display user avatar icon
//
// Color Scheme (Catppuccin Mocha):
//   - Base (#1E1E2E): Primary background color
//   - Text (#CDD6F4): Primary text color
//   - Green (#A6E3A1): Accent color for interactive elements
//   - Surface0 (#313244): Secondary backgrounds
//   - Crust (#11111B): Darkest background elements
// =============================================================================

import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import "Components"

// =============================================================================
// ROOT ITEM
// =============================================================================
// The root Item spans the entire screen dimensions (Screen.height x Screen.width).
// All child elements are positioned relative to this container.
// Using Item instead of Rectangle to avoid unnecessary rendering overhead.
// =============================================================================

Item {
  id: root
  height: Screen.height
  width: Screen.width

  // ===========================================================================
  // SOLID BACKGROUND LAYER (Z-Index: 0)
  // ===========================================================================
  // Provides a fallback solid color background (#1E1E2E - Catppuccin Base).
  // Always rendered first (z: 0) to ensure no visual gaps if image fails to load.
  // This is the Catppuccin Mocha "Base" color for dark theme consistency.
  // ===========================================================================

  Rectangle {
    id: background
    anchors.fill: parent
    height: parent.height
    width: parent.width
    z: 0
    color: "#1E1E2E"  // Catppuccin Mocha Base color
  }

  // ===========================================================================
  // CUSTOM BACKGROUND IMAGE LAYER (Z-Index: 1)
  // ===========================================================================
  // Conditionally displays a custom wallpaper image when enabled via theme.conf.
  // Uses PreserveAspectCrop to maintain aspect ratio while filling the screen
  // (may crop edges on non-matching aspect ratios).
  //
  // Performance Optimizations:
  //   - asynchronous: false - Blocks until loaded (prevents flash of solid color)
  //   - cache: true - Caches decoded image in GPU memory
  //   - mipmap: true - Generates mipmaps for smooth scaling on different resolutions
  //   - clip: true - Prevents overflow beyond parent bounds
  //
  // Source Path:
  //   Resolved from config.Background in theme.conf (e.g., "backgrounds/wall.png")
  // ===========================================================================

  Image {
    id: backgroundImage
    anchors.fill: parent
    height: parent.height
    width: parent.width
    fillMode: Image.PreserveAspectCrop
    visible: config.CustomBackground == "true" ? true : false
    z: 1
    source: config.Background
    asynchronous: false  // Synchronous load prevents visual flicker
    cache: true          // Cache image in GPU memory for performance
    mipmap: true         // Enable mipmapping for high-quality scaling
    clip: true           // Clip to parent bounds
  }

  // ===========================================================================
  // MAIN INTERACTIVE PANEL (Z-Index: 3)
  // ===========================================================================
  // Container for all interactive UI elements:
  //   - Clock widget (top-right, optional)
  //   - LoginPanel (centered, contains username/password/session controls)
  //
  // The 50px margin provides breathing room from screen edges, preventing
  // UI elements from touching bezels on ultrawide/curved monitors.
  // ===========================================================================

  Item {
    id: mainPanel
    z: 3
    anchors {
      fill: parent
      margins: 50  // 50px padding from all screen edges
    }

    // =========================================================================
    // CLOCK WIDGET
    // =========================================================================
    // Displays current time and date in the top-right corner.
    // Visibility controlled by config.ClockEnabled in theme.conf.
    // Uses Catppuccin Text color (#CDD6F4) for readability on dark background.
    // Clock component defined in Components/Clock.qml.
    // =========================================================================

    Clock {
      id: time
      visible: config.ClockEnabled == "true" ? true : false
    }

    // =========================================================================
    // LOGIN PANEL (USERNAME/PASSWORD/SESSION)
    // =========================================================================
    // The primary authentication interface containing:
    //   - User avatar (optional, from AccountsService)
    //   - Username input field
    //   - Password input field (masked)
    //   - Login button (Catppuccin Green accent)
    //   - Power/Reboot/Sleep buttons (bottom-left)
    //   - Session selector (bottom-right)
    //
    // LoginPanel handles SDDM authentication via sddm.login() API call.
    // Component defined in Components/LoginPanel.qml.
    // =========================================================================

    LoginPanel {
      id: loginPanel
      anchors.fill: parent
    }
  }
}
