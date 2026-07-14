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

// RFC_1035.ResourceRecord.A.Error.swift
// swift-rfc-1035
//
// A RDATA construction errors

extension RFC_1035.ResourceRecord.A {
    /// Errors raised when constructing an ``RFC_1035/ResourceRecord/A`` record.
    public enum Error: Swift.Error, Sendable, Equatable {
        /// The octet array did not contain exactly four octets, as required by
        /// the 32-bit `ADDRESS` field (RFC 1035 Section 3.4.1).
        case invalidOctetCount(_ count: Int)
    }
}

// MARK: - CustomStringConvertible

extension RFC_1035.ResourceRecord.A.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .invalidOctetCount(let count):
            return "A record address requires exactly 4 octets (got \(count))"
        }
    }
}
