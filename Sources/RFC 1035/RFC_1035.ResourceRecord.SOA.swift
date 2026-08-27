public import Binary_Serializable

extension RFC_1035.ResourceRecord {

    public struct SOA: Sendable, Hashable {

        public let mname: RFC_1035.Domain

        public let rname: RFC_1035.Domain

        public let serial: UInt32

        public let refresh: UInt32

        public let retry: UInt32

        public let expire: UInt32

        public let minimum: UInt32

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

extension RFC_1035.ResourceRecord.SOA: Binary.Serializable {

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
