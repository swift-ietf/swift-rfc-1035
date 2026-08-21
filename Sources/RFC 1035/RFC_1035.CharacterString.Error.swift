extension RFC_1035.CharacterString {

    public enum Error: Swift.Error, Sendable, Equatable {

        case tooLong(_ length: Int)
    }
}

extension RFC_1035.CharacterString.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .tooLong(let length):
            return "<character-string> is too long (\(length) bytes, maximum 255)"
        }
    }
}
