// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "yason",
    platforms: [
        .macOS(.v10_13)
    ],
    products: [
        .executable(name: "yason", targets: ["yason"]),
        .library(name: "yasonLib", targets: [
            "yasonLib"
        ])
    ],
    dependencies: [
        .package(url: "https://github.com/jpsim/Yams.git", from: "4.0.1"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "0.3.1"),
    ],
    targets: [
        .target(
            name: "yasonLib",
            dependencies: ["Yams"]),
        .target(
            name: "yason",
            dependencies: [
                "yasonLib",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]),
        .testTarget(
            name: "yasonTests",
            dependencies: ["yason"],
            resources: [
                .copy("test.yaml"),
                .copy("test.json"),
                .copy("corrupted.json")
            ]),
    ]
)
