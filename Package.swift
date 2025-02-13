// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "ParaSwift",
    platforms: [.iOS(.v16)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ParaSwift",
            targets: ["ParaSwift"]),
    ],
    dependencies: [
        // Add BigInt as a dependency
        .package(url: "https://github.com/attaswift/BigInt.git", from: "5.5.1") // Update version if needed
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        .target(
            name: "ParaSwift",
            dependencies: ["BigInt"]), // Add BigInt to the ParaSwift target
        .testTarget(
            name: "ParaSwiftTests",
            dependencies: ["ParaSwift"]),
    ]
)
