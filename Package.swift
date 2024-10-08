// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let package = Package(
  name: "CoreDataEvolution",
  platforms: [
    .iOS(.v13),
    .macOS(.v10_15),
    .tvOS(.v13),
    .watchOS(.v6),
    .visionOS(.v1)
  ],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "CoreDataEvolution",
      targets: ["CoreDataEvolution"]
    ),
    .library(
      name: "CoreDataEvolutionMacros",
      targets: ["CoreDataEvolutionMacros"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/swiftlang/swift-syntax", "509.0.0"..<"601.0.0-prerelease"),
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "CoreDataEvolution"
    ),
    .testTarget(
      name: "CoreDataEvolutionTests",
      dependencies: [
        "CoreDataEvolution",
        "CoreDataEvolutionMacros"
      ]
    ),
    .target(
      name: "CoreDataEvolutionMacros",
      dependencies: [
        "CoreDataEvolutionMacrosPlugin",
      ]
    ),
    .macro(
      name: "CoreDataEvolutionMacrosPlugin",
      dependencies: [
        .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
        .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
      ]
    ),
  ]
)
