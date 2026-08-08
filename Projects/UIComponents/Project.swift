//
//  Project.swift
//  AnywhereManifests
//
//  Created by 김경훈 on 7/12/26.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.makeProject(
    name: "UIComponents",
    product: .staticFramework,
    hasResource: true,
    hasSampleApp: true,
    resourceSynthesizers: [
        .custom(name: "Colors", parser: .assets, extensions: ["xcassets"]),
    ]
)
