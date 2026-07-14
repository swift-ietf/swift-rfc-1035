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

// RFC_1035.Wire.Compression.Tests.swift
// swift-rfc-1035 tests
//
// Hand-computed name-compression and label-parsing vectors exercising the
// message-context reader (RFC 1035 Section 3.1 / 4.1.4) directly.

import Testing

@testable import RFC_1035

@Suite
struct `DNS name compression and label parsing` {

    /// Reads a single name from `hex` starting at offset 0.
    private func readName(_ hex: String) throws(RFC_1035.Wire.Error) -> RFC_1035.Domain {
        var reader = RFC_1035.Wire.Reader(dnsHexBytes(hex))
        return try reader.name()
    }

    // MARK: - Valid resolution

    @Test
    func `reads an uncompressed name`() throws {
        // 03 'f''o''o' 00
        let domain = try readName("03666f6f00")
        #expect(domain == (try RFC_1035.Domain("foo")))
    }

    @Test
    func `resolves a multi-level pointer chase`() throws {
        // offset 0:  03 'f''o''o' 00                 -> "foo"
        // offset 5:  03 'b''a''r' C0 00              -> "bar" + ptr->0  == "bar.foo"
        // offset 11: C0 05                           -> ptr->5          == "bar.foo"
        let hex = "03666f6f0003626172c000c005"
        var reader = RFC_1035.Wire.Reader(dnsHexBytes(hex))

        let first = try reader.name()
        let second = try reader.name()
        let third = try reader.name()

        #expect(first == (try RFC_1035.Domain("foo")))
        #expect(second == (try RFC_1035.Domain("bar.foo")))
        // `third` chases pointer -> 5 -> (labels) -> pointer -> 0: a genuine
        // two-hop chase, and the strictly-decreasing guard must NOT reject it.
        #expect(third == (try RFC_1035.Domain("bar.foo")))
    }

    // MARK: - Pointer violations

    @Test
    func `rejects a forward pointer`() {
        // C0 04 -> offset 4, which is >= the pointer's own position 0.
        #expect(throws: RFC_1035.Wire.Error.pointerNotBackward) {
            _ = try readName("c004")
        }
    }

    @Test
    func `rejects a self-pointer`() {
        // C0 00 at offset 0 -> offset 0, not strictly less than position 0.
        #expect(throws: RFC_1035.Wire.Error.pointerNotBackward) {
            _ = try readName("c000")
        }
    }

    @Test
    func `rejects a pointer loop`() {
        // 03 'b''a''r' C0 00 : after reading "bar" the pointer at position 4
        // jumps to 0, re-reads "bar", and meets the same pointer at position 4
        // again -> not strictly decreasing -> loop.
        #expect(throws: RFC_1035.Wire.Error.pointerLoop) {
            _ = try readName("03626172c000")
        }
    }

    // MARK: - Reserved label discriminants

    @Test
    func `rejects the reserved 0b01 label discriminant`() {
        #expect(throws: RFC_1035.Wire.Error.reservedLabelBits) {
            _ = try readName("40")
        }
    }

    @Test
    func `rejects the reserved 0b10 label discriminant`() {
        #expect(throws: RFC_1035.Wire.Error.reservedLabelBits) {
            _ = try readName("80")
        }
    }

    // MARK: - Length limits

    @Test
    func `rejects a name exceeding 255 octets`() {
        // Four maximal 63-octet labels = 4 * 64 = 256 octets > 255.
        let label = "3f" + String(repeating: "61", count: 63)  // 0x3f + 63 * 'a'
        let hex = String(repeating: label, count: 4)
        #expect(throws: RFC_1035.Wire.Error.nameTooLong) {
            _ = try readName(hex)
        }
    }

    @Test
    func `rejects the root name as unrepresentable`() {
        // A bare zero octet is the root; RFC_1035.Domain cannot represent it.
        #expect(throws: RFC_1035.Wire.Error.rootName) {
            _ = try readName("00")
        }
    }

    @Test
    func `rejects a truncated label`() {
        // Length octet claims 5 octets but only 2 follow.
        #expect(throws: RFC_1035.Wire.Error.truncated) {
            _ = try readName("056162")
        }
    }
}
