import SwiftUI

/// Modern Settings view for LotusKey - macOS 2025 design patterns
/// Two tabs: General (all settings) and About (app info)
struct SettingsView: View {
    // Input method settings
    @AppStorage(SettingsKey.inputMethod.rawValue) private var inputMethod = "Telex"
    @AppStorage(SettingsKey.quickTelexEnabled.rawValue) private var quickTelexEnabled = true
    @AppStorage(SettingsKey.autoCapitalize.rawValue) private var autoCapitalize = true

    // Spelling settings
    @AppStorage(SettingsKey.spellCheckEnabled.rawValue) private var spellCheckEnabled = true
    @AppStorage(SettingsKey.restoreIfWrongSpelling.rawValue) private var restoreIfWrongSpelling = true

    // Features
    @AppStorage(SettingsKey.smartSwitchEnabled.rawValue) private var smartSwitchEnabled = true

    // Startup settings
    @AppStorage(SettingsKey.launchAtLogin.rawValue) private var launchAtLogin = false
    @AppStorage(SettingsKey.showDockIcon.rawValue) private var showDockIcon = false

    // Advanced settings
    @AppStorage(SettingsKey.fixBrowserAutocomplete.rawValue) private var fixBrowserAutocomplete = true
    @AppStorage(SettingsKey.fixChromiumBrowser.rawValue) private var fixChromiumBrowser = true
    @AppStorage(SettingsKey.sendKeyStepByStep.rawValue) private var sendKeyStepByStep = false

    // Shortcut
    @AppStorage(SettingsKey.switchLanguageHotkey.rawValue) private var switchLanguageHotkey: Int = 0x8131

    // i18n
    @AppStorage(SettingsKey.appLanguage.rawValue) private var appLanguageRaw = AppLanguage.system.rawValue
    @State private var showRestartAlert = false

    private let inputMethods = ["Telex", "Simple Telex"]

    private var appLanguage: AppLanguage {
        get { AppLanguage(rawValue: appLanguageRaw) ?? .system }
        nonmutating set { appLanguageRaw = newValue.rawValue }
    }

    var body: some View {
        TabView {
            generalTab
                .tabItem {
                    Label(L("General"), systemImage: "gearshape")
                }

            aboutTab
                .tabItem {
                    Label(L("About"), systemImage: "info.circle")
                }
        }
        .frame(width: 420, height: 420)
    }

    // MARK: - General Tab

    private var generalTab: some View {
        Form {
            Section {
                Picker(L("Input Method"), selection: $inputMethod) {
                    ForEach(inputMethods, id: \.self) { method in
                        Text(method).tag(method)
                    }
                }

                Toggle(isOn: $quickTelexEnabled) {
                    HelpLabel(
                        L("Quick Telex"),
                        help: L("cc → ch, gg → gi\nkk → kh, ngg → ngh\nqq → qu"),
                    )
                }

                Toggle(L("Auto-capitalize"), isOn: $autoCapitalize)
            } header: {
                Label(L("Input"), systemImage: "keyboard")
            }

            Section {
                ShortcutPicker(hotkeyBitfield: Binding(
                    get: { UInt32(switchLanguageHotkey) },
                    set: { switchLanguageHotkey = Int($0) },
                ))
            } header: {
                Label(L("Shortcut"), systemImage: "command")
            }

            Section {
                Toggle(L("Spell Checking"), isOn: $spellCheckEnabled)

                Toggle(isOn: $restoreIfWrongSpelling) {
                    HelpLabel(
                        L("Restore Invalid Words"),
                        help: L("Reverts text if spelling is invalid.\nHold ⌃ Control to bypass."),
                    )
                }
                .disabled(!spellCheckEnabled)
            } header: {
                Label(L("Spelling"), systemImage: "textformat.abc")
            }

            Section {
                Toggle(isOn: $smartSwitchEnabled) {
                    HelpLabel(
                        L("Smart Language Switch"),
                        help: L("Remembers Vietnamese or English preference for each application."),
                    )
                }

                Toggle(L("Launch at Login"), isOn: $launchAtLogin)

                Toggle(L("Show in Dock"), isOn: $showDockIcon)

                Picker(L("Language"), selection: Binding(
                    get: { appLanguage },
                    set: { newValue in
                        appLanguageRaw = newValue.rawValue
                        showRestartAlert = true
                    },
                )) {
                    ForEach(AppLanguage.allCases, id: \.self) { lang in
                        Text(lang.displayName).tag(lang)
                    }
                }
            } header: {
                Label(L("Behavior"), systemImage: "arrow.triangle.2.circlepath")
            }

            Section {
                Toggle(isOn: $fixBrowserAutocomplete) {
                    HelpLabel(
                        L("Fix Browser Autocomplete"),
                        help: L("Fixes input issues in browser address bars and search fields."),
                    )
                }

                Toggle(isOn: $fixChromiumBrowser) {
                    HelpLabel(
                        L("Fix Chromium Browsers"),
                        help: L("Chrome, Edge, Arc, Brave, and other Chromium-based browsers."),
                    )
                }
                .disabled(!fixBrowserAutocomplete)

                Toggle(isOn: $sendKeyStepByStep) {
                    HelpLabel(
                        L("Step-by-Step Mode"),
                        help: L("Sends keys one at a time.\nSlower but more compatible."),
                    )
                }
            } header: {
                Label(L("Compatibility"), systemImage: "puzzlepiece.extension")
            }
        }
        .formStyle(.grouped)
        .alert(L("Restart Required"), isPresented: $showRestartAlert) {
            Button(L("Restart Now")) {
                restartApp()
            }
            Button(L("Later"), role: .cancel) {}
        } message: {
            Text(L("Language change requires restart."))
        }
    }

