import Carbon
import Foundation

/// Protocol for keyboard event handling
public protocol KeyboardEventHandling: AnyObject, Sendable {
    /// Start capturing keyboard events
    /// - Throws: Error if unable to create event tap (usually permissions)
    func start() throws

    /// Stop capturing keyboard events
    func stop()

    /// Whether the handler is currently active
    var isActive: Bool { get }
}

/// Error types for keyboard event handling
public enum KeyboardEventError: Error, LocalizedError {
    case accessibilityNotEnabled
    case failedToCreateEventTap
    case failedToCreateRunLoopSource

    public var errorDescription: String? {
        switch self {
        case .accessibilityNotEnabled:
            return "Accessibility permissions not enabled. Please enable in System Settings > Privacy & Security > Accessibility"
        case .failedToCreateEventTap:
            return "Failed to create keyboard event tap"
        case .failedToCreateRunLoopSource:
            return "Failed to create run loop source for event tap"
        }
    }
}

/// Handles keyboard events using CGEventTap
public final class KeyboardEventHandler: KeyboardEventHandling, @unchecked Sendable {
    fileprivate var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private let engine: any VietnameseEngine
    private let queue = DispatchQueue(label: "com.openkey.keyboard", qos: .userInteractive)

    public private(set) var isActive: Bool = false

    public init(engine: any VietnameseEngine) {
        self.engine = engine
    }

    deinit {
        stop()
    }

    public func start() throws {
        // Check accessibility permissions
        let trusted = AXIsProcessTrusted()
        guard trusted else {
            throw KeyboardEventError.accessibilityNotEnabled
        }

        // Create event tap
        let eventMask = (1 << CGEventType.keyDown.rawValue) | (1 << CGEventType.flagsChanged.rawValue)

        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: keyboardCallback,
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        ) else {
            throw KeyboardEventError.failedToCreateEventTap
        }

        eventTap = tap

        // Create run loop source
        guard let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0) else {
            throw KeyboardEventError.failedToCreateRunLoopSource
        }

        runLoopSource = source

        // Add to run loop
        CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)

        isActive = true
    }

    public func stop() {
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
        }

        if let source = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, .commonModes)
        }

        runLoopSource = nil
        eventTap = nil
        isActive = false
    }

    fileprivate func handleKeyEvent(_ event: CGEvent) -> CGEvent? {
        let keyCode = UInt16(event.getIntegerValueField(.keyboardEventKeycode))
        let flags = event.flags.rawValue

        // Get the character from the event
        var actualStringLength = 0
        var unicodeString = [UniChar](repeating: 0, count: 4)
        event.keyboardGetUnicodeString(
            maxStringLength: 4,
            actualStringLength: &actualStringLength,
            unicodeString: &unicodeString
        )

        let character: Character? = actualStringLength > 0
            ? Character(UnicodeScalar(unicodeString[0])!)
            : nil

        // Process through engine
        let result = engine.processKey(keyCode: keyCode, character: character, modifiers: flags)

        switch result {
        case .passThrough:
            return event
        case .suppress:
            return nil
        case .replace(let backspaceCount, let replacement):
            // Send backspaces and replacement text
            sendBackspaces(count: backspaceCount)
            sendString(replacement)
            return nil
        }
    }

    private func sendBackspaces(count: Int) {
        for _ in 0..<count {
            let keyDown = CGEvent(keyboardEventSource: nil, virtualKey: 0x33, keyDown: true)
            let keyUp = CGEvent(keyboardEventSource: nil, virtualKey: 0x33, keyDown: false)
            keyDown?.post(tap: .cghidEventTap)
            keyUp?.post(tap: .cghidEventTap)
        }
    }

    private func sendString(_ string: String) {
        for char in string {
            guard !char.unicodeScalars.isEmpty else { continue }

            var chars = [UniChar](repeating: 0, count: 2)
            let charCount = char.utf16.count
            for (i, unit) in char.utf16.enumerated() {
                chars[i] = unit
            }

            let keyDown = CGEvent(keyboardEventSource: nil, virtualKey: 0, keyDown: true)
            let keyUp = CGEvent(keyboardEventSource: nil, virtualKey: 0, keyDown: false)

            keyDown?.keyboardSetUnicodeString(stringLength: charCount, unicodeString: &chars)
            keyUp?.keyboardSetUnicodeString(stringLength: charCount, unicodeString: &chars)

            keyDown?.post(tap: .cghidEventTap)
            keyUp?.post(tap: .cghidEventTap)
        }
    }
}

// CGEventTap callback function
private func keyboardCallback(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent,
    refcon: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
    guard let refcon = refcon else {
        return Unmanaged.passRetained(event)
    }

    let handler = Unmanaged<KeyboardEventHandler>.fromOpaque(refcon).takeUnretainedValue()

    // Handle tap being disabled (system can disable if we're too slow)
    if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
        if let tap = handler.eventTap {
            CGEvent.tapEnable(tap: tap, enable: true)
        }
        return Unmanaged.passRetained(event)
    }

    // Only process keyDown events
    guard type == .keyDown else {
        return Unmanaged.passRetained(event)
    }

    if let result = handler.handleKeyEvent(event) {
        return Unmanaged.passRetained(result)
    }

    return nil
}
