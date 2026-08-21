extension RFC_1035.Domain {
    package enum Limits {
    }
}

extension RFC_1035.Domain.Limits {
    static let maxLength = 255
    static let maxLabels = 127
    static let maxLabelLength = 63
}
