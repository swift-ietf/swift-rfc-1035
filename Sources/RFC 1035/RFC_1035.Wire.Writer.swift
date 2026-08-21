internal import Binary_Serializable_Primitives

extension RFC_1035.Wire {

    static func appendName<Buffer: RangeReplaceableCollection>(
        _ domain: RFC_1035.Domain,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        for label in domain.labels {
            let labelBytes = label.wireOctets
            buffer.append(Byte(UInt8(labelBytes.count)))
            buffer.append(contentsOf: labelBytes)
        }
        buffer.append(Byte(0))
    }
}
