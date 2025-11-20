// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "NagaConfigurator",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "NagaConfigurator", targets: ["NagaConfigurator"])
    ],
    targets: [
        .executableTarget(
            name: "NagaConfigurator",
            path: "Sources" // Direct path to sources
        )
    ]
)
