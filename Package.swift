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
    dependencies: [
        .package(url: "https://github.com/weichsel/ZIPFoundation.git", .upToNextMajor(from: "0.9.0")),
    ],
    targets: [
        .target(
            name: "EpubBuilder",
            dependencies: [
                .product(name: "ZIPFoundation", package: "ZIPFoundation"),
            ]
        ),
        .testTarget(
            name: "EpubBuilderTests",
            dependencies: ["EpubBuilder"]
        ),
    ]
)
