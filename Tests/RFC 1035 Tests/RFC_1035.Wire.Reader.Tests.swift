import Testing

@testable import RFC_1035

extension RFC_1035.Wire.Reader {
    @Suite
    struct `Edge Case` {

        private func readName(_ hex: String) throws(RFC_1035.Wire.Error) -> RFC_1035.Domain {
            var reader = RFC_1035.Wire.Reader(dnsHexBytes(hex))
            return try reader.name()
        }

        @Test
        func `decodes a digit-first label`() throws {

            let domain = try readName("0433636f6d03636f6d00")
            #expect(domain.labels.map(\.rawValue) == ["3com", "com"])
        }

        @Test
        func `decodes an underscore label`() throws {

            let domain = try readName("065f646d617263076578616d706c6500")
            #expect(domain.labels.map(\.rawValue) == ["_dmarc", "example"])
        }

        @Test
        func `decodes the root name`() throws {

            let domain = try readName("00")
            #expect(domain.labels.isEmpty)
            #expect(domain.rawValue == ".")
        }

        @Test
        func `round-trips a wire-legal name through the writer`() throws {
            let hex = "065f646d617263076578616d706c6500"
            let domain = try readName(hex)
            var buffer: [Byte] = []
            RFC_1035.Wire.appendName(domain, into: &buffer)
            #expect(dnsHexString(buffer) == hex)
        }

        @Test
        func `round-trips the root name through the writer`() throws {
            let domain = try readName("00")
            var buffer: [Byte] = []
            RFC_1035.Wire.appendName(domain, into: &buffer)
            #expect(dnsHexString(buffer) == "00")
        }
    }
}
