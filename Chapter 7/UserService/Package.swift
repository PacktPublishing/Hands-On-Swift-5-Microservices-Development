// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "UserService",
    platforms: [
       .macOS(.v10_15)
    ],
    products: [
        .executable(name: "Run", targets: ["Run"]),
        .library(name: "App", targets: ["App"]),
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0-beta"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0-beta"),
        .package(url: "https://github.com/skelpo/sendgrid-provider.git", from: "4.0.0"),
        .package(url: "https://github.com/proggeramlug/SimpleJWTMiddleware", .branch("master")),
        .package(url: "https://github.com/vapor/fluent-mysql-driver.git", from: "4.0.0-beta"),
    ],
    targets: [
        .target(name: "App", dependencies: ["Fluent", "SendGrid", "FluentMySQLDriver", "SimpleJWTMiddleware", "Vapor"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App", "XCTVapor"])
    ]
)
