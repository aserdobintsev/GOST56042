// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "GOST56042",
    products: [
        .library(name: "GOST56042", targets: ["GOST56042"])
    ],
    targets: [
        .target(
            name: "GOST56042",
            dependencies: []),
        .testTarget(
            name: "GOST56042Tests",
            dependencies: ["GOST56042"],
            resources: [
                .process("win1251.txt")
            ])
    ]
)
