import Foundation

/// Simple Telex input method variant.
///
/// Key differences from standard Telex:
/// - `ow` → `ơ` (horn works - pattern matching runs regardless of Simple Telex)
/// - `uw` → `ư` (horn works - pattern matching runs regardless of Simple Telex)
/// - `aw` → `ă` (breve works)
/// - Standalone `w` stays `w` (ONLY standalone w → ư is blocked)
/// - Bracket keys `[` and `]` pass through as literal (word break)
///
/// Reference: OpenKey's vSimpleTelex1 at Engine.cpp:1155-1187, 1541
public struct SimpleTelexInputMethod: InputMethod {
    public let name = "Simple Telex"

    /// Delegate to standard Telex for most operations
    private let telex = TelexInputMethod()

    public init() {}

    // MARK: - Simple Processing (backward compatibility)

    public func processCharacter(_ character: Character, context: String) -> InputTransformation? {
        var state = InputMethodState()
        return processCharacter(character, context: context, state: &state)
    }

    // MARK: - Processing with State (supports undo)

    public func processCharacter(
        _ character: Character,
        context: String,
        state: inout InputMethodState,
    ) -> InputTransformation? {
        let char = character.lowercased().first ?? character

        // Block bracket keys - pass through as literal (word break)
        // Reference: OpenKey Engine.cpp:1541 - bracket keys cause word break in Simple Telex
        if char == "[" || char == "]" {
            return nil
        }

        // Check if key is temporarily disabled (after undo)
        if state.isDisabled(char) {
            return nil
        }

        // Check for undo opportunity FIRST (before W handling)
        // This allows aww → aw (undo breve) to work in Simple Telex
        if let undoTransform = checkForUndo(char, state: &state) {
            return undoTransform
        }

        // Special handling for W key in Simple Telex
        if char == "w" {
            return handleSimpleTelexWKey(context: context, state: &state)
        }

        // Everything else delegates to standard Telex
        return telex.processCharacter(character, context: context, state: &state)
    }

    public func isSpecialKey(_ character: Character) -> Bool {
        let char = character.lowercased().first ?? character
        // Brackets are NOT special in Simple Telex - they pass through as literal
        if char == "[" || char == "]" {
            return false
        }
        return telex.isSpecialKey(character)
    }

    // MARK: - Undo Detection

    /// Check if current character would undo the last transformation
    /// Simple Telex only supports undo for breve (aww → aw)
    private func checkForUndo(_ char: Character, state: inout InputMethodState) -> InputTransformation? {
        guard let last = state.lastTransformation else {
            return nil
        }

        let triggerLower = last.triggerKey.lowercased().first ?? last.triggerKey

        // Undo is triggered when the same key is pressed again
        guard char == triggerLower else {
            return nil
        }

        // Simple Telex supports undo for both breve and horn
        // aww → aw (undo breve)
        // oww → ow, uww → uw (undo horn)
        if char == "w" {
            if case .breve = last.type {
                state.disableKey(char)
                state.lastTransformation = nil
                return InputTransformation(type: .undo(originalChars: last.originalChars))
            }
            if case .horn = last.type {
                state.disableKey(char)
                state.lastTransformation = nil
                return InputTransformation(type: .undo(originalChars: last.originalChars))
            }
        }

        return nil
    }

    // MARK: - W Key Handling (Simple Telex specific)

    /// Handle W key with Simple Telex rules:
    /// - `ow` → `ơ` (horn works - pattern matching runs regardless of Simple Telex)
    /// - `uw` → `ư` (horn works - pattern matching runs regardless of Simple Telex)
    /// - `aw` → `ă` (breve works)
    /// - Standalone `w` stays `w` (ONLY this is blocked)
    ///
    /// Reference: OpenKey Engine.cpp:1155-1187
    /// - Pattern matching runs first regardless of Simple Telex mode
    /// - Simple Telex only blocks fallback standalone w → ư
    private func handleSimpleTelexWKey(context: String, state _: inout InputMethodState) -> InputTransformation? {
        let lower = context.lowercased()

        // Case 1: w after o → horn (ow → ơ)
        // Pattern matching runs regardless of Simple Telex mode
        if lower.hasSuffix("o") {
            return InputTransformation(type: .modifier(.horn), category: .horn)
        }

        // Case 2: w after u → horn (uw → ư)
        // Pattern matching runs regardless of Simple Telex mode
        if lower.hasSuffix("u") {
            return InputTransformation(type: .modifier(.horn), category: .horn)
        }

        // Case 3: w after a → breve (aw → ă)
        if lower.hasSuffix("a") {
            return InputTransformation(type: .modifier(.breve), category: .breve)
        }

        // Case 4: Standalone w → no transformation
        // Simple Telex ONLY blocks standalone w → ư conversion
        return nil
    }
}
