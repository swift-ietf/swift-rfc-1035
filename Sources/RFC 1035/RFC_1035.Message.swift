public import Binary_Endianness
public import Binary_Serializable
import Binary_Standard_Library_Integration

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

extension RFC_1035.Message: Binary.Serializable {

    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ value: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        buffer.append(contentsOf: value.header.id.bytes(endianness: .big))
        buffer.append(contentsOf: value.header.flags.bytes(endianness: .big))
        buffer.append(contentsOf: UInt16(value.questions.count).bytes(endianness: .big))
        buffer.append(contentsOf: UInt16(value.answers.count).bytes(endianness: .big))
        buffer.append(contentsOf: UInt16(value.authority.count).bytes(endianness: .big))
        buffer.append(contentsOf: UInt16(value.additional.count).bytes(endianness: .big))

        for question in value.questions {
            RFC_1035.Question.serialize(question, into: &buffer)
        }
        for record in value.answers {
            RFC_1035.ResourceRecord.serialize(record, into: &buffer)
        }
        for record in value.authority {
            RFC_1035.ResourceRecord.serialize(record, into: &buffer)
        }
        for record in value.additional {
            RFC_1035.ResourceRecord.serialize(record, into: &buffer)
        }
    }
}

extension RFC_1035.Message {

    public init<Bytes: Swift.Collection>(binary bytes: Bytes) throws(RFC_1035.Message.Error)
    where Bytes.Element == Byte {
        var reader = RFC_1035.Wire.Reader(Array(bytes))

        let id: UInt16
        let flags: UInt16
        let qdcount: Int
        let ancount: Int
        let nscount: Int
        let arcount: Int
        do throws(RFC_1035.Wire.Error) {
            id = try reader.uint16()
            flags = try reader.uint16()
            qdcount = Int(try reader.uint16())
            ancount = Int(try reader.uint16())
            nscount = Int(try reader.uint16())
            arcount = Int(try reader.uint16())
        } catch {
            throw RFC_1035.Message.Error(error)
        }

        let header = try RFC_1035.Message.Header(id: id, flags: flags)

        do throws(RFC_1035.Wire.Error) {
            var questions: [RFC_1035.Question] = []
            questions.reserveCapacity(qdcount)
            for _ in 0..<qdcount { questions.append(try reader.question()) }

            var answers: [RFC_1035.ResourceRecord] = []
            answers.reserveCapacity(ancount)
            for _ in 0..<ancount { answers.append(try reader.resourceRecord()) }

            var authority: [RFC_1035.ResourceRecord] = []
            authority.reserveCapacity(nscount)
            for _ in 0..<nscount { authority.append(try reader.resourceRecord()) }

            var additional: [RFC_1035.ResourceRecord] = []
            additional.reserveCapacity(arcount)
            for _ in 0..<arcount { additional.append(try reader.resourceRecord()) }

            try reader.expectEnd()

            self.init(
                header: header,
                questions: questions,
                answers: answers,
                authority: authority,
                additional: additional
            )
        } catch {
            throw RFC_1035.Message.Error(error)
        }
    }
}
