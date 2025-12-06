import Foundation

/// Represents a Vietnamese input method (Telex, Simple Telex)
public protocol InputMethod: Sendable {
    /// The name of the input method
    var name: String { get }

    /// Process a character and return the transformation rules to apply
    /// - Parameters:
    ///   - character: The input character
    ///   - context: The current input context (previous characters)
    /// - Returns: The transformation to apply, if any
    func processCharacter(_ character: Character, context: String) -> InputTransformation?

    /// Check if a character is a special key for this input method
    /// - Parameter character: The character to check
    /// - Returns: True if the character has special meaning
    func isSpecialKey(_ character: Character) -> Bool
}

/// Represents a transformation to apply to the input
public struct InputTransformation: Sendable {
    /// Type of transformation
    public enum TransformationType: Sendable {
        /// Add a tone mark (sắc, huyền, hỏi, ngã, nặng)
        case tone(ToneMark)
        /// Add a modifier mark (circumflex, breve, horn, stroke)
        case modifier(ModifierMark)
        /// Replace characters (e.g., dd -> đ)
        case replace(String)
        /// No transformation needed
        case none
    }

    public let type: TransformationType
    public let targetPosition: Int? // Position relative to end (nil = current)

    public init(type: TransformationType, targetPosition: Int? = nil) {
        self.type = type
        self.targetPosition = targetPosition
    }
}

/// Vietnamese tone marks
public enum ToneMark: Sendable {
    case acute      // sắc (á)
    case grave      // huyền (à)
    case hook       // hỏi (ả)
    case tilde      // ngã (ã)
    case dot        // nặng (ạ)
    case none       // remove tone
}

/// Vietnamese modifier marks
public enum ModifierMark: Sendable {
    case circumflex // mũ (â, ê, ô)
    case breve      // trăng (ă)
    case horn       // móc (ơ, ư)
    case stroke     // gạch (đ)
}
