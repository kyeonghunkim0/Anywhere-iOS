//
//  Settings+Template.swift
//  AnywhereManifests
//
//  Created by 김경훈 on 7/12/26.
//

import ProjectDescription

public extension Settings {
    static func defaultTargetSettings() -> Settings {
        return Settings.settings(
            base: [
                "SWIFT_VERSION": "6.0",
                // Swift 버전 고정
                "IPHONEOS_DEPLOYMENT_TARGET": "17.0", // 최소 지원 타겟 고정,
                "OTHER_LDFLAGS": "-ObjC", // 카테고리나 메타데이터가 포함된 정적 라이브러리의 코드가 런타임에 정상 동작하도록 설정
            ],
            configurations: [
                .debug(
                    name: .debug,
                    settings: [
                        "OTHER_SWIFT_FLAGS": "-DDEBUG", //  #if DEBUG 조건을 가능하도록 설정
                    ],
                    xcconfig: .relativeToRoot("Tuist/Config/Secrets.xcconfig")
                ),
                .release(
                    name: .release,
                    settings: [
                        "OTHER_SWIFT_FLAGS": ["-DRELEASE"], // Swift 코드에서 #if RELEASE 조건을 가능하게 함
                    ],
                    xcconfig: .relativeToRoot("Tuist/Config/Secrets.xcconfig")
                )
            ],
            defaultSettings: DefaultSettings.recommended
            // defaultConfiguration: 이거는 프로젝트 세팅에서 설정하는 것
        )
    }

    /// 외부 SPM 패키지에 적용할 기본 설정입니다.
    ///
    /// 앱 타겟 설정(defaultTargetSettings)을 그대로 쓰면 안 됩니다.
    /// - SWIFT_VERSION 6.0 을 강제하면 Swift 5 로 작성된 SDK가 깨집니다.
    /// - Secrets.xcconfig 는 외부 패키지가 알 필요가 없습니다.
    /// 여기서는 앱과 동일한 Configuration 이름(Debug/Release)만 맞춰줍니다.
    static func externalPackageSettings() -> Settings {
        return Settings.settings(
            base: [
                "IPHONEOS_DEPLOYMENT_TARGET": "17.0",
            ],
            configurations: [
                .debug(name: .debug),
                .release(name: .release),
            ],
            defaultSettings: DefaultSettings.recommended
        )
    }
}
