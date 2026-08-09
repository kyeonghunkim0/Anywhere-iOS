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
        dependencies: [TargetDependency] = [],
        sampleAppInfoPlist: [String: Plist.Value] = [:],
        entitlements: Entitlements? = nil
    ) -> Target {
        let sources: SourceFilesList = isSampleApp ? ["SampleApp/Sources/**"] : ["Sources/**"]
        let resources: ResourceFileElements? = isSampleApp ? ["SampleApp/Resources/**"] : (hasResource ? ["Resources/**"] : nil)
        // 런치스크린, 화면 방향, URL scheme 같은 키는 앱 번들에만 의미가 있습니다.
        // 정적 프레임워크까지 같은 Info.plist를 물리면 GIDClientID 같은 앱 전용 값이
        // 모든 모듈 번들에 복사되므로, 앱 타겟에만 커스텀 Info.plist를 적용합니다.
        // sampleAppInfoPlist는 Google Sign-In처럼 특정 모듈의 샘플 앱에서만
        // 필요한 키(GIDClientID, URL scheme 등)를 추가로 얹기 위한 것으로,
        // 지정하지 않으면 다른 샘플 앱과 동일하게 기본 런치스크린 키만 갖습니다.
        let infoPlist: InfoPlist
        if isSampleApp {
            var entries: [String: Plist.Value] = [
                "UILaunchScreen": [
                    "UIColorName": "",
                    "UIImageName": "",
                ]
            ]
            entries.merge(sampleAppInfoPlist) { _, custom in custom }
            infoPlist = .extendingDefault(with: entries)
        } else if product == .app {
            infoPlist = .file(path: .relativeToRoot("Tuist/Config/Info.plist"))
        } else {
            infoPlist = .default
        }
        
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
            entitlements: entitlements,
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
