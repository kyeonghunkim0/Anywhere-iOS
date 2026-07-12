import ProjectDescription

let project = Project(
    name: "Anywhere",
    targets: [
        .target(
            name: "Anywhere",
            destinations: .iOS,
            product: .app,
            bundleId: "dev.tuist.Anywhere",
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                ]
            ),
            buildableFolders: [
                "Anywhere/Sources",
                "Anywhere/Resources",
            ],
            dependencies: []
        ),
        .target(
            name: "AnywhereTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "dev.tuist.AnywhereTests",
            infoPlist: .default,
            buildableFolders: [
                "Anywhere/Tests"
            ],
            dependencies: [.target(name: "Anywhere")]
        ),
    ]
)
