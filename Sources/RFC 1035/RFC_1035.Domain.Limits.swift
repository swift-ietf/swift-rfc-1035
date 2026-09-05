extension RFC_1035.Domain {
    public enum Limits {
    }
}

extension RFC_1035.Domain.Limits {
    public static let maxLength = 255
    public static let maxLabels = 127
    public static let maxLabelLength = 63
}
