// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "SVGKit",
    platforms: [
        .macOS(.v10_10),
        .iOS(.v8),
        .tvOS(.v9)
    ],
    products: [
        .library(
            name: "SVGKit",
            targets: ["SVGKit"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/CocoaLumberjack/CocoaLumberjack.git", .upToNextMajor(from: "3.0.0"))
    ],
    targets: [
        .target(
            name: "SVGKit",
            dependencies: [
                "CocoaLumberjack"
            ],
            path: "Source",
            exclude: [
                "SwiftUI additions"
            ],
            publicHeadersPath: ".",
            cSettings: [
                .headerSearchPath("."),
                .headerSearchPath("AppKit additions", .when(platforms: [.macOS])),
                .headerSearchPath("DOM classes"),
                .headerSearchPath("DOM classes/Core DOM"),
                .headerSearchPath("DOM classes/SVG-DOM"),
                .headerSearchPath("DOM classes/Unported or Partial DOM"),
                .headerSearchPath("Exporters"),
                .headerSearchPath("Foundation additions"),
                .headerSearchPath("Parsers"),
                .headerSearchPath("Parsers/Parser Extensions"),
                .headerSearchPath("QuartzCore additions"),
                .headerSearchPath("Sources"),
                .headerSearchPath("UIKit additions", .when(platforms: [.iOS, .tvOS])),
                .headerSearchPath("Utils")
            ]
        )
    ]
)
