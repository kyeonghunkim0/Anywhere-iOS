//
//  BackBar.swift
//  Presentation
//
//  푸시된 화면 상단의 뒤로가기 줄. NavigationStack 기본 툴바를 쓰지 않는 이유는
//  HomeView와 같다 — iOS 26 툴바가 항목을 임의로 접어버려 프로토타입 배치를 못 맞춘다.
//

import SwiftUI
import UIComponents

struct BackBar: View {
    private let title: String?
    private let onBack: () -> Void

    init(title: String? = nil, onBack: @escaping () -> Void) {
        self.title = title
        self.onBack = onBack
    }

    var body: some View {
        HStack(spacing: 4) {
            // 왼쪽 셰브론이 따로 없어 chevronRight를 뒤집어 쓴다 — 프로토타입도 같은 방식이다.
            Button(action: onBack) {
                DSIconView(.chevronRight, size: 19, color: DSColor.ink900)
                    .rotationEffect(.degrees(180))
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(DSPressStyle())
            .accessibilityLabel(L10n.commonBack)

            if let title {
                Text(title)
                    .font(DSTypography.font(DSTypography.Size.md, weight: DSTypography.Weight.bold))
                    .foregroundStyle(DSColor.ink900)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity)
                // 제목을 정확히 가운데 두기 위한 좌측 버튼과 같은 너비의 여백.
                Color.clear.frame(width: 44, height: 44)
            } else {
                Spacer()
            }
        }
        .padding(.horizontal, 12)
    }
}
