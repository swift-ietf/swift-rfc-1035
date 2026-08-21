extension RFC_1035 {

    public struct RecordClass: Sendable, Hashable {

        public let rawValue: UInt16

        public init(rawValue: UInt16) {
            self.rawValue = rawValue
        }

        init(__unchecked _: Void, rawValue: UInt16) {
            self.rawValue = rawValue
        }
    }
}

extension RFC_1035.RecordClass {

    public static let internet = Self(__unchecked: (), rawValue: 1)

    public static let csnet = Self(__unchecked: (), rawValue: 2)

    public static let chaos = Self(__unchecked: (), rawValue: 3)

    public static let hesiod = Self(__unchecked: (), rawValue: 4)
}

extension RFC_1035.RecordClass {

    public static let any = Self(__unchecked: (), rawValue: 255)
}

extension RFC_1035.RecordClass: CustomStringConvertible {
    public var description: String {
        switch rawValue {
        case 1: return "IN"
        case 2: return "CS"
        case 3: return "CH"
        case 4: return "HS"
        case 255: return "*"
        default: return "CLASS\(rawValue)"
        }
    }
}
