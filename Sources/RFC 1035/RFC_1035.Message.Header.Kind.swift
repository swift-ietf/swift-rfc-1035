extension RFC_1035.Message.Header {

    public enum Kind: Sendable, Hashable {

        case query

        case response
    }
}
