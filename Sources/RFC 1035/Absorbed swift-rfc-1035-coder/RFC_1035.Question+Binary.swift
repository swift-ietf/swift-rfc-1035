#if Coder
    public import Binary
    public import Byte

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
#endif
