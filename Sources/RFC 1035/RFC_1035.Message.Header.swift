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

// RFC_1035.Message.Header.swift
// swift-rfc-1035
//
// RFC 1035 Section 4.1.1: Header section format

extension RFC_1035.Message {
    /// A DNS message header (RFC 1035 Section 4.1.1).
    ///
    /// ## Wire format
    ///
    /// ```
    ///                                 1  1  1  1  1  1
    ///   0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
    /// +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    /// |                      ID                       |
    /// +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    /// |QR|   Opcode  |AA|TC|RD|RA|   Z    |   RCODE   |
    /// +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    /// |                    QDCOUNT                    |
    /// +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    /// |                    ANCOUNT                    |
    /// +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    /// |                    NSCOUNT                    |
    /// +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    /// |                    ARCOUNT                    |
    /// +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    /// ```
    ///
    /// The four section counts (`QDCOUNT`, `ANCOUNT`, `NSCOUNT`, `ARCOUNT`) are
    /// **not** stored on the header: they are derived from the section array
    /// lengths of the owning ``RFC_1035/Message`` on serialization and validated
    /// against those arrays on parse. This keeps the model impossible to
    /// desynchronize — a header can never claim a count that disagrees with the
    /// records actually present.
    ///
    /// The three `Z` bits are reserved and must be zero in all queries and
    /// responses; ``flags`` always emits them as zero and ``init(id:flags:)``
    /// rejects a nonzero `Z`.
    public struct Header: Sendable, Hashable {
        /// `ID` — a 16-bit identifier assigned by the query originator and
        /// copied into the response.
        public let id: UInt16

        /// `QR` — whether the message is a query or a response.
        public let kind: Kind

        /// `OPCODE` — the kind of query.
        public let opcode: Opcode

        /// `AA` / `TC` / `RD` / `RA` — the single-bit flags.
        public let options: Options

        /// `RCODE` — the response code.
        public let rcode: Rcode

        /// Creates a header from its decomposed fields.
        public init(
            id: UInt16,
            kind: Kind,
            opcode: Opcode = .query,
            options: Options = [],
            rcode: Rcode = .noError
        ) {
            self.id = id
            self.kind = kind
            self.opcode = opcode
            self.options = options
            self.rcode = rcode
        }
    }
}

// MARK: - Flags word bit layout (RFC 1035 Section 4.1.1)

extension RFC_1035.Message.Header {
    /// `QR` bit mask within the 16-bit flags word.
    static let qrMask: UInt16 = 0x8000

    /// `OPCODE` field mask within the flags word.
    static let opcodeMask: UInt16 = 0x7800

    /// `OPCODE` field shift (bits 11–14).
    static let opcodeShift: UInt16 = 11

    /// `Z` (reserved) field mask within the flags word.
    static let reservedMask: UInt16 = 0x0070

    /// `RCODE` field mask within the flags word.
    static let rcodeMask: UInt16 = 0x000F
}

// MARK: - Flags word encoding / decoding

extension RFC_1035.Message.Header {
    /// The second and third header octets (`QR | Opcode | AA | TC | RD | RA | Z |
    /// RCODE`) packed as a big-endian 16-bit word.
    ///
    /// The `Z` bits are always emitted as zero (RFC 1035 Section 4.1.1). Only the
    /// low four bits of ``opcode`` and ``rcode`` are significant; higher bits are
    /// masked off so the packing can never collide with an adjacent field.
    public var flags: UInt16 {
        var word: UInt16 = 0
        if kind == .response { word |= Self.qrMask }
        word |= (UInt16(opcode.rawValue) << Self.opcodeShift) & Self.opcodeMask
        word |= options.rawValue & Options.mask
        word |= UInt16(rcode.rawValue) & Self.rcodeMask
        return word
    }

    /// Decodes a header from an `ID` and a 16-bit flags word.
    ///
    /// - Throws: ``RFC_1035/Message/Error/nonzeroReserved`` if any `Z` bit is
    ///   set (RFC 1035 Section 4.1.1 requires `Z` to be zero in all queries and
    ///   responses).
    public init(id: UInt16, flags: UInt16) throws(RFC_1035.Message.Error) {
        guard flags & Self.reservedMask == 0 else {
            throw .nonzeroReserved
        }
        let kind: Kind = (flags & Self.qrMask) != 0 ? .response : .query
        let opcode = Opcode(rawValue: UInt8((flags & Self.opcodeMask) >> Self.opcodeShift))
        let options = Options(rawValue: flags & Options.mask)
        let rcode = Rcode(rawValue: UInt8(flags & Self.rcodeMask))
        self.init(id: id, kind: kind, opcode: opcode, options: options, rcode: rcode)
    }
}
