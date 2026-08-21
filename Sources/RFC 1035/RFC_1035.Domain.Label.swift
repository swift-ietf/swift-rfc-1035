public import ASCII_Serializer_Primitives
public import Binary_Serializable_Primitives
public import Parseable_ASCII_Primitives

extension RFC_1035.Domain {

    public struct Label: Sendable, Codable {

        public let rawValue: String

        init(
            __unchecked _: Void,
            rawValue: String
        ) {
            self.rawValue = rawValue
        }
    }
}

extension RFC_1035.Domain.Label: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue.lowercased())
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue.lowercased() == rhs.rawValue.lowercased()
    }

    public static func == (lhs: Self, rhs: Self.RawValue) -> Bool {
        lhs.rawValue.lowercased() == rhs.lowercased()
    }

    public static func == (lhs: Self.RawValue, rhs: Self) -> Bool {
        lhs.lowercased() == rhs.rawValue.lowercased()
    }
}

extension RFC_1035.Domain.Label: Swift.RawRepresentable, ASCII.Serializable, Binary.Serializable {

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

extension RFC_1035.Domain.Label: CustomStringConvertible {

    public var description: String {
        String(decoding: serialized, as: UTF8.self)
    }
}

extension RFC_1035.Domain.Label: ASCII.Parseable {

    public init(_ string: some StringProtocol) throws(Error) {
        try self.init(ascii: [Byte](string.utf8))
    }

    public init<Bytes: Swift.Collection>(ascii bytes: Bytes) throws(Error)
    where Bytes.Element == Byte {
        guard let firstByte = bytes.first else {
            throw Error.empty
        }

        var count = 0
        var lastByte = firstByte

        for byte in bytes {
            count += 1
            lastByte = byte

            let code: ASCII.Code
            do throws(ASCII.Code.Error) {
                code = try ASCII.Code(byte)
            } catch {
                let string = String(decoding: bytes, as: UTF8.self)
                throw Error.invalidCharacters(
                    string,
                    byte: byte,
                    reason: "Only letters, digits, and hyphens allowed"
                )
            }
            let validInterior = code.isLetter || code.isDigit || code == ASCII.Code.hyphen
            guard validInterior else {
                let string = String(decoding: bytes, as: UTF8.self)
                throw Error.invalidCharacters(
                    string,
                    byte: byte,
                    reason: "Only letters, digits, and hyphens allowed"
                )
            }
        }

        guard count <= RFC_1035.Domain.Limits.maxLabelLength else {
            let string = String(decoding: bytes, as: UTF8.self)
            throw Error.tooLong(count, label: string)
        }

        let firstCode: ASCII.Code
        do throws(ASCII.Code.Error) {
            firstCode = try ASCII.Code(firstByte)
        } catch {
            let string = String(decoding: bytes, as: UTF8.self)
            throw Error.invalidCharacters(
                string,
                byte: firstByte,
                reason: "Must start with a letter"
            )
        }
        guard firstCode.isLetter else {
            let string = String(decoding: bytes, as: UTF8.self)
            if firstCode == ASCII.Code.hyphen {
                throw Error.startsWithHyphen(string)
            } else if firstCode.isDigit {
                throw Error.startsWithDigit(string)
            } else {
                throw Error.invalidCharacters(
                    string,
                    byte: firstByte,
                    reason: "Must start with a letter"
                )
            }
        }

        let lastCode: ASCII.Code
        do throws(ASCII.Code.Error) {
            lastCode = try ASCII.Code(lastByte)
        } catch {
            let string = String(decoding: bytes, as: UTF8.self)
            throw Error.invalidCharacters(
                string,
                byte: lastByte,
                reason: "Must end with a letter or digit"
            )
        }
        guard lastCode.isLetter || lastCode.isDigit else {
            let string = String(decoding: bytes, as: UTF8.self)
            if lastCode == ASCII.Code.hyphen {
                throw Error.endsWithHyphen(string)
            } else {
                throw Error.invalidCharacters(
                    string,
                    byte: lastByte,
                    reason: "Must end with a letter or digit"
                )
            }
        }

        self.init(__unchecked: (), rawValue: String(decoding: bytes, as: UTF8.self))
    }
}
