//
//  PickedPlaceView.swift
//  Presentation
//
//  직접 고른 장소의 결과 창. 랜덤 매칭 결과(MatchResultView)와 달리 matchId가 없어
//  "여기로 결정"(confirm)을 못 탄다 — 체크인은 placeId만 받으므로 도착 인증으로 바로 넘긴다.
//  좌표도 없어(TaggedPlace) 지도 히어로 대신 텍스트 히어로를 쓴다.
//

import SwiftUI
import Domain
import UIComponents

struct PickedPlaceView: View {
    private let place: TaggedPlace
    private let onBack: () -> Void
    private let onVerifyArrival: () -> Void

    init(
        place: TaggedPlace,
        onBack: @escaping () -> Void = {},
        onVerifyArrival: @escaping () -> Void = {}
    ) {
        self.place = place
        self.onBack = onBack
        self.onVerifyArrival = onVerifyArrival
    }

    var body: some View {
        VStack(spacing: 0) {
            BackBar(onBack: onBack)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    DSTag(L10n.pickedPlaceChip, tone: .info)

                    Text(place.name)
                        .font(DSTypography.font(DSTypography.Size.xl2, weight: DSTypography.Weight.extrabold))
                        .foregroundStyle(DSColor.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 12)

                    Text("\(place.sidoName) \(place.sigunguName)")
                        .font(DSTypography.font(DSTypography.Size.base, weight: DSTypography.Weight.semibold))
                        .foregroundStyle(DSColor.textSecondary)
                        .padding(.top, 6)

                    infoRow(label: L10n.pickedPlaceAddressLabel, value: place.address)
                        .padding(.top, 24)

                    if place.isDepopulated {
                        HStack(spacing: 8) {
                            DSIconView(.sprout, size: 16, color: DSColor.brandPrimary)
                            Text(L10n.matchResultDepopulatedBonus)
                                .font(DSTypography.font(DSTypography.Size.sm, weight: DSTypography.Weight.semibold))
                                .foregroundStyle(DSColor.brandPrimary)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(DSColor.green50)
                        .clipShape(RoundedRectangle(cornerRadius: DSRadius.lg, style: .continuous))
                        .padding(.top, 20)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, DSSpacing.s6)
                .padding(.top, 12)
            }
        }
        .background(Color.white)
        .toolbar(.hidden, for: .navigationBar)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            VStack(spacing: 10) {
                DSButton(L10n.homeVerifyArrival, variant: .primary, action: onVerifyArrival)
                DSButton(L10n.pickedPlacePickAgain, variant: .secondary, action: onBack)
            }
            .padding(.horizontal, DSSpacing.s6)
            .padding(.top, 16)
            .padding(.bottom, 32)
            .background(Color.white)
        }
    }

    private func infoRow(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(DSTypography.font(DSTypography.Size.xs, weight: DSTypography.Weight.semibold))
                .foregroundStyle(DSColor.textSecondary)
            Text(value)
                .font(DSTypography.font(DSTypography.Size.base, weight: DSTypography.Weight.bold))
                .foregroundStyle(DSColor.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 16)
        .padding(.horizontal, 18)
        .background(DSColor.surfaceSunken)
        .clipShape(RoundedRectangle(cornerRadius: DSRadius.lg, style: .continuous))
    }
}
