//
//  RegionBadgeIcon.swift
//  Presentation
//
//  도메인 뱃지를 디자인 시스템 메달리온(DSRegionBadge)에 넘기는 얇은 어댑터.
//  그리는 규칙(잘라내기·레벨 링·타이포 토큰)은 전부 DSRegionBadge가 갖는다 —
//  화면마다 뱃지가 달라 보이지 않게 하려면 규칙이 한 곳에만 있어야 한다.
//

import SwiftUI
import Domain
import UIComponents

struct RegionBadgeIcon: View {
    let badge: RegionBadge?
    /// 뱃지 그림이 없을 때 타이포 토큰에 새길 지역명과, 색을 고정하는 시드.
    let name: String
    let seed: String
    /// 지역 성장 레벨. nil이면 링 없이 그림만 그린다.
    var level: Int?
    var isLocked = false
    var diameter: CGFloat = 64

    var body: some View {
        DSRegionBadge(
            imageURL: badge?.iconURL,
            name: badge?.name ?? name,
            seed: seed,
            level: level,
            isLocked: isLocked,
            diameter: diameter
        )
    }
}
