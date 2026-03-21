// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "EpubBuilder",
    platforms: [.macOS(.v13)],
    products: [
        .library(
            name: "EpubBuilder",
            targets: ["EpubBuilder"]
        ),
    ],
    targets: [
        .target(
            name: "EpubBuilder"
        ),
        .testTarget(
            name: "EpubBuilderTests",
            dependencies: ["EpubBuilder"]
        ),
    ]
)
