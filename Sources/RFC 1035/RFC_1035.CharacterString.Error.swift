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

// RFC_1035.CharacterString.Error.swift
// swift-rfc-1035
//
// <character-string> construction errors

extension RFC_1035.CharacterString {
    /// Errors raised when constructing a ``RFC_1035/CharacterString``.
    public enum Error: Swift.Error, Sendable, Equatable {
        /// The content exceeds the 255-octet limit imposed by the single length
        /// octet (RFC 1035 Section 3.3).
        case tooLong(_ length: Int)
    }
}

// MARK: - CustomStringConvertible

extension RFC_1035.CharacterString.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .tooLong(let length):
            return "<character-string> is too long (\(length) bytes, maximum 255)"
        }
    }
}
