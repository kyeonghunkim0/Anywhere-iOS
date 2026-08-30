//
//  RegionBadgeIcon.swift
//  Presentation
//
//  지역 뱃지 이미지 자리.
//  뱃지 PNG는 자체 배경(흰 사각형)을 갖고 오므로 뒤에 원을 깔지 않는다 —
//  깔면 흰 사각형이 색 원 위에 떠 보인다. 원은 이미지가 없을 때의 폴백 전용이다.
//

import SwiftUI
import Domain
import UIComponents

struct RegionBadgeIcon: View {
    let badge: RegionBadge?
    var diameter: CGFloat = 64

    var body: some View {
        Group {
            if let url = badge?.iconURL {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    // 로딩 중에 원을 깔면 이미지로 바뀔 때 배경이 튄다. 자리만 비워 둔다.
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
            .fill(DSColor.green50)
            .overlay {
                DSIconView(.sprout, size: diameter * (26.0 / 64.0), color: DSColor.brandPrimary)
            }
    }
}
