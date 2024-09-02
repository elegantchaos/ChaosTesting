// swift-tools-version: 6.0
// Package: MyPackage

import PackageDescription

let package = Package(
  name: "ChaosTesting",
  platforms: [
    .macOS(.v13)
  ],
  products: [
    .library(
      name: "ChaosTesting",
      targets: ["ChaosTesting"])
  ],
  targets: [
    .target(name: "ChaosTesting")
  ]
)
