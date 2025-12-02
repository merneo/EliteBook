// =============================================================================
// SDDM LOGIN PANEL COMPONENT
// =============================================================================
// Author: merneo
// Theme: Catppuccin Mocha Green
// Purpose: Main authentication interface for SDDM login screen, containing:
//          - User avatar display (optional)
//          - Username input field
//          - Password input field (masked)
//          - Login button with Catppuccin Green accent
//          - Power/Reboot/Sleep controls (bottom-left)
//          - Session selector dropdown (bottom-right)
//
// This component handles the SDDM authentication flow via sddm.login() API.
// On successful authentication, SDDM starts the selected session (Hyprland, etc.)
//
// Color Scheme (Catppuccin Mocha):
//   - Base (#1E1E2E): Background color
//   - Mantle (#181825): Login panel background (darker)
//   - Crust (#11111B): Button text color (darkest)
//   - Text (#CDD6F4): Primary text color
//   - Subtext0 (#A6ADC8): Hover/pressed state color
//   - Green (#A6E3A1): Primary accent (login button, active states)
// =============================================================================

import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import "../assets"

Item {
  // ===========================================================================
  // EXPORTED PROPERTIES
  // ===========================================================================
  // These properties are accessible from parent components (Main.qml).
  // They provide the current authentication state for the login process.
  // ===========================================================================

  property var user: userField.text       // Current username from input field
  property var password: passwordField.text // Current password from input field
  property var session: sessionPanel.session // Selected session (e.g., Hyprland)

  // ===========================================================================
  // RESPONSIVE SIZING
  // ===========================================================================
  // Input dimensions are calculated relative to screen size for responsive layout.
  // This ensures the login form looks proportional on different display sizes:
  //   - 1080p: Standard comfortable size
  //   - 1440p/4K: Scales up appropriately
  //   - 768p: Scales down for smaller displays
  // ===========================================================================

  property var inputHeight: Screen.height * 0.032  // ~35px on 1080p
  property var inputWidth: Screen.width * 0.16    // ~307px on 1920px wide

  // ===========================================================================
  // LOGIN PANEL BACKGROUND (OPTIONAL)
  // ===========================================================================
  // Semi-transparent dark rectangle behind the login form.
  // Visibility controlled by config.LoginBackground in theme.conf.
  // Improves readability on busy or bright wallpaper images.
  //
  // Height calculation:
  //   - With UserIcon: inputHeight * 11.2 (accommodates avatar + inputs)
  //   - Without UserIcon: inputHeight * 5.3 (compact mode, inputs only)
  // ===========================================================================

  Rectangle {
    id: loginBackground
    anchors {
      verticalCenter: parent.verticalCenter
      horizontalCenter: parent.horizontalCenter
    }
    height: inputHeight * ( config.UserIcon == "true" ? 11.2 : 5.3 )
    width: inputWidth * 1.2
    radius: 5                              // Subtle rounded corners
    visible: config.LoginBackground == "true" ? true : false
    color: "#181825"                       // Catppuccin Mantle (darker than Base)
  }

  // ===========================================================================
  // POWER CONTROLS (BOTTOM-LEFT)
  // ===========================================================================
  // System power management buttons arranged vertically.
  // Each button calls SDDM's respective power API:
  //   - PowerButton: sddm.powerOff() - Shutdown system
  //   - RebootButton: sddm.reboot() - Restart system
  //   - SleepButton: sddm.suspend() - Suspend to RAM
  //
  // Z-index 5 ensures buttons appear above background elements.
  // ===========================================================================

  Column {
    spacing: 8                             // 8px gap between buttons
    anchors {
      bottom: parent.bottom
      left: parent.left
    }
    PowerButton {
      id: powerButton
    }
    RebootButton {
      id: rebootButton
    }
    SleepButton {
      id: sleepButton
    }
    z: 5                                   // Above background layers
  }

  // ===========================================================================
  // SESSION SELECTOR (BOTTOM-RIGHT)
  // ===========================================================================
  // Dropdown menu for selecting the desktop session to launch after login.
  // SDDM automatically detects installed sessions from:
  //   - /usr/share/xsessions/ (X11 sessions)
  //   - /usr/share/wayland-sessions/ (Wayland sessions)
  //
  // Default: Last used session (or first available if no history)
  // This system typically shows: Hyprland, GNOME, KDE Plasma, etc.
  // ===========================================================================

  Column {
    spacing: 8
    anchors {
      bottom: parent.bottom
      right: parent.right
    }
    SessionPanel {
      id: sessionPanel
    }
    z: 5
  }

  // ===========================================================================
  // MAIN LOGIN FORM (CENTER)
  // ===========================================================================
  // Vertically stacked login interface containing:
  //   1. User avatar (optional, from AccountsService)
  //   2. Username input field
  //   3. Password input field (masked)
  //   4. Login button
  //
  // Layout is centered both horizontally and vertically on screen.
  // ===========================================================================

  Column {
    spacing: 8
    z: 5
    width: inputWidth
    anchors {
      verticalCenter: parent.verticalCenter
      horizontalCenter: parent.horizontalCenter
    }

    // =========================================================================
    // USER AVATAR DISPLAY (OPTIONAL)
    // =========================================================================
    // Displays user's profile picture when config.UserIcon is "true".
    // Image loading priority:
    //   1. AccountsService icon: /var/lib/AccountsService/icons/<username>
    //   2. Default icon: assets/defaultIcon.png
    //
    // Decorative layers:
    //   - mask.svg / maskDark.svg: Circular crop mask
    //   - ring.svg: Decorative ring around avatar
    //
    // Mask variant selection:
    //   - maskDark.svg: Used when LoginBackground is enabled (dark panel bg)
    //   - mask.svg: Used when LoginBackground is disabled (wallpaper visible)
    // =========================================================================

    Rectangle {
      visible: config.UserIcon == "true" ? true : false
      width: inputHeight * 5.7 ; height: inputHeight * 5.7
      color: "transparent"

      // Default avatar (fallback if no AccountsService icon)
      Image {
        source: Qt.resolvedUrl("../assets/defaultIcon.png")
        height: parent.width
        width: parent.width
      }

      // AccountsService user icon (standard path for KDE/GNOME)
      Image {
        // Common icon path for KDE and GNOME AccountsService
        source: Qt.resolvedUrl("/var/lib/AccountsService/icons/" + user)
        height: parent.width
        width: parent.width
      }

      // Circular mask overlay (crops avatar to circle)
      Image {
        source: Qt.resolvedUrl(config.LoginBackground == "true" ? "../assets/maskDark.svg" : "../assets/mask.svg")
        height: parent.width
        width: parent.width
      }

      // Decorative ring around avatar
      Image {
        source: Qt.resolvedUrl("../assets/ring.svg")
        height: parent.width
        width: parent.width
      }

      anchors {
        horizontalCenter: parent.horizontalCenter
      }
    }

    // =========================================================================
    // USERNAME INPUT FIELD
    // =========================================================================
    // Text input for username. Defaults to last logged-in user (SDDM history).
    // Component defined in Components/UserField.qml.
    //
    // Howdy Integration:
    //   - When user enters username and presses Enter, automatically attempt
    //     authentication with empty password to trigger Howdy face recognition
    //   - If Howdy succeeds, user is logged in automatically
    //   - If Howdy fails, password field is focused for manual password entry
    // =========================================================================

    UserField {
      id: userField
      height: inputHeight
      width: parent.width
      onAccepted: {
        // Stop auto-auth timer when user manually triggers authentication
        autoAuthTimer.stop()
        
        // Automatically attempt authentication with empty password
        // This triggers PAM authentication, which will try Howdy first
        // If Howdy succeeds, login completes; if it fails, password field is focused
        if (user != "") {
          sddm.login(user, "", session)
        }
      }
      onUserStartedTyping: {
        // Stop auto-auth timer when user starts typing
        autoAuthTimer.stop()
      }
    }

    // =========================================================================
    // PASSWORD INPUT FIELD
    // =========================================================================
    // Masked text input for password (echoMode: Password).
    // Pressing Enter triggers login via onAccepted signal.
    // Component defined in Components/PasswordField.qml.
    // =========================================================================

    PasswordField {
      id: passwordField
      height: inputHeight
      width: parent.width
      onAccepted: loginButton.clicked()   // Enter key triggers login
    }

    // =========================================================================
    // LOGIN BUTTON
    // =========================================================================
    // Primary action button that initiates SDDM authentication.
    // Button is enabled when username is entered (password optional for Howdy).
    //
    // Visual States:
    //   - Default (enabled): Green background (#A6E3A1), dark text (#11111B)
    //   - Hovered: Lighter gray background (#A6ADC8)
    //   - Pressed: Same as hovered (feedback on click)
    //   - Disabled: Grayed out (when user empty)
    //
    // On click: Calls sddm.login(user, password, session) API.
    // SDDM handles authentication and session startup.
    // Howdy Integration: Button works with empty password to trigger face recognition.
    // =========================================================================

    Button {
      id: loginButton
      height: inputHeight
      width: parent.width
      enabled: user != "" ? true : false  // Only require username (password optional for Howdy)
      hoverEnabled: true

      // Button text content
      contentItem: Text {
        id: buttonText
        renderType: Text.NativeRendering
        font {
          family: config.Font
          pointSize: config.FontSize
          bold: true
        }
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color: "#11111B"                   // Catppuccin Crust (darkest, for contrast)
        text: "Login"
      }

      // Button background styling
      background: Rectangle {
        id: buttonBackground
        color: "#A6E3A1"                   // Catppuccin Green (primary accent)
        radius: 3                          // Subtle rounded corners
      }

      // Visual state transitions
      states: [
        State {
          name: "pressed"
          when: loginButton.down
          PropertyChanges {
            target: buttonBackground
            color: "#A6ADC8"               // Catppuccin Subtext0 (pressed feedback)
          }
          PropertyChanges {
            target: buttonText
          }
        },
        State {
          name: "hovered"
          when: loginButton.hovered
          PropertyChanges {
            target: buttonBackground
            color: "#A6ADC8"               // Catppuccin Subtext0 (hover feedback)
          }
          PropertyChanges {
            target: buttonText
          }
        },
        State {
          name: "enabled"
          when: loginButton.enabled
          PropertyChanges {
            target: buttonBackground
          }
          PropertyChanges {
            target: buttonText
          }
        }
      ]

      // Smooth color transition animation
      transitions: Transition {
        PropertyAnimation {
          properties: "color"
          duration: 300                    // 300ms transition duration
        }
      }

      // Authentication handler
      onClicked: {
        sddm.login(user, password, session)  // SDDM authentication API call
      }
    }
  }

  // ===========================================================================
  // AUTO-ACTIVATION: Camera and Fingerprint
  // ===========================================================================
  // Automatically activate camera (Howdy) and fingerprint when login screen loads.
  // This triggers PAM authentication with empty password, which activates:
  //   1. Howdy face recognition (IR camera)
  //   2. Fingerprint sensor (if face recognition fails)
  //   3. Password prompt (if both biometric methods fail)
  //
  // Timer provides a small delay (1 second) to ensure UI is fully loaded
  // before attempting authentication.
  // ===========================================================================

  Timer {
    id: autoAuthTimer
    interval: 1000  // 1 second delay after component loads
    running: false
    onTriggered: {
      // Get last user from SDDM user model
      var lastUser = userModel.lastUser
      if (lastUser != "") {
        // Automatically trigger authentication with empty password
        // This activates Howdy (camera) and fingerprint via PAM
        sddm.login(lastUser, "", session)
      }
    }
  }

  // ===========================================================================
  // COMPONENT INITIALIZATION
  // ===========================================================================
  // When LoginPanel loads, automatically start authentication timer.
  // This ensures camera and fingerprint activate immediately when login
  // screen appears, without requiring user interaction.
  // ===========================================================================

  Component.onCompleted: {
    // Start auto-authentication timer
    autoAuthTimer.start()
  }

  // ===========================================================================
  // SDDM SIGNAL HANDLERS
  // ===========================================================================
  // Connections to SDDM daemon signals for handling authentication results.
  // ===========================================================================

  Connections {
    target: sddm

    // =========================================================================
    // LOGIN FAILURE HANDLER
    // =========================================================================
    // Called when authentication fails (wrong password, user not found, etc.)
    // Clears password field and refocuses for retry.
    // User is NOT notified visually (security: don't reveal valid usernames).
    // =========================================================================

    function onLoginFailed() {
      // Stop auto-auth timer to prevent repeated attempts
      autoAuthTimer.stop()
      
      // If password was empty (Howdy/fingerprint attempt), focus password field for manual entry
      // If password was provided, clear it and refocus for retry
      if (password == "") {
        passwordField.focus = true         // Focus password field after biometric failure
      } else {
        passwordField.text = ""            // Clear password field
        passwordField.focus = true         // Refocus for retry
      }
    }

    // =========================================================================
    // LOGIN SUCCESS HANDLER
    // =========================================================================
    // Called when authentication succeeds. Stop auto-auth timer.
    // =========================================================================

    function onLoginSucceeded() {
      autoAuthTimer.stop()
    }
  }
}
