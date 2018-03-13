// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Builder",
    products: [
      .executable(name: "Builder", targets: ["BuilderCommand"]),
      .library(name: "libBuilder", targets: ["Builder"])
    ],
    dependencies: [
        .package(url: "https://github.com/elegantchaos/Logger", from: "1.0.6"),
        .package(url: "https://github.com/elegantchaos/docopt.swift", from: "0.6.8"),
        ],
    targets: [
      .target(
          name: "BuilderCommand",
          dependencies: ["Builder"]),
        .target(
            name: "Builder",
            dependencies: ["Docopt", "Logger"]),
        .testTarget(
            name: "BuilderTests"
        )
    ]
)
