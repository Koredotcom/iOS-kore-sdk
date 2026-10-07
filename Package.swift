// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ArtemisUISDK",
    platforms: [.iOS(.v15), .macOS(.v12)],
    products: [.library(name: "ArtemisUISDK", targets: ["ArtemisUISDK"])],
    dependencies: [
        .package(name: "ArtemisSocketSDK", path: "../artemis_socket_plugin")
    ],
    targets: [
        .target(name: "ArtemisUISDK", dependencies: [
            .product(name: "ArtemisSocketSDK", package: "ArtemisSocketSDK")
        ], path: "Sources/ArtemisUISDK"),
        .testTarget(name: "ArtemisUISDKTests", dependencies: ["ArtemisUISDK"], path: "Tests/ArtemisUISDKTests")
    ]
)
