// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "Wolf",
    platforms: [.iOS(.v10)],
    products: [
        .library(
            name: "Wolf",
            targets: ["Wolf"]),
    ],
    dependencies: [
        .package(url: "https://github.com/mxcl/PromiseKit.git", .upToNextMajor(from: "6.8.4")),
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "4.9.0")),
        .package(url: "https://github.com/AliSoftware/OHHTTPStubs.git", .upToNextMajor(from: "9.0.0")),
        .package(url: "https://github.com/kean/Nuke.git", .upToNextMajor(from: "8.4.0")),
        .package(url: "https://github.com/Quick/Nimble.git", .upToNextMajor(from: "8.0.7"))
    ],
    targets: [
        .target(
            name: "Wolf",
            dependencies: ["Alamofire", "PromiseKit"],
            path: "Source"),
        .testTarget(
            name: "WolfTests",
            dependencies: [
                "Wolf",
                "Alamofire",
                "PromiseKit",
                "Nimble",
                "OHHTTPStubs",
                "OHHTTPStubsSwift",
                "Nuke"
            ],
            path: "Tests"),
    ]
)
