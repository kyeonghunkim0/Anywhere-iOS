//
//  BadgeIcon.swift
//  Presentation
//
//  뱃지 아이콘 자리. 서버가 이미지 URL(`icon`)을 주면 그걸 그리고,
//  아직 못 받았거나 URL이 아니면 DSIcon 폴백으로 그린다.
//  원 배경·클립·잠금 딤 처리는 호출부가 감싼다 — 여기선 아이콘만 채운다.
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
                    fallback
                }
            } else {
                fallback
            }
        }
        .frame(width: diameter, height: diameter)
    }

    private var fallback: some View {
        DSIconView(
            badge.stampIcon,
            size: diameter * (22.0 / 56.0),
            color: badge.isUnlocked ? DSColor.brandAccent : DSColor.textMuted
        )
    }
}
