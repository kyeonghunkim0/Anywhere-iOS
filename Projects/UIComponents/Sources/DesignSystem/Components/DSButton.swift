//
//  DSButton.swift
//  UIComponents
//
//  원본: components/core/Button.jsx
//

import SwiftUI

public enum DSButtonVariant: Sendable {
    case primary
    case hero
    case dark
    case kakao
    case google
    case social
    case secondary
    case ghost

    var foreground: Color {
        switch self {
        case .primary, .hero, .dark:
            return DSColor.textOnBrand
        case .kakao:
            return DSColor.textOnKakao
        case .google, .social:
            return DSColor.ink900
        case .secondary:
            return DSColor.sand600
        case .ghost:
            return DSColor.textSecondary
        }
    }

    var borderColor: Color? {
        switch self {
        case .google, .social: return DSColor.border
        default: return nil
        }
    }

    var shadow: DSShadowStyle {
        switch self {
        case .hero: return DSShadow.brand
        case .dark: return DSShadow.lg
        case .google, .social: return DSShadow.sm
        default: return .none
        }
    }

    @ViewBuilder
    var background: some View {
        switch self {
        case .primary:
            DSColor.brandPrimary
        case .hero:
            LinearGradient(
                colors: [DSColor.green400, DSColor.green600],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .dark:
            DSColor.surfaceDark
        case .kakao:
            DSColor.kakao
        case .google, .social:
            Color.white
        case .secondary:
            DSColor.sand100
        case .ghost:
            Color.clear
        }
    }
}

public enum DSButtonSize: Sendable {
    case md
    case lg
    case hero

    var verticalPadding: CGFloat {
        switch self {
        case .md: return 13
        case .lg: return 15
        case .hero: return 26
        }
    }

    var horizontalPadding: CGFloat {
        switch self {
        case .md: return 18
        case .lg: return 22
        case .hero: return 26
        }
    }

    var fontSize: CGFloat {
        switch self {
        case .md: return DSTypography.Size.sm
        case .lg: return DSTypography.Size.base
        case .hero: return DSTypography.Size.md
        }
    }

    var cornerRadius: CGFloat {
        switch self {
        case .md, .lg: return DSRadius.lg
        case .hero: return 46
        }
    }
}

public struct DSButton: View {
    private let title: String
    private let variant: DSButtonVariant
    private let size: DSButtonSize
    private let icon: DSIcon?
    private let stacked: Bool
    private let fullWidth: Bool
    private let action: () -> Void

    @Environment(\.isEnabled) private var isEnabled

    public init(
        _ title: String,
        variant: DSButtonVariant = .primary,
        size: DSButtonSize = .lg,
        icon: DSIcon? = nil,
        stacked: Bool = false,
        fullWidth: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.variant = variant
        self.size = size
        self.icon = icon
        self.stacked = stacked
        self.fullWidth = fullWidth
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            layout {
                if let icon {
                    DSIconView(icon, size: stacked ? 30 : 18, color: variant.foreground)
                }
                Text(title)
                    .font(DSTypography.font(size.fontSize, weight: DSTypography.Weight.bold))
            }
            .foregroundStyle(variant.foreground)
            .padding(.vertical, size.verticalPadding)
            .padding(.horizontal, size.horizontalPadding)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .background(variant.background)
            .clipShape(RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous))
            .overlay {
                if let borderColor = variant.borderColor {
                    RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous)
                        .strokeBorder(borderColor, lineWidth: 1)
                }
            }
            .dsShadow(variant.shadow)
            .opacity(isEnabled ? 1 : 0.6)
        }
        .buttonStyle(DSPressStyle())
    }

    private var layout: AnyLayout {
        stacked
            ? AnyLayout(VStackLayout(spacing: 10))
            : AnyLayout(HStackLayout(spacing: 8))
    }
}

#Preview {
    ScrollView {
        VStack(spacing: DSSpacing.s3) {
            DSButton("아무데나 떠나기", variant: .hero, size: .hero, icon: .target, stacked: true) {}
            DSButton("확인", variant: .primary) {}
            DSButton("GPS 위치 인증하기", variant: .dark, icon: .pin) {}
            DSButton("카카오로 시작하기", variant: .kakao, icon: .chat) {}
            DSButton("Google로 계속하기", variant: .google) {}
            DSButton("나중에 하기", variant: .secondary) {}
            DSButton("건너뛰기", variant: .ghost) {}
            DSButton("비활성", variant: .primary) {}
                .disabled(true)
        }
        .padding(DSSpacing.s5)
    }
    .background(DSColor.bgApp)
}
