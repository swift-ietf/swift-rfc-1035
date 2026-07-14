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

// RFC_1035.ResourceRecord.SOA.swift
// swift-rfc-1035
//
// RFC 1035 Section 3.3.13: SOA RDATA format

public import Binary_Serializable_Primitives

extension RFC_1035.ResourceRecord {
    /// The `RDATA` of an `SOA` record (RFC 1035 Section 3.3.13).
    ///
    /// ```
    /// +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    /// /                     MNAME                     /
    /// +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    /// /                     RNAME                     /
    /// +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    /// |                    SERIAL                     |
    /// +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    /// |                    REFRESH                    |
    /// +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    /// |                     RETRY                     |
    /// +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    /// |                    EXPIRE                     |
    /// +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    /// |                    MINIMUM                    |
    /// +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    /// ```
    ///
    /// `SERIAL` and `MINIMUM` are unsigned 32-bit values; `REFRESH`, `RETRY`,
    /// and `EXPIRE` are described as 32-bit time intervals/values. All five are
    /// stored as raw `UInt32` with no range rejection on parse (the same
    /// treatment as ``RFC_1035/ResourceRecord/ttl``); the signed reading, where
    /// applicable, is a caller concern.
    public struct SOA: Sendable, Hashable {
        /// `MNAME` — the primary source of data for this zone.
        public let mname: RFC_1035.Domain

        /// `RNAME` — the mailbox of the person responsible for this zone.
        public let rname: RFC_1035.Domain

        /// `SERIAL` — the unsigned 32-bit version number of the zone.
        public let serial: UInt32

        /// `REFRESH` — the interval before the zone should be refreshed.
        public let refresh: UInt32

        /// `RETRY` — the interval before a failed refresh should be retried.
        public let retry: UInt32

        /// `EXPIRE` — the upper limit before the zone is no longer authoritative.
        public let expire: UInt32

        /// `MINIMUM` — the minimum TTL exported with any RR from this zone.
        public let minimum: UInt32

        /// Creates an `SOA` record body from its fields.
        public init(
            mname: RFC_1035.Domain,
            rname: RFC_1035.Domain,
            serial: UInt32,
            refresh: UInt32,
            retry: UInt32,
            expire: UInt32,
            minimum: UInt32
        ) {
            self.mname = mname
            self.rname = rname
            self.serial = serial
            self.refresh = refresh
            self.retry = retry
            self.expire = expire
            self.minimum = minimum
        }
    }
}

// MARK: - Binary.Serializable

extension RFC_1035.ResourceRecord.SOA: Binary.Serializable {
    /// Serializes an `SOA` record body (RFC 1035 Section 3.3.13).
    ///
    /// The `MNAME` and `RNAME` domain names are emitted uncompressed.
    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ value: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        RFC_1035.Wire.appendName(value.mname, into: &buffer)
        RFC_1035.Wire.appendName(value.rname, into: &buffer)
        buffer.append(contentsOf: value.serial.bytes(endianness: .big))
        buffer.append(contentsOf: value.refresh.bytes(endianness: .big))
        buffer.append(contentsOf: value.retry.bytes(endianness: .big))
        buffer.append(contentsOf: value.expire.bytes(endianness: .big))
        buffer.append(contentsOf: value.minimum.bytes(endianness: .big))
    }
}
