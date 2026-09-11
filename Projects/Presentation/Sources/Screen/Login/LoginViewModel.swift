//
//  LoginViewModel.swift
//  Presentation
//

import Foundation
import Domain
import UIComponents

@MainActor
@Observable
public final class LoginViewModel {
    public private(set) var isLoading = false
    public var errorMessage: String?
    public private(set) var session: AuthSession?

    private let signInUseCase: SignInUseCase
    private let signInAsGuestUseCase: SignInAsGuestUseCase

    public init(signInUseCase: SignInUseCase, signInAsGuestUseCase: SignInAsGuestUseCase) {
        self.signInUseCase = signInUseCase
        self.signInAsGuestUseCase = signInAsGuestUseCase
    }

    /// 로그아웃 시 RootView가 호출한다. 지우지 않으면 같은 계정으로 재로그인했을 때
    /// user.id가 로그아웃 전과 동일해 RootView의 onChange(of:)가 발동하지 않는다.
    public func reset() {
        session = nil
        errorMessage = nil
    }

    public func signIn(with socialType: SocialType) {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        Task {
            do throws(AuthError) {
                session = try await signInUseCase.execute(socialType: socialType)
            } catch {
                errorMessage = Self.message(for: error)
            }
            isLoading = false
        }
    }

    public func signInAsGuest() {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        Task {
            do throws(AuthError) {
                session = try await signInAsGuestUseCase.execute()
            } catch {
                errorMessage = Self.message(for: error)
            }
            isLoading = false
        }
    }

    /// 사용자가 시스템 시트에서 직접 취소한 경우는 에러로 취급하지 않는다.
    private static func message(for error: AuthError) -> String? {
        switch error {
        case .signInCancelled:
            nil
        case .sessionExpired:
            L10n.loginSessionExpired
        case .socialSignInFailed:
            L10n.loginSocialSignInFailed
        case .rejected(let message):
            message
        case .network:
            L10n.loginNetworkError
        }
    }
}
