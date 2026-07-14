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

// RFC_1035.Message.Header.Rcode.swift
// swift-rfc-1035
//
// RFC 1035 Section 4.1.1: RCODE

extension RFC_1035.Message.Header {
    /// The header `RCODE` — the four-bit response code (RFC 1035 Section 4.1.1).
    ///
    /// Only the low four bits are significant; values 6–15 are reserved by
    /// RFC 1035. Modelled as an **open set** so that codes defined by later
    /// RFCs round-trip through ``rawValue`` unchanged.
    ///
    /// - Note: This models only the base four-bit `RCODE`. The EDNS0 extended
    ///   RCODE (RFC 6891, which widens the code using the OPT pseudo-record's
    ///   TTL bits) is deliberately out of scope for RFC 1035 and belongs to
    ///   `swift-rfc-6891`.
    public struct Rcode: Sendable, Hashable {
        /// The four-bit response code (only the low nibble is significant).
        public let rawValue: UInt8

        /// Creates a response code from a raw value.
        public init(rawValue: UInt8) {
            self.rawValue = rawValue
        }

        /// Creates a response code from a raw value WITHOUT any lookup.
        init(__unchecked _: Void, rawValue: UInt8) {
            self.rawValue = rawValue
        }
    }
}

// MARK: - Well-known response codes (RFC 1035 Section 4.1.1)

extension RFC_1035.Message.Header.Rcode {
    /// `NoError` (0) — no error condition.
    public static let noError = Self(__unchecked: (), rawValue: 0)

    /// `FormErr` (1) — the name server was unable to interpret the query.
    public static let formatError = Self(__unchecked: (), rawValue: 1)

    /// `ServFail` (2) — the name server was unable to process the query.
    public static let serverFailure = Self(__unchecked: (), rawValue: 2)

    /// `NXDomain` (3) — the domain name referenced does not exist.
    public static let nameError = Self(__unchecked: (), rawValue: 3)

    /// `NotImp` (4) — the name server does not support the requested query kind.
    public static let notImplemented = Self(__unchecked: (), rawValue: 4)

    /// `Refused` (5) — the name server refuses to perform the operation.
    public static let refused = Self(__unchecked: (), rawValue: 5)
}

// MARK: - CustomStringConvertible

extension RFC_1035.Message.Header.Rcode: CustomStringConvertible {
    public var description: String {
        switch rawValue {
        case 0: return "NoError"
        case 1: return "FormErr"
        case 2: return "ServFail"
        case 3: return "NXDomain"
        case 4: return "NotImp"
        case 5: return "Refused"
        default: return "RCODE\(rawValue)"
        }
    }
}
