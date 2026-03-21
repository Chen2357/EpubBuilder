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
    // dependencies: [
    //     .package(url: "https://github.com/marmelroy/Zip.git", from: "2.1.0"),
    // ],
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
