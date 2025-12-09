import AppKit
import Observation
import SwiftUI

/// View explaining accessibility permission requirements
struct AccessibilityPermissionView: View {
    var viewModel: AccessibilityPermissionViewModel

    var body: some View {
        VStack(spacing: 24) {
            // Header icon
            Image(systemName: "hand.raised.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 64, height: 64)
                .foregroundStyle(.orange)

            // Title
            Text(L("Accessibility Permission Required"))
                .font(.title2)
                .fontWeight(.bold)

            // Description
            VStack(alignment: .leading, spacing: 12) {
                Text(L("LotusKey needs accessibility permissions to:"))
                    .font(.headline)

                VStack(alignment: .leading, spacing: 8) {
                    PermissionReasonRow(
                        icon: "keyboard",
                        text: L("Intercept keyboard events for Vietnamese input"),
                    )
                    PermissionReasonRow(
                        icon: "character.cursor.ibeam",
                        text: L("Send text to applications"),
                    )
                    PermissionReasonRow(
                        icon: "arrow.left.arrow.right",
                        text: L("Switch between Vietnamese and English modes"),
                    )
                }
            }
            .padding()
            .background(Color(.controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 8))

            // Status indicator
            HStack {
                Circle()
                    .fill(viewModel.isPermissionGranted ? .green : .red)
                    .frame(width: 10, height: 10)
                Text(viewModel.isPermissionGranted ? L("Permission Granted") : L("Permission Required"))
                    .foregroundStyle(viewModel.isPermissionGranted ? .green : .red)
            }

            // Buttons
            VStack(spacing: 12) {
                Button(action: viewModel.openSystemSettings) {
                    Label(L("Open System Settings"), systemImage: "gearshape")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                if viewModel.isPermissionGranted {
                    Button(action: viewModel.dismiss) {
                        Text(L("Continue"))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                } else {
                    Button(action: viewModel.checkPermission) {
                        Text(L("Check Permission Status"))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }
            }

            // Help text
            Text(L("Go to System Settings → Privacy & Security → Accessibility,\nthen enable LotusKey in the list."))
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(32)
        .frame(width: 400)
        .onAppear {
            viewModel.startMonitoring()
        }
        .onDisappear {
            viewModel.stopMonitoring()
        }
    }
}

/// Row showing a reason for needing permission
private struct PermissionReasonRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .frame(width: 24)
                .foregroundStyle(.secondary)
            Text(text)
                .font(.subheadline)
        }
    }
}

/// View model for accessibility permission handling
@Observable
@MainActor
final class AccessibilityPermissionViewModel {
    var isPermissionGranted: Bool = false
    private var monitoringTask: Task<Void, Never>?
    private var hasCalledPermissionGranted = false

    // Use a simple callback holder to avoid closure retain cycles
    private weak var windowController: AccessibilityPermissionWindowController?

    init() {
        isPermissionGranted = AXIsProcessTrusted()
    }

    func setWindowController(_ controller: AccessibilityPermissionWindowController) {
        windowController = controller
    }

    func checkPermission() {
        isPermissionGranted = AXIsProcessTrusted()
        if isPermissionGranted, !hasCalledPermissionGranted {
            hasCalledPermissionGranted = true
            windowController?.handlePermissionGranted()
        }
    }

    func openSystemSettings() {
        // Open Accessibility settings in System Settings
        guard let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")
        else {
            return
        }
        NSWorkspace.shared.open(url)
    }

    func startMonitoring() {
        // Check permission status periodically using structured concurrency
        monitoringTask = Task { [weak self] in
            while !Task.isCancelled {
                self?.checkPermission()
                try? await Task.sleep(for: .seconds(1))
            }
        }
    }

    func stopMonitoring() {
        monitoringTask?.cancel()
        monitoringTask = nil
    }

    func dismiss() {
        windowController?.handleDismiss()
    }
}

/// Window controller for presenting the permission dialog
@MainActor
final class AccessibilityPermissionWindowController {
    private var window: NSWindow?
    private var viewModel: AccessibilityPermissionViewModel?
    private var onGrantedCallback: (() -> Void)?

    static let shared = AccessibilityPermissionWindowController()

    private init() {}

    /// Called by view model when permission is granted
    func handlePermissionGranted() {
        #if DEBUG
            debugPrint("[LotusKey] Permission granted")
        #endif

        // Stop monitoring first
        viewModel?.stopMonitoring()

        // Get and clear callback before calling to prevent double call
        let callback = onGrantedCallback
        onGrantedCallback = nil

        // Call the callback
        #if DEBUG
            debugPrint("[LotusKey] Calling onGranted callback...")
        #endif
        callback?()
        #if DEBUG
            debugPrint("[LotusKey] onGranted callback completed")
        #endif

        // Just hide the window - don't close or cleanup to avoid memory issues
        // The window will stay hidden but alive, preventing crashes from dangling references
        #if DEBUG
            debugPrint("[LotusKey] Hiding permission window...")
        #endif
        window?.orderOut(nil)
        #if DEBUG
            debugPrint("[LotusKey] Permission window hidden, app should continue running")
        #endif
    }

    /// Called by view model when user dismisses
    func handleDismiss() {
        if AXIsProcessTrusted() {
            handlePermissionGranted()
        } else {
            // Just hide, don't cleanup
            window?.orderOut(nil)
        }
    }

    /// Show the permission dialog
    /// - Parameters:
    ///   - onGranted: Callback when permission is granted
    func show(onGranted: @escaping () -> Void) {
        // Don't show if already granted
        guard !AXIsProcessTrusted() else {
            onGranted()
            return
        }

        // Store callback
        onGrantedCallback = onGranted

        let viewModel = AccessibilityPermissionViewModel()
        viewModel.setWindowController(self)
        self.viewModel = viewModel

        let contentView = AccessibilityPermissionView(viewModel: viewModel)
        let hostingView = NSHostingView(rootView: contentView)

        // Calculate size manually to avoid constraint issues
        let fittingSize = hostingView.fittingSize
        hostingView.frame = CGRect(origin: .zero, size: fittingSize)

        let window = NSWindow(
            contentRect: NSRect(origin: .zero, size: fittingSize),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false,
        )
        window.contentView = hostingView
        window.title = L("LotusKey - Permission Required")
        window.level = .floating
        window.center()

        self.window = window
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    /// Check if permission is granted without showing UI
    static func checkPermission() -> Bool {
        AXIsProcessTrusted()
    }

    /// Request permission with prompt (shows system dialog)
    static func requestPermission() -> Bool {
        // Use the well-known string value directly to avoid Swift 6 concurrency issues
        // with the kAXTrustedCheckOptionPrompt C global
        let options = ["AXTrustedCheckOptionPrompt": true] as CFDictionary
        return AXIsProcessTrustedWithOptions(options)
    }
}

#Preview {
    AccessibilityPermissionView(viewModel: AccessibilityPermissionViewModel())
}
