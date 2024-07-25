// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GoogleScholarSwift",
    platforms: [
        .iOS(.v13),
        .macOS(.v12),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(
            name: "GoogleScholarSwift",
            targets: ["GoogleScholarSwift"]),
    ],
    dependencies: [
        .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "2.7.2"),
        .package(url: "https://github.com/apple/swift-docc-plugin.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "GoogleScholarSwift",
            dependencies: ["SwiftSoup"]),
        .testTarget(
            name: "GoogleScholarSwiftTests",
            dependencies: ["GoogleScholarSwift"])
    ]
)
