//
//  Project.swift
//  AnywhereManifests
//
//  Created by 김경훈 on 7/12/26.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.makeProject(
    name: "AnywhereApp",
    product: .app,
    hasResource: true,
    entitlements: .file(path: "AnywhereApp.entitlements")
)
