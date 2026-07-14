// ===----------------------------------------------------------------------===//
//
// Copyright (c) 2025 Coen ten Thije Boonkkamp
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of project contributors
//
// SPDX-License-Identifier: Apache-2.0
//
// ===----------------------------------------------------------------------===//

// RFC_1035.CharacterString.swift
// swift-rfc-1035
//
// RFC 1035 Section 3.3: <character-string>

public import Binary_Serializable_Primitives

extension RFC_1035 {
    /// A `<character-string>` (RFC 1035 Section 3.3).
    ///
    /// > `<character-string>` is a single length octet followed by that number
    /// > of characters. `<character-string>` is treated as binary information,
    /// > and can be up to 256 characters in length (including the length octet).
    ///
    /// The single length octet caps the payload at 255 octets. The content is
    /// arbitrary binary, so it is modelled as `[Byte]` rather than a validated
    /// ASCII string.
    public struct CharacterString: Sendable, Hashable {
        /// The content octets (0...255 bytes; the length octet is not stored).
        public let bytes: [Byte]

        /// Creates a `<character-string>` WITHOUT validating the length.
        ///
        /// The caller guarantees `bytes.count <= 255`. Used by the wire reader,
        /// where the count originates from a single length octet and therefore
        /// cannot exceed 255.
        init(__unchecked _: Void, bytes: [Byte]) {
            self.bytes = bytes
        }
    }
}

// MARK: - Validated initializers

extension RFC_1035.CharacterString {
    /// The maximum content length (the single length octet caps this at 255).
    public static let maxLength = 255

    /// Creates a `<character-string>` from content octets.
    ///
    /// - Throws: ``Error/tooLong(_:)`` if `bytes.count` exceeds 255.
    public init(bytes: [Byte]) throws(Error) {
        guard bytes.count <= Self.maxLength else {
            throw .tooLong(bytes.count)
        }
        self.init(__unchecked: (), bytes: bytes)
    }

    /// Creates a `<character-string>` from a string's UTF-8 bytes.
    ///
    /// - Throws: ``Error/tooLong(_:)`` if the UTF-8 encoding exceeds 255 octets.
    public init(_ text: some StringProtocol) throws(Error) {
        try self.init(bytes: text.utf8.map(Byte.init))
    }
}

// MARK: - Binary.Serializable

extension RFC_1035.CharacterString: Binary.Serializable {
    /// Serializes a `<character-string>`: one length octet followed by the
    /// content octets (RFC 1035 Section 3.3).
    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ value: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        buffer.append(Byte(UInt8(truncatingIfNeeded: value.bytes.count)))
        buffer.append(contentsOf: value.bytes)
    }
}
