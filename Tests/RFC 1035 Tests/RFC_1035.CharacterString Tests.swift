import Byte
import RFC_1035
import Testing

@Suite
struct `RFC 1035 CharacterString Tests` {

    @Test
    func `A character-string holds up to 255 octets`() throws {
        let text = try RFC_1035.CharacterString("v=spf1 -all")
        #expect(text.bytes.count == 11)
        #expect(RFC_1035.CharacterString.maxLength == 255)
    }

    @Test
    func `A character-string longer than 255 octets is rejected`() {
        let tooLong = [Byte](repeating: Byte(bitPattern: 0x61), count: 256)
        #expect(throws: RFC_1035.CharacterString.Error.tooLong(256)) {
            _ = try RFC_1035.CharacterString(bytes: tooLong)
        }
    }
}
