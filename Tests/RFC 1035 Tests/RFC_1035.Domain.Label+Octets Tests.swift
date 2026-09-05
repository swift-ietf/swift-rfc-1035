import Byte
import Byte_Standard_Library_Integration
import RFC_1035
import Testing

@Suite
struct `RFC 1035 Label Octets Tests` {

    @Test
    func `A label built from octets keeps its octets`() throws {
        let label = try RFC_1035.Domain.Label(octets: [Byte](utf8: "example"))
        #expect(label.rawValue == "example")
        #expect(label.octets == [Byte](utf8: "example"))
    }

    @Test
    func `Octets outside the preferred syntax are admitted`() throws {
        let underscore = try RFC_1035.Domain.Label(octets: [Byte](utf8: "_dmarc"))
        #expect(underscore.rawValue == "_dmarc")

        let digitFirst = try RFC_1035.Domain.Label(octets: [Byte](utf8: "3com"))
        #expect(digitFirst.rawValue == "3com")
    }

    @Test
    func `A period and a backslash are escaped in the presentation form`() throws {
        let label = try RFC_1035.Domain.Label(octets: [Byte](utf8: "a.b\\c"))
        #expect(label.rawValue == #"a\.b\\c"#)
        #expect(label.octets == [Byte](utf8: "a.b\\c"))
    }

    @Test
    func `Non-printable octets are escaped as three decimal digits`() throws {
        let label = try RFC_1035.Domain.Label(octets: [Byte(bitPattern: 0x00), Byte(bitPattern: 0x20), Byte(bitPattern: 0xFF)])
        #expect(label.rawValue == #"\000\032\255"#)
        #expect(label.octets == [Byte(bitPattern: 0x00), Byte(bitPattern: 0x20), Byte(bitPattern: 0xFF)])
    }

    @Test
    func `An empty octet sequence is rejected`() {
        #expect(throws: RFC_1035.Domain.Label.Error.empty) {
            _ = try RFC_1035.Domain.Label(octets: [Byte]())
        }
    }

    @Test
    func `More than 63 octets are rejected`() {
        let octets = [Byte](repeating: Byte(bitPattern: 0x61), count: 64)
        #expect(throws: RFC_1035.Domain.Label.Error.tooLong(64, label: String(repeating: "a", count: 64))) {
            _ = try RFC_1035.Domain.Label(octets: octets)
        }
    }

    @Test
    func `Octet labels compose into a domain`() throws {
        let domain = try RFC_1035.Domain(labels: [
            try RFC_1035.Domain.Label(octets: [Byte](utf8: "_dmarc")),
            try RFC_1035.Domain.Label("example"),
            try RFC_1035.Domain.Label("com"),
        ])
        #expect(domain.name == "_dmarc.example.com")
        #expect(domain.labels.count == 3)
    }
}
