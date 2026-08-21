extension RFC_1035.ResourceRecord.A {

    public enum Error: Swift.Error, Sendable, Equatable {

        case invalidOctetCount(_ count: Int)
    }
}

extension RFC_1035.ResourceRecord.A.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .invalidOctetCount(let count):
            return "A record address requires exactly 4 octets (got \(count))"
        }
    }
}
