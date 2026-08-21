public import Binary_Serializable_Primitives

extension RFC_1035 {

    public struct ResourceRecord: Sendable, Hashable {

        public let name: RFC_1035.Domain

        public let type: RFC_1035.RecordType

        public let `class`: RFC_1035.RecordClass

        public let ttl: UInt32

        public let data: RFC_1035.ResourceRecord.Data

        public init(
            name: RFC_1035.Domain,
            type: RFC_1035.RecordType,
            `class`: RFC_1035.RecordClass,
            ttl: UInt32,
            data: RFC_1035.ResourceRecord.Data
        ) {
            self.name = name
            self.type = type
            self.`class` = `class`
            self.ttl = ttl
            self.data = data
        }
    }
}

extension RFC_1035.ResourceRecord: Binary.Serializable {

    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ value: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        RFC_1035.Wire.appendName(value.name, into: &buffer)
        buffer.append(contentsOf: value.type.rawValue.bytes(endianness: .big))
        buffer.append(contentsOf: value.`class`.rawValue.bytes(endianness: .big))
        buffer.append(contentsOf: value.ttl.bytes(endianness: .big))

        let rdata = value.data.bytes
        buffer.append(contentsOf: UInt16(rdata.count).bytes(endianness: .big))
        buffer.append(contentsOf: rdata)
    }
}
