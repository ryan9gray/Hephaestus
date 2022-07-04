// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
private struct PackageData {
    static let packageName: String = "Hephaestus"
    
    struct TargetNames {
        static let main: String = "HefestosSandbox"
    }
    struct Dependencies {
        static let sqLite: String = "SQLite"
    }
}

let package = Package(
    name: PackageData.packageName,
    platforms: [
        .iOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: PackageData.packageName,
            targets: [PackageData.packageName]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/stephencelis/SQLite.swift.git",
            from: "0.13.3"
        )
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: PackageData.packageName,
            dependencies: [
                .product(name: "SQLite", package: "SQLite.swift")
            ]),
        .testTarget(
            name: "HephaestusTests",
            dependencies: ["Hephaestus"]),
    ]
)
