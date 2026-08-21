extension RFC_1035.Message.Header {

    public struct Opcode: Sendable, Hashable {

        public let rawValue: UInt8

        public init(rawValue: UInt8) {
            self.rawValue = rawValue
        }

        init(__unchecked _: Void, rawValue: UInt8) {
            self.rawValue = rawValue
        }
    }
}

extension RFC_1035.Message.Header.Opcode {

    public static let query = Self(__unchecked: (), rawValue: 0)

    public static let inverseQuery = Self(__unchecked: (), rawValue: 1)

    public static let status = Self(__unchecked: (), rawValue: 2)
}

extension RFC_1035.Message.Header.Opcode: CustomStringConvertible {
    public var description: String {
        switch rawValue {
        case 0: return "QUERY"
        case 1: return "IQUERY"
        case 2: return "STATUS"
        default: return "OPCODE\(rawValue)"
        }
    }
}
