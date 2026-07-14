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

// RFC_1035.Message.Header.Opcode.swift
// swift-rfc-1035
//
// RFC 1035 Section 4.1.1: OPCODE

extension RFC_1035.Message.Header {
    /// The header `OPCODE` — a four-bit field specifying the kind of query
    /// (RFC 1035 Section 4.1.1).
    ///
    /// Only the low four bits are significant; values 3–15 are reserved for
    /// future use by RFC 1035. Modelled as an **open set** so that opcodes
    /// defined by later RFCs (e.g. NOTIFY, UPDATE) round-trip through
    /// ``rawValue`` unchanged.
    public struct Opcode: Sendable, Hashable {
        /// The four-bit opcode value (only the low nibble is significant).
        public let rawValue: UInt8

        /// Creates an opcode from a raw value.
        public init(rawValue: UInt8) {
            self.rawValue = rawValue
        }

        /// Creates an opcode from a raw value WITHOUT any lookup.
        init(__unchecked _: Void, rawValue: UInt8) {
            self.rawValue = rawValue
        }
    }
}

// MARK: - Well-known opcodes (RFC 1035 Section 4.1.1)

extension RFC_1035.Message.Header.Opcode {
    /// `QUERY` (0) — a standard query.
    public static let query = Self(__unchecked: (), rawValue: 0)

    /// `IQUERY` (1) — an inverse query.
    public static let inverseQuery = Self(__unchecked: (), rawValue: 1)

    /// `STATUS` (2) — a server status request.
    public static let status = Self(__unchecked: (), rawValue: 2)
}

// MARK: - CustomStringConvertible

extension RFC_1035.Message.Header.Opcode: CustomStringConvertible {
    public var description: String {
        switch rawValue {
        case 0: return "QUERY"
        case 1: return "IQUERY"
        case 2: return "STATUS"
        default: return "OPCODE\(rawValue)"
        }
    }
}
