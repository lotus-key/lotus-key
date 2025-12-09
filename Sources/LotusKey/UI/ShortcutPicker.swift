import AppKit
import Carbon
import SwiftUI

/// Converts keyCode to human-readable string
private func keyCodeToString(_ keyCode: UInt16) -> String {
    switch Int(keyCode) {
    case kVK_Space: return "Space"
    case kVK_Return: return "↩"
    case kVK_Tab: return "⇥"
    case kVK_Delete: return "⌫"
    case kVK_ForwardDelete: return "⌦"
    case kVK_Escape: return "⎋"
    case kVK_LeftArrow: return "←"
    case kVK_RightArrow: return "→"
    case kVK_UpArrow: return "↑"
    case kVK_DownArrow: return "↓"
    case kVK_Home: return "↖"
    case kVK_End: return "↘"
    case kVK_PageUp: return "⇞"
    case kVK_PageDown: return "⇟"
    case kVK_F1: return "F1"
    case kVK_F2: return "F2"
    case kVK_F3: return "F3"
    case kVK_F4: return "F4"
    case kVK_F5: return "F5"
    case kVK_F6: return "F6"
    case kVK_F7: return "F7"
    case kVK_F8: return "F8"
    case kVK_F9: return "F9"
    case kVK_F10: return "F10"
    case kVK_F11: return "F11"
    case kVK_F12: return "F12"
    default:
        if let char = characterForKeyCode(keyCode) {
            return char.uppercased()
        }
        return "Key\(keyCode)"
    }
}

/// Gets the character for a key code using InputSource
private func characterForKeyCode(_ keyCode: UInt16) -> String? {
    let source = TISCopyCurrentKeyboardInputSource().takeRetainedValue()
    guard let layoutData = TISGetInputSourceProperty(source, kTISPropertyUnicodeKeyLayoutData) else {
        return nil
    }
    let data = unsafeBitCast(layoutData, to: CFData.self) as Data
    return data.withUnsafeBytes { ptr -> String? in
        guard let layoutPtr = ptr.baseAddress?.assumingMemoryBound(to: UCKeyboardLayout.self) else {
            return nil
        }
        var deadKeyState: UInt32 = 0
        var chars = [UniChar](repeating: 0, count: 4)
        var length = 0
        let result = UCKeyTranslate(
            layoutPtr,
            keyCode,
            UInt16(kUCKeyActionDisplay),
            0,
            UInt32(LMGetKbdType()),
            UInt32(kUCKeyTranslateNoDeadKeysBit),
            &deadKeyState,
            chars.count,
            &length,
            &chars,
        )
        guard result == noErr, length > 0 else { return nil }
        return String(utf16CodeUnits: chars, count: length)
    }
}

/// Observable object to manage shortcut recording state
@MainActor
private final class ShortcutRecorder: ObservableObject {
    @Published var isRecording = false
    @Published var displayText = ""
    @Published var recordedBitfield: UInt32?

    private var monitor: Any?

    func startRecording() {
        isRecording = true
        displayText = ""
        recordedBitfield = nil

        monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            DispatchQueue.main.async {
                self?.handleKeyDown(event)
            }
            return nil
        }
    }

    func stopRecording() {
        isRecording = false
        if let monitor {
            NSEvent.removeMonitor(monitor)
            self.monitor = nil
        }
    }

    func cancel() {
        stopRecording()
        recordedBitfield = nil
    }

    private func handleKeyDown(_ event: NSEvent) {
        let keyCode = event.keyCode
        let modifiers = event.modifierFlags.intersection([.control, .option, .command, .shift])

        // Escape cancels recording
        if keyCode == UInt16(kVK_Escape) {
            cancel()
            return
        }

        // Require at least one modifier for most keys (except function keys)
        let functionKeys: Set<Int> = [
            kVK_F1, kVK_F2, kVK_F3, kVK_F4, kVK_F5, kVK_F6,
            kVK_F7, kVK_F8, kVK_F9, kVK_F10, kVK_F11, kVK_F12,
        ]
        let isFunctionKey = functionKeys.contains(Int(keyCode))
        if modifiers.isEmpty, !isFunctionKey {
            displayText = L("Add modifier key")
            return
        }

        // Build display string
        var parts: [String] = []
        if modifiers.contains(.control) { parts.append("⌃") }
        if modifiers.contains(.option) { parts.append("⌥") }
        if modifiers.contains(.shift) { parts.append("⇧") }
        if modifiers.contains(.command) { parts.append("⌘") }
        parts.append(keyCodeToString(keyCode))
        displayText = parts.joined()

        // Build bitfield
        var bitfield = UInt32(keyCode)
        if modifiers.contains(.control) { bitfield |= 0x100 }
        if modifiers.contains(.option) { bitfield |= 0x200 }
        if modifiers.contains(.command) { bitfield |= 0x400 }
        if modifiers.contains(.shift) { bitfield |= 0x800 }
        bitfield |= 0x8000 // Enable beep

        recordedBitfield = bitfield
        stopRecording()
    }
}

/// Converts bitfield to display string
private func bitfieldToDisplayString(_ bitfield: UInt32) -> String {
    let keyCode = UInt16(bitfield & 0xFF)
    var parts: [String] = []
    if (bitfield & 0x100) != 0 { parts.append("⌃") }
    if (bitfield & 0x200) != 0 { parts.append("⌥") }
    if (bitfield & 0x800) != 0 { parts.append("⇧") }
    if (bitfield & 0x400) != 0 { parts.append("⌘") }
    parts.append(keyCodeToString(keyCode))
    return parts.joined()
}

/// A picker for selecting the language switch shortcut with custom recording support
struct ShortcutPicker: View {
    @Binding var hotkeyBitfield: UInt32
    @StateObject private var recorder = ShortcutRecorder()

    private var displayString: String {
        bitfieldToDisplayString(hotkeyBitfield)
    }

    var body: some View {
        HStack {
            Text(L("Switch Language"))
            Spacer()
            if recorder.isRecording {
                Button(
                    action: { recorder.cancel() },
                    label: {
                        Text(recorder.displayText.isEmpty ? L("Press shortcut...") : recorder.displayText)
                            .frame(minWidth: 80)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                    },
                )
                .buttonStyle(.borderedProminent)
            } else {
                Button(
                    action: { recorder.startRecording() },
                    label: {
                        Text(displayString)
                            .frame(minWidth: 80)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                    },
                )
                .buttonStyle(.bordered)
            }
        }
        .onChange(of: recorder.recordedBitfield) { _, newValue in
            if let bitfield = newValue {
                hotkeyBitfield = bitfield
            }
        }
        .onDisappear {
            recorder.stopRecording()
        }
    }
}

#Preview {
    Form {
        Section {
            ShortcutPicker(hotkeyBitfield: .constant(0x8131))
        } header: {
            Label("Shortcut", systemImage: "keyboard")
        }
    }
    .formStyle(.grouped)
    .frame(width: 400)
}
