// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "Catbird",
    products: [
        .library(name: "Nest", targets: ["Nest"]),
        .library(name: "CatbirdAPI", targets: ["CatbirdAPI"]),
        .executable(name: "Catbird", targets: ["Catbird"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.0.0"),
        .package(url: "https://github.com/apple/swift-log.git", Version("0.0.0")..<Version("2.0.0")),
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.0.0"),
    ],
    targets: [
        // Nest - Web framwork based on Swift NIO
        .target(name: "Nest", dependencies: [
            "NIO",
            "NIOHTTP1",
            "NIOFoundationCompat",
            "Logging",
            "AsyncHTTPClient"
        ]),

        // Common API
        .target(name: "CatbirdAPI"),
        .testTarget(name: "CatbirdAPITests", dependencies: ["CatbirdAPI"]),

        // Web app
        .target(name: "CatbirdApp", dependencies: ["Nest", "CatbirdAPI"]), // "Leaf"
        .testTarget(name: "CatbirdAppTests", dependencies: ["CatbirdApp"]),

        // CLI app
        .target(name: "Catbird", dependencies: ["CatbirdApp"]),
    ]
)
