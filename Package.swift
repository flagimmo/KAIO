// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TerminalOrchestrator",
    platforms: [
        .macOS(.v11)
    ],
    dependencies: [
        .package(url: "https://github.com/moreSwift/swift-cross-ui", branch: "main")
    ],
    targets: [
        .executableTarget(
            name: "TerminalOrchestrator",
            dependencies: [
                .product(name: "SwiftCrossUI", package: "swift-cross-ui"),
                .product(name: "DefaultBackend", package: "swift-cross-ui")
            ],
            path: "Sources/TerminalOrchestrator"
        )
    ]
)
