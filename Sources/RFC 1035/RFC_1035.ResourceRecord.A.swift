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

// RFC_1035.ResourceRecord.A.swift
// swift-rfc-1035
//
// RFC 1035 Section 3.4.1: A RDATA format

public import Binary_Serializable_Primitives

extension RFC_1035.ResourceRecord {
    /// The `RDATA` of an `A` record — a 32-bit Internet address
    /// (RFC 1035 Section 3.4.1).
    ///
    /// ```
    /// +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    /// |                    ADDRESS                    |
    /// +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    /// ```
    ///
    /// This is a minimal, self-contained value holding the four address octets.
    /// It is intentionally not the ecosystem's canonical IPv4 address type:
    /// `swift-rfc-1035` may not depend on an address package, and integrating
    /// RFC 791 is a separate satellite decision. The type and its
    /// ``octets`` surface are shaped so that a future `RFC_791.IPv4.Address`
    /// bridge (e.g. an `init(_:)` from that type, or an `address` accessor) is a
    /// purely additive change.
    public struct A: Sendable, Hashable {
        /// The four address octets in network order (e.g. `172.66.147.243` is
        /// `[172, 66, 147, 243]`).
        public let octets: [Byte]

        /// Creates an `A` record body WITHOUT validating the octet count.
        ///
        /// The caller guarantees `octets.count == 4`. Used by the wire reader,
        /// which reads exactly four octets.
        init(__unchecked _: Void, octets: [Byte]) {
            self.octets = octets
        }
    }
}

// MARK: - Validated initializers

extension RFC_1035.ResourceRecord.A {
    /// The fixed number of octets in an IPv4 address.
    public static let octetCount = 4

    /// Creates an `A` record body from four octets.
    public init(_ a: UInt8, _ b: UInt8, _ c: UInt8, _ d: UInt8) {
        self.init(__unchecked: (), octets: [Byte(a), Byte(b), Byte(c), Byte(d)])
    }

    /// Creates an `A` record body from an octet array.
    ///
    /// - Throws: ``Error/invalidOctetCount(_:)`` unless `octets.count == 4`.
    public init(octets: [Byte]) throws(Error) {
        guard octets.count == Self.octetCount else {
            throw .invalidOctetCount(octets.count)
        }
        self.init(__unchecked: (), octets: octets)
    }
}

// MARK: - Binary.Serializable

extension RFC_1035.ResourceRecord.A: Binary.Serializable {
    /// Serializes the four address octets (RFC 1035 Section 3.4.1).
    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ value: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        buffer.append(contentsOf: value.octets)
    }
}

// MARK: - CustomStringConvertible

extension RFC_1035.ResourceRecord.A: CustomStringConvertible {
    /// The address in dotted-quad presentation form (e.g. `"172.66.147.243"`).
    public var description: String {
        octets.map { String($0.underlying) }.joined(separator: ".")
    }
}
