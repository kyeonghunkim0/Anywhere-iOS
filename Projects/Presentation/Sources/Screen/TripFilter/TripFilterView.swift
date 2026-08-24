//
//  TripFilterView.swift
//  Presentation
//
//  원본: Prototype.dc.html의 isFilter 화면.
//  거리 선택은 서버를 부르지 않는 순수 로컬 상태라 ViewModel을 두지 않는다.
//

import SwiftUI
import UIComponents

struct TripFilterView: View {
    private let onBack: () -> Void
    private let onStart: (TripRange) -> Void

    @State private var selected: TripRange = .default

    init(
        onBack: @escaping () -> Void = {},
        onStart: @escaping (TripRange) -> Void = { _ in }
    ) {
        self.onBack = onBack
        self.onStart = onStart
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            backBar

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text(L10n.tripFilterTitle)
                        .font(DSTypography.font(34, weight: DSTypography.Weight.extrabold))
                        .foregroundStyle(DSColor.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(L10n.tripFilterDistanceQuestion)
                        .font(DSTypography.font(DSTypography.Size.sm, weight: DSTypography.Weight.bold))
                        .foregroundStyle(DSColor.textSecondary)
                        .padding(.top, 16)
                        .padding(.bottom, 10)

                    VStack(spacing: 8) {
                        ForEach(TripRange.allCases) { range in
                            rangeRow(range)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, DSSpacing.s6)
                .padding(.top, 8)
            }
        }
        .background(Color.white)
        .toolbar(.hidden, for: .navigationBar)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            DSButton(L10n.homeStartTrip, variant: .primary) {
                onStart(selected)
            }
            .padding(.horizontal, DSSpacing.s6)
            .padding(.top, 16)
            .background(Color.white)
        }
    }

    private var backBar: some View {
        HStack {
            // 왼쪽 셰브론이 따로 없어 chevronRight를 뒤집어 쓴다 — 프로토타입도 같은 방식이다.
            Button(action: onBack) {
                DSIconView(.chevronRight, size: 19, color: DSColor.ink900)
                    .rotationEffect(.degrees(180))
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(DSPressStyle())
            .accessibilityLabel(L10n.commonBack)

            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 8)
    }

    private func rangeRow(_ range: TripRange) -> some View {
        let isSelected = selected == range

        return Button {
            selected = range
        } label: {
            VStack(alignment: .leading, spacing: 3) {
                Text(range.title)
                    .font(DSTypography.font(DSTypography.Size.base, weight: DSTypography.Weight.extrabold))
                    .foregroundStyle(isSelected ? DSColor.brandPrimary : DSColor.textPrimary)

                Text(range.subtitle)
                    .font(DSTypography.font(DSTypography.Size.xs, weight: DSTypography.Weight.semibold))
                    .foregroundStyle(isSelected ? DSColor.brandPrimary : DSColor.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 16)
            .padding(.horizontal, 18)
            .background(isSelected ? DSColor.green50 : DSColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: DSRadius.lg, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: DSRadius.lg, style: .continuous)
                    .strokeBorder(isSelected ? DSColor.brandPrimary : DSColor.border, lineWidth: 1)
            }
        }
        .buttonStyle(DSPressStyle())
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}

#Preview {
    TripFilterView()
}
