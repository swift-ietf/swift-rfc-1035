public import Byte

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
