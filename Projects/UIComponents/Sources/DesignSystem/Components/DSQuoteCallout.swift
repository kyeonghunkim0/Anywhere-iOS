//
//  DSQuoteCallout.swift
//  UIComponents
//
//  원본: components/collection/QuoteCallout.jsx
//

import SwiftUI

public struct DSQuoteCallout: View {
    private let quote: String

    public init(_ quote: String) {
        self.quote = quote
    }

    public var body: some View {
        Text(quote)
            .font(DSTypography.font(DSTypography.Size.xs, weight: DSTypography.Weight.regular))
            .foregroundStyle(DSColor.sand700)
            .lineSpacing(DSTypography.lineSpacing(size: DSTypography.Size.xs, leading: 1.625))
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 16)
            .padding(12)
            .background(DSColor.sand100)
            .clipShape(RoundedRectangle(cornerRadius: DSRadius.lg, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: DSRadius.lg, style: .continuous)
                    .strokeBorder(DSColor.border, lineWidth: 1)
            }
            // 따옴표 배지는 카드 위쪽 테두리에 걸쳐 나온다.
            .overlay(alignment: .topLeading) {
                DSIconView(.quote, size: 12, color: Color.white)
                    .frame(width: 24, height: 24)
                    .background(DSColor.brandAccent)
                    .clipShape(Circle())
                    .dsShadow(DSShadow.sm)
                    .offset(x: 16, y: -12)
            }
            .padding(.top, 12)
    }
}

#Preview {
    DSQuoteCallout("관광버스 안 오는 평일 오후가 제일 좋습니다. 강 따라 걷다 보면 시간 다 가요. - 부여 주민 박ㅇㅇ")
        .padding(DSSpacing.s6)
        .background(Color.white)
}
