// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Argument",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "Argument",
            targets: ["Argument"]),
    ],
    dependencies: [
        // WebP support for advanced image formats
        .package(url: "https://github.com/SDWebImage/libwebp-Xcode", from: "1.3.0")
    ],
    targets: [
        .target(
            name: "Argument",
            dependencies: [
                .product(name: "libwebp", package: "libwebp-Xcode")
            ]),
        .testTarget(
            name: "ArgumentTests",
            dependencies: ["Argument"]),
    ]
)