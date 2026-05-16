// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "NetworkKing",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "NetworkKing",
            targets: ["NetworkKing"]),
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
