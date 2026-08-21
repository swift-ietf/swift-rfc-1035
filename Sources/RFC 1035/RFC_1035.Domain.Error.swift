extension RFC_1035.Domain {

    public enum Error: Swift.Error, Sendable, Equatable {

        case empty

        case tooLong(_ length: Int)

        case tooManyLabels

        case invalidLabel(_ error: Label.Error)
    }
}

extension RFC_1035.Domain.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .empty:
            return "Domain name cannot be empty"

        case .tooLong(let length):
            return "Domain name is too long (\(length) bytes, maximum 255)"

        case .tooManyLabels:
            return "Domain has too many labels (maximum 127)"

        case .invalidLabel(let error):
            return "Invalid label: \(error.description)"
        }
    }
}
