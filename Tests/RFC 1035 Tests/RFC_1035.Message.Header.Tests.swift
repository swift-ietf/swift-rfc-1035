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

// RFC_1035.Message.Header.Tests.swift
// swift-rfc-1035 tests
//
// Header flags-word bit packing (RFC 1035 Section 4.1.1).

import Testing

@testable import RFC_1035

@Suite
struct `DNS message header bit packing` {

    private typealias Header = RFC_1035.Message.Header

    // MARK: - QR bit

    @Test
    func `query has QR clear`() {
        #expect(Header(id: 0x1234, kind: .query).flags == 0x0000)
    }

    @Test
    func `response sets QR`() {
        #expect(Header(id: 0x1234, kind: .response).flags == 0x8000)
    }

    // MARK: - OPCODE field

    @Test
    func `opcode packs into bits 11 through 14`() {
        #expect(Header(id: 0, kind: .query, opcode: .query).flags == 0x0000)
        #expect(Header(id: 0, kind: .query, opcode: .inverseQuery).flags == 0x0800)
        #expect(Header(id: 0, kind: .query, opcode: .status).flags == 0x1000)
        #expect(
            Header(id: 0, kind: .query, opcode: RFC_1035.Message.Header.Opcode(rawValue: 15)).flags
                == 0x7800
        )
    }

    // MARK: - AA / TC / RD / RA flags

    @Test
    func `each option bit occupies its RFC 1035 position`() {
        #expect(Header(id: 0, kind: .query, options: .authoritativeAnswer).flags == 0x0400)
        #expect(Header(id: 0, kind: .query, options: .truncation).flags == 0x0200)
        #expect(Header(id: 0, kind: .query, options: .recursionDesired).flags == 0x0100)
        #expect(Header(id: 0, kind: .query, options: .recursionAvailable).flags == 0x0080)
        #expect(
            Header(
                id: 0,
                kind: .query,
                options: [.authoritativeAnswer, .truncation, .recursionDesired, .recursionAvailable]
            ).flags == 0x0780
        )
    }

    // MARK: - RCODE field

    @Test
    func `rcode packs into the low four bits`() {
        #expect(Header(id: 0, kind: .query, rcode: .noError).flags == 0x0000)
        #expect(Header(id: 0, kind: .query, rcode: .formatError).flags == 0x0001)
        #expect(Header(id: 0, kind: .query, rcode: .serverFailure).flags == 0x0002)
        #expect(Header(id: 0, kind: .query, rcode: .nameError).flags == 0x0003)
        #expect(Header(id: 0, kind: .query, rcode: .notImplemented).flags == 0x0004)
        #expect(Header(id: 0, kind: .query, rcode: .refused).flags == 0x0005)
        #expect(
            Header(id: 0, kind: .query, rcode: RFC_1035.Message.Header.Rcode(rawValue: 15)).flags
                == 0x000F
        )
    }

    // MARK: - Z (reserved) bits

    @Test
    func `flags never emits the reserved Z bits`() {
        // Even with every other field maxed, bits 4-6 stay zero.
        let header = Header(
            id: 0xFFFF,
            kind: .response,
            opcode: RFC_1035.Message.Header.Opcode(rawValue: 15),
            options: [.authoritativeAnswer, .truncation, .recursionDesired, .recursionAvailable],
            rcode: RFC_1035.Message.Header.Rcode(rawValue: 15)
        )
        #expect(header.flags & 0x0070 == 0)
        #expect(header.flags == 0xFF8F)
    }

    @Test
    func `decoding rejects a nonzero Z`() {
        for zBit: UInt16 in [0x0010, 0x0020, 0x0040] {
            #expect(throws: RFC_1035.Message.Error.nonzeroReserved) {
                _ = try Header(id: 0, flags: 0x0100 | zBit)
            }
        }
    }

    // MARK: - Encode / decode round-trip

    @Test
    func `decodes the captured response flags word`() throws {
        let header = try Header(id: 0x2b7d, flags: 0x8180)
        #expect(header.id == 0x2b7d)
        #expect(header.kind == .response)
        #expect(header.opcode == .query)
        #expect(header.rcode == .noError)
        #expect(header.options == [.recursionDesired, .recursionAvailable])
    }

    @Test
    func `flags encode and decode round-trips`() throws {
        let headers = [
            Header(id: 0x0000, kind: .query),
            Header(id: 0xABCD, kind: .response, options: [.recursionDesired, .recursionAvailable]),
            Header(id: 0x1000, kind: .query, opcode: .status, options: .recursionDesired),
            Header(
                id: 0x7FFF,
                kind: .response,
                opcode: .inverseQuery,
                options: [.authoritativeAnswer, .truncation],
                rcode: .refused
            ),
        ]
        for header in headers {
            let round = try Header(id: header.id, flags: header.flags)
            #expect(round == header)
            #expect(round.flags == header.flags)
        }
    }
}
