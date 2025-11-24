// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "swift-integers",
    platforms: [.macOS("14.4"), .iOS("17.4"), .watchOS("10.4"), .tvOS("17.4"), .visionOS("1.1")],
    products: [.library(name: "Integers", targets: ["Integers"])],
    targets: [.target(name: "Integers")]
)
