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

// RFC_1035.ResourceRecord.swift
// swift-rfc-1035
//
// RFC 1035 Section 4.1.3: Resource record format

public import Binary_Serializable_Primitives

extension RFC_1035 {
    /// A resource record (RFC 1035 Section 4.1.3), the shared format of the
    /// answer, authority, and additional sections.
    ///
    /// ## Wire format
    ///
    /// ```
    /// +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    /// /                      NAME                     /
    /// +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    /// |                      TYPE                     |
    /// +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    /// |                     CLASS                     |
    /// +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    /// |                      TTL                      |
    /// +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    /// |                   RDLENGTH                    |
    /// +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    /// /                     RDATA                     /
    /// +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    /// ```
    ///
    /// `RDLENGTH` is not stored: it is derived from the serialized length of
    /// ``data`` and validated against the record boundary on parse.
    public struct ResourceRecord: Sendable, Hashable {
        /// `NAME` — the owner name to which this resource record pertains.
        public let name: RFC_1035.Domain

        /// `TYPE` — the RR type code.
        public let type: RFC_1035.RecordType

        /// `CLASS` — the class of the data in the `RDATA` field.
        public let `class`: RFC_1035.RecordClass

        /// `TTL` — the cache time interval, in seconds.
        ///
        /// RFC 1035 Section 3.2.1 describes `TTL` as a signed 32-bit integer and
        /// Section 2.3.4 limits it to "positive values of a signed 32 bit
        /// number"; RFC 1035 Section 4.1.3 (this record layout) and the later
        /// clarification RFC 2181 Section 8 read it as an **unsigned** 32-bit
        /// value with the top bit reserved. This stores the raw `UInt32` and
        /// applies no range rejection on parse — a value with the high bit set
        /// round-trips unchanged.
        public let ttl: UInt32

        /// `RDATA` — the typed resource data.
        public let data: RFC_1035.ResourceRecord.Data

        /// Creates a resource record from its fields.
        public init(
            name: RFC_1035.Domain,
            type: RFC_1035.RecordType,
            `class`: RFC_1035.RecordClass,
            ttl: UInt32,
            data: RFC_1035.ResourceRecord.Data
        ) {
            self.name = name
            self.type = type
            self.`class` = `class`
            self.ttl = ttl
            self.data = data
        }
    }
}

// MARK: - Binary.Serializable

extension RFC_1035.ResourceRecord: Binary.Serializable {
    /// Serializes a resource record (RFC 1035 Section 4.1.3).
    ///
    /// The owner `NAME` and any domain names inside `RDATA` are always emitted
    /// **uncompressed** — RFC 1035 Section 4.1.4 makes compression optional
    /// ("Programs are free to avoid using pointers in messages they generate").
    /// `RDLENGTH` is computed from the serialized `RDATA` body.
    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ value: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        RFC_1035.Wire.appendName(value.name, into: &buffer)
        buffer.append(contentsOf: value.type.rawValue.bytes(endianness: .big))
        buffer.append(contentsOf: value.`class`.rawValue.bytes(endianness: .big))
        buffer.append(contentsOf: value.ttl.bytes(endianness: .big))

        let rdata = value.data.bytes
        buffer.append(contentsOf: UInt16(rdata.count).bytes(endianness: .big))
        buffer.append(contentsOf: rdata)
    }
}
