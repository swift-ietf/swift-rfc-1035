//
//  RFC_1035.Domain.Label.swift
//  swift-rfc-1035
//
//  Created by Coen ten Thije Boonkkamp on 20/11/2025.
//

public import ASCII_Serializer_Primitives
public import Binary_Serializable_Primitives
public import Parseable_ASCII_Primitives

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

extension RFC_1035.Domain.Label: Swift.RawRepresentable, ASCII.Serializable, Binary.Serializable {
    /// Creates a label by validating `rawValue`, or `nil` if it is not a valid RFC 1035 label.
    ///
    /// Re-provides the `Swift.RawRepresentable` requirement (previously inherited
    /// from the retired combined ASCII serializable protocol).
    public init?(rawValue: String) {
        do throws(Error) {
            try self.init(rawValue)
        } catch {
            return nil
        }
    }

    /// Serializes `value` as ASCII bytes into `buffer`.
    ///
    /// Own `ASCII.Serializable` witness (Phase D): emits the label's ASCII
    /// octets directly from `rawValue`, replacing the transitional default that
    /// routed conformers through the retired canonical `Serializable` tier.
    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ value: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == ASCII.Code {
        for byte in value.rawValue.utf8 { buffer.append(ASCII.Code(byte)) }
    }

    /// Serializes `value` as ASCII bytes into `buffer`.
    ///
    /// Explicit `Binary.Serializable` witness: disambiguates the two
    /// constraint-incomparable `serialize(_:into:)` defaults (the RawRepresentable
    /// default vs the W0 ASCII bridge) — a conformer-declared member out-ranks both.
    /// The bytes derive from the free `[ASCII.Code]` serializer supplied by the
    /// `String`-RawRepresentable default (`.serialized`).
    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ value: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        buffer.append(contentsOf: value.serialized)
    }
}

extension RFC_1035.Domain.Label: CustomStringConvertible {
    /// The label's ASCII serialization decoded as a `String`.
    public var description: String {
        String(decoding: serialized, as: UTF8.self)
    }
}

extension RFC_1035.Domain.Label: ASCII.Parseable {
    /// Creates a label by validating `string`'s UTF-8 bytes as ASCII.
    ///
    /// Re-provides the string convenience initializer (previously inherited from
    /// the retired combined ASCII serializable protocol, Void context).
    public init(_ string: some StringProtocol) throws(Error) {
        try self.init(ascii: [Byte](string.utf8))
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
    public init<Bytes: Collection>(ascii bytes: Bytes) throws(Error)
    where Bytes.Element == Byte {
        guard let firstByte = bytes.first else {
            throw Error.empty
        }

        var count = 0
        var lastByte = firstByte

        for byte in bytes {
            count += 1
            lastByte = byte

            // A byte outside the 7-bit ASCII range cannot be a valid label
            // character; ASCII.Code(_:) throws for it, mapping to the same
            // invalid-character error as a wrong-category ASCII byte.
            let code: ASCII.Code
            do throws(ASCII.Code.Error) {
                code = try ASCII.Code(byte)
            } catch {
                let string = String(decoding: bytes, as: UTF8.self)
                throw Error.invalidCharacters(
                    string,
                    byte: byte,
                    reason: "Only letters, digits, and hyphens allowed"
                )
            }
            let validInterior = code.isLetter || code.isDigit || code == ASCII.Code.hyphen
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

        // A non-ASCII first byte cannot start a label; map ASCII.Code(_:)'s
        // throw to the generic "must start with a letter" invalid-character error.
        let firstCode: ASCII.Code
        do throws(ASCII.Code.Error) {
            firstCode = try ASCII.Code(firstByte)
        } catch {
            let string = String(decoding: bytes, as: UTF8.self)
            throw Error.invalidCharacters(
                string,
                byte: firstByte,
                reason: "Must start with a letter"
            )
        }
        guard firstCode.isLetter else {
            let string = String(decoding: bytes, as: UTF8.self)
            if firstCode == ASCII.Code.hyphen {
                throw Error.startsWithHyphen(string)
            } else if firstCode.isDigit {
                throw Error.startsWithDigit(string)
            } else {
                throw Error.invalidCharacters(
                    string,
                    byte: firstByte,
                    reason: "Must start with a letter"
                )
            }
        }

        // A non-ASCII last byte cannot end a label; map ASCII.Code(_:)'s throw
        // to the generic "must end with a letter or digit" invalid-character error.
        let lastCode: ASCII.Code
        do throws(ASCII.Code.Error) {
            lastCode = try ASCII.Code(lastByte)
        } catch {
            let string = String(decoding: bytes, as: UTF8.self)
            throw Error.invalidCharacters(
                string,
                byte: lastByte,
                reason: "Must end with a letter or digit"
            )
        }
        guard lastCode.isLetter || lastCode.isDigit else {
            let string = String(decoding: bytes, as: UTF8.self)
            if lastCode == ASCII.Code.hyphen {
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
