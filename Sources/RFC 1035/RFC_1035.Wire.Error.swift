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

// RFC_1035.Wire.Error.swift
// swift-rfc-1035
//
// DNS message wire codec: reader errors

extension RFC_1035.Wire {
    /// Errors raised by the DNS message wire reader.
    ///
    /// This is the internal, rich error vocabulary of the ``RFC_1035/Wire``
    /// codec. The public parse entry point, ``RFC_1035/Message/init(binary:)``,
    /// maps these onto the public ``RFC_1035/Message/Error`` so the internal
    /// ``RFC_1035/Wire`` namespace stays out of the public surface (the
    /// two-layer error idiom).
    enum Error: Swift.Error, Sendable, Equatable {
        /// The reader ran out of bytes before a field was complete.
        case truncated

        /// Bytes remained after a structure that should have consumed the input.
        case trailingData(_ remaining: Int)

        /// A label length octet had reserved high bits (`0b01` or `0b10`); only
        /// `0b00` (label) and `0b11` (pointer) are defined (RFC 1035 Section 4.1.4).
        case reservedLabelBits

        /// A compression pointer did not point strictly backward — its target
        /// offset was greater than or equal to the pointer's own position
        /// (a forward reference or a self-pointer).
        case pointerNotBackward

        /// A chain of compression pointers did not strictly decrease in
        /// position, indicating a loop (RFC 1035 Section 4.1.4).
        case pointerLoop

        /// An assembled name exceeded the 255-octet limit (RFC 1035 Section 2.3.4).
        case nameTooLong

        /// The bytes consumed while parsing structured `RDATA` did not equal the
        /// record's `RDLENGTH`.
        case rdataLengthMismatch

        /// The header `Z` (reserved) bits were nonzero (RFC 1035 Section 4.1.1
        /// requires them to be zero in all queries and responses).
        case nonzeroReserved
    }
}
