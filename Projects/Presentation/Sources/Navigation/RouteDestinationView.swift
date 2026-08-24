//
//  RouteDestinationView.swift
//  Presentation
//
//  Route를 실제 화면으로 바꾸는 유일한 지점. 새 화면을 만들면 여기 case만 채운다.
//

import SwiftUI
import UIComponents

struct RouteDestinationView: View {
    let route: Route

    var body: some View {
        switch route {
        // 아직 화면이 없는 Route는 자리표시자로 둔다 — 화면이 생기는 대로 이 case를 교체한다.
        case .profile, .passport, .ranking, .settings,
             .matching, .arrivalVerification, .regionDetail, .placeDetail,
             .terms, .privacy:
            placeholder
        }
    }

    private var placeholder: some View {
        VStack(spacing: DSSpacing.s2) {
            Text(String(describing: route))
                .font(DSTypography.font(DSTypography.Size.base, weight: DSTypography.Weight.bold))
                .foregroundStyle(DSColor.textPrimary)
            Text("준비 중인 화면입니다.")
                .font(DSTypography.font(DSTypography.Size.sm, weight: DSTypography.Weight.regular))
                .foregroundStyle(DSColor.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
}
