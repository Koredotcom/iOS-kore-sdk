// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

#if !COCOAPODS
import PackageDescription

let package = Package(
    name: "KoreBotSDK",
    platforms: [
          .iOS(.v12)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "KoreBotSDK",
            targets: ["KoreBotSDK"]),
    ],
    dependencies: [
        .package(url: "https://github.com/daltoniam/Starscream.git", from: "4.0.0"),
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.8.1")),
        .package(url: "https://github.com/tristanhimmelman/ObjectMapper.git", .exact("4.1.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "KoreBotSDK",
            dependencies: ["Starscream", "Alamofire", "ObjectMapper"]),
    ]
)
#endif


