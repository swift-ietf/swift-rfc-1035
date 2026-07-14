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

// DNSWireVectors.swift
// swift-rfc-1035 tests
//
// Shared hex helpers and the captured real DNS wire vectors used as the
// test oracle. The three query/response pairs below were captured live from
// 1.1.1.1 (Cloudflare). Responses use `c00c` compression pointers back to the
// question name at offset 12.

import Binary_Serializable_Primitives

/// Decodes a contiguous hex string (no separators) into `[Byte]`.
func dnsHexBytes(_ hex: String) -> [Byte] {
    var result: [Byte] = []
    result.reserveCapacity(hex.count / 2)
    var iterator = hex.makeIterator()
    while let high = iterator.next(), let low = iterator.next() {
        guard let value = UInt8(String([high, low]), radix: 16) else {
            continue
        }
        result.append(Byte(value))
    }
    return result
}

/// Renders `[Byte]` as a lowercase contiguous hex string (for failure output).
func dnsHexString(_ bytes: [Byte]) -> String {
    var out = ""
    out.reserveCapacity(bytes.count * 2)
    for byte in bytes {
        let value = byte.underlying
        out.append(hexDigit(value >> 4))
        out.append(hexDigit(value & 0x0F))
    }
    return out
}

private func hexDigit(_ nibble: UInt8) -> Character {
    nibble < 10
        ? Character(Unicode.Scalar(nibble + 0x30))  // '0'...'9'
        : Character(Unicode.Scalar(nibble - 10 + 0x61))  // 'a'...'f'
}

/// The captured wire vectors (contiguous hex, no separators).
enum DNSVectors {
    // example.com, TYPE A (1)
    static let queryExampleA =
        "2b7d01000001000000000000076578616d706c6503636f6d0000010001"
    static let responseExampleA =
        "2b7d81800001000200000000076578616d706c6503636f6d0000010001"
        + "c00c000100010000001d0004ac4293f3"
        + "c00c000100010000001d00046814179a"

    // example.com, TYPE AAAA (28) — AAAA belongs to RFC 3596, so it parses as
    // .opaque (16 raw octets) here.
    static let queryExampleAAAA =
        "2b7d01000001000000000000076578616d706c6503636f6d00001c0001"
    static let responseExampleAAAA =
        "2b7d81800001000200000000076578616d706c6503636f6d00001c0001"
        + "c00c001c0001000000b30010260647000010000000000000ac4293f3"
        + "c00c001c0001000000b300102606470000100000000000006814179a"

    // www.example.com, TYPE A (1)
    static let queryWWWExampleA =
        "2b7d0100000100000000000003777777076578616d706c6503636f6d0000010001"
    static let responseWWWExampleA =
        "2b7d8180000100020000000003777777076578616d706c6503636f6d0000010001"
        + "c00c000100010000005100046814179a"
        + "c00c00010001000000510004ac4293f3"
}
