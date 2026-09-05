public import Byte

extension RFC_1035.Domain.Label {

    public enum Error: Swift.Error, Sendable, Equatable {

        case empty

        case tooLong(_ length: Int, label: String)

        case invalidCharacters(_ label: String, byte: Byte, reason: String)

        case startsWithHyphen(_ label: String)

        case endsWithHyphen(_ label: String)

        case startsWithDigit(_ label: String)
    }
}

extension RFC_1035.Domain.Label.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .empty:
            return "Domain label cannot be empty"

        case .tooLong(let length, let label):
            return "Domain label '\(label)' is too long (\(length) bytes, maximum 63)"

        case .invalidCharacters(let label, let byte, let reason):
            return
                "Domain label '\(label)' has invalid byte 0x\(String(byte.bitPattern, radix: 16)): \(reason)"

        case .startsWithHyphen(let label):
            return "Domain label '\(label)' cannot start with a hyphen"

        case .endsWithHyphen(let label):
            return "Domain label '\(label)' cannot end with a hyphen"

        case .startsWithDigit(let label):
            return "Domain label '\(label)' must start with a letter (RFC 1035)"
        }
    }
}
