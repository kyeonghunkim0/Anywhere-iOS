//
//  DependencyInfo.swift
//  AnywhereManifests
//
//  Created by 김경훈 on 7/12/26.
//

@preconcurrency import ProjectDescription

/// 각 모듈이 가지는 내부 모듈 의존성을 정리합니다.
let dependencyInfo: [DependencyInformation: [DependencyInformation]] = [
    .app: [.dicontainer, .presentation],
    .dicontainer: [.presentation, .domain, .data, .uiComponents, .auth, .core],
    .presentation: [.domain, .core, .uiComponents],
    .domain: [.core],
    .auth: [.core],
    .data: [.domain, .core],

    .core: [],
]

/// 각 모듈이 사용하는 외부 라이브러리를 정리합니다.
/// 사용 가능한 상수는 ExternalDependency.swift 를 참고하세요.
let externalDependencyInfo: [DependencyInformation: [TargetDependency]] = [
    .auth: [.googleSignIn, .firebaseAuth, .firebaseCore],
    .presentation: [.lottie],
]

/// 내부 모듈을 정의합니다.
public enum DependencyInformation: String, CaseIterable, Sendable {
    // MARK: - Clean Architecture 기반으로 설정
    case app = "AnywhereApp"
    case presentation = "Presentation"
    case domain = "Domain"
    case data = "Data"
    case uiComponents = "UIComponents"
    case auth = "Auth"
    case core = "Core"
    case dicontainer = "DIContainer"
}

/// 모듈과 의존성을 연결합니다.
public extension DependencyInformation {
    /// name(String)을 기반으로 의존성 모듈(TargetDependency)을 반환
    static func dependencies(name: String) -> [TargetDependency] {
        guard let module = DependencyInformation(rawValue: name) else { return [] }

        // 내부 모듈 의존성
        let internalModules = dependencyInfo[module] ?? []
        let internalDependencies: [TargetDependency] = internalModules.map {
            .project(target: $0.rawValue, path: .relativeToRoot("Projects/\($0.rawValue)"))
        }

        // 외부 라이브러리 의존성
        let externalDependencies = externalDependencyInfo[module] ?? []

        return internalDependencies + externalDependencies
    }
}
