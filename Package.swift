// swift-tools-version: 6.0
// Package: MyPackage

import PackageDescription

let package = Package(
  name: "ChaosTesting",
  platforms: [
    .macOS(.v14), .iOS(.v17), .tvOS(.v17), .watchOS(.v10),
  ],
  products: [
    .library(
      name: "ChaosTesting",
      targets: ["ChaosTesting"])
  ],
  targets: [
    .target(name: "ChaosTesting"),
    .testTarget(
      name: "ChaosTestingTests",
      dependencies: ["ChaosTesting"]),
  ]
)
