// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "Builder",
    platforms: [
        .macOS(.v10_13)
    ],
    
    products: [
        .executable(name: "builder", targets: ["Builder"]),
    ],
    dependencies: [
        .package(url: "https://github.com/elegantchaos/Logger.git", from: "1.3.6"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.0.2")
    ],
    targets: [
        .target(
            name: "Builder",
            dependencies: [
                "Logger",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
        ]),
        .testTarget(
            name: "BuilderTests",
            dependencies: ["Builder"]
        )
    ]
)
