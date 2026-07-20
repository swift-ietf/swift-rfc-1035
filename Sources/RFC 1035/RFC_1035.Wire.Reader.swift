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

// RFC_1035.Wire.Reader.swift
// swift-rfc-1035
//
// DNS message wire codec: message-context cursor

internal import Binary_Serializable_Primitives

extension RFC_1035.Wire {
    /// A cursor over a **complete** DNS message that decodes the wire forms of
    /// RFC 1035 Section 4.
    ///
    /// Unlike a self-contained field reader, this reader is constructed over the
    /// entire message because compression pointers (RFC 1035 Section 4.1.4)
    /// reference offsets from the start of the message. ``name()`` resolves
    /// those pointers against the full backing buffer while the public cursor
    /// (``index``) advances only past the bytes physically consumed at the
    /// current position.
    ///
    /// All reads throw ``RFC_1035/Wire/Error`` on exhaustion, malformed
    /// structure, or a compression-pointer violation.
    struct Reader {
        /// The full message bytes. Compression offsets index into this buffer.
        let bytes: [Byte]

        /// The current read offset from the start of the message.
        private(set) var index: Int

        /// Creates a reader positioned at the start of a complete message.
        init(_ bytes: [Byte]) {
            self.bytes = bytes
            self.index = 0
        }
    }
}

// MARK: - Primitive reads

extension RFC_1035.Wire.Reader {
    /// Whether every byte has been consumed.
    var isAtEnd: Bool { index >= bytes.count }

    /// Reads a single octet, advancing the cursor.
    mutating func byte() throws(RFC_1035.Wire.Error) -> UInt8 {
        guard index < bytes.count else { throw .truncated }
        defer { index += 1 }
        return bytes[index].underlying
    }

    /// Reads a big-endian `uint16`.
    mutating func uint16() throws(RFC_1035.Wire.Error) -> UInt16 {
        let hi = try byte()
        let lo = try byte()
        return (UInt16(hi) << 8) | UInt16(lo)
    }

    /// Reads a big-endian `uint32`.
    mutating func uint32() throws(RFC_1035.Wire.Error) -> UInt32 {
        let a = try byte()
        let b = try byte()
        let c = try byte()
        let d = try byte()
        return (UInt32(a) << 24) | (UInt32(b) << 16) | (UInt32(c) << 8) | UInt32(d)
    }

    /// Reads `count` raw octets, advancing the cursor.
    mutating func take(_ count: Int) throws(RFC_1035.Wire.Error) -> [Byte] {
        guard count >= 0, bytes.count - index >= count else { throw .truncated }
        let slice = bytes[index..<index + count]
        index += count
        return Array(slice)
    }

    /// Asserts the reader has consumed all of its input.
    func expectEnd() throws(RFC_1035.Wire.Error) {
        guard isAtEnd else { throw .trailingData(bytes.count - index) }
    }
}

// MARK: - Name reads (RFC 1035 Section 3.1 / 4.1.4)

extension RFC_1035.Wire.Reader {
    /// The pointer/label discriminant mask (the high two bits of a length octet).
    private static var discriminantMask: UInt8 { 0xC0 }

    /// A label length octet (high two bits `0b00`).
    private static var labelDiscriminant: UInt8 { 0x00 }

    /// A compression pointer (high two bits `0b11`).
    private static var pointerDiscriminant: UInt8 { 0xC0 }

    /// The label-length mask (the low six bits of a length octet).
    private static var lengthMask: UInt8 { 0x3F }

    /// Reads a domain name, resolving compression pointers.
    ///
    /// A name is a sequence of length-prefixed labels terminated by a zero
    /// octet, optionally ending in — or consisting solely of — a compression
    /// pointer (RFC 1035 Section 4.1.4). This method:
    ///
    /// - rejects the reserved label discriminants `0b01` and `0b10`
    ///   (``RFC_1035/Wire/Error/reservedLabelBits``);
    /// - requires each pointer to point strictly backward relative to its own
    ///   position (``RFC_1035/Wire/Error/pointerNotBackward``), which kills
    ///   forward references and self-pointers;
    /// - requires a chain of followed pointers to strictly decrease in position
    ///   (``RFC_1035/Wire/Error/pointerLoop``), which kills multi-hop loops;
    /// - caps the assembled length at 255 octets
    ///   (``RFC_1035/Wire/Error/nameTooLong``), which independently bounds total
    ///   work and thus guarantees termination.
    ///
    /// After the name is read, ``index`` is left just past the first pointer
    /// encountered, or just past the terminating zero octet if no pointer was
    /// used — never inside the pointed-to region.
    mutating func name() throws(RFC_1035.Wire.Error) -> RFC_1035.Domain {
        var rawLabels: [[Byte]] = []
        var totalLength = 0
        var position = index
        var followedPointer = false
        var cursorAfter = index
        var lowestPointerPosition = Int.max

        while true {
            guard position < bytes.count else { throw .truncated }
            let lengthOctet = bytes[position].underlying

            switch lengthOctet & Self.discriminantMask {
            case Self.labelDiscriminant:
                let labelLength = Int(lengthOctet & Self.lengthMask)
                if labelLength == 0 {
                    // Root terminator: the zero octet counts toward the length.
                    totalLength += 1
                    if !followedPointer { cursorAfter = position + 1 }
                    index = cursorAfter
                    return Self.assemble(rawLabels)
                }
                let labelStart = position + 1
                let labelEnd = labelStart + labelLength
                guard labelEnd <= bytes.count else { throw .truncated }
                totalLength += 1 + labelLength
                guard totalLength <= RFC_1035.Domain.Limits.maxLength else {
                    throw .nameTooLong
                }
                rawLabels.append(Array(bytes[labelStart..<labelEnd]))
                position = labelEnd

            case Self.pointerDiscriminant:
                guard position + 1 < bytes.count else { throw .truncated }
                let offset =
                    (Int(lengthOctet & Self.lengthMask) << 8)
                    | Int(bytes[position + 1].underlying)
                guard offset < position else { throw .pointerNotBackward }
                guard position < lowestPointerPosition else { throw .pointerLoop }
                lowestPointerPosition = position
                if !followedPointer {
                    cursorAfter = position + 2
                    followedPointer = true
                }
                position = offset

            default:
                // Reserved discriminants 0b01 / 0b10 (RFC 1035 Section 4.1.4).
                throw .reservedLabelBits
            }
        }
    }

