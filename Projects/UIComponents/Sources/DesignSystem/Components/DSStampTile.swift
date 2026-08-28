//
//  DSStampTile.swift
//  UIComponents
//
//  원본: components/collection/StampTile.jsx
//

import SwiftUI

public struct DSStampTile: View {
    private let icon: DSIcon
    private let name: String
    private let isCollected: Bool
    private let visitorNumber: Int?

    public init(icon: DSIcon, name: String, isCollected: Bool, visitorNumber: Int? = nil) {
        self.icon = icon
        self.name = name
        self.isCollected = isCollected
        self.visitorNumber = visitorNumber
    }

    public var body: some View {
        VStack(spacing: 6) {
            stamp
            Text(name)
                .font(DSTypography.font(DSTypography.Size.xs2, weight: DSTypography.Weight.bold))
                .foregroundStyle(isCollected ? DSColor.textPrimary : DSColor.textMuted)
                .lineLimit(1)
        }
    }

    private var stamp: some View {
        ZStack {
            Circle()
                .fill(isCollected ? DSColor.brandPrimary : DSColor.surfaceSunken)
                .overlay {
                    if !isCollected {
                        Circle()
                            .strokeBorder(
                                DSColor.borderStrong,
                                style: StrokeStyle(lineWidth: 2, dash: [4, 3])
                            )
                    }
                }
                .dsShadow(isCollected ? DSShadow.sm : .none)

            DSIconView(icon, size: 22, color: isCollected ? Color.white : DSColor.borderStrong)
        }
        .frame(width: 56, height: 56)
        // 도장/자물쇠 표식은 원 밖으로 삐져나온다 — 타일 크기는 원 그대로 두고 겹쳐 얹는다.
        .overlay(alignment: .bottomTrailing) {
            marker
                .offset(x: 8, y: 4)
        }
    }

    @ViewBuilder
    private var marker: some View {
        if isCollected, let visitorNumber {
            Text("#\(visitorNumber)")
                .font(DSTypography.font(8, weight: DSTypography.Weight.extrabold))
                .foregroundStyle(Color.white)
                .padding(.vertical, 2)
                .padding(.horizontal, 5)
                .background(DSColor.brandAccent)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .rotationEffect(.degrees(-8))
                .dsShadow(DSShadow.sm)
        } else if !isCollected {
            DSIconView(.lock, size: 9, color: DSColor.textMuted)
                .frame(width: 16, height: 16)
                .background(DSColor.sand100)
                .clipShape(Circle())
                .offset(x: -6, y: -2)
        }
    }
}

#Preview {
    HStack(spacing: 12) {
        DSStampTile(icon: .temple, name: "부여", isCollected: true, visitorNumber: 86)
        DSStampTile(icon: .tree, name: "영양", isCollected: true, visitorNumber: 1_204)
        DSStampTile(icon: .wind, name: "양양", isCollected: false)
    }
    .padding(DSSpacing.s6)
    .background(Color.white)
}
