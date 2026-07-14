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

// RFC_1035.Question.swift
// swift-rfc-1035
//
// RFC 1035 Section 4.1.2: Question section format

public import Binary_Serializable_Primitives

extension RFC_1035 {
    /// A question section entry (RFC 1035 Section 4.1.2).
    ///
    /// ## Wire format
    ///
    /// ```
    /// +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    /// /                     QNAME                     /
    /// +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    /// |                     QTYPE                     |
    /// +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    /// |                     QCLASS                    |
    /// +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    /// ```
    public struct Question: Sendable, Hashable {
        /// `QNAME` — the query domain name.
        public let name: RFC_1035.Domain

        /// `QTYPE` — the query type (a superset of TYPE, RFC 1035 Section 3.2.3).
        public let type: RFC_1035.RecordType

        /// `QCLASS` — the query class (a superset of CLASS, RFC 1035 Section 3.2.5).
        public let `class`: RFC_1035.RecordClass

        /// Creates a question from its fields.
        public init(
            name: RFC_1035.Domain,
            type: RFC_1035.RecordType,
            `class`: RFC_1035.RecordClass = .internet
        ) {
            self.name = name
            self.type = type
            self.`class` = `class`
        }
    }
}

// MARK: - Binary.Serializable

extension RFC_1035.Question: Binary.Serializable {
    /// Serializes a question (RFC 1035 Section 4.1.2). `QNAME` is emitted
    /// uncompressed.
    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ value: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        RFC_1035.Wire.appendName(value.name, into: &buffer)
        buffer.append(contentsOf: value.type.rawValue.bytes(endianness: .big))
        buffer.append(contentsOf: value.`class`.rawValue.bytes(endianness: .big))
    }
}
