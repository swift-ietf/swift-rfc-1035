import RFC_1035
import Testing

@Suite
struct `RFC 1035 Message Tests` {

    @Test
    func `A header defaults to a standard query`() {
        let header = RFC_1035.Message.Header(id: 0x2b7d, kind: .query)
        #expect(header.opcode == .query)
        #expect(header.options.isEmpty)
        #expect(header.rcode == .noError)
    }

    @Test
    func `A question defaults to the internet class`() throws {
        let question = RFC_1035.Question(name: try RFC_1035.Domain("example.com"), type: .a)
        #expect(question.`class` == .internet)
        #expect(question.type.description == "A")
    }

    @Test
    func `A message defaults to empty sections`() {
        let message = RFC_1035.Message(header: RFC_1035.Message.Header(id: 1, kind: .response))
        #expect(message.questions.isEmpty)
        #expect(message.answers.isEmpty)
        #expect(message.authority.isEmpty)
        #expect(message.additional.isEmpty)
    }

    @Test
    func `Record types and classes describe their mnemonics`() {
        #expect(RFC_1035.RecordType.mx.description == "MX")
        #expect(RFC_1035.RecordType(rawValue: 28).description == "TYPE28")
        #expect(RFC_1035.RecordClass.internet.description == "IN")
        #expect(RFC_1035.Message.Header.Rcode.nameError.description == "NXDomain")
    }
}
