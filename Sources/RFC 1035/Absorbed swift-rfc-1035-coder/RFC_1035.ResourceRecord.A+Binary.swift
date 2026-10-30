#if Coder
    public import Binary
    public import Byte

    extension RFC_1035.ResourceRecord.A: Binary.Serializable {

        public static func serialize<Buffer: RangeReplaceableCollection>(
            _ value: Self,
            into buffer: inout Buffer
        ) where Buffer.Element == Byte {
            buffer.append(contentsOf: value.octets)
        }
    }
#endif
