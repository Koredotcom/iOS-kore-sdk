// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ArtemisUISDK",
    platforms: [.iOS(.v15), .macOS(.v12)],
    products: [.library(name: "ArtemisUISDK", targets: ["ArtemisUISDK"])],
    dependencies: [
        .package(path: "/Users/Kartheek.Pagidimarri/Desktop/Git Codes/artemis_Native_iOS_Code/artemis_socket_plugin")
    ],
    targets: [
        .target(name: "ArtemisUISDK", dependencies: [
            .product(name: "ArtemisSocketPlugin", package: "artemis_socket_plugin")
        ], path: "Sources/ArtemisUISDK"),
        .testTarget(name: "ArtemisUISDKTests", dependencies: ["ArtemisUISDK"], path: "Tests/ArtemisUISDKTests")
    ]
)
