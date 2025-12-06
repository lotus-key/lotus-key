// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "VnIme",
    platforms: [
        .macOS(.v15)
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
