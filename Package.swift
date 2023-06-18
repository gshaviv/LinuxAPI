// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TeslaBackendAPI",
    platforms: [
      .macOS(.v12),
      .iOS(.v14)
    ],
    products: [
        .library(
            name: "TeslaBackendAPI",
            targets: ["TeslaBackendAPI"]),
    ],
    dependencies: [
//      .package(url: "https://github.com/swift-server/async-http-client", .upToNextMajor(from: "1.0.0")),
    ],
    targets: [
        .target(
            name: "TeslaBackendAPI",
            dependencies: [
//              .product(name: "AsyncHTTPClient", package: "async-http-client"),
            ]),
        .testTarget(
            name: "TeslaBackendAPITests",
            dependencies: ["TeslaBackendAPI"]),
    ]
)
