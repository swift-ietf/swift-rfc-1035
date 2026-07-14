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

// RFC_1035.Wire.swift
// swift-rfc-1035
//
// DNS message wire codec (RFC 1035 Section 4)
//
// Internal home for the DNS message wire-format primitives: the length-prefixed
// label / compression-pointer name encoding (Section 3.1 / 4.1.4), big-endian
// integer reads and writes, and the message-context cursor. All wire-level reads
// and writes route through here so the encoding discipline lives in ONE place
// per [IMPL-060].
//
// This is distinct from, and does NOT touch, `RFC_1035.Domain`'s
// `Binary.Serializable` conformance, which serializes the *presentation* form
// (dotted ASCII). The DNS wire label format is a separate codec.

extension RFC_1035 {
    /// Internal DNS message wire-format codec namespace.
    ///
    /// The DNS message format's composite forms are fixed-width big-endian
    /// integers, length-prefixed labels terminated by a zero octet, and 14-bit
    /// backward compression pointers. ``Wire`` centralizes reading
    /// (``Wire/Reader``) and writing (``Wire`` append helpers) of those forms.
    enum Wire {}
}
