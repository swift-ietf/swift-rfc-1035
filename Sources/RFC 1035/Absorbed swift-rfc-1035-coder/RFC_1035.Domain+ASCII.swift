#if Coder
    public import ASCII
    public import Binary
    public import Byte

    extension RFC_1035.Domain: ASCII.Parseable {}

    extension RFC_1035.Domain: ASCII.Serializable, Binary.Serializable {

        public static func serialize<Buffer: RangeReplaceableCollection>(
            _ value: Self,
            into buffer: inout Buffer
        ) where Buffer.Element == ASCII.Code {
            for byte in value.rawValue.utf8 { buffer.append(ASCII.Code(byte)) }
        }

        public static func serialize<Buffer: RangeReplaceableCollection>(
            _ value: Self,
            into buffer: inout Buffer
        ) where Buffer.Element == Byte {
            buffer.append(contentsOf: value.rawValue.utf8.lazy.map(Byte.init(bitPattern:)))
        }
    }
#endif
