//
//  Project.swift
//  AnywhereManifests
//
//  Created by 김경훈 on 7/27/26.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.makeProject(
    name: "Auth",
    product: .staticFramework,
    hasResource: true,
    hasSampleApp: true,
    sampleAppInfoPlist: [
        "GIDClientID": "$(GOOGLE_CLIENT_ID)",
        "CFBundleURLTypes": [
            [
                "CFBundleTypeRole": "Editor",
                "CFBundleURLSchemes": ["$(GOOGLE_REVERSED_CLIENT_ID)"],
            ]
        ],
    ]
)
