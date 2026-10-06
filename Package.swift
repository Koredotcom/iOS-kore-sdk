// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ArtemisSocketPlugin",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
    ],
    products: [
        .library(
            name: "ArtemisSocketPlugin",
            targets: ["ArtemisSocketPlugin"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.0"),
    ],
    targets: [
        .target(
            name: "ArtemisSocketPlugin",
            dependencies: ["Yams"],
            path: "Sources/ArtemisSocketPlugin",
            resources: [
                .process("PrivacyInfo.xcprivacy"),
            ]
        ),
        .testTarget(
            name: "ArtemisSocketPluginTests",
            dependencies: ["ArtemisSocketPlugin"],
            path: "Tests/ArtemisSocketPluginTests"
        ),
    ]
)
