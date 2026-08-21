import Testing

@testable import RFC_1035

@Suite
struct `DNS name compression and label parsing` {

    private func readName(_ hex: String) throws(RFC_1035.Wire.Error) -> RFC_1035.Domain {
        var reader = RFC_1035.Wire.Reader(dnsHexBytes(hex))
        return try reader.name()
    }

    @Test
    func `reads an uncompressed name`() throws {

        let domain = try readName("03666f6f00")
        #expect(domain == (try RFC_1035.Domain("foo")))
    }

    @Test
    func `resolves a multi-level pointer chase`() throws {

        let hex = "03666f6f0003626172c000c005"
        var reader = RFC_1035.Wire.Reader(dnsHexBytes(hex))

        let first = try reader.name()
        let second = try reader.name()
        let third = try reader.name()

        #expect(first == (try RFC_1035.Domain("foo")))
        #expect(second == (try RFC_1035.Domain("bar.foo")))

        #expect(third == (try RFC_1035.Domain("bar.foo")))
    }

    @Test
    func `rejects a forward pointer`() {

        #expect(throws: RFC_1035.Wire.Error.pointerNotBackward) {
            _ = try readName("c004")
        }
    }

    @Test
    func `rejects a self-pointer`() {

        #expect(throws: RFC_1035.Wire.Error.pointerNotBackward) {
            _ = try readName("c000")
        }
    }

    @Test
    func `rejects a pointer loop`() {

        #expect(throws: RFC_1035.Wire.Error.pointerLoop) {
            _ = try readName("03626172c000")
        }
    }

    @Test
    func `rejects the reserved 0b01 label discriminant`() {
        #expect(throws: RFC_1035.Wire.Error.reservedLabelBits) {
            _ = try readName("40")
        }
    }

    @Test
    func `rejects the reserved 0b10 label discriminant`() {
        #expect(throws: RFC_1035.Wire.Error.reservedLabelBits) {
            _ = try readName("80")
        }
    }

    @Test
    func `rejects a name exceeding 255 octets`() {

        let label = "3f" + String(repeating: "61", count: 63)
        let hex = String(repeating: label, count: 4)
        #expect(throws: RFC_1035.Wire.Error.nameTooLong) {
            _ = try readName(hex)
        }
    }

    @Test
    func `decodes the root name`() throws {

        let domain = try readName("00")
        #expect(domain == RFC_1035.Domain.root)
    }

    @Test
    func `rejects a truncated label`() {

        #expect(throws: RFC_1035.Wire.Error.truncated) {
            _ = try readName("056162")
        }
    }
}
