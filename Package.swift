// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Wolf",
    platforms: [.macOS(.v10_12),
                .iOS(.v10),
                .tvOS(.v10),
                .watchOS(.v3)],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "Wolf",
            targets: ["Wolf"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/mxcl/PromiseKit.git", .upToNextMajor(from: "6.8.4")),
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "4.9.0")),
        .package(url: "https://github.com/AliSoftware/OHHTTPStubs.git", .upToNextMajor(from: "9.0.0")),
        .package(url: "https://github.com/kean/Nuke.git", .upToNextMajor(from: "8.4.0")),
        .package(url: "https://github.com/Quick/Nimble.git", .upToNextMajor(from: "8.0.5")),
        .package(url: "https://github.com/mattgallagher/CwlPreconditionTesting.git", .branch("master"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
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
