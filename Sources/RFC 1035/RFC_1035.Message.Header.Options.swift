extension RFC_1035.Message.Header {

    public struct Options: OptionSet, Sendable, Hashable {
        public let rawValue: UInt16

        public init(rawValue: UInt16) {
            self.rawValue = rawValue
        }

        public static let authoritativeAnswer = Self(rawValue: 0x0400)

        public static let truncation = Self(rawValue: 0x0200)

        public static let recursionDesired = Self(rawValue: 0x0100)

        public static let recursionAvailable = Self(rawValue: 0x0080)
    }
}
