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

// RFC_1035.Message.Header.Options.swift
// swift-rfc-1035
//
// RFC 1035 Section 4.1.1: the AA/TC/RD/RA flag bits

extension RFC_1035.Message.Header {
    /// The single-bit header flags `AA`, `TC`, `RD`, and `RA`
    /// (RFC 1035 Section 4.1.1).
    ///
    /// The `QR` bit is modelled separately as ``Kind`` and the `Z` bits are
    /// reserved-must-be-zero, so this option set covers exactly the four
    /// remaining independent one-bit fields.
    ///
    /// The `rawValue` deliberately uses the **same bit positions these flags
    /// occupy in the 16-bit header flags word** (big-endian, bit 0 = the most
    /// significant bit of octet 2). This lets the flags word be assembled by a
    /// simple bitwise OR of ``Kind``, ``Opcode``, this option set, and ``Rcode``.
    public struct Options: OptionSet, Sendable, Hashable {
        public let rawValue: UInt16

        public init(rawValue: UInt16) {
            self.rawValue = rawValue
        }

        /// `AA` — Authoritative Answer (bit 5 of the flags word, mask `0x0400`).
        ///
        /// Valid in responses: the responding name server is an authority for
        /// the domain name in the question section.
        public static let authoritativeAnswer = Self(rawValue: 0x0400)

        /// `TC` — TrunCation (bit 6 of the flags word, mask `0x0200`).
        ///
        /// The message was truncated due to length greater than that permitted
        /// on the transmission channel.
        public static let truncation = Self(rawValue: 0x0200)

        /// `RD` — Recursion Desired (bit 7 of the flags word, mask `0x0100`).
        ///
        /// May be set in a query and is copied into the response; directs the
        /// name server to pursue the query recursively.
        public static let recursionDesired = Self(rawValue: 0x0100)

        /// `RA` — Recursion Available (bit 8 of the flags word, mask `0x0080`).
        ///
        /// Set or cleared in a response; denotes whether recursive query support
        /// is available in the name server.
        public static let recursionAvailable = Self(rawValue: 0x0080)
    }
}

extension RFC_1035.Message.Header.Options {
    /// The bit mask covering exactly the four modelled flag bits
    /// (`AA | TC | RD | RA` = `0x0780`).
    ///
    /// Used when decoding a flags word to isolate the option bits from the
    /// `QR`, `OPCODE`, `Z`, and `RCODE` fields.
    static let mask: UInt16 = 0x0780
}
