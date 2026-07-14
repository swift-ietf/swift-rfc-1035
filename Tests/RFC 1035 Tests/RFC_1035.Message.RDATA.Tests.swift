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

// RFC_1035.Message.RDATA.Tests.swift
// swift-rfc-1035 tests
//
// Typed RDATA round-trips (RFC 1035 Sections 3.3 / 3.4) and message-level
// structural errors (RFC 1035 Section 4.1).

import Binary_Serializable_Primitives
import Testing

@testable import RFC_1035

@Suite
struct `DNS RDATA and message structure` {

    private typealias Record = RFC_1035.ResourceRecord

    // MARK: - Typed RDATA round-trips

    @Test
    func `every typed RDATA format round-trips through the wire`() throws {
        let owner = try RFC_1035.Domain("example.com")

        let ns = Record(
            name: owner, type: .ns, `class`: .internet, ttl: 3600,
            data: .ns(try RFC_1035.Domain("ns1.example.com"))
        )
        let cname = Record(
            name: try RFC_1035.Domain("www.example.com"), type: .cname, `class`: .internet,
            ttl: 300, data: .cname(owner)
        )
        let ptr = Record(
            name: owner, type: .ptr, `class`: .internet, ttl: 60,
            data: .ptr(try RFC_1035.Domain("host.example.com"))
        )
        let mx = Record(
            name: owner, type: .mx, `class`: .internet, ttl: 3600,
            data: .mx(preference: 10, exchange: try RFC_1035.Domain("mail.example.com"))
        )
        let txt = Record(
            name: owner, type: .txt, `class`: .internet, ttl: 3600,
            data: .txt([try RFC_1035.CharacterString("v=spf1 -all"), try RFC_1035.CharacterString("hello")])
        )
        let soa = Record(
            name: owner, type: .soa, `class`: .internet, ttl: 3600,
            data: .soa(
                RFC_1035.ResourceRecord.SOA(
                    mname: try RFC_1035.Domain("ns1.example.com"),
                    rname: try RFC_1035.Domain("hostmaster.example.com"),
                    serial: 2_021_010_101,
                    refresh: 7200,
                    retry: 3600,
                    expire: 1_209_600,
                    minimum: 3600
                )
            )
        )
        let a = Record(
            name: owner, type: .a, `class`: .internet, ttl: 3600,
            data: .a(RFC_1035.ResourceRecord.A(93, 184, 216, 34))
        )
        let opaque = Record(
            name: owner, type: RFC_1035.RecordType(rawValue: 99), `class`: .internet, ttl: 3600,
            data: .opaque([Byte(0xDE), Byte(0xAD), Byte(0xBE), Byte(0xEF)])
        )

        let message = RFC_1035.Message(
            header: RFC_1035.Message.Header(id: 0x1234, kind: .response),
            answers: [ns, cname, ptr, mx, txt, soa, a, opaque]
        )

        let parsed = try RFC_1035.Message(binary: message.bytes)
        #expect(parsed == message)
        #expect(parsed.answers.count == 8)

        // Spot-check that each format decoded to the right case/value.
        #expect(parsed.answers[0].data == .ns(try RFC_1035.Domain("ns1.example.com")))
        #expect(parsed.answers[1].data == .cname(owner))
        #expect(parsed.answers[2].data == .ptr(try RFC_1035.Domain("host.example.com")))
        #expect(parsed.answers[3].data == .mx(preference: 10, exchange: try RFC_1035.Domain("mail.example.com")))
        #expect(parsed.answers[6].data == .a(RFC_1035.ResourceRecord.A(93, 184, 216, 34)))

        // Unknown TYPE preserved verbatim, and its type code survives.
        #expect(parsed.answers[7].type == RFC_1035.RecordType(rawValue: 99))
        #expect(parsed.answers[7].data == .opaque([Byte(0xDE), Byte(0xAD), Byte(0xBE), Byte(0xEF)]))
    }

    @Test
    func `TXT preserves multiple character-strings`() throws {
        let owner = try RFC_1035.Domain("example.com")
        let strings = [
            try RFC_1035.CharacterString("first"),
            try RFC_1035.CharacterString(""),
            try RFC_1035.CharacterString("third chunk"),
        ]
        let record = Record(
            name: owner, type: .txt, `class`: .internet, ttl: 3600, data: .txt(strings)
        )
        let message = RFC_1035.Message(
            header: RFC_1035.Message.Header(id: 1, kind: .response), answers: [record]
        )

        let parsed = try RFC_1035.Message(binary: message.bytes)
        #expect(parsed.answers[0].data == .txt(strings))
    }

    // MARK: - Message-level structural errors

    @Test
    func `truncation at every offset is rejected`() throws {
        let full = dnsHexBytes(DNSVectors.queryExampleA)
        for cut in [0, 4, 11, 12, 15, 20, full.count - 1] {
            let prefix = Array(full.prefix(cut))
            #expect(throws: RFC_1035.Message.Error.truncated) {
                _ = try RFC_1035.Message(binary: prefix)
            }
        }
    }

    @Test
    func `trailing bytes after a complete message are rejected`() {
        var bytes = dnsHexBytes(DNSVectors.queryExampleA)
        bytes.append(Byte(0xFF))
        #expect(throws: RFC_1035.Message.Error.trailingData(1)) {
            _ = try RFC_1035.Message(binary: bytes)
        }
    }

    @Test
    func `an ANCOUNT smaller than the records present leaves trailing data`() {
        // Response has ANCOUNT=2; force it to 1 (offset 6-7 in the header).
        var bytes = dnsHexBytes(DNSVectors.responseExampleA)
        bytes[7] = Byte(0x01)
        #expect(throws: RFC_1035.Message.Error.trailingData(16)) {
            _ = try RFC_1035.Message(binary: bytes)
        }
    }

    @Test
    func `an ANCOUNT larger than the records present truncates`() {
        var bytes = dnsHexBytes(DNSVectors.responseExampleA)
        bytes[7] = Byte(0x03)
        #expect(throws: RFC_1035.Message.Error.truncated) {
            _ = try RFC_1035.Message(binary: bytes)
        }
    }

    @Test
    func `a nonzero Z bit in the header is rejected`() {
        // Query flags are 0x0100 (offset 2-3); set a Z bit (0x0010).
        var bytes = dnsHexBytes(DNSVectors.queryExampleA)
        bytes[3] = Byte(0x10)
        #expect(throws: RFC_1035.Message.Error.nonzeroReserved) {
            _ = try RFC_1035.Message(binary: bytes)
        }
    }

    // MARK: - CharacterString validation

    @Test
    func `a character-string longer than 255 octets is rejected`() {
        let tooLong = [Byte](repeating: Byte(0x61), count: 256)
        #expect(throws: RFC_1035.CharacterString.Error.tooLong(256)) {
            _ = try RFC_1035.CharacterString(bytes: tooLong)
        }
    }

    @Test
    func `an A record requires exactly four octets`() {
        #expect(throws: RFC_1035.ResourceRecord.A.Error.invalidOctetCount(3)) {
            _ = try RFC_1035.ResourceRecord.A(octets: [Byte(1), Byte(2), Byte(3)])
        }
    }
}
