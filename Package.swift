// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WWPatternLockView",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(name: "WWPatternLockView", targets: ["WWPatternLockView"]),
    ],
    targets: [
        .target(name: "WWPatternLockView", resources: [.process("Xib"), .copy("Privacy")]),
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
