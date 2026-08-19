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

    public init(signInUseCase: SignInUseCase) {
        self.signInUseCase = signInUseCase
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

    /// 사용자가 시스템 시트에서 직접 취소한 경우는 에러로 취급하지 않는다.
    private static func message(for error: AuthError) -> String? {
        switch error {
        case .signInCancelled:
            nil
        case .sessionExpired:
            L10n.loginSessionExpired
        case .rejected(let message):
            message
        case .network:
            L10n.loginNetworkError
        }
    }
}
