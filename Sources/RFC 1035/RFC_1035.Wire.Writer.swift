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

// RFC_1035.Wire.Writer.swift
// swift-rfc-1035
//
// DNS message wire codec: name append helpers

internal import Binary_Serializable_Primitives

extension RFC_1035.Wire {
    /// Appends a domain name in the length-prefixed label form terminated by a
    /// zero octet (RFC 1035 Section 3.1), **uncompressed**.
    ///
    /// Each label is written as a one-octet length (its top two bits are
    /// guaranteed zero because ``RFC_1035/Domain/Label`` validation limits a
    /// label to 63 octets) followed by the label octets, and the name ends with
    /// a single zero octet for the null label of the root.
    ///
    /// Compression pointers (RFC 1035 Section 4.1.4) are never emitted:
    /// compression is optional, and always writing the expanded form keeps
    /// serialization context-free and byte-deterministic.
    static func appendName<Buffer: RangeReplaceableCollection>(
        _ domain: RFC_1035.Domain,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        for label in domain.labels {
            let labelBytes = label.wireOctets
            buffer.append(Byte(UInt8(labelBytes.count)))
            buffer.append(contentsOf: labelBytes)
        }
        buffer.append(Byte(0))
    }
}
