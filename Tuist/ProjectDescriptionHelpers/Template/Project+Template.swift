//
//  Project+Template.swift
//  AnywhereManifests
//
//  Created by 김경훈 on 7/12/26.
//

@preconcurrency import ProjectDescription

public extension Project {
    /// 서비스 이름
    private static let appName = Environment.appName
    /// 지원 플랫폼
    private static let destination = Environment.destinations
    /// 최소 지원 버전
    private static let deploymentTarget = Environment.deploymentTarget
    /// 조직 이름
    private static let organizationName = Environment.organizationName
    
    /// 타겟을 통해서 프로젝트를 생성하는 함수입니다.
    static func makeProject(
        name: String,
        product: Product,
        hasResource: Bool,
        hasSampleApp: Bool = false
    ) -> Project {
        let debugScheme = Scheme.scheme(
            schemeName: "\(name)Debug",
            targetName: name,
            configurationName: .debug
        )
        
        let releaseScheme = Scheme.scheme(
            schemeName: "\(name)Release",
            targetName: name,
            configurationName: .release
        )
        
        var targets: [Target] = [
            Target.makeTarget(
                name: name,
                hasResource: hasResource,
                product: product,
                dependencies: DependencyInformation.dependencies(name: name)
            )
        ]
        
        var schemes: [Scheme] = [debugScheme, releaseScheme]
        
        if hasSampleApp {
            let sampleAppName = "\(name)SampleApp"
            targets.append(
                Target.makeTarget(
                    name: sampleAppName,
                    hasResource: true,
                    product: .app,
                    isSampleApp: true,
                    dependencies: [.target(name: name)]
                )
            )
            
            let sampleAppScheme = Scheme.scheme(
                schemeName: sampleAppName,
                targetName: sampleAppName,
                configurationName: .debug
            )
            schemes.append(sampleAppScheme)
        }
        
        return Project(
            name: name,
            organizationName: organizationName,
            options: options(disableBundleAccessors: hasResource),
            settings: Settings.defaultTargetSettings(),
            targets: targets,
            schemes: schemes
        )
    }
    
    private static func options(disableBundleAccessors: Bool) -> Options {
        return Options.options(
            automaticSchemesOptions: .disabled,
            defaultKnownRegions: ["en", "ko"],
            developmentRegion: "ko",
            disableBundleAccessors: !disableBundleAccessors
        )
    }
}
