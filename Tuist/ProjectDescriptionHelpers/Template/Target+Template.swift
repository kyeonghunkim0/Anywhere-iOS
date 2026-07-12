//
//  Target+Template.swift
//  AnywhereManifests
//
//  Created by 김경훈 on 7/12/26.
//

import ProjectDescription

public extension Target {
    /// 서비스 이름
    private static let appName = Environment.appName
    /// 지원 플랫폼
    private static let destination = Environment.destinations
    /// 최소 지원 버전
    private static let deploymentTarget = Environment.deploymentTarget
    /// 조직 이름
    private static let organizationName = Environment.organizationName
    
    /// 각 타겟은 이름과 의존성, Resource 유무 등을 입력 받습니다.
    static func makeTarget(
        name: String,
        hasResource: Bool,
        product: Product,
        isSampleApp: Bool = false,
        dependencies: [TargetDependency] = []
    ) -> Target {
        let sources: SourceFilesList = isSampleApp ? ["SampleApp/Sources/**"] : ["Sources/**"]
        let resources: ResourceFileElements? = isSampleApp ? ["SampleApp/Resources/**"] : (hasResource ? ["Resources/**"] : nil)
        let infoPlist: InfoPlist = isSampleApp ? .extendingDefault(
            with: [
                "UILaunchScreen": [
                    "UIColorName": "",
                    "UIImageName": "",
                ]
            ]
        ) : .file(path: .relativeToRoot("Tuist/Config/Info.plist"))
        
        return Target.target(
            name: name,
            destinations: destination,
            product: product,
            // productName: 생락 시 name과 동일하게 자동 설정됨,
            bundleId: "\(Target.organizationName).\(Target.appName).\(name)",
            deploymentTargets: Target.deploymentTarget,
            infoPlist: infoPlist,
            sources: sources,
            resources: resources,
            // entitlements: 사용하는 경우 \(Target.appName).entitlements,
            // scripts: 사용하는 경우 지정,
            dependencies: dependencies,
            settings: Settings.defaultTargetSettings()
            // coreDataModels: 사용하는 경우 지정,
            // environmentVariables: 사용하는 경우 지정,
            // launchArguments: 사용하는 경우 지정,
            // additionalFiles: 사용하는 경우 지정,
            // buildRules: 사용하는 경우 지정,
            // mergedBinaryType: 사용하는 경우 지정,
            // mergeable: 사용하는 경우 지정,
            // onDemandResourcesTags: 사용하는 경우 지정,
            //  metadata: 사용하는 경우 지정
        )
    }
}
