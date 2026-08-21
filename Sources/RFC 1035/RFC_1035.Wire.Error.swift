extension RFC_1035.Wire {

    enum Error: Swift.Error, Sendable, Equatable {

        case truncated

        case trailingData(_ remaining: Int)

        case reservedLabelBits

        case pointerNotBackward

        case pointerLoop

        case nameTooLong

        case rdataLengthMismatch

        case nonzeroReserved
    }
}