    private func restartApp() {
        // Clear localization cache so it reloads on next launch
        LocalizationManager.invalidateCache()

        // Get the app bundle path
        let bundlePath = Bundle.main.bundlePath

        // Use /usr/bin/open with delay to restart after quit
        let task = Process()
        task.launchPath = "/bin/sh"
        task.arguments = ["-c", "sleep 0.5 && open '\(bundlePath)'"]

        do {
            try task.run()
        } catch {
            #if DEBUG
                debugPrint("Failed to schedule restart: \(error)")
            #endif
        }

        // Terminate the app
        NSApp.terminate(nil)
    }

    // MARK: - About Tab

    private var aboutTab: some View {
        VStack(spacing: 20) {
            Spacer()

            // App icon and name
            VStack(spacing: 12) {
                Image(nsImage: NSApp.applicationIconImage)
                    .resizable()
                    .frame(width: 80, height: 80)

                Text("LotusKey")
                    .font(.title.bold())

                Text(L("Version \(appVersion)"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            // Description
            Text(L("Vietnamese Input Method for macOS"))
                .font(.callout)
                .foregroundStyle(.secondary)

            Spacer()

            // Links
            HStack(spacing: 16) {
                if let url = URL(string: "https://github.com/lotus-key/lotus-key") {
                    Link(destination: url) {
                        Label(L("GitHub"), systemImage: "link")
                    }
                    .buttonStyle(.link)
                }
            }

            // Copyright
            Text("© 2025 \(L("Author Name"))")
                .font(.caption)
                .foregroundStyle(.tertiary)

            Text(L("Licensed under GPL-3.0"))
                .font(.caption)
                .foregroundStyle(.tertiary)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Helpers

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
}

// MARK: - Help Label Component

/// A label with an inline help button that shows a popover on click
private struct HelpLabel: View {
    let title: String
    let help: String

    @State private var showingHelp = false

    init(_ title: String, help: String) {
        self.title = title
        self.help = help
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 3) {
            Text(title)

            Image(systemName: "questionmark.circle")
                .font(.footnote)
                .foregroundStyle(.tertiary)
                .onTapGesture {
                    showingHelp.toggle()
                }
                .popover(isPresented: $showingHelp, arrowEdge: .trailing) {
                    Text(help)
                        .font(.callout)
                        .padding(12)
                        .frame(maxWidth: 240)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .help(help.replacingOccurrences(of: "\n", with: " "))
        }
    }
}

#Preview {
    SettingsView()
}
