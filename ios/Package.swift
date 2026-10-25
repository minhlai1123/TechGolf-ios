// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TechGolf",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "TechGolfCore",
            targets: ["TechGolfCore"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/supabase-community/supabase-swift.git",
            from: "2.14.0"
        ),
    ],
    targets: [
        .target(
            name: "TechGolfCore",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift"),
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "TechGolfTests",
            dependencies: ["TechGolfCore"],
            path: "Tests"
        ),
    ]
)
