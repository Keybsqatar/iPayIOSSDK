// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "iPaySDK",
    platforms: [
        .iOS(.v13), // Minimum iOS version supported
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "iPaySDK",
            targets: ["iPaySDK"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/SVGKit/SVGKit.git",
            from: "3.0.0"
        ),
        .package(
            url: "https://github.com/SDWebImage/SDWebImageSwiftUI.git",
            from: "2.2.7"
        ),
        .package(
            url: "https://github.com/SDWebImage/SDWebImageSVGCoder.git",
            from: "1.8.0"
        ),
        .package(
                    url: "https://github.com/airbnb/lottie-ios.git",
                    from: "4.4.0"
        )
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "iPaySDK",
            dependencies: [
                // Reference the products exported by the above packages:
                .product(name: "SVGKit", package: "SVGKit"),
                .product(name: "SDWebImageSwiftUI", package: "SDWebImageSwiftUI"),
                .product(name: "SDWebImageSVGCoder", package: "SDWebImageSVGCoder"),
                .product(name: "Lottie", package: "lottie-ios")

            ],
            path: "Sources/iPaySDK",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "iPaySDKTests",
            dependencies: ["iPaySDK"]),
    ]
)
