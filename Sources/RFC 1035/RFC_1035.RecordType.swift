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

// RFC_1035.RecordType.swift
// swift-rfc-1035
//
// RFC 1035 Section 3.2.2 (TYPE) / Section 3.2.3 (QTYPE)

extension RFC_1035 {
    /// A DNS record TYPE / QTYPE code (two octets, RFC 1035 Section 3.2.2 / 3.2.3).
    ///
    /// QTYPEs are a superset of TYPEs — every TYPE is a valid QTYPE, and a few
    /// codes (``axfr``, ``mailb``, ``maila``, ``any``) are query-only. This one
    /// registry type carries both roles: the `Question` type field is a QTYPE and
    /// the resource-record type field is a TYPE, but on the wire they occupy the
    /// same two-octet code space.
    ///
    /// The type is an **open set**: unrecognized codes round-trip through
    /// ``rawValue`` unchanged so that types defined by later RFCs (e.g. AAAA,
    /// RFC 3596) parse and re-serialize losslessly.
    public struct RecordType: Sendable, Hashable {
        /// The two-octet TYPE / QTYPE code.
        public let rawValue: UInt16

        /// Creates a record type from a raw two-octet code.
        public init(rawValue: UInt16) {
            self.rawValue = rawValue
        }

        /// Creates a record type from a raw code WITHOUT any lookup.
        ///
        /// Used by the well-known static factories below; identical in effect to
        /// ``init(rawValue:)`` but marks intent at the call site.
        init(__unchecked _: Void, rawValue: UInt16) {
            self.rawValue = rawValue
        }
    }
}

// MARK: - Well-known TYPE values (RFC 1035 Section 3.2.2)

extension RFC_1035.RecordType {
    /// `A` (1) — a host address (RFC 1035 Section 3.4.1).
    public static let a = Self(__unchecked: (), rawValue: 1)

    /// `NS` (2) — an authoritative name server (RFC 1035 Section 3.3.11).
    public static let ns = Self(__unchecked: (), rawValue: 2)

    /// `MD` (3) — a mail destination (Obsolete — use MX).
    public static let md = Self(__unchecked: (), rawValue: 3)

    /// `MF` (4) — a mail forwarder (Obsolete — use MX).
    public static let mf = Self(__unchecked: (), rawValue: 4)

    /// `CNAME` (5) — the canonical name for an alias (RFC 1035 Section 3.3.1).
    public static let cname = Self(__unchecked: (), rawValue: 5)

    /// `SOA` (6) — marks the start of a zone of authority (RFC 1035 Section 3.3.13).
    public static let soa = Self(__unchecked: (), rawValue: 6)

    /// `MB` (7) — a mailbox domain name (EXPERIMENTAL).
    public static let mb = Self(__unchecked: (), rawValue: 7)

    /// `MG` (8) — a mail group member (EXPERIMENTAL).
    public static let mg = Self(__unchecked: (), rawValue: 8)

    /// `MR` (9) — a mail rename domain name (EXPERIMENTAL).
    public static let mr = Self(__unchecked: (), rawValue: 9)

    /// `NULL` (10) — a null RR (EXPERIMENTAL).
    public static let null = Self(__unchecked: (), rawValue: 10)

    /// `WKS` (11) — a well known service description (RFC 1035 Section 3.4.2).
    public static let wks = Self(__unchecked: (), rawValue: 11)

    /// `PTR` (12) — a domain name pointer (RFC 1035 Section 3.3.12).
    public static let ptr = Self(__unchecked: (), rawValue: 12)

    /// `HINFO` (13) — host information (RFC 1035 Section 3.3.2).
    public static let hinfo = Self(__unchecked: (), rawValue: 13)

    /// `MINFO` (14) — mailbox or mail list information (RFC 1035 Section 3.3.7).
    public static let minfo = Self(__unchecked: (), rawValue: 14)

    /// `MX` (15) — mail exchange (RFC 1035 Section 3.3.9).
    public static let mx = Self(__unchecked: (), rawValue: 15)

    /// `TXT` (16) — text strings (RFC 1035 Section 3.3.14).
    public static let txt = Self(__unchecked: (), rawValue: 16)
}

// MARK: - Well-known QTYPE-only values (RFC 1035 Section 3.2.3)

extension RFC_1035.RecordType {
    /// `AXFR` (252) — a request for a transfer of an entire zone (QTYPE-only).
    public static let axfr = Self(__unchecked: (), rawValue: 252)

    /// `MAILB` (253) — a request for mailbox-related records (QTYPE-only).
    public static let mailb = Self(__unchecked: (), rawValue: 253)

    /// `MAILA` (254) — a request for mail agent RRs (Obsolete; QTYPE-only).
    public static let maila = Self(__unchecked: (), rawValue: 254)

    /// `*` / `ANY` (255) — a request for all records (QTYPE-only).
    public static let any = Self(__unchecked: (), rawValue: 255)
}

// MARK: - CustomStringConvertible

extension RFC_1035.RecordType: CustomStringConvertible {
    public var description: String {
        switch rawValue {
        case 1: return "A"
        case 2: return "NS"
        case 3: return "MD"
        case 4: return "MF"
        case 5: return "CNAME"
        case 6: return "SOA"
        case 7: return "MB"
        case 8: return "MG"
        case 9: return "MR"
        case 10: return "NULL"
        case 11: return "WKS"
        case 12: return "PTR"
        case 13: return "HINFO"
        case 14: return "MINFO"
        case 15: return "MX"
        case 16: return "TXT"
        case 252: return "AXFR"
        case 253: return "MAILB"
        case 254: return "MAILA"
        case 255: return "*"
        default: return "TYPE\(rawValue)"
        }
    }
}
