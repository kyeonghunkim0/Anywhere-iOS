//
//  Environment.swift
//  AnywhereManifests
//
//  Created by 김경훈 on 7/12/26.
//

import ProjectDescription

public enum Environment {
    public static let appName: String = "Anywhere"
    public static let organizationName = "com.kimkhuna"
    public static let destinations: Destinations = [.iPhone]
    public static let deploymentTarget: DeploymentTargets = .iOS("17.0")
}

