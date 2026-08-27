public import Binary_Serializable

extension RFC_1035 {

    public struct Question: Sendable, Hashable {

        public let name: RFC_1035.Domain

        public let type: RFC_1035.RecordType

        public let `class`: RFC_1035.RecordClass

        public init(
            name: RFC_1035.Domain,
            type: RFC_1035.RecordType,
            `class`: RFC_1035.RecordClass = .internet
        ) {
            self.name = name
            self.type = type
            self.`class` = `class`
        }
    }
}

extension RFC_1035.Question: Binary.Serializable {

    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ value: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        RFC_1035.Wire.appendName(value.name, into: &buffer)
        buffer.append(contentsOf: value.type.rawValue.bytes(endianness: .big))
        buffer.append(contentsOf: value.`class`.rawValue.bytes(endianness: .big))
    }
}
