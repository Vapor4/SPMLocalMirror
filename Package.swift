// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
let localMirrorPath = "~/SPMLocalMirror"
let package = Package(
    name: "SPMLocalMirror",
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(path: "\(localMirrorPath)/kylef/Commander"),
        .package(path: "\(localMirrorPath)/kareman/SwiftShell"),
        
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "SPMLocalMirror",
            dependencies: ["Commander", "SwiftShell"]),
        .testTarget(
            name: "SPMLocalMirrorTests",
            dependencies: ["SPMLocalMirror"]),
    ]
)
