import PackageDescription

let package = Package(
  name: "Macaw",
  dependencies: [
        .Package(url: "https://github.com/ReactiveX/RxSwift.git", Version(3, 0, 0, prereleaseIdentifiers: ["rc"])),
        .Package(url: "https://github.com/drmohundro/SWXMLHash.git", majorVersion: 3.0),
    ]
)

