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

// RFC_1035.Message.Error.swift
// swift-rfc-1035
//
// Public DNS message parse errors

extension RFC_1035.Message {
    /// Errors raised when parsing a DNS message with ``RFC_1035/Message/init(binary:)``.
    ///
    /// This is the public face of the internal ``RFC_1035/Wire/Error``; the
    /// parser maps each low-level wire error onto one of these cases.
    ///
    /// - Note: A header section count that disagrees with the records actually
    ///   present is not a distinct case: too few records exhausts the input
    ///   (``truncated``), and too many leaves ``trailingData(_:)`` after the
    ///   declared sections.
    public enum Error: Swift.Error, Sendable, Equatable {
        /// The input ended before a field was complete — including a section
        /// count that claimed more records than the bytes contained.
        case truncated

        /// Bytes remained after the declared sections — including extra records
        /// beyond a section count.
        case trailingData(_ remaining: Int)

        /// A label length octet used a reserved discriminant (`0b01` / `0b10`).
        case reservedLabelBits

        /// A compression pointer did not point strictly backward.
        case pointerNotBackward

        /// A chain of compression pointers formed a loop.
        case pointerLoop

        /// An assembled domain name exceeded 255 octets.
        case nameTooLong

        /// A name resolved to the root (bare zero octet).
        ///
        /// No longer thrown: since fable-448 F-001 the root name decodes to
        /// ``RFC_1035/Domain/root``. The case is retained for source
        /// compatibility.
        case unsupportedRootName

        /// A label's octets failed ``RFC_1035/Domain/Label`` validation.
        ///
        /// No longer thrown: wire names are no longer forced through the
        /// strict RFC 1035 Section 2.3.1 preferred-syntax presentation
        /// validation (fable-448 F-001). The case is retained for source
        /// compatibility; presentation parsing still throws
        /// ``RFC_1035/Domain/Label/Error`` directly.
        case invalidLabel(RFC_1035.Domain.Label.Error)

        /// Assembled labels failed ``RFC_1035/Domain`` composition validation.
        ///
        /// No longer thrown (see ``invalidLabel(_:)``); retained for source
        /// compatibility.
        case invalidDomain(RFC_1035.Domain.Error)

        /// The bytes consumed decoding structured `RDATA` did not equal the
        /// record's `RDLENGTH`.
        case rdataLengthMismatch

        /// The header `Z` (reserved) bits were nonzero (RFC 1035 Section 4.1.1).
        case nonzeroReserved
    }
}

// MARK: - Wire.Error mapping (internal two-layer bridge)

extension RFC_1035.Message.Error {
    /// Maps an internal ``RFC_1035/Wire/Error`` onto the public parse error.
    init(_ wire: RFC_1035.Wire.Error) {
        switch wire {
        case .truncated: self = .truncated
        case .trailingData(let remaining): self = .trailingData(remaining)
        case .reservedLabelBits: self = .reservedLabelBits
        case .pointerNotBackward: self = .pointerNotBackward
        case .pointerLoop: self = .pointerLoop
        case .nameTooLong: self = .nameTooLong
        case .rdataLengthMismatch: self = .rdataLengthMismatch
        case .nonzeroReserved: self = .nonzeroReserved
        }
    }
}

// MARK: - CustomStringConvertible

extension RFC_1035.Message.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .truncated:
            return "DNS message truncated before a field was complete"
        case .trailingData(let remaining):
            return "DNS message has \(remaining) trailing byte(s) after the declared sections"
        case .reservedLabelBits:
            return "Domain name label used a reserved length discriminant (0b01 or 0b10)"
        case .pointerNotBackward:
            return "Compression pointer did not point strictly backward"
        case .pointerLoop:
            return "Compression pointers formed a loop"
        case .nameTooLong:
            return "Assembled domain name exceeded 255 octets"
        case .unsupportedRootName:
            return "Root (empty) domain name is not representable by RFC_1035.Domain"
        case .invalidLabel(let error):
            return "Invalid domain name label on the wire: \(error)"
        case .invalidDomain(let error):
            return "Invalid domain name on the wire: \(error)"
        case .rdataLengthMismatch:
            return "Decoded RDATA length did not match RDLENGTH"
        case .nonzeroReserved:
            return "Header Z (reserved) bits were nonzero"
        }
    }
}
