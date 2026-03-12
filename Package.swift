// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TimeTracker",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "TimeTracker", targets: ["TimeTracker"])
    ],
    targets: [
        .executableTarget(
            name: "TimeTracker",
            path: ".",
            exclude: [
                "build.sh",
                "README.md",
                "LICENSE",
                "TimeTracker.app",
                ".gitignore"
            ],
            sources: ["TimeTrackerApp.swift", "TimerManager.swift", "TimerView.swift"]
        )
    ]
)
