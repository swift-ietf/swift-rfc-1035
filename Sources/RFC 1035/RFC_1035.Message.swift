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

// RFC_1035.Message.swift
// swift-rfc-1035
//
// RFC 1035 Section 4.1: Message format

public import Binary_Serializable_Primitives

extension RFC_1035 {
    /// A complete DNS message (RFC 1035 Section 4.1).
    ///
    /// ```
    /// +---------------------+
    /// |        Header       |
    /// +---------------------+
    /// |       Question      | the question for the name server
    /// +---------------------+
    /// |        Answer       | RRs answering the question
    /// +---------------------+
    /// |      Authority      | RRs pointing toward an authority
    /// +---------------------+
    /// |      Additional     | RRs holding additional information
    /// +---------------------+
    /// ```
    ///
    /// The header's four section counts are not stored: on ``serialize(_:into:)``
    /// they are derived from the section array lengths, and on ``init(binary:)``
    /// they drive how many entries are read and are then validated against the
    /// bytes present (a count larger than the records available fails with
    /// ``Error/truncated``; a count smaller than the records present leaves
    /// ``Error/trailingData(_:)``).
    ///
    /// ## Serialization is uncompressed
    ///
    /// ``serialize(_:into:)`` never emits RFC 1035 Section 4.1.4 compression
    /// pointers. ``init(binary:)`` fully resolves any pointers it encounters.
    /// A message whose names were uncompressed on the wire round-trips
    /// byte-for-byte; a message that used compression parses correctly and
    /// re-serializes to a logically-equal (but byte-different) expanded form.
    public struct Message: Sendable, Hashable {
        /// The header section (always present).
        public let header: RFC_1035.Message.Header

        /// The question section entries (`QDCOUNT`).
        public let questions: [RFC_1035.Question]

        /// The answer section records (`ANCOUNT`).
        public let answers: [RFC_1035.ResourceRecord]

        /// The authority section records (`NSCOUNT`).
        public let authority: [RFC_1035.ResourceRecord]

        /// The additional section records (`ARCOUNT`).
        public let additional: [RFC_1035.ResourceRecord]

        /// Creates a message from its sections.
        public init(
            header: RFC_1035.Message.Header,
            questions: [RFC_1035.Question] = [],
            answers: [RFC_1035.ResourceRecord] = [],
            authority: [RFC_1035.ResourceRecord] = [],
            additional: [RFC_1035.ResourceRecord] = []
        ) {
            self.header = header
            self.questions = questions
            self.answers = answers
            self.authority = authority
            self.additional = additional
        }
    }
}

// MARK: - Binary.Serializable

extension RFC_1035.Message: Binary.Serializable {
    /// Serializes a complete DNS message (RFC 1035 Section 4.1), uncompressed.
    ///
    /// The 12-octet header is written first — `ID`, the packed flags word, then
    /// the four section counts derived from the section arrays — followed by the
    /// question, answer, authority, and additional sections in order.
    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ value: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        buffer.append(contentsOf: value.header.id.bytes(endianness: .big))
        buffer.append(contentsOf: value.header.flags.bytes(endianness: .big))
        buffer.append(contentsOf: UInt16(value.questions.count).bytes(endianness: .big))
        buffer.append(contentsOf: UInt16(value.answers.count).bytes(endianness: .big))
        buffer.append(contentsOf: UInt16(value.authority.count).bytes(endianness: .big))
        buffer.append(contentsOf: UInt16(value.additional.count).bytes(endianness: .big))

        for question in value.questions {
            RFC_1035.Question.serialize(question, into: &buffer)
        }
        for record in value.answers {
            RFC_1035.ResourceRecord.serialize(record, into: &buffer)
        }
        for record in value.authority {
            RFC_1035.ResourceRecord.serialize(record, into: &buffer)
        }
        for record in value.additional {
            RFC_1035.ResourceRecord.serialize(record, into: &buffer)
        }
    }
}

// MARK: - Parsing

extension RFC_1035.Message {
    /// Parses a complete DNS message from its wire bytes (RFC 1035 Section 4.1).
    ///
    /// The entire message must be supplied because compression pointers
    /// reference offsets from the start of the message. Trailing bytes after the
    /// declared sections are rejected with ``Error/trailingData(_:)``.
    ///
    /// - Throws: ``RFC_1035/Message/Error`` on any malformed structure.
    public init<Bytes: Collection>(binary bytes: Bytes) throws(RFC_1035.Message.Error)
    where Bytes.Element == Byte {
        var reader = RFC_1035.Wire.Reader(Array(bytes))

        let id: UInt16
        let flags: UInt16
        let qdcount: Int
        let ancount: Int
        let nscount: Int
        let arcount: Int
        do throws(RFC_1035.Wire.Error) {
            id = try reader.uint16()
            flags = try reader.uint16()
            qdcount = Int(try reader.uint16())
            ancount = Int(try reader.uint16())
            nscount = Int(try reader.uint16())
            arcount = Int(try reader.uint16())
        } catch {
            throw RFC_1035.Message.Error(error)
        }

        let header = try RFC_1035.Message.Header(id: id, flags: flags)

        do throws(RFC_1035.Wire.Error) {
            var questions: [RFC_1035.Question] = []
            questions.reserveCapacity(qdcount)
            for _ in 0..<qdcount { questions.append(try reader.question()) }

            var answers: [RFC_1035.ResourceRecord] = []
            answers.reserveCapacity(ancount)
            for _ in 0..<ancount { answers.append(try reader.resourceRecord()) }

            var authority: [RFC_1035.ResourceRecord] = []
            authority.reserveCapacity(nscount)
            for _ in 0..<nscount { authority.append(try reader.resourceRecord()) }

            var additional: [RFC_1035.ResourceRecord] = []
            additional.reserveCapacity(arcount)
            for _ in 0..<arcount { additional.append(try reader.resourceRecord()) }

            try reader.expectEnd()

            self.init(
                header: header,
                questions: questions,
                answers: answers,
                authority: authority,
                additional: additional
            )
        } catch {
            throw RFC_1035.Message.Error(error)
        }
    }
}
