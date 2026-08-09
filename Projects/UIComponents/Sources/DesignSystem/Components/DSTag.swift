//
//  DSTag.swift
//  UIComponents
//
//  원본: components/core/Tag.jsx
//

import SwiftUI

public enum DSTagTone: Sendable {
    case brand
    case success
    case info
    case dark
    case neutral

    var background: Color {
        switch self {
        case .brand: return DSColor.green100
        case .success: return DSColor.successBg
        case .info: return DSColor.infoBg
        case .dark: return DSColor.sand800
        case .neutral: return DSColor.sand100
        }
    }

    var foreground: Color {
        switch self {
        case .brand: return DSColor.green600
        case .success: return DSColor.successDeep
        case .info: return DSColor.info
        case .dark: return .white
        case .neutral: return DSColor.sand500
        }
    }
}

public struct DSTag: View {
    private let title: String
    private let tone: DSTagTone

    public init(_ title: String, tone: DSTagTone = .brand) {
        self.title = title
        self.tone = tone
    }

    public var body: some View {
        Text(title)
            .font(DSTypography.font(DSTypography.Size.xs2, weight: DSTypography.Weight.bold))
            .foregroundStyle(tone.foreground)
            .padding(.vertical, DSSpacing.s1)
            .padding(.horizontal, DSSpacing.s2)
            .background(tone.background)
            .clipShape(RoundedRectangle(cornerRadius: DSRadius.sm, style: .continuous))
    }
}

#Preview {
    HStack(spacing: DSSpacing.s2) {
        DSTag("인증 완료", tone: .brand)
        DSTag("도장 획득", tone: .success)
        DSTag("이동 중", tone: .info)
        DSTag("히든", tone: .dark)
        DSTag("미방문", tone: .neutral)
    }
    .padding(DSSpacing.s5)
    .background(DSColor.bgApp)
}
