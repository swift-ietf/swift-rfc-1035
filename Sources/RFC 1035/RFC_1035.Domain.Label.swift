//
//  RFC_1035.Domain.Label.swift
//  swift-rfc-1035
//
//  Created by Coen ten Thije Boonkkamp on 20/11/2025.
//

public import ASCII_Serializer_Primitives

extension RFC_1035.Domain {
    /// RFC 1035 compliant domain label
    ///
    /// Represents a single label within a domain name as defined by RFC 1035 Section 2.3.1.
    /// Labels are case-insensitive ASCII strings with strict character restrictions.
    ///
    /// ## RFC 1035 Constraints
    ///
    /// Per RFC 1035 Section 2.3.1:
    /// - Must be 1-63 octets long
    /// - Must start with a letter (a-z, A-Z)
    /// - Must end with a letter or digit
    /// - May contain letters, digits, and hyphens in interior positions
    ///
    /// ## Example
    ///
    /// ```swift
    /// let label = try RFC_1035.Domain.Label("example")
    /// let invalid = try RFC_1035.Domain.Label("123") // Throws: must start with letter
    /// ```
    ///
    /// ## RFC Reference
    ///
    /// From RFC 1035 Section 2.3.1:
    ///
    /// > labels must follow the rules for ARPANET host names. They must
    /// > start with a letter, end with a letter or digit, and have as interior
    /// > characters only letters, digits, and hyphen.
    public struct Label: Sendable, Codable {
        /// The label value
        public let rawValue: String

        /// Creates a label WITHOUT validation
        ///
        /// **Warning**: Bypasses RFC 1035 validation.
        /// Only use with compile-time constants or pre-validated values.
        ///
        /// - Parameters:
        ///   - unchecked: Void parameter to prevent accidental use
        ///   - rawValue: The raw label value (unchecked)
        init(
            __unchecked _: Void,
            rawValue: String
        ) {
            self.rawValue = rawValue
        }
    }
}

// MARK: - Hashable

extension RFC_1035.Domain.Label: Hashable {
    /// Hash value (case-insensitive per RFC 1035)
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue.lowercased())
    }

    /// Equality comparison (case-insensitive per RFC 1035)
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue.lowercased() == rhs.rawValue.lowercased()
    }

    /// Equality comparison with raw value (case-insensitive)
    public static func == (lhs: Self, rhs: Self.RawValue) -> Bool {
        lhs.rawValue.lowercased() == rhs.lowercased()
    }

    /// Equality comparison with raw value (case-insensitive)
    public static func == (lhs: Self.RawValue, rhs: Self) -> Bool {
        lhs.lowercased() == rhs.rawValue.lowercased()
    }
}

extension RFC_1035.Domain.Label: Binary.ASCII.RawRepresentable {}

extension RFC_1035.Domain.Label: CustomStringConvertible {}

extension RFC_1035.Domain.Label: Binary.ASCII.Serializable {
    public static func serialize<Buffer: RangeReplaceableCollection>(
        ascii label: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == UInt8 {
        buffer.append(contentsOf: label.rawValue.utf8)
    }

    /// Parses a domain label from canonical byte representation (CANONICAL PRIMITIVE)
    ///
    /// This is the primitive parser that works at the byte level.
    /// RFC 1035 domain labels are ASCII-only.
    ///
    /// ## RFC 1035 Compliance
    ///
    /// Per RFC 1035 Section 2.3.1:
    /// - Labels must be 1-63 octets
    /// - Must start with a letter (a-z, A-Z)
    /// - Must end with a letter or digit
    /// - May contain letters, digits, and hyphens
    ///
    /// ## Category Theory
    ///
    /// This is the fundamental parsing transformation:
    /// - **Domain**: [UInt8] (ASCII bytes)
    /// - **Codomain**: RFC_1035.Domain.Label (structured data)
    ///
    /// String-based parsing is derived as composition:
    /// ```
    /// String → [UInt8] (UTF-8 bytes) → Domain.Label
    /// ```
    ///
    /// ## Example
    ///
    /// ```swift
    /// let bytes = Array("example".utf8)
    /// let label = try RFC_1035.Domain.Label(ascii: bytes)
    /// ```
    ///
    /// - Parameter bytes: The ASCII byte representation of the label
    /// - Throws: `RFC_1035.Domain.Label.Error` if the bytes are malformed
    public init<Bytes: Collection>(ascii bytes: Bytes, in context: Void) throws(Error)
    where Bytes.Element == UInt8 {
        guard let firstByte = bytes.first else {
            throw Error.empty
        }

        var count = 0
        var lastByte = firstByte

        for byte in bytes {
            count += 1
            lastByte = byte

            let validInterior = byte.ascii.isLetter || byte.ascii.isDigit || byte == .ascii.hyphen
            guard validInterior else {
                let string = String(decoding: bytes, as: UTF8.self)
                throw Error.invalidCharacters(
                    string,
                    byte: byte,
                    reason: "Only letters, digits, and hyphens allowed"
                )
            }
        }

        guard count <= RFC_1035.Domain.Limits.maxLabelLength else {
            let string = String(decoding: bytes, as: UTF8.self)
            throw Error.tooLong(count, label: string)
        }

        guard firstByte.ascii.isLetter else {
            let string = String(decoding: bytes, as: UTF8.self)
            if firstByte == .ascii.hyphen {
                throw Error.startsWithHyphen(string)
            } else if firstByte.ascii.isDigit {
                throw Error.startsWithDigit(string)
            } else {
                throw Error.invalidCharacters(
                    string,
                    byte: firstByte,
                    reason: "Must start with a letter"
                )
            }
        }

        guard lastByte.ascii.isLetter || lastByte.ascii.isDigit else {
            let string = String(decoding: bytes, as: UTF8.self)
            if lastByte == .ascii.hyphen {
                throw Error.endsWithHyphen(string)
            } else {
                throw Error.invalidCharacters(
                    string,
                    byte: lastByte,
                    reason: "Must end with a letter or digit"
                )
            }
        }

        self.init(__unchecked: (), rawValue: String(decoding: bytes, as: UTF8.self))
    }
}
