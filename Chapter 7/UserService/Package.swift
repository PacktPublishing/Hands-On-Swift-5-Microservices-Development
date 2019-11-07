// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "users",
    products: [
        .library(name: "App", targets: ["App"]),
        .executable(name: "Run", targets: ["Run"])
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "3.3.0"),
        .package(url: "https://github.com/vapor/fluent-mysql.git", from: "3.0.1"),
        .package(url: "https://github.com/vapor/jwt.git", from: "3.0.0"),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", from: "1.0.0"),
        .package(url: "https://github.com/vapor-community/sendgrid-provider.git", from: "3.0.0"),
        .package(url: "https://github.com/skelpo/JWTDataProvider.git", from: "1.0.0"),
        .package(url: "https://github.com/skelpo/vapor-request-storage.git", from: "0.1.0"),
        .package(url: "https://github.com/skelpo/JWTMiddleware", from: "0.9.0"),
        .package(url: "https://github.com/skelpo/APIErrorMiddleware.git", from: "0.1.0"),
        .package(url: "https://github.com/skelpo/JWTVapor.git", from: "0.13.0"),
    ],
    targets: [
        .target(name: "App", dependencies: ["Vapor", "VaporRequestStorage", "FluentMySQL", "APIErrorMiddleware", "JWTMiddleware", "SendGrid", "JWT", "CryptoSwift", "JWTDataProvider", "JWTVapor"],
                exclude: [
                    "Config",
                    "Public",
                    "Resources",
                    ]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

