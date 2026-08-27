public import Binary_Serializable

extension RFC_1035.ResourceRecord {

    public enum Data: Sendable, Hashable {

        case a(RFC_1035.ResourceRecord.A)

        case ns(RFC_1035.Domain)

        case cname(RFC_1035.Domain)

        case ptr(RFC_1035.Domain)

        case mx(preference: UInt16, exchange: RFC_1035.Domain)

        case txt([RFC_1035.CharacterString])

        case soa(RFC_1035.ResourceRecord.SOA)

        case opaque([Byte])
    }
}

extension RFC_1035.ResourceRecord.Data: Binary.Serializable {

    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ value: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        switch value {
        case .a(let address):
            RFC_1035.ResourceRecord.A.serialize(address, into: &buffer)

        case .ns(let name), .cname(let name), .ptr(let name):
            RFC_1035.Wire.appendName(name, into: &buffer)

        case .mx(let preference, let exchange):
            buffer.append(contentsOf: preference.bytes(endianness: .big))
            RFC_1035.Wire.appendName(exchange, into: &buffer)

        case .txt(let strings):
            for string in strings {
                RFC_1035.CharacterString.serialize(string, into: &buffer)
            }

        case .soa(let soa):
            RFC_1035.ResourceRecord.SOA.serialize(soa, into: &buffer)

        case .opaque(let bytes):
            buffer.append(contentsOf: bytes)
        }
    }
}
