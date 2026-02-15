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
        // Core library with all business logic
        .target(
            name: "TerminalOrchestratorCore",
            dependencies: [
                .product(name: "SwiftCrossUI", package: "swift-cross-ui")
            ],
            path: "Sources/TerminalOrchestrator",
            exclude: ["OrchestratorApp.swift"]
        ),
        // Executable app
        .executableTarget(
            name: "TerminalOrchestrator",
            dependencies: [
                "TerminalOrchestratorCore",
                .product(name: "DefaultBackend", package: "swift-cross-ui")
            ],
            path: "Sources/App"
        ),
        // Tests
        .testTarget(
            name: "TerminalOrchestratorTests",
            dependencies: ["TerminalOrchestratorCore"],
            path: "Tests/TerminalOrchestratorTests"
        )
    ]
)
