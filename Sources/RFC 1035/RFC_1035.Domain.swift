public import ASCII_Serializer
public import Binary_Serializable
import Byte_Standard_Library_Integration
public import Parseable_ASCII

extension RFC_1035 {

    public struct Domain: Sendable, Codable {

        public let rawValue: String

        package let labels: [RFC_1035.Domain.Label]

        init(
            __unchecked _: Void,
            rawValue: String,
            labels: [RFC_1035.Domain.Label]
        ) {
            self.rawValue = rawValue
            self.labels = labels
        }
    }
}

extension RFC_1035.Domain: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue.lowercased())
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue.lowercased() == rhs.rawValue.lowercased()
    }

    public static func == (lhs: Self, rhs: Self.RawValue) -> Bool {
        lhs.rawValue.lowercased() == rhs.lowercased()
    }
}

extension RFC_1035.Domain: Swift.RawRepresentable, ASCII.Serializable, Binary.Serializable {

    public init?(rawValue: String) {
        do throws(Error) {
            try self.init(rawValue)
        } catch {
            return nil
        }
    }

    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ value: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == ASCII.Code {
        for byte in value.rawValue.utf8 { buffer.append(ASCII.Code(byte)) }
    }

    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ value: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        buffer.append(contentsOf: value.serialized)
    }
}

extension RFC_1035.Domain: CustomStringConvertible {

    public var description: String {
        String(decoding: serialized, as: UTF8.self)
    }
}

extension RFC_1035.Domain: ASCII.Parseable {

    public init(_ string: some StringProtocol) throws(Error) {
        try self.init(ascii: string.utf8.map(Byte.init(bitPattern:)))
    }

    public init<Bytes: Swift.Collection>(ascii bytes: Bytes) throws(Error)
    where Bytes.Element == Byte {

        guard !bytes.isEmpty else {
            throw Error.empty
        }

        guard bytes.count <= Limits.maxLength else {
            throw Error.tooLong(bytes.count)
        }

        var labels: [RFC_1035.Domain.Label] = []
        var currentStart = bytes.startIndex
        var currentIndex = bytes.startIndex

        while currentIndex < bytes.endIndex {

            if bytes[currentIndex] == ASCII.Code.period.byte {

                if currentStart < currentIndex {
                    let labelBytes = bytes[currentStart..<currentIndex]
                    do throws(Label.Error) {
                        try labels.append(RFC_1035.Domain.Label(ascii: labelBytes))
                    } catch {
                        throw Error.invalidLabel(error)
                    }
                }
                currentStart = bytes.index(after: currentIndex)
            }
            currentIndex = bytes.index(after: currentIndex)
        }

        if currentStart < bytes.endIndex {
            let labelBytes = bytes[currentStart...]
            do throws(Label.Error) {
                try labels.append(RFC_1035.Domain.Label(ascii: labelBytes))
            } catch {
                throw Error.invalidLabel(error)
            }
        }

        guard !labels.isEmpty else {
            throw Error.empty
        }

        guard labels.count <= Limits.maxLabels else {
            throw Error.tooManyLabels
        }

        let rawValue = String(decoding: bytes, as: UTF8.self)
        self.init(
            __unchecked: (),
            rawValue: rawValue,
            labels: labels
        )
    }
}

extension RFC_1035.Domain {

    public var name: String {
        rawValue
    }

    public var tld: RFC_1035.Domain.Label? {
        labels.last
    }

    public var sld: RFC_1035.Domain.Label? {
        labels.dropLast().last
    }
}

extension RFC_1035.Domain {

    public func isSubdomain(of parent: RFC_1035.Domain) -> Bool {
        guard labels.count > parent.labels.count else { return false }
        return labels.suffix(parent.labels.count) == parent.labels
    }

    public func addingSubdomain(_ components: [String]) throws(Error) -> RFC_1035.Domain {
        var newLabels: [Label] = []
        for component in components {
            do throws(Label.Error) {
                try newLabels.append(Label(component))
            } catch {
                throw Error.invalidLabel(error)
            }
        }

        let allLabels = newLabels + labels
        guard allLabels.count <= Limits.maxLabels else {
            throw Error.tooManyLabels
        }

        let newName = (components + labels.map(\.rawValue)).joined(separator: ".")
        guard newName.count <= Limits.maxLength else {
            throw Error.tooLong(newName.count)
        }

        return RFC_1035.Domain(__unchecked: (), rawValue: newName, labels: allLabels)
    }

    public func addingSubdomain(_ components: String...) throws(Error) -> RFC_1035.Domain {
        try addingSubdomain(components)
    }

    public func parent() throws(Error) -> RFC_1035.Domain? {
        guard labels.count > 1 else { return nil }
        let parentLabels = Array(labels.dropFirst())
        let parentName = parentLabels.map(\.rawValue).joined(separator: ".")
        return RFC_1035.Domain(__unchecked: (), rawValue: parentName, labels: parentLabels)
    }

    public func root() throws(Error) -> RFC_1035.Domain? {
        guard labels.count >= 2 else { return nil }
        let rootLabels = Array(labels.suffix(2))
        let rootName = rootLabels.map(\.rawValue).joined(separator: ".")
        return RFC_1035.Domain(__unchecked: (), rawValue: rootName, labels: rootLabels)
    }
}

extension RFC_1035.Domain {

    public static let root = RFC_1035.Domain(__unchecked: (), rawValue: ".", labels: [])
}

extension RFC_1035.Domain {

    public init(labels: [RFC_1035.Domain.Label]) throws(Error) {
        guard !labels.isEmpty else {
            throw Error.empty
        }

        guard labels.count <= Limits.maxLabels else {
            throw Error.tooManyLabels
        }

        let name = labels.map(\.rawValue).joined(separator: ".")
        guard name.count <= Limits.maxLength else {
            throw Error.tooLong(name.count)
        }

        self.init(__unchecked: (), rawValue: name, labels: labels)
    }

    public init<S: Swift.Sequence>(labels labelStrings: S) throws(Error)
    where S.Element: StringProtocol {
        var validatedLabels: [Label] = []
        for labelString in labelStrings {
            do throws(Label.Error) {
                try validatedLabels.append(Label(labelString))
            } catch {
                throw Error.invalidLabel(error)
            }
        }
        try self.init(labels: validatedLabels)
    }

    public static func root(_ sld: String, _ tld: String) throws(Error) -> RFC_1035.Domain {
        try RFC_1035.Domain(labels: [sld, tld])
    }

    public static func subdomain(_ components: String...) throws(Error) -> RFC_1035.Domain {
        try RFC_1035.Domain(labels: components.reversed())
    }
}
