// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "VnIme",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "VnIme",
            targets: ["VnIme"]
        )
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "VnIme",
            dependencies: [],
            path: "Sources/VnIme",
            resources: [
                .process("Resources")
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "VnImeTests",
            dependencies: ["VnIme"],
            path: "Tests/VnImeTests"
        ),
        .testTarget(
            name: "VnImeUITests",
            dependencies: ["VnIme"],
            path: "Tests/VnImeUITests"
        )
    ]
)
