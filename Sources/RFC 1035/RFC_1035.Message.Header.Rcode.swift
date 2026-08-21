extension RFC_1035.Message.Header {

    public struct Rcode: Sendable, Hashable {

        public let rawValue: UInt8

        public init(rawValue: UInt8) {
            self.rawValue = rawValue
        }

        init(__unchecked _: Void, rawValue: UInt8) {
            self.rawValue = rawValue
        }
    }
}

extension RFC_1035.Message.Header.Rcode {

    public static let noError = Self(__unchecked: (), rawValue: 0)

    public static let formatError = Self(__unchecked: (), rawValue: 1)

    public static let serverFailure = Self(__unchecked: (), rawValue: 2)

    public static let nameError = Self(__unchecked: (), rawValue: 3)

    public static let notImplemented = Self(__unchecked: (), rawValue: 4)

    public static let refused = Self(__unchecked: (), rawValue: 5)
}

extension RFC_1035.Message.Header.Rcode: CustomStringConvertible {
    public var description: String {
        switch rawValue {
        case 0: return "NoError"
        case 1: return "FormErr"
        case 2: return "ServFail"
        case 3: return "NXDomain"
        case 4: return "NotImp"
        case 5: return "Refused"
        default: return "RCODE\(rawValue)"
        }
    }
}
