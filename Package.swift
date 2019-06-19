// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "Builder",
    platforms: [
      .macOS(.v10_13)
    ],
 
    products: [
      .executable(name: "builder", targets: ["BuilderCommand"]),
    ],
    dependencies: [
        .package(url: "https://github.com/elegantchaos/Logger", from: "1.3.6"),
        .package(url: "https://github.com/elegantchaos/docopt.swift", from: "0.6.11"),
        ],
    targets: [
      .target(
          name: "BuilderCommand",
          dependencies: ["Builder"]),
        .target(
            name: "Builder",
            dependencies: ["Docopt", "Logger"]),
        .testTarget(
            name: "BuilderTests",
            dependencies: ["Builder"]
        )
    ],
    swiftLanguageVersions: [.v4_2]
)
