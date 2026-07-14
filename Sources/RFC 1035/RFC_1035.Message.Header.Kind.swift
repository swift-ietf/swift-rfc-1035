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

// RFC_1035.Message.Header.Kind.swift
// swift-rfc-1035
//
// RFC 1035 Section 4.1.1: the QR bit

extension RFC_1035.Message.Header {
    /// Whether a message is a query or a response — the header `QR` bit
    /// (RFC 1035 Section 4.1.1).
    ///
    /// > QR  A one bit field that specifies whether this message is a
    /// >     query (0), or a response (1).
    public enum Kind: Sendable, Hashable {
        /// A query (`QR` = 0).
        case query

        /// A response (`QR` = 1).
        case response
    }
}
