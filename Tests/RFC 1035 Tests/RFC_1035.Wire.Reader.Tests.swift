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

// RFC_1035.Wire.Reader.Tests.swift
// swift-rfc-1035 tests
//
// Regression vectors for fable-448 F-001: wire-legal DNS names (digit-first,
// underscore, root) must decode without being forced through the strict
// RFC 1035 Section 2.3.1 preferred-syntax presentation validation.

import Testing

@testable import RFC_1035

extension RFC_1035.Wire.Reader {
    @Suite
    struct `Edge Case` {

        /// Reads a single name from `hex` starting at offset 0.
        private func readName(_ hex: String) throws(RFC_1035.Wire.Error) -> RFC_1035.Domain {
            var reader = RFC_1035.Wire.Reader(dnsHexBytes(hex))
            return try reader.name()
        }

        // MARK: - F-001: wire-legal names rejected by preferred-syntax validation

        @Test
        func `decodes a digit-first label`() throws {
            // 04 '3''c''o''m' 03 'c''o''m' 00 -> "3com.com"
            let domain = try readName("0433636f6d03636f6d00")
            #expect(domain.labels.map(\.rawValue) == ["3com", "com"])
        }

        @Test
        func `decodes an underscore label`() throws {
            // 06 '_''d''m''a''r''c' 07 'e''x''a''m''p''l''e' 00 -> "_dmarc.example"
            let domain = try readName("065f646d617263076578616d706c6500")
            #expect(domain.labels.map(\.rawValue) == ["_dmarc", "example"])
        }

        @Test
        func `decodes the root name`() throws {
            // A bare zero octet is the root name.
            let domain = try readName("00")
            #expect(domain.labels.isEmpty)
            #expect(domain.rawValue == ".")
        }

        @Test
        func `round-trips a wire-legal name through the writer`() throws {
            let hex = "065f646d617263076578616d706c6500"
            let domain = try readName(hex)
            var buffer: [Byte] = []
            RFC_1035.Wire.appendName(domain, into: &buffer)
            #expect(dnsHexString(buffer) == hex)
        }

        @Test
        func `round-trips the root name through the writer`() throws {
            let domain = try readName("00")
            var buffer: [Byte] = []
            RFC_1035.Wire.appendName(domain, into: &buffer)
            #expect(dnsHexString(buffer) == "00")
        }
    }
}
