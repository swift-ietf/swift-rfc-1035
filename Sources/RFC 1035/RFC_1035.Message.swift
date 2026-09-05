extension RFC_1035 {

    public struct Message: Sendable, Hashable {

        public let header: RFC_1035.Message.Header

        public let questions: [RFC_1035.Question]

        public let answers: [RFC_1035.ResourceRecord]

        public let authority: [RFC_1035.ResourceRecord]

        public let additional: [RFC_1035.ResourceRecord]

        public init(
            header: RFC_1035.Message.Header,
            questions: [RFC_1035.Question] = [],
            answers: [RFC_1035.ResourceRecord] = [],
            authority: [RFC_1035.ResourceRecord] = [],
            additional: [RFC_1035.ResourceRecord] = []
        ) {
            self.header = header
            self.questions = questions
            self.answers = answers
            self.authority = authority
            self.additional = additional
        }
    }
}
