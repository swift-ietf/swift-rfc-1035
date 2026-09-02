public import Binary_Serializable

extension RFC_1035 {

    public struct CharacterString: Sendable, Hashable {

        public let bytes: [Byte]

        init(__unchecked _: Void, bytes: [Byte]) {
            self.bytes = bytes
        }
    }
}

extension RFC_1035.CharacterString {

    public static let maxLength = 255

    public init(bytes: [Byte]) throws(Error) {
        guard bytes.count <= Self.maxLength else {
            throw .tooLong(bytes.count)
        }
        self.init(__unchecked: (), bytes: bytes)
    }

    public init(_ text: some StringProtocol) throws(Error) {
        try self.init(bytes: text.utf8.map(Byte.init))
    }
}

extension RFC_1035.CharacterString: Binary.Serializable {

    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ value: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        buffer.append(Byte(bitPattern: UInt8(truncatingIfNeeded: value.bytes.count)))
        buffer.append(contentsOf: value.bytes)
    }
}
