extension RFC_1035.ResourceRecord {

    public struct SOA: Sendable, Hashable {

        public let mname: RFC_1035.Domain

        public let rname: RFC_1035.Domain

        public let serial: UInt32

        public let refresh: UInt32

        public let retry: UInt32

        public let expire: UInt32

        public let minimum: UInt32

        public init(
            mname: RFC_1035.Domain,
            rname: RFC_1035.Domain,
            serial: UInt32,
            refresh: UInt32,
            retry: UInt32,
            expire: UInt32,
            minimum: UInt32
        ) {
            self.mname = mname
            self.rname = rname
            self.serial = serial
            self.refresh = refresh
            self.retry = retry
            self.expire = expire
            self.minimum = minimum
        }
    }
}
