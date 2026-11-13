// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Launcher",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "launcher",
            targets: ["LauncherApp"]
        ),
        .library(
            name: "LauncherCore",
            targets: ["LauncherCore"]
        ),
        .library(
            name: "LauncherGUI",
            targets: ["LauncherGUI"]
        ),
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "LauncherApp",
            dependencies: ["LauncherGUI"]
        ),
        .target(
            name: "LauncherGUI",
            dependencies: ["LauncherCore"]
        ),
        .target(name: "LauncherCore"),
        .testTarget(
            name: "LauncherCoreTests",
            dependencies: ["LauncherCore"]
        ),
    ]
)
