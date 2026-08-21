extension RFC_1035 {

    public struct RecordType: Sendable, Hashable {

        public let rawValue: UInt16

        public init(rawValue: UInt16) {
            self.rawValue = rawValue
        }

        init(__unchecked _: Void, rawValue: UInt16) {
            self.rawValue = rawValue
        }
    }
}

extension RFC_1035.RecordType {

    public static let a = Self(__unchecked: (), rawValue: 1)

    public static let ns = Self(__unchecked: (), rawValue: 2)

    public static let md = Self(__unchecked: (), rawValue: 3)

    public static let mf = Self(__unchecked: (), rawValue: 4)

    public static let cname = Self(__unchecked: (), rawValue: 5)

    public static let soa = Self(__unchecked: (), rawValue: 6)

    public static let mb = Self(__unchecked: (), rawValue: 7)

    public static let mg = Self(__unchecked: (), rawValue: 8)

    public static let mr = Self(__unchecked: (), rawValue: 9)

    public static let null = Self(__unchecked: (), rawValue: 10)

    public static let wks = Self(__unchecked: (), rawValue: 11)

    public static let ptr = Self(__unchecked: (), rawValue: 12)

    public static let hinfo = Self(__unchecked: (), rawValue: 13)

    public static let minfo = Self(__unchecked: (), rawValue: 14)

    public static let mx = Self(__unchecked: (), rawValue: 15)

    public static let txt = Self(__unchecked: (), rawValue: 16)
}

extension RFC_1035.RecordType {

    public static let axfr = Self(__unchecked: (), rawValue: 252)

    public static let mailb = Self(__unchecked: (), rawValue: 253)

    public static let maila = Self(__unchecked: (), rawValue: 254)

    public static let any = Self(__unchecked: (), rawValue: 255)
}

extension RFC_1035.RecordType: CustomStringConvertible {
    public var description: String {
        switch rawValue {
        case 1: return "A"
        case 2: return "NS"
        case 3: return "MD"
        case 4: return "MF"
        case 5: return "CNAME"
        case 6: return "SOA"
        case 7: return "MB"
        case 8: return "MG"
        case 9: return "MR"
        case 10: return "NULL"
        case 11: return "WKS"
        case 12: return "PTR"
        case 13: return "HINFO"
        case 14: return "MINFO"
        case 15: return "MX"
        case 16: return "TXT"
        case 252: return "AXFR"
        case 253: return "MAILB"
        case 254: return "MAILA"
        case 255: return "*"
        default: return "TYPE\(rawValue)"
        }
    }
}
