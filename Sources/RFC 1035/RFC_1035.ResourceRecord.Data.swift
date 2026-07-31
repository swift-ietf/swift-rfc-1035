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

// RFC_1035.ResourceRecord.Data.swift
// swift-rfc-1035
//
// RFC 1035 Sections 3.3 / 3.4: RDATA formats

public import Binary_Serializable_Primitives

extension RFC_1035.ResourceRecord {
    /// The typed `RDATA` of a resource record (RFC 1035 Sections 3.3 / 3.4).
    ///
    /// Cases are provided for the self-contained RDATA formats defined in
    /// RFC 1035 whose structure is fully known: `A`, `NS`, `CNAME`, `PTR`, `MX`,
    /// `TXT`, and `SOA`. Every other type — including the experimental / obsolete
    /// mail formats (`MB`, `MG`, `MR`, `MD`, `MF`, `MINFO`), `HINFO`, `WKS`,
    /// `NULL`, and any type defined by a later RFC (e.g. AAAA, RFC 3596) — is
    /// preserved verbatim as ``opaque(_:)``. This is deliberate: those formats
    /// are either rarely useful, defined elsewhere, or (for `WKS`/`HINFO`) add
    /// surface without wire-format subtlety. The enclosing
    /// ``RFC_1035/ResourceRecord/type`` preserves the original TYPE code, so an
    /// opaque record re-serializes to identical bytes.
    ///
    /// ## Compression
    ///
    /// On **decode**, the domain names inside name-bearing RDATA
    /// (`NS`/`CNAME`/`PTR`/`MX`/`SOA`) honor RFC 1035 Section 4.1.4 compression
    /// pointers, which are legal there because these formats are not
    /// class-specific. On **encode**, names are always emitted uncompressed
    /// (compression is optional per the RFC). Consequently a message containing
    /// only uncompressed names round-trips byte-for-byte, whereas a captured
    /// message that used pointers parses correctly but re-serializes to a
    /// logically-equal, byte-different form.
    public enum Data: Sendable, Hashable {
        /// `A` (RFC 1035 Section 3.4.1) — a 32-bit Internet address.
        case a(RFC_1035.ResourceRecord.A)

        /// `NS` (RFC 1035 Section 3.3.11) — an authoritative name server.
        case ns(RFC_1035.Domain)

        /// `CNAME` (RFC 1035 Section 3.3.1) — the canonical name for an alias.
        case cname(RFC_1035.Domain)

        /// `PTR` (RFC 1035 Section 3.3.12) — a pointer to another name.
        case ptr(RFC_1035.Domain)

        /// `MX` (RFC 1035 Section 3.3.9) — a mail exchange with its preference.
        case mx(preference: UInt16, exchange: RFC_1035.Domain)

        /// `TXT` (RFC 1035 Section 3.3.14) — one or more character-strings.
        case txt([RFC_1035.CharacterString])

        /// `SOA` (RFC 1035 Section 3.3.13) — the start of a zone of authority.
        case soa(RFC_1035.ResourceRecord.SOA)

        /// Any other TYPE — the raw `RDATA` octets, preserved verbatim.
        case opaque([Byte])
    }
}

// MARK: - Binary.Serializable

extension RFC_1035.ResourceRecord.Data: Binary.Serializable {
    /// Serializes the `RDATA` **body** (without the enclosing `RDLENGTH`).
    ///
    /// The `RDLENGTH` prefix is written by ``RFC_1035/ResourceRecord`` from the
    /// length of this body. Domain names are emitted uncompressed.
    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ value: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        switch value {
        case .a(let address):
            RFC_1035.ResourceRecord.A.serialize(address, into: &buffer)

        case .ns(let name), .cname(let name), .ptr(let name):
            RFC_1035.Wire.appendName(name, into: &buffer)

        case .mx(let preference, let exchange):
            buffer.append(contentsOf: preference.bytes(endianness: .big))
            RFC_1035.Wire.appendName(exchange, into: &buffer)

        case .txt(let strings):
            for string in strings {
                RFC_1035.CharacterString.serialize(string, into: &buffer)
            }

        case .soa(let soa):
            RFC_1035.ResourceRecord.SOA.serialize(soa, into: &buffer)

        case .opaque(let bytes):
            buffer.append(contentsOf: bytes)
        }
    }
}
