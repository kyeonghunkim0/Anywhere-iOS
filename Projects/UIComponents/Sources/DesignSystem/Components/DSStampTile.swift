//
//  DSStampTile.swift
//  UIComponents
//
//  원본: components/collection/StampTile.jsx
//  수집판 한 칸. 뱃지 그림·레벨 링·잠금은 DSRegionBadge가 그리고,
//  여기서는 이름표와 칸 위에 얹는 표식(방문자 번호 / 자물쇠)만 맡는다.
//

import SwiftUI

public struct DSStampTile: View {
    private let name: String
    private let seed: String
    private let isCollected: Bool
    private let level: Int?
    private let visitorNumber: Int?
    private let imageURL: URL?

    public init(
        name: String,
        seed: String,
        isCollected: Bool,
        level: Int? = nil,
        visitorNumber: Int? = nil,
        imageURL: URL? = nil
    ) {
        self.name = name
        self.seed = seed
        self.isCollected = isCollected
        self.level = level
        self.visitorNumber = visitorNumber
        self.imageURL = imageURL
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
        DSRegionBadge(
            imageURL: imageURL,
            name: name,
            seed: seed,
            level: level,
            isLocked: !isCollected,
            diameter: 56
        )
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
        DSStampTile(name: "부여군", seed: "a", isCollected: true, level: 3, visitorNumber: 86)
        DSStampTile(name: "영양군", seed: "b", isCollected: true, level: 5, visitorNumber: 1_204)
        DSStampTile(name: "양양군", seed: "c", isCollected: false, level: 2)
    }
    .padding(DSSpacing.s6)
    .background(Color.white)
}
