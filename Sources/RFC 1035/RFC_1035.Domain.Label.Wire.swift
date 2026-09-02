internal import Binary_Serializable

extension RFC_1035.Domain.Label {

    init(wire octets: some Swift.Collection<Byte>) {
        var presentation = ""
        presentation.reserveCapacity(octets.count)
        for octet in octets {
            let value = octet.bitPattern
            switch value {
            case 0x2E, 0x5C:
                presentation.append("\\")
                presentation.append(Character(Unicode.Scalar(value)))

            case 0x21...0x7E:
                presentation.append(Character(Unicode.Scalar(value)))

            default:
                presentation.append("\\")
                let decimal = String(value)
                presentation.append(String(repeating: "0", count: 3 - decimal.count))
                presentation.append(decimal)
            }
        }
        self.init(__unchecked: (), rawValue: presentation)
    }

    var wireOctets: [Byte] {
        let scalars = Array(rawValue.utf8)
        var octets: [Byte] = []
        octets.reserveCapacity(scalars.count)
        var index = 0
        while index < scalars.count {
            let scalar = scalars[index]
            guard scalar == 0x5C, index + 1 < scalars.count else {
                octets.append(Byte(bitPattern: scalar))
                index += 1
                continue
            }
            let next = scalars[index + 1]
            if index + 3 < scalars.count,
                (0x30...0x39).contains(next),
                (0x30...0x39).contains(scalars[index + 2]),
                (0x30...0x39).contains(scalars[index + 3])
            {

                let value =
                    UInt16(next - 0x30) * 100
                    + UInt16(scalars[index + 2] - 0x30) * 10
                    + UInt16(scalars[index + 3] - 0x30)
                octets.append(Byte(bitPattern: UInt8(truncatingIfNeeded: value)))
                index += 4
            } else {

                octets.append(Byte(bitPattern: next))
                index += 2
            }
        }
        return octets
    }
}
