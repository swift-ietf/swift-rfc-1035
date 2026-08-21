import Binary_Serializable_Primitives

func dnsHexBytes(_ hex: String) -> [Byte] {
    var result: [Byte] = []
    result.reserveCapacity(hex.count / 2)
    var iterator = hex.makeIterator()
    while let high = iterator.next(), let low = iterator.next() {
        guard let value = UInt8(String([high, low]), radix: 16) else {
            continue
        }
        result.append(Byte(value))
    }
    return result
}

func dnsHexString(_ bytes: [Byte]) -> String {
    var out = ""
    out.reserveCapacity(bytes.count * 2)
    for byte in bytes {
        let value = byte.underlying
        out.append(hexDigit(value >> 4))
        out.append(hexDigit(value & 0x0F))
    }
    return out
}

private func hexDigit(_ nibble: UInt8) -> Character {
    nibble < 10
        ? Character(Unicode.Scalar(nibble + 0x30))
        : Character(Unicode.Scalar(nibble - 10 + 0x61))
}

enum DNSVectors {

    static let queryExampleA =
        "2b7d01000001000000000000076578616d706c6503636f6d0000010001"
    static let responseExampleA =
        "2b7d81800001000200000000076578616d706c6503636f6d0000010001"
        + "c00c000100010000001d0004ac4293f3"
        + "c00c000100010000001d00046814179a"

    static let queryExampleAAAA =
        "2b7d01000001000000000000076578616d706c6503636f6d00001c0001"
    static let responseExampleAAAA =
        "2b7d81800001000200000000076578616d706c6503636f6d00001c0001"
        + "c00c001c0001000000b30010260647000010000000000000ac4293f3"
        + "c00c001c0001000000b300102606470000100000000000006814179a"

    static let queryWWWExampleA =
        "2b7d0100000100000000000003777777076578616d706c6503636f6d0000010001"
    static let responseWWWExampleA =
        "2b7d8180000100020000000003777777076578616d706c6503636f6d0000010001"
        + "c00c000100010000005100046814179a"
        + "c00c00010001000000510004ac4293f3"
}
