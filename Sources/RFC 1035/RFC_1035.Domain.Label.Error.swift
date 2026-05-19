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

// RFC_1035.Domain.Label.Error.swift
// swift-rfc-1035
//
// Label-level validation errors

import Standard_Library_Extensions

extension RFC_1035.Domain.Label {
    /// Errors that can occur during label validation
    ///
    /// These represent atomic constraint violations at the individual label level,
    /// as defined by RFC 1035 Section 2.3.1.
    public enum Error: Swift.Error, Sendable, Equatable {
        /// Label is empty
        case empty

        /// Label exceeds maximum length of 63 octets
        case tooLong(_ length: Int, label: String)

        /// Label contains invalid characters (must be letters, digits, or hyphens)
        case invalidCharacters(_ label: String, byte: Byte, reason: String)

        /// Label starts with a hyphen (RFC 1035 violation)
        case startsWithHyphen(_ label: String)

        /// Label ends with a hyphen (RFC 1035 violation)
        case endsWithHyphen(_ label: String)

        /// Label starts with a digit (RFC 1035 violation - must start with letter)
        case startsWithDigit(_ label: String)
    }
}

// MARK: - CustomStringConvertible

extension RFC_1035.Domain.Label.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .empty:
            return "Domain label cannot be empty"
        case .tooLong(let length, let label):
            return "Domain label '\(label)' is too long (\(length) bytes, maximum 63)"
        case .invalidCharacters(let label, let byte, let reason):
            return
                "Domain label '\(label)' has invalid byte 0x\(String(byte, radix: 16)): \(reason)"
        case .startsWithHyphen(let label):
            return "Domain label '\(label)' cannot start with a hyphen"
        case .endsWithHyphen(let label):
            return "Domain label '\(label)' cannot end with a hyphen"
        case .startsWithDigit(let label):
            return "Domain label '\(label)' must start with a letter (RFC 1035)"
        }
    }
}
