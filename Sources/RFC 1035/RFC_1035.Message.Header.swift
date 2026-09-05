extension RFC_1035.Message {

    public struct Header: Sendable, Hashable {

        public let id: UInt16

        public let kind: Kind

        public let opcode: Opcode

        public let options: Options

        public let rcode: Rcode

        public init(
            id: UInt16,
            kind: Kind,
            opcode: Opcode = .query,
            options: Options = [],
            rcode: Rcode = .noError
        ) {
            self.id = id
            self.kind = kind
            self.opcode = opcode
            self.options = options
            self.rcode = rcode
        }
    }
}
