// swift-tools-version: 6.1

import PackageDescription

let package = Package(
  name: "DnsApi",
  platforms: [
    .macOS(.v11)
  ],
  products: [
    .library(
      name: "DnsApi",
      targets: ["DnsApi"])
  ],
  dependencies: [
    .package(
      url: "https://github.com/apple/swift-async-dns-resolver", from: "0.4.0",
    ),
    .package(
      url: "https://github.com/apple/swift-async-algorithms", from: "1.0.4",
    ),
    .package(
      url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.4.4",
    ),
    .package(url: "https://github.com/realm/SwiftLint", from: "0.59.1"),
  ],
  targets: [
    .target(
      name: "DnsApi",
      dependencies: [
        .product(name: "AsyncDNSResolver", package: "swift-async-dns-resolver"),
        .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
      ],
    ),
    .testTarget(
      name: "DnsApiTests",
      dependencies: ["DnsApi"]
    ),
  ]
)
