import Foundation
import RFC_1035
import Testing

@Suite
struct `README Verification` {
    @Test
    func `README Line 51-52: Create from string`() throws {
        let domain = try RFC_1035.Domain("example.com")

        #expect(domain.name == "example.com")
    }

    @Test
    func `README Line 54-55: Create from root components`() throws {
        let domain = try RFC_1035.Domain.root("example", "com")

        #expect(domain.name == "example.com")
    }

    @Test
    func `README Line 57-59: Create subdomain with reversed components`() throws {
        let domain = try RFC_1035.Domain.subdomain("com", "example", "api")

        #expect(domain.name == "api.example.com")
    }

    @Test
    func `README Line 65-72: Working with domain components`() throws {
        let domain = try RFC_1035.Domain("api.example.com")

        #expect(domain.tld! == "com")
        #expect(domain.sld! == "example")
        #expect(domain.name == "api.example.com")
    }

    @Test
    func `README Line 78-95: Domain hierarchy navigation`() throws {
        let domain = try RFC_1035.Domain("api.v1.example.com")

        let parent = try domain.parent()
        #expect(parent?.name == "v1.example.com")

        let root = try domain.root()
        #expect(root?.name == "example.com")

        let subdomain = try domain.addingSubdomain("staging")
        #expect(subdomain.name == "staging.api.v1.example.com")

        let parentDomain = try RFC_1035.Domain("example.com")
        let childDomain = try RFC_1035.Domain("api.example.com")
        #expect(childDomain.isSubdomain(of: parentDomain))
    }

    @Test
    func `README Line 136-146: Error handling`() throws {

        #expect(throws: RFC_1035.Domain.Error.empty) {
            _ = try RFC_1035.Domain("")
        }

        #expect(throws: RFC_1035.Domain.Error.invalidLabel(.startsWithHyphen("-example"))) {
            _ = try RFC_1035.Domain("-example.com")
        }
    }

    @Test
    func `README Line 151-158: Codable support`() throws {
        let domain = try RFC_1035.Domain("example.com")

        let encoded = try JSONEncoder().encode(domain)

        let decoded = try JSONDecoder().decode(RFC_1035.Domain.self, from: encoded)

        #expect(domain == decoded)
    }
}
