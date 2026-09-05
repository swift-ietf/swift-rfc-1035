import Foundation
import RFC_1035
import RFC_1035_Foundation_Integration
import Testing

@Suite
struct `RFC_1035.Domain+Codable Tests` {

    @Test
    func `a domain codes as its text form`() throws {
        let domain = try RFC_1035.Domain("example.com")

        let encoded = try JSONEncoder().encode(domain)

        #expect(String(decoding: encoded, as: UTF8.self) == #""example.com""#)
        #expect(try JSONDecoder().decode(RFC_1035.Domain.self, from: encoded) == domain)
    }

    @Test
    func `a label codes as its text form`() throws {
        let label = try RFC_1035.Domain.Label("example")

        let encoded = try JSONEncoder().encode(label)

        #expect(String(decoding: encoded, as: UTF8.self) == #""example""#)
        #expect(try JSONDecoder().decode(RFC_1035.Domain.Label.self, from: encoded) == label)
    }

    @Test
    func `a malformed domain fails to decode`() {
        let encoded = Data(#""-example.com""#.utf8)

        #expect(throws: RFC_1035.Domain.Error.invalidLabel(.startsWithHyphen("-example"))) {
            try JSONDecoder().decode(RFC_1035.Domain.self, from: encoded)
        }
    }
}
