import Byte
import RFC_1035
import Testing

@Suite
struct `RFC 1035 A Record Tests` {

    @Test
    func `An A record is a dotted quad`() {
        let address = RFC_1035.ResourceRecord.A(93, 184, 216, 34)
        #expect(address.description == "93.184.216.34")
        #expect(address.octets.count == RFC_1035.ResourceRecord.A.octetCount)
    }

    @Test
    func `An A record requires exactly four octets`() {
        #expect(throws: RFC_1035.ResourceRecord.A.Error.invalidOctetCount(3)) {
            _ = try RFC_1035.ResourceRecord.A(octets: [Byte(bitPattern: 1), Byte(bitPattern: 2), Byte(bitPattern: 3)])
        }
    }
}
