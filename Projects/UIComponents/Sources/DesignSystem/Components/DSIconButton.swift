//
//  DSIconButton.swift
//  UIComponents
//
//  원본: components/core/IconButton.jsx
//  아이콘 버튼과, 여권 사진처럼 쓰이는 이니셜 아바타를 함께 제공합니다.
//

import SwiftUI

public enum DSIconButtonTone: Sendable {
    case neutral
    case info
    case light

    var background: Color {
        switch self {
        case .neutral: return DSColor.sand200
        case .info: return DSColor.infoBg
        case .light: return DSColor.surface.opacity(0.9)
        }
    }

    var foreground: Color {
        switch self {
        case .neutral: return DSColor.sand700
        case .info: return DSColor.info
        case .light: return DSColor.ink900
        }
    }
}

public struct DSIconButton: View {
    private enum Content {
        case icon(DSIcon)
        case initials(String)
    }

    private let content: Content
    private let tone: DSIconButtonTone
    private let size: CGFloat
    private let action: () -> Void

    public init(
        icon: DSIcon = .compass,
        tone: DSIconButtonTone = .neutral,
        size: CGFloat = 48,
        action: @escaping () -> Void
    ) {
        self.content = .icon(icon)
        self.tone = tone
        self.size = size
        self.action = action
    }

    /// 여권 사진 자리를 대신하는 이니셜 아바타입니다. 항상 브랜드 그린 원형으로 렌더링됩니다.
    public init(
        initials: String,
        size: CGFloat = 48,
        action: @escaping () -> Void = {}
    ) {
        self.content = .initials(initials)
        self.tone = .neutral
        self.size = size
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Group {
                switch content {
                case .icon(let icon):
                    DSIconView(icon, size: size * 0.42, color: tone.foreground)
                case .initials(let initials):
                    Text(initials)
                        .font(DSTypography.font(size * 0.4, weight: DSTypography.Weight.extrabold))
                        .foregroundStyle(Color.white)
                }
            }
            .frame(width: size, height: size)
            .background(background)
            .clipShape(shape)
            .overlay {
                if isAvatar {
                    Circle().strokeBorder(DSColor.surface, lineWidth: 2)
                }
            }
            .dsShadow(DSShadow.sm)
        }
        .buttonStyle(DSPressStyle())
    }

    private var isAvatar: Bool {
        if case .initials = content { return true }
        return false
    }

    private var background: Color {
        isAvatar ? DSColor.brandPrimary : tone.background
    }

    private var shape: AnyShape {
        isAvatar
            ? AnyShape(Circle())
            : AnyShape(RoundedRectangle(cornerRadius: DSRadius.lg, style: .continuous))
    }
}

#Preview {
    HStack(spacing: DSSpacing.s4) {
        DSIconButton(icon: .compass) {}
        DSIconButton(icon: .settings, tone: .info) {}
        DSIconButton(icon: .close, tone: .light) {}
        DSIconButton(initials: "경훈")
    }
    .padding(DSSpacing.s5)
    .background(DSColor.bgApp)
}
