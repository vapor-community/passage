// swift-tools-version:5.9
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
        .package(url: "https://github.com/vapor/vapor.git", from: "4.89.0"),
        .package(url: "https://github.com/vapor/jwt.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/leaf.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/queues.git", from: "1.0.0"),
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
                .copy("Resources/EmailTemplates"),
                .copy("Resources/Views"),
            ]
        ),
    ]
)