    /// Assembles collected label octets into a ``RFC_1035/Domain`` using the
    /// wire-form label codec.
    ///
    /// Wire names carry arbitrary-octet labels bounded only by the 63-octet
    /// label and 255-octet name limits (both already enforced by ``name()``),
    /// and a bare zero octet is the root — so assembly cannot fail, and the
    /// strict RFC 1035 Section 2.3.1 preferred-syntax validation is *not*
    /// applied here (it remains the presentation-layer parsers' default).
    private static func assemble(_ rawLabels: [[Byte]]) -> RFC_1035.Domain {
        guard !rawLabels.isEmpty else { return .root }

        var labels: [RFC_1035.Domain.Label] = []
        labels.reserveCapacity(rawLabels.count)
        for raw in rawLabels {
            labels.append(RFC_1035.Domain.Label(wire: raw))
        }
        return RFC_1035.Domain(
            __unchecked: (),
            rawValue: labels.map(\.rawValue).joined(separator: "."),
            labels: labels
        )
    }
}

// MARK: - Structural reads (RFC 1035 Section 4.1)

extension RFC_1035.Wire.Reader {
    /// Reads one question section entry (RFC 1035 Section 4.1.2).
    mutating func question() throws(RFC_1035.Wire.Error) -> RFC_1035.Question {
        let name = try self.name()
        let type = RFC_1035.RecordType(rawValue: try uint16())
        let recordClass = RFC_1035.RecordClass(rawValue: try uint16())
        return RFC_1035.Question(name: name, type: type, class: recordClass)
    }

    /// Reads one resource record (RFC 1035 Section 4.1.3), decoding its `RDATA`
    /// by TYPE and verifying the consumed length equals `RDLENGTH`.
    mutating func resourceRecord() throws(RFC_1035.Wire.Error) -> RFC_1035.ResourceRecord {
        let name = try self.name()
        let type = RFC_1035.RecordType(rawValue: try uint16())
        let recordClass = RFC_1035.RecordClass(rawValue: try uint16())
        let ttl = try uint32()
        let rdlength = Int(try uint16())
        let rdataEnd = index + rdlength
        guard rdataEnd <= bytes.count else { throw .truncated }

        let data = try recordData(type: type, rdlength: rdlength, rdataEnd: rdataEnd)
        guard index == rdataEnd else { throw .rdataLengthMismatch }

        return RFC_1035.ResourceRecord(
            name: name,
            type: type,
            class: recordClass,
            ttl: ttl,
            data: data
        )
    }

    /// Reads one `<character-string>` (RFC 1035 Section 3.3): a single length
    /// octet followed by that many content octets.
    mutating func characterString() throws(RFC_1035.Wire.Error) -> RFC_1035.CharacterString {
        let length = Int(try byte())
        let content = try take(length)
        // `length` came from a single octet, so it is at most 255 — the
        // <character-string> invariant holds without a validated init.
        return RFC_1035.CharacterString(__unchecked: (), bytes: content)
    }

    /// Decodes `RDATA` by TYPE (RFC 1035 Sections 3.3 / 3.4).
    ///
    /// Recognized self-contained formats are decoded to typed cases; every other
    /// TYPE is preserved as ``RFC_1035/ResourceRecord/Data/opaque(_:)``. Names
    /// inside name-bearing formats resolve compression pointers via ``name()``.
    private mutating func recordData(
        type: RFC_1035.RecordType,
        rdlength: Int,
        rdataEnd: Int
    ) throws(RFC_1035.Wire.Error) -> RFC_1035.ResourceRecord.Data {
        switch type {
        case .a:
            guard rdlength == RFC_1035.ResourceRecord.A.octetCount else {
                throw .rdataLengthMismatch
            }
            return .a(RFC_1035.ResourceRecord.A(__unchecked: (), octets: try take(rdlength)))

        case .ns:
            return .ns(try name())

        case .cname:
            return .cname(try name())

        case .ptr:
            return .ptr(try name())

        case .mx:
            let preference = try uint16()
            let exchange = try name()
            return .mx(preference: preference, exchange: exchange)

        case .soa:
            let mname = try name()
            let rname = try name()
            let serial = try uint32()
            let refresh = try uint32()
            let retry = try uint32()
            let expire = try uint32()
            let minimum = try uint32()
            return .soa(
                RFC_1035.ResourceRecord.SOA(
                    mname: mname,
                    rname: rname,
                    serial: serial,
                    refresh: refresh,
                    retry: retry,
                    expire: expire,
                    minimum: minimum
                )
            )

        case .txt:
            var strings: [RFC_1035.CharacterString] = []
            while index < rdataEnd {
                strings.append(try characterString())
            }
            return .txt(strings)

        default:
            return .opaque(try take(rdlength))
        }
    }
}
