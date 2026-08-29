// swift-tools-version: 6.4

import PackageDescription

extension String {
    static let rfc1035: Self = "RFC 1035"
}

extension Target.Dependency {
    static var rfc1035: Self { .target(name: .rfc1035) }
    static var standards: Self {
        .product(name: "Standard Library Extensions", package: "swift-standard-library-extensions")
    }
    static var binary: Self {
        .product(name: "Binary", package: "swift-binary")
    }
    static var incits41986: Self {
        .product(name: "ASCII Serializer", package: "swift-ascii-serializer")
    }
    static var asciiParser: Self {
        .product(name: "Parseable ASCII", package: "swift-ascii-parser")
    }
}

let package = Package(
    name: "swift-rfc-1035",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(name: "RFC 1035", targets: ["RFC 1035"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-atoms/swift-standard-library-extensions.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-binary.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-ascii-serializer.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-ascii-parser.git",
            branch: "main"
        ),
    ],
    targets: [
        .target(
            name: "RFC 1035",
            dependencies: [
                .standards,
                .binary,
                .incits41986,
                .asciiParser,
            ]
        ),
        .testTarget(
            name: "RFC 1035 Tests",
            dependencies: [
                "RFC 1035"
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

extension String {
    var tests: Self { self + " Tests" }
    var foundation: Self { self + " Foundation" }
}

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
