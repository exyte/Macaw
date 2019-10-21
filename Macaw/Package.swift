// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "Macaw",
    platforms: [
        .iOS(.v9),
        .macOS(.v10_11)
    ],
    products: [
        .library(
            name: "Macaw",
            targets: ["Macaw"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/drmohundro/SWXMLHash",
            from: Version(4, 7, 5)
        )
    ],
    targets: [
        .target(
            name: "Macaw",
            dependencies: ["SWXMLHash"]
        ),
        .testTarget(
            name: "MacawTests",
            dependencies: ["Macaw"]
        ),
    ]
)
