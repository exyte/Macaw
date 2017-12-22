// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "Macaw",
     products: [
        .library(
            name: "Macaw",
            targets: ["Macaw"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SWXMLHash",
            dependencies: [],
            path: "Dependencies/SWXMLHash"),
        .target(
            name: "Macaw",
            dependencies: ["SWXMLHash"],
            path: "Source")
    ]
)
