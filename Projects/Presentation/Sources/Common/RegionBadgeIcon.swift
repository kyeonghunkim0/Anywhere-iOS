//
//  RegionBadgeIcon.swift
//  Presentation
//
//  지역 뱃지 이미지 자리. 서버가 뱃지 아이콘 URL을 주면 그걸 그리고,
//  아직 없는 지역이면 기존 새싹 아이콘으로 폴백한다.
//

import SwiftUI
import Domain
import UIComponents

struct RegionBadgeIcon: View {
    let badge: RegionBadge?
    var diameter: CGFloat = 64

    var body: some View {
        Circle()
            .fill(DSColor.green50)
            .frame(width: diameter, height: diameter)
            .overlay {
                if let url = badge?.iconURL {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .padding(diameter * 0.14)
                    } placeholder: {
                        fallback
                    }
                } else {
                    fallback
                }
            }
            .clipShape(Circle())
    }

    private var fallback: some View {
        DSIconView(.sprout, size: diameter * (26.0 / 64.0), color: DSColor.brandPrimary)
    }
}
