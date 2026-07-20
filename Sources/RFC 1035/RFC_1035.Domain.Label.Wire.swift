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

// RFC_1035.Domain.Label.Wire.swift
// swift-rfc-1035
//
// Documented extension: the wire-form label codec.
//
// A label on the DNS wire (RFC 1035 Section 3.1) is 1-63 *arbitrary* octets —
// the strict "preferred syntax" of Section 2.3.1 is a recommendation for host
// names, not a constraint of the message format. The wire reader therefore
// must not force decoded labels through the preferred-syntax presentation
// validator (fable-448 F-001). This extension provides:
//
// - `init(wire:)` — assembles a label from raw wire octets, storing the
//   master-file presentation form (RFC 1035 Section 5.1 `\X` / `\DDD`
//   escaping) so arbitrary octets remain byte-faithful in `rawValue`;
// - `wireOctets` — the inverse mapping used by the wire writer.
//
// Labels built from presentation input keep the strict Section 2.3.1
// validation in `init(ascii:)`; strictness remains the presentation-layer
// default and is simply no longer applied to decoded wire names.

internal import Binary_Serializable_Primitives

extension RFC_1035.Domain.Label {
    /// Creates a label from raw DNS wire octets, without preferred-syntax
    /// validation.
    ///
    /// The caller (the wire reader) is responsible for the wire bounds: a
    /// label is 1-63 octets. Octets outside the printable ASCII range, and
    /// the two presentation metacharacters `.` and `\`, are stored escaped in
    /// the RFC 1035 Section 5.1 master-file form (`\.`, `\\`, `\DDD`) so the
    /// presentation `rawValue` remains byte-faithful and reversible.
    init(wire octets: some Collection<Byte>) {
        var presentation = ""
        presentation.reserveCapacity(octets.count)
        for octet in octets {
            let value = octet.underlying
            switch value {
            case 0x2E, 0x5C:  // '.' and '\' — presentation metacharacters
                presentation.append("\\")
                presentation.append(Character(Unicode.Scalar(value)))
            case 0x21...0x7E:  // printable ASCII, stored literally
                presentation.append(Character(Unicode.Scalar(value)))
            default:  // non-printable / non-ASCII — \DDD decimal escape
                presentation.append("\\")
                let decimal = String(value)
                presentation.append(String(repeating: "0", count: 3 - decimal.count))
                presentation.append(decimal)
            }
        }
        self.init(__unchecked: (), rawValue: presentation)
    }

    /// The label's raw DNS wire octets: the inverse of ``init(wire:)``,
    /// un-escaping the RFC 1035 Section 5.1 master-file form.
    ///
    /// For labels built from presentation input (which contain no escapes),
    /// this is simply the label's ASCII octets.
    var wireOctets: [Byte] {
        let scalars = Array(rawValue.utf8)
        var octets: [Byte] = []
        octets.reserveCapacity(scalars.count)
        var index = 0
        while index < scalars.count {
            let scalar = scalars[index]
            guard scalar == 0x5C, index + 1 < scalars.count else {  // '\'
                octets.append(Byte(scalar))
                index += 1
                continue
            }
            let next = scalars[index + 1]
            if index + 3 < scalars.count,
                (0x30...0x39).contains(next),
                (0x30...0x39).contains(scalars[index + 2]),
                (0x30...0x39).contains(scalars[index + 3]) {
                // \DDD — three decimal digits, one octet.
                let value =
                    UInt16(next - 0x30) * 100
                    + UInt16(scalars[index + 2] - 0x30) * 10
                    + UInt16(scalars[index + 3] - 0x30)
                octets.append(Byte(UInt8(truncatingIfNeeded: value)))
                index += 4
            } else {
                // \X — the next byte, literally.
                octets.append(Byte(next))
                index += 2
            }
        }
        return octets
    }
}
