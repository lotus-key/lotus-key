import Foundation

/// Result of processing a keyboard event
public enum EngineResult: Sendable {
    /// No action needed, pass through the original key
    case passThrough
    /// Suppress the key, engine handled it
    case suppress
    /// Replace with new characters (backspace count, new string)
    case replace(backspaceCount: Int, replacement: String)
}

/// Protocol defining the Vietnamese input processing engine
public protocol VietnameseEngine: Sendable {
    /// Process a key press event
    /// - Parameters:
    ///   - keyCode: The virtual key code
    ///   - character: The character representation of the key
    ///   - modifiers: Modifier flags (shift, control, etc.)
    /// - Returns: The result indicating how to handle the event
    func processKey(keyCode: UInt16, character: Character?, modifiers: UInt64) -> EngineResult

    /// Reset the engine state (e.g., when focus changes)
    func reset()

    /// Get the current input method
    var inputMethod: any InputMethod { get }

    /// Set the input method
    func setInputMethod(_ method: any InputMethod)

    /// Get the current character table
    var characterTable: any CharacterTable { get }

    /// Set the character table
    func setCharacterTable(_ table: any CharacterTable)

    /// Enable or disable spell checking
    var spellCheckEnabled: Bool { get set }
}

/// Default implementation placeholder
public final class DefaultVietnameseEngine: VietnameseEngine, @unchecked Sendable {
    private var _inputMethod: any InputMethod
    private var _characterTable: any CharacterTable
    public var spellCheckEnabled: Bool = true

    public var inputMethod: any InputMethod { _inputMethod }
    public var characterTable: any CharacterTable { _characterTable }

    public init(inputMethod: any InputMethod = TelexInputMethod(),
                characterTable: any CharacterTable = UnicodeCharacterTable()) {
        self._inputMethod = inputMethod
        self._characterTable = characterTable
    }

    public func processKey(keyCode: UInt16, character: Character?, modifiers: UInt64) -> EngineResult {
        // TODO: Implement Vietnamese input processing
        return .passThrough
    }

    public func reset() {
        // TODO: Clear buffer and state
    }

    public func setInputMethod(_ method: any InputMethod) {
        _inputMethod = method
    }

    public func setCharacterTable(_ table: any CharacterTable) {
        _characterTable = table
    }
}
