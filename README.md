# Swift RFC 1035

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)
[![CI](https://github.com/swift-ietf/swift-rfc-1035/workflows/CI/badge.svg)](https://github.com/swift-ietf/swift-rfc-1035/actions/workflows/ci.yml)

Swift implementation of RFC 1035: Domain Names - Implementation and Specification.

## Overview

RFC 1035 defines the specification for domain name syntax and semantics in the Domain Name System (DNS). This package provides a pure Swift implementation of RFC 1035-compliant domain names with full validation, type-safe label handling, and convenient APIs for working with domain hierarchies.

The package enforces all RFC 1035 rules including label length limits (63 characters), total domain length limits (255 characters), label format requirements (must start with letter, end with letter or digit, contain only letters/digits/hyphens), and maximum label count (127).

## Features

- **RFC 1035 Compliance**: Full validation of domain name syntax according to RFC 1035 specification
- **Type-Safe Labels**: Label type that enforces RFC 1035 rules at compile time
- **Domain Hierarchy**: Navigate parent domains, root domains, and detect subdomain relationships
- **Flexible Construction**: Create domains from strings, arrays of labels, or using convenience builders
- **Codable Support**: Full Codable conformance for JSON encoding/decoding
- **Zero Dependencies**: Pure Swift implementation with no external dependencies

## Installation

Add swift-rfc-1035 to your package dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/swift-ietf/swift-rfc-1035.git", from: "0.4.5")
]
```

Then add it to your target:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "RFC 1035", package: "swift-rfc-1035")
    ]
)
```

## Quick Start

### Creating Domains

```swift
import RFC_1035

// Create from string
let domain = try Domain("example.com")

// Create from root components
let domain = try Domain.root("example", "com")

// Create subdomain with reversed components
let domain = try Domain.subdomain("com", "example", "api")
// Result: "api.example.com"
```

### Working with Domain Components

```swift
let domain = try Domain("api.example.com")

// Access TLD and SLD
print(domain.tld?.stringValue)  // "com"
print(domain.sld?.stringValue)  // "example"

// Get full domain name
print(domain.name)  // "api.example.com"
```

### Domain Hierarchy Navigation

```swift
let domain = try Domain("api.v1.example.com")

// Get parent domain
let parent = try domain.parent()
print(parent?.name)  // "v1.example.com"

// Get root domain (TLD + SLD)
let root = try domain.root()
print(root?.name)  // "example.com"

// Add subdomain
let subdomain = try domain.addingSubdomain("staging")
print(subdomain.name)  // "staging.api.v1.example.com"

// Check subdomain relationships
let parent = try Domain("example.com")
let child = try Domain("api.example.com")
print(child.isSubdomain(of: parent))  // true
```

## Usage

### Domain Type

The core `Domain` type is a struct that validates and stores domain names:

```swift
public struct Domain: Hashable, Sendable {
    public init(_ string: String) throws
    public init(labels: [String]) throws

    public var name: String
    public var tld: Domain.Label?
    public var sld: Domain.Label?

    public func isSubdomain(of parent: Domain) -> Bool
    public func addingSubdomain(_ components: [String]) throws -> Domain
    public func addingSubdomain(_ components: String...) throws -> Domain
    public func parent() throws -> Domain?
    public func root() throws -> Domain?
}
```

### Validation Rules

RFC 1035 enforces the following rules:

- **Label Length**: Each label must be 1-63 characters
- **Total Length**: Complete domain name must not exceed 255 characters
- **Label Count**: Maximum 127 labels
- **Label Format**:
  - Must start with a letter (a-z, A-Z)
  - Must end with a letter or digit
  - May contain letters, digits, and hyphens in interior positions

### Error Handling

```swift
do {
    let domain = try Domain("example.com")
} catch Domain.ValidationError.empty {
    print("Domain cannot be empty")
} catch Domain.ValidationError.tooLong(let length) {
    print("Domain length \(length) exceeds maximum")
} catch Domain.ValidationError.tooManyLabels {
    print("Too many labels in domain")
} catch Domain.ValidationError.invalidLabel(let label) {
    print("Invalid label: \(label)")
}
```

### Codable Support

```swift
let domain = try Domain("example.com")

// Encode to JSON
let encoded = try JSONEncoder().encode(domain)

// Decode from JSON
let decoded = try JSONDecoder().decode(Domain.self, from: encoded)
```

## Related Packages

### Used By
- [swift-rfc-1123](https://github.com/swift-ietf/swift-rfc-1123) - RFC 1123 compliant hostnames building on RFC 1035 domains

## Requirements

- Swift 6.0+
- macOS 13.0+ / iOS 16.0+

## License

This library is released under the Apache License 2.0. See [LICENSE](LICENSE) for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
