//
//  BadgeIcon.swift
//  Presentation
//
//  뱃지 아이콘 자리. 서버가 이미지 URL(`icon`)을 주면 그걸 그리고,
//  아직 못 받았거나 URL이 아니면 DSIcon 폴백으로 그린다.
//
//  뱃지 PNG는 자체 배경(흰 사각형)을 갖고 오므로 이미지 뒤에는 아무것도 깔지 않는다 —
//  깔면 흰 사각형이 그 색 위에 떠 보인다. 원 배경은 폴백 글리프 전용이다.
//  잠금 딤 처리만 호출부가 감싼다.
//

import SwiftUI
import Domain
import UIComponents

struct BadgeIcon: View {
    let badge: Badge
    /// 자리 지름. 폴백 DSIcon 크기는 도장 뱃지 비율(56 → 22)을 그대로 따른다.
    var diameter: CGFloat = 56

    var body: some View {
        Group {
            if let url = badge.iconURL {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    // 로딩 중에 원을 깔면 이미지로 바뀔 때 배경이 튄다.
                    Color.clear
                }
            } else {
                fallback
            }
        }
        .frame(width: diameter, height: diameter)
    }

    private var fallback: some View {
        Circle()
            .fill(badge.isUnlocked ? Color.white : DSColor.sand100)
            .overlay {
                DSIconView(
                    badge.stampIcon,
                    size: diameter * (22.0 / 56.0),
                    color: badge.isUnlocked ? DSColor.brandAccent : DSColor.textMuted
                )
            }
    }
}
