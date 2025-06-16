// swift-tools-version: 6.1

import PackageDescription

let package = Package(
  name: "simpledns",
  platforms: [
    .macOS(.v11)
  ],
  dependencies: [
    .package(path: "../../.."),
    .package(url: "https://github.com/realm/SwiftLint", from: "0.59.1"),
  ],
  targets: [
    .executableTarget(
      name: "simpledns",
      dependencies: [
        .product(name: "DnsApi", package: "sw-dns-api")
      ],
      swiftSettings: [
        .unsafeFlags(
          ["-cross-module-optimization"],
          .when(configuration: .release),
        )
      ],
    )
  ]
)
