import Foundation

/// Telex input method implementation
public struct TelexInputMethod: InputMethod {
    public let name = "Telex"

    public init() {}

    public func processCharacter(_ character: Character, context: String) -> InputTransformation? {
        let char = character.lowercased().first ?? character

        switch char {
        // Tone marks
        case "s":
            return InputTransformation(type: .tone(.acute))
        case "f":
            return InputTransformation(type: .tone(.grave))
        case "r":
            return InputTransformation(type: .tone(.hook))
        case "x":
            return InputTransformation(type: .tone(.tilde))
        case "j":
            return InputTransformation(type: .tone(.dot))
        case "z":
            return InputTransformation(type: .tone(.none))

        // Modifier marks
        case "a" where context.lowercased().hasSuffix("a"):
            return InputTransformation(type: .modifier(.circumflex))
        case "e" where context.lowercased().hasSuffix("e"):
            return InputTransformation(type: .modifier(.circumflex))
        case "o" where context.lowercased().hasSuffix("o"):
            return InputTransformation(type: .modifier(.circumflex))
        case "w":
            // Could be ă, ư, or ơ depending on context
            return handleWKey(context: context)
        case "d" where context.lowercased().hasSuffix("d"):
            return InputTransformation(type: .modifier(.stroke))

        default:
            return nil
        }
    }

    public func isSpecialKey(_ character: Character) -> Bool {
        let specialKeys: Set<Character> = ["s", "f", "r", "x", "j", "z", "w"]
        return specialKeys.contains(character.lowercased().first ?? character)
    }

    private func handleWKey(context: String) -> InputTransformation? {
        let lower = context.lowercased()
        if lower.hasSuffix("a") {
            return InputTransformation(type: .modifier(.breve))
        } else if lower.hasSuffix("u") || lower.hasSuffix("o") {
            return InputTransformation(type: .modifier(.horn))
        }
        return nil
    }
}
