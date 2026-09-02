public import Binary_Serializable

extension RFC_1035.ResourceRecord {

    public struct A: Sendable, Hashable {

        public let octets: [Byte]

        init(__unchecked _: Void, octets: [Byte]) {
            self.octets = octets
        }
    }
}

extension RFC_1035.ResourceRecord.A {

    public static let octetCount = 4

    public init(_ a: UInt8, _ b: UInt8, _ c: UInt8, _ d: UInt8) {
        self.init(__unchecked: (), octets: [Byte(bitPattern: a), Byte(bitPattern: b), Byte(bitPattern: c), Byte(bitPattern: d)])
    }

    public init(octets: [Byte]) throws(Error) {
        guard octets.count == Self.octetCount else {
            throw .invalidOctetCount(octets.count)
        }
        self.init(__unchecked: (), octets: octets)
    }
}

extension RFC_1035.ResourceRecord.A: Binary.Serializable {

    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ value: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        buffer.append(contentsOf: value.octets)
    }
}

extension RFC_1035.ResourceRecord.A: CustomStringConvertible {

    public var description: String {
        octets.map { String($0.bitPattern) }.joined(separator: ".")
    }
}
