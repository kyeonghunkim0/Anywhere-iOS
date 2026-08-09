//
//  AuthConfiguration.swift
//  Auth
//
//  Created by 김경훈 on 7/27/26.
//  Copyright © 2026 com.kimkhuna. All rights reserved.
//

import Foundation
import GoogleSignIn

/// 인증 SDK 초기화와 리다이렉트 처리를 담당합니다.
///
/// 이 타입을 `Auth` 로 두면 FirebaseAuth 의 `Auth` 클래스와 이름이 겹칩니다.
/// 모듈 이름도 `Auth` 라서 `Auth.xxx` 한정 접근까지 모호해지므로 이름을 분리했습니다.
public enum AuthConfiguration {
    /// Info.plist의 GIDClientID로 GIDSignIn을 초기화합니다. 앱 시작 시 한 번 호출해야 합니다.
    public static func configure() {
        guard let clientID = Bundle.main.object(forInfoDictionaryKey: "GIDClientID") as? String else { return }
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
    }

    /// 구글 로그인 리다이렉트 URL을 처리합니다. App의 onOpenURL에서 호출해야 합니다.
    @discardableResult
    public static func handle(_ url: URL) -> Bool {
        GIDSignIn.sharedInstance.handle(url)
    }
}
