import SwiftUI

// MARK: - Notification Names for Settings Window

extension Notification.Name {
    /// Posted when Settings window should be opened
    static let openSettingsRequest = Notification.Name("LotusKey.openSettingsRequest")
    /// Posted when Settings window is closed
    static let settingsWindowClosed = Notification.Name("LotusKey.settingsWindowClosed")
}

// MARK: - Hidden Window for Settings Access

/// A hidden utility window that provides SwiftUI environment context for opening Settings.
/// Required because menu bar apps (accessory apps) don't have the window infrastructure
/// that SwiftUI's Settings scene expects.
///
/// Reference: https://steipete.me/posts/2025/showing-settings-from-macos-menu-bar-items
private struct SettingsOpenerView: View {
    @Environment(\.openSettings) private var openSettings

    var body: some View {
        Color.clear
            .onAppear {
                // Hide this utility window immediately after it appears
                hideOpenerWindow()
            }
            .onReceive(NotificationCenter.default.publisher(for: .openSettingsRequest)) { _ in
                Task { @MainActor in
                    // Switch to regular activation policy to allow window focus
                    NSApp.setActivationPolicy(.regular)

                    // Small delay to let the policy change take effect
                    try? await Task.sleep(for: .milliseconds(50))

                    // Activate the app
                    NSApp.activate(ignoringOtherApps: true)

                    // Open settings using SwiftUI environment action
                    openSettings()

                    // Ensure settings window comes to front
                    try? await Task.sleep(for: .milliseconds(100))
                    bringSettingsWindowToFront()
                }
            }
    }

    private func hideOpenerWindow() {
        // Find and hide the opener window
        DispatchQueue.main.async {
            for window in NSApp.windows {
                if
                    window.identifier?.rawValue == "SettingsOpener" ||
                    window.title == "SettingsOpener"
                {
                    window.orderOut(nil)
                    return
                }
            }
        }
    }

    private func bringSettingsWindowToFront() {
        // Find and focus the Settings window
        for window in NSApp.windows {
            // Skip our opener window
            if window.identifier?.rawValue == "SettingsOpener" { continue }

            // Check for SwiftUI Settings window identifier
            if
                window.identifier?.rawValue.contains("Settings") == true ||
                window.title.lowercased().contains("settings") ||
                window.title.lowercased().contains("preferences")
            {
                window.makeKeyAndOrderFront(nil)
                window.orderFrontRegardless()
                return
            }
        }
    }
}

// MARK: - Main App

@main
struct LotusKeyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // Hidden utility window for Settings access - MUST come before Settings scene
        // This provides the SwiftUI environment context needed for @Environment(\.openSettings)
        // The window is hidden immediately in onAppear
        Window("SettingsOpener", id: "SettingsOpener") {
            SettingsOpenerView()
                .frame(width: 100, height: 100)
        }
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
        .defaultPosition(.center)

        // Settings window (opened via notification from menu)
        Settings {
            SettingsView()
                .onDisappear {
                    // Notify that settings closed so we can restore accessory mode
                    NotificationCenter.default.post(name: .settingsWindowClosed, object: nil)
                }
        }
    }
}
