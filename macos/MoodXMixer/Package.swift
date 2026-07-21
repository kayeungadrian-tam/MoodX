// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "MoodXMixer",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "MoodXMixer", targets: ["MoodXMixer"])
    ],
    targets: [
        .executableTarget(
            name: "MoodXMixer",
            path: "Sources/MoodXMixer"
        ),
        .testTarget(
            name: "MoodXMixerTests",
            dependencies: ["MoodXMixer"],
            path: "Tests/MoodXMixerTests"
        )
    ]
)
