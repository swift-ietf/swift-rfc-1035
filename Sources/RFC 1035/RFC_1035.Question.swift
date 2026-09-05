extension RFC_1035 {

    public struct Question: Sendable, Hashable {

        public let name: RFC_1035.Domain

        public let type: RFC_1035.RecordType

        public let `class`: RFC_1035.RecordClass

        public init(
            name: RFC_1035.Domain,
            type: RFC_1035.RecordType,
            `class`: RFC_1035.RecordClass = .internet
        ) {
            self.name = name
            self.type = type
            self.`class` = `class`
        }
    }
}
