// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.
// multi target : https://github.com/Instagram/IGListKit/blob/main/Package.swift

import PackageDescription

let package = Package(
    name: "MarkDrop",
    platforms: [ .iOS(.v13), .macOS(.v11) ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "MarkDrop",
            targets: ["MarkDrop"]
        )
//        ,
//        .library(
//            name: "MarkDropYYText",
//            targets: ["MarkDropYYText"]
//        )
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "MarkDrop",
            path: "MarkDrop/Deployment/spm/MarkDrop"
        ),
//        .target(
//            name: "MarkDropYYText",
//            path: "MarkDrop/Deployment/spm/MarkDropYYText"
//        ),
        .testTarget(
            name: "MarkDropTests",
            dependencies: ["MarkDrop"],
            path: "MarkDropTests"
        ),
    ],
    swiftLanguageVersions: [.v5]
)
