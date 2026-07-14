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

// RFC_1035.RecordClass.swift
// swift-rfc-1035
//
// RFC 1035 Section 3.2.4 (CLASS) / Section 3.2.5 (QCLASS)

extension RFC_1035 {
    /// A DNS record CLASS / QCLASS code (two octets, RFC 1035 Section 3.2.4 / 3.2.5).
    ///
    /// QCLASS values are a superset of CLASS values — every CLASS is a valid
    /// QCLASS, and the ``any`` code (255) is query-only. As with ``RecordType``,
    /// one registry type carries both roles because they share the same
    /// two-octet code space on the wire.
    ///
    /// The type is an **open set**: unrecognized codes round-trip through
    /// ``rawValue`` unchanged.
    public struct RecordClass: Sendable, Hashable {
        /// The two-octet CLASS / QCLASS code.
        public let rawValue: UInt16

        /// Creates a record class from a raw two-octet code.
        public init(rawValue: UInt16) {
            self.rawValue = rawValue
        }

        /// Creates a record class from a raw code WITHOUT any lookup.
        init(__unchecked _: Void, rawValue: UInt16) {
            self.rawValue = rawValue
        }
    }
}

// MARK: - Well-known CLASS values (RFC 1035 Section 3.2.4)

extension RFC_1035.RecordClass {
    /// `IN` (1) — the Internet.
    public static let internet = Self(__unchecked: (), rawValue: 1)

    /// `CS` (2) — the CSNET class (Obsolete).
    public static let csnet = Self(__unchecked: (), rawValue: 2)

    /// `CH` (3) — the CHAOS class.
    public static let chaos = Self(__unchecked: (), rawValue: 3)

    /// `HS` (4) — Hesiod [Dyer 87].
    public static let hesiod = Self(__unchecked: (), rawValue: 4)
}

// MARK: - Well-known QCLASS-only values (RFC 1035 Section 3.2.5)

extension RFC_1035.RecordClass {
    /// `*` / `ANY` (255) — any class (QCLASS-only).
    public static let any = Self(__unchecked: (), rawValue: 255)
}

// MARK: - CustomStringConvertible

extension RFC_1035.RecordClass: CustomStringConvertible {
    public var description: String {
        switch rawValue {
        case 1: return "IN"
        case 2: return "CS"
        case 3: return "CH"
        case 4: return "HS"
        case 255: return "*"
        default: return "CLASS\(rawValue)"
        }
    }
}
