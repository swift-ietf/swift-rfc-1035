import Binary_Serializable_Primitives
import Testing

@testable import RFC_1035

@Suite
struct `DNS captured wire vectors` {

    @Test
    func `example.com A query serializes byte-exactly`() throws {
        let question = RFC_1035.Question(name: try RFC_1035.Domain("example.com"), type: .a)
        let header = RFC_1035.Message.Header(id: 0x2b7d, kind: .query, options: [.recursionDesired])
        let message = RFC_1035.Message(header: header, questions: [question])

        #expect(message.bytes == dnsHexBytes(DNSVectors.queryExampleA))

        let reparsed = try RFC_1035.Message(binary: message.bytes)
        #expect(reparsed == message)
    }

    @Test
    func `example.com AAAA query serializes byte-exactly`() throws {
        let question = RFC_1035.Question(
            name: try RFC_1035.Domain("example.com"),
            type: RFC_1035.RecordType(rawValue: 28)
        )
        let header = RFC_1035.Message.Header(id: 0x2b7d, kind: .query, options: [.recursionDesired])
        let message = RFC_1035.Message(header: header, questions: [question])

        #expect(message.bytes == dnsHexBytes(DNSVectors.queryExampleAAAA))
    }

    @Test
    func `www.example.com A query serializes byte-exactly`() throws {
        let question = RFC_1035.Question(name: try RFC_1035.Domain("www.example.com"), type: .a)
        let header = RFC_1035.Message.Header(id: 0x2b7d, kind: .query, options: [.recursionDesired])
        let message = RFC_1035.Message(header: header, questions: [question])

        #expect(message.bytes == dnsHexBytes(DNSVectors.queryWWWExampleA))

        let reparsed = try RFC_1035.Message(binary: message.bytes)
        #expect(reparsed == message)
    }

    @Test
    func `example.com A response parses with resolved answer names`() throws {
        let wire = dnsHexBytes(DNSVectors.responseExampleA)
        let message = try RFC_1035.Message(binary: wire)

        #expect(message.header.id == 0x2b7d)
        #expect(message.header.kind == .response)
        #expect(message.header.opcode == .query)
        #expect(message.header.rcode == .noError)
        #expect(message.header.options.contains(.recursionDesired))
        #expect(message.header.options.contains(.recursionAvailable))
        #expect(!message.header.options.contains(.authoritativeAnswer))

        #expect(message.questions.count == 1)
        #expect(message.answers.count == 2)
        #expect(message.authority.isEmpty)
        #expect(message.additional.isEmpty)

        let expectedName = try RFC_1035.Domain("example.com")
        #expect(message.questions[0].name == expectedName)
        #expect(message.questions[0].type == .a)
        #expect(message.questions[0].`class` == .internet)

        #expect(message.answers[0].name == expectedName)
        #expect(message.answers[1].name == expectedName)
        #expect(message.answers[0].ttl == 29)
        #expect(message.answers[0].data == .a(RFC_1035.ResourceRecord.A(172, 66, 147, 243)))
        #expect(message.answers[1].data == .a(RFC_1035.ResourceRecord.A(104, 20, 23, 154)))
    }

    @Test
    func `example.com AAAA response parses AAAA answers as opaque`() throws {
        let wire = dnsHexBytes(DNSVectors.responseExampleAAAA)
        let message = try RFC_1035.Message(binary: wire)

        #expect(message.answers.count == 2)
        #expect(message.answers[0].type == RFC_1035.RecordType(rawValue: 28))

        guard case .opaque(let rdata0) = message.answers[0].data else {
            Issue.record("expected AAAA RDATA to decode as .opaque")
            return
        }
        #expect(rdata0.count == 16)

        #expect(rdata0 == dnsHexBytes("260647000010000000000000ac4293f3"))
    }

    @Test
    func `www.example.com A response parses with resolved answer names`() throws {
        let wire = dnsHexBytes(DNSVectors.responseWWWExampleA)
        let message = try RFC_1035.Message(binary: wire)

        let expectedName = try RFC_1035.Domain("www.example.com")
        #expect(message.questions[0].name == expectedName)
        #expect(message.answers.count == 2)
        #expect(message.answers[0].name == expectedName)
        #expect(message.answers[1].name == expectedName)
        #expect(message.answers[0].ttl == 0x51)
        #expect(message.answers[0].data == .a(RFC_1035.ResourceRecord.A(104, 20, 23, 154)))
        #expect(message.answers[1].data == .a(RFC_1035.ResourceRecord.A(172, 66, 147, 243)))
    }

    @Test
    func `responses round-trip logically through uncompressed re-serialization`() throws {
        for hex in [
            DNSVectors.responseExampleA,
            DNSVectors.responseExampleAAAA,
            DNSVectors.responseWWWExampleA,
        ] {
            let original = dnsHexBytes(hex)
            let message = try RFC_1035.Message(binary: original)

            let reserialized = message.bytes
            let reparsed = try RFC_1035.Message(binary: reserialized)

            #expect(reparsed == message)

            #expect(reserialized.count > original.count)
            #expect(reserialized != original)
        }
    }
}
