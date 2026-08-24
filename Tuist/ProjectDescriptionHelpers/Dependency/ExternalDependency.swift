//
//  ExternalDependency.swift
//  AnywhereManifests
//
//  외부 SPM 라이브러리를 타입 안전하게 참조하기 위한 상수 모음입니다.
//  라이브러리를 추가할 때는
//    1) Tuist/Package.swift 의 dependencies 에 패키지를 추가하고
//    2) 여기에 프로덕트 이름으로 상수를 하나 추가한 뒤
//    3) DependencyInfo.swift 의 externalDependencyInfo 에서 모듈과 연결합니다.
//

import ProjectDescription

public extension TargetDependency {
    // MARK: - Google
    static let googleSignIn: TargetDependency = .external(name: "GoogleSignIn")

    // MARK: - Firebase
    static let firebaseAuth: TargetDependency = .external(name: "FirebaseAuth")
    static let firebaseCore: TargetDependency = .external(name: "FirebaseCore")

    // MARK: - Animation
    static let lottie: TargetDependency = .external(name: "Lottie")
}
