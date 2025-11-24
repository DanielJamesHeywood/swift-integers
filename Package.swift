// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "swift-integers",
    platforms: [.macOS("15.0"), .iOS("18.0"), .watchOS("11.0"), .tvOS("18.0"), .visionOS("2.0")],
    products: [.library(name: "Integers", targets: ["Integers"])],
    targets: [.target(name: "Integers")]
)
