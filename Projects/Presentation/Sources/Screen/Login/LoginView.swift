//
//  LoginView.swift
//  Presentation
//
//  원본: Prototype.dc.html의 isLoggedOut 화면.
//

import SwiftUI
import Domain
import UIComponents

public struct LoginView: View {
    @Bindable private var viewModel: LoginViewModel
    private let onTermsTap: () -> Void
    private let onPrivacyTap: () -> Void

    public init(
        viewModel: LoginViewModel,
        onTermsTap: @escaping () -> Void = {},
        onPrivacyTap: @escaping () -> Void = {}
    ) {
        self.viewModel = viewModel
        self.onTermsTap = onTermsTap
        self.onPrivacyTap = onPrivacyTap
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                header
                buttons
                footer
            }
        }
        .scrollBounceBehavior(.basedOnSize)
        .background(Color.white)
        .alert(
            L10n.loginFailureTitle,
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { isPresented in if !isPresented { viewModel.errorMessage = nil } }
            )
        ) {
            Button(L10n.commonConfirm) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(L10n.loginTitle)
                .font(DSTypography.font(36, weight: DSTypography.Weight.extrabold))
                .foregroundStyle(DSColor.textPrimary)
                .lineSpacing(DSTypography.lineSpacing(size: 36, leading: 1.16))

            Text(L10n.loginSubtitle)
                .font(DSTypography.font(DSTypography.Size.base, weight: DSTypography.Weight.regular))
                .foregroundStyle(DSColor.textSecondary)
                .lineSpacing(DSTypography.lineSpacing(size: DSTypography.Size.base, leading: DSTypography.Leading.relaxed))
        }
        .padding(.top, 96)
        .padding(.horizontal, DSSpacing.s6)
    }

    private var buttons: some View {
        VStack(spacing: 10) {
            SocialLoginButton(
                title: L10n.loginGoogleButton,
                style: .google,
                isDisabled: viewModel.isLoading
            ) {
                viewModel.signIn(with: .google)
            }

            SocialLoginButton(
                title: L10n.loginAppleButton,
                style: .apple,
                isDisabled: viewModel.isLoading
            ) {
                viewModel.signIn(with: .apple)
            }
        }
        .padding(.top, 32)
        .padding(.horizontal, DSSpacing.s6)
    }

    private var footer: some View {
        Text(termsAttributedString)
            .font(DSTypography.font(DSTypography.Size.sm, weight: DSTypography.Weight.regular))
            .lineSpacing(DSTypography.lineSpacing(size: DSTypography.Size.sm, leading: 1.7))
            .padding(.top, 36)
            .padding(.horizontal, DSSpacing.s6)
            .padding(.bottom, DSSpacing.s10)
            .environment(\.openURL, OpenURLAction { url in
                switch url.host {
                case "terms": onTermsTap()
                case "privacy": onPrivacyTap()
                default: break
                }
                return .handled
            })
    }

    private var termsAttributedString: AttributedString {
        func plain(_ text: String) -> AttributedString {
            var s = AttributedString(text)
            s.foregroundColor = DSColor.textSecondary
            return s
        }
        func link(_ text: String, host: String) -> AttributedString {
            var s = AttributedString(text)
            s.foregroundColor = DSColor.textPrimary
            s.underlineStyle = .single
            s.link = URL(string: "anywhere://\(host)")
            return s
        }

        return plain(L10n.loginTermsPrefix)
            + link(L10n.loginTermsOfService, host: "terms")
            + plain(L10n.loginTermsConnector)
            + link(L10n.loginPrivacyPolicy, host: "privacy")
            + plain(L10n.loginTermsSuffix)
    }
}

private enum SocialLoginStyle {
    case google
    case apple
}

private struct SocialLoginButton: View {
    let title: String
    let style: SocialLoginStyle
    let isDisabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Text(title)
                    .font(DSTypography.font(16, weight: DSTypography.Weight.bold))
                    .foregroundStyle(textColor)
                    .frame(maxWidth: .infinity)

                HStack {
                    mark
                    Spacer()
                }
            }
            .padding(.horizontal, style == .google ? 8 : 20)
            .frame(height: 56)
            .background(background)
            .clipShape(Capsule())
            .overlay {
                if style == .apple {
                    Capsule().strokeBorder(DSColor.border, lineWidth: 1)
                }
            }
        }
        .buttonStyle(DSPressStyle())
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.6 : 1)
    }

    @ViewBuilder
    private var mark: some View {
        switch style {
        case .google:
            Circle()
                .fill(Color.white)
                .frame(width: 40, height: 40)
                .overlay { DSGoogleMark(size: 20) }
        case .apple:
            Image(systemName: "applelogo")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(DSColor.textPrimary)
                .frame(width: 20)
        }
    }

    private var background: Color {
        switch style {
        case .google: DSColor.brandPrimary
        case .apple: Color.white
        }
    }

    private var textColor: Color {
        switch style {
        case .google: DSColor.textOnBrand
        case .apple: DSColor.brandPrimary
        }
    }
}

#Preview {
    LoginView(viewModel: LoginViewModel(signInUseCase: .preview))
}

private extension SignInUseCase {
    /// Xcode Preview 전용. 실제 앱에서는 DIContainer가 조립한 인스턴스를 주입받는다.
    static var preview: SignInUseCase {
        struct NoopSocialAuthenticating: SocialAuthenticating {
            func signIn(with socialType: SocialType) async throws(SocialAuthenticationError) -> SocialCredential {
                throw .cancelled
            }
            func signOut() async {}
        }
        struct NoopAuthRepository: AuthRepository {
            func login(with credential: SocialCredential) async throws(AuthError) -> AuthSession {
                throw .signInCancelled
            }
        }
        struct NoopSessionRepository: SessionRepository {
            func saveToken(_ token: String) async {}
            func currentToken() async -> String? { nil }
            func clearToken() async {}
        }
        return SignInUseCase(
            socialAuthenticating: NoopSocialAuthenticating(),
            authRepository: NoopAuthRepository(),
            sessionRepository: NoopSessionRepository()
        )
    }
}
