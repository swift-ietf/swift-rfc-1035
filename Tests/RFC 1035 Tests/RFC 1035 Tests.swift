import RFC_1035
import Testing

@Suite
struct `RFC 1035 Domain Tests` {
    @Test
    func `Successfully creates valid domain`() throws {
        let domain = try RFC_1035.Domain("example.com")
        #expect(domain.name == "example.com")
    }

    @Test
    func `Successfully creates domain from Substring`() throws {
        let fullString = "www.example.com"
        let substring = fullString.dropFirst(4)
        let domain = try RFC_1035.Domain(substring)
        #expect(domain.name == "example.com")
    }

    @Test
    func `Successfully creates label from Substring`() throws {
        let labelStr = "test-label"
        let substring = labelStr.dropLast(6)
        let label = try RFC_1035.Domain.Label(substring)
        #expect(label == "test")
    }

    @Test
    func `Successfully creates subdomain`() throws {
        let domain = try RFC_1035.Domain("sub.example.com")
        #expect(domain.name == "sub.example.com")
    }

    @Test
    func `Successfully gets TLD`() throws {
        let domain = try RFC_1035.Domain("example.com")
        #expect(domain.tld! == "com")
    }

    @Test
    func `Successfully gets SLD`() throws {
        let domain = try RFC_1035.Domain("example.com")
        #expect(domain.sld! == "example")
    }

    @Test
    func `Exposes its labels in presentation order`() throws {
        let domain = try RFC_1035.Domain("api.example.com")
        #expect(domain.labels.map(\.rawValue) == ["api", "example", "com"])
    }

    @Test
    func `Describes itself as its name`() throws {
        let domain = try RFC_1035.Domain("Example.COM")
        #expect(domain.description == "Example.COM")
        #expect(domain == "example.com")
    }

    @Test
    func `Fails with empty domain`() throws {
        #expect(throws: RFC_1035.Domain.Error.empty) {
            _ = try RFC_1035.Domain("")
        }
    }

    @Test
    func `Fails with too many labels`() throws {
        let longDomain = Array(repeating: "a", count: 128).joined(separator: ".")
        #expect(throws: RFC_1035.Domain.Error.tooManyLabels) {
            _ = try RFC_1035.Domain(longDomain)
        }
    }

    @Test
    func `Fails with too long domain`() throws {
        let longLabel = String(repeating: "a", count: 63)
        let longDomain = Array(repeating: longLabel, count: 5).joined(separator: ".")
        #expect(throws: RFC_1035.Domain.Error.tooLong(319)) {
            _ = try RFC_1035.Domain(longDomain)
        }
    }

    @Test
    func `Fails with invalid label starting with hyphen`() throws {
        #expect(throws: RFC_1035.Domain.Error.invalidLabel(.startsWithHyphen("-example"))) {
            _ = try RFC_1035.Domain("-example.com")
        }
    }

    @Test
    func `Fails with invalid label ending with hyphen`() throws {
        #expect(throws: RFC_1035.Domain.Error.invalidLabel(.endsWithHyphen("example-"))) {
            _ = try RFC_1035.Domain("example-.com")
        }
    }

    @Test
    func `Fails with invalid label starting with digit`() throws {
        #expect(throws: RFC_1035.Domain.Error.invalidLabel(.startsWithDigit("3com"))) {
            _ = try RFC_1035.Domain("3com.com")
        }
    }

    @Test
    func `Successfully detects subdomain relationship`() throws {
        let parent = try RFC_1035.Domain("example.com")
        let child = try RFC_1035.Domain("sub.example.com")
        #expect(child.isSubdomain(of: parent))
    }

    @Test
    func `Successfully adds subdomain`() throws {
        let domain = try RFC_1035.Domain("example.com")
        let subdomain = try domain.addingSubdomain("sub")
        #expect(subdomain.name == "sub.example.com")
    }

    @Test
    func `Successfully gets parent domain`() throws {
        let domain = try RFC_1035.Domain("sub.example.com")
        let parent = try domain.parent()
        #expect(parent?.name == "example.com")
    }

    @Test
    func `Successfully gets root domain`() throws {
        let domain = try RFC_1035.Domain("sub.example.com")
        let root = try domain.root()
        #expect(root?.name == "example.com")
    }

    @Test
    func `Successfully creates domain from root components`() throws {
        let domain = try RFC_1035.Domain.root("example", "com")
        #expect(domain.name == "example.com")
    }

    @Test
    func `Successfully creates domain from subdomain components`() throws {
        let domain = try RFC_1035.Domain.subdomain("com", "example", "sub")
        #expect(domain.name == "sub.example.com")
    }

    @Test
    func `The root name has no labels`() {
        #expect(RFC_1035.Domain.root.isRoot)
        #expect(RFC_1035.Domain.root.labels.isEmpty)
        #expect(RFC_1035.Domain.root.name == ".")
    }

    @Test
    func `Limits follow section 2.3.4`() {
        #expect(RFC_1035.Domain.Limits.maxLength == 255)
        #expect(RFC_1035.Domain.Limits.maxLabels == 127)
        #expect(RFC_1035.Domain.Limits.maxLabelLength == 63)
    }
}
