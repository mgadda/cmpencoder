// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CMPEncoder",
    products: [
        .library(
            name: "CMPEncoder",
            targets: ["CMPEncoder"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "CMP"),
        .target(
            name: "CMPEncoder",
            dependencies: ["CMP"]),        
        .testTarget(
            name: "cmpencoderTests",
            dependencies: ["CMPEncoder"]),
    ]
)

