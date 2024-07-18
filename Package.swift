// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GoogleScholarSwift",
    products: [
        .library(
            name: "GoogleScholarSwift",
            targets: ["GoogleScholarSwift"]),
        .executable(
            name: "GoogleScholarSwiftCLI",
            targets: ["GoogleScholarSwiftCLI"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "2.7.2")
    ],
    targets: [
        .target(
            name: "GoogleScholarSwift",
            dependencies: ["SwiftSoup"]),
        .executableTarget(
            name: "GoogleScholarSwiftCLI",
            dependencies: ["GoogleScholarSwift"]
        ),
        .testTarget(
            name: "GoogleScholarSwiftTests",
            dependencies: ["GoogleScholarSwift"]),
    ]
)
