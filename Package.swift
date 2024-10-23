// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "iSimCameraTool",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "isim",
                    targets: ["iSimCameraTool"])
    ],
    targets: [
        .executableTarget(
            name: "iSimCameraTool",
            path: "./Sources"
        )
    ]
)
