// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "vapor-identity",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(name: "Identity", targets: ["Identity"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.119.2"),
        .package(url: "https://github.com/vapor/jwt.git", from: "5.1.2"),
        .package(url: "https://github.com/vapor/leaf.git", from: "4.5.1"),
        .package(url: "https://github.com/vapor/queues.git", from: "1.17.2"),
    ],
    targets: [
        .target(
            name: "Identity",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "JWT", package: "jwt"),
                .product(name: "Leaf", package: "leaf"),
                .product(name: "Queues", package: "queues"),
            ],
            resources: [
                .copy("Resources/Views"),
            ]
        ),
    ]
)
