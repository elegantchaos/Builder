// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Example",
    products: [
        .executable(
            name: "Example",
            targets: ["Example"]),
    ],
    dependencies: [
        // example tool we're going to use in the build
        .package(url: "https://github.com/elegantchaos/BuilderToolExample.git", from: "1.0.5"),

        // support library we're going to use in the configuration target
        .package(url: "https://github.com/elegantchaos/BuilderBasicConfigure.git", from: "1.0.4"),
    ],
    targets: [
        .target(
            name: "Example",
            dependencies: []),
        .target(
            name: "Configure",
          dependencies: ["BuilderBasicConfigure", "BuilderToolExample"]),
        .testTarget(
            name: "ExampleTests",
            dependencies: ["Example"]),
    ]
)
