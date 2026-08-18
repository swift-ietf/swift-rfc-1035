// swift-tools-version: 6.3.3

import PackageDescription

extension String {
    static let rfc1035: Self = "RFC 1035"
}

extension Target.Dependency {
    static var rfc1035: Self { .target(name: .rfc1035) }
    static var standards: Self { .product(name: "Standard Library Extensions", package: "swift-standard-library-extensions") }
    static var binary: Self { .product(name: "Binary Primitives", package: "swift-binary-primitives") }
    static var incits41986: Self { .product(name: "ASCII Serializer Primitives", package: "swift-ascii-serializer-primitives") }
    static var asciiParser: Self { .product(name: "Parseable ASCII Primitives", package: "swift-ascii-parser-primitives") }
}

let package = Package(
    name: "swift-rfc-1035",
    platforms: [
        .macOS("27"),
        .iOS("27"),
        .tvOS("27"),
        .watchOS("27"),
        .visionOS("27")
    ],
    products: [
        .library(name: "RFC 1035", targets: ["RFC 1035"])
    ],
    dependencies: [
        .package(url: "https://github.com/swift-primitives/swift-standard-library-extensions.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-binary-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-ascii-serializer-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-ascii-parser-primitives.git", branch: "main")
    ],
    targets: [
        .target(
            name: "RFC 1035",
            dependencies: [
                .standards,
                .binary,
                .incits41986,
                .asciiParser
            ]
        ),
        .testTarget(
            name: "RFC 1035 Tests",
            dependencies: [
                "RFC 1035",
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
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
