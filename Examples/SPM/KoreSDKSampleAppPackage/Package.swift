// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "KoreSDKSampleAppPackage",
    platforms: [.iOS(.v15)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ChatBot",
            targets: ["KoreBotSDK","ChatBotObjc"]),
    ],
    dependencies: [
            .package(url: "https://github.com/daltoniam/Starscream.git", .upToNextMajor(from: "4.0.0")),
            .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.6.4")),
            .package(url: "https://github.com/Alamofire/AlamofireImage.git", .upToNextMajor(from: "4.1.0")),
            .package(url: "https://github.com/tristanhimmelman/ObjectMapper.git", .upToNextMajor(from: "4.1.0")),
            .package(url: "https://github.com/bmoliveira/MarkdownKit.git", from: "1.7.0"),
            .package(url: "https://github.com/danielgindi/Charts.git", .upToNextMajor(from: "5.0.0")),
            .package(url: "https://github.com/wibosco/GhostTypewriter", .upToNextMajor(from: "2.1.0")),
            .package(url: "https://github.com/safx/Emoji-Swift", .upToNextMajor(from: "0.4.0")),
            .package(url: "https://github.com/congnd/FMPhotoPicker.git", .upToNextMajor(from: "1.3.0")),
            .package(url: "https://github.com/mkeiser/SwiftUTI", branch: "master")
        ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies. ChatBotSwift
        .target(
            name: "KoreBotSDK", dependencies: ["Starscream","Alamofire","AlamofireImage","ObjectMapper", "MarkdownKit", .product(name: "DGCharts", package: "Charts"), "GhostTypewriter", .product(name: "Emoji", package: "Emoji-swift"), "FMPhotoPicker", "SwiftUTI","ChatBotObjc"]),
            .target(name: "ChatBotObjc", path: "Sources/ChatBotObjc"),

    ]
)
