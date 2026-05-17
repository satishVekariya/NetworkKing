// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "NetworkKing",
    platforms: [.iOS(.v16), .macOS(.v13)],
    products: [
        .library(
            name: "NetworkKing",
            targets: ["NetworkKing"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.4.0"),
    ],
    targets: [
        .target(
            name: "NetworkKing",
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]),
        .testTarget(
            name: "NetworkKingTests",
            dependencies: ["NetworkKing"],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]),
    ]
)
