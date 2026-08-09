//
//  AppleSignInCoordinator.swift
//  Auth
//
//  Created by 김경훈 on 8/9/26.
//  Copyright © 2026 com.kimkhuna. All rights reserved.
//

import AuthenticationServices
import CryptoKit
import Foundation

/// ASAuthorizationController의 델리게이트 콜백을 async/await로 감싸는 헬퍼입니다.
/// Apple 로그인은 GoogleSignIn과 달리 completion 기반 API가 없어 직접 continuation을 관리해야 합니다.
final class AppleSignInCoordinator: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    private let anchor: ASPresentationAnchor
    private var continuation: CheckedContinuation<ASAuthorizationAppleIDCredential, Error>?

    init(anchor: ASPresentationAnchor) {
        self.anchor = anchor
    }

    func performRequest(scopes: [ASAuthorization.Scope], nonce: String) async throws -> ASAuthorizationAppleIDCredential {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = scopes
        request.nonce = Self.sha256(nonce)

        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        defer { continuation = nil }
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            continuation?.resume(throwing: AuthProviderError.missingAppleCredential)
            return
        }
        continuation?.resume(returning: credential)
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        continuation?.resume(throwing: error)
        continuation = nil
    }

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        anchor
    }

    /// Firebase가 재전송 공격을 막기 위해 요구하는 raw nonce입니다. 해시된 값은 Apple 요청에, 원본은 Firebase 자격 증명에 사용합니다.
    static func randomNonceString(length: Int = 32) -> String {
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            var randomBytes = [UInt8](repeating: 0, count: 16)
            let status = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
            precondition(status == errSecSuccess, "SecRandomCopyBytes 실패: \(status)")

            for byte in randomBytes where remainingLength > 0 {
                if byte < charset.count {
                    result.append(charset[Int(byte)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }

    private static func sha256(_ input: String) -> String {
        let hashed = SHA256.hash(data: Data(input.utf8))
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
}

enum AuthProviderError: LocalizedError {
    case missingGoogleIDToken
    case missingAppleCredential
    case missingAppleIdentityToken

    var errorDescription: String? {
        switch self {
        case .missingGoogleIDToken:
            return "구글 로그인 토큰을 가져오지 못했습니다."
        case .missingAppleCredential:
            return "애플 로그인 인증 정보를 가져오지 못했습니다."
        case .missingAppleIdentityToken:
            return "애플 로그인 토큰을 가져오지 못했습니다."
        }
    }
}
