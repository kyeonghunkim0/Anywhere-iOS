//
//  RouteDestinationView.swift
//  Presentation
//
//  Route를 실제 화면으로 바꾸는 유일한 지점. 새 화면을 만들면 여기 case만 채운다.
//

import SwiftUI
import Domain
import UIComponents

struct RouteDestinationView: View {
    let route: Route
    /// 화면이 필요로 하는 ViewModel은 여기서 만들지 않는다 — DI 컨테이너를 아는 쪽이 넘겨준다.
    let factory: ViewModelFactory

    @Environment(NavigationCoordinator.self) private var coordinator
    @Environment(TripPlanModel.self) private var plan

    var body: some View {
        switch route {
        case .tripFilter:
            TripFilterView(
                onBack: { coordinator.popViewController() },
                onStart: { range in
                    coordinator.pushViewController(.matching(radiusKm: range.radiusKm))
                },
                onPickMyself: { coordinator.pushViewController(.placeSearch) },
                onStartCustom: {
                    guard let picked = plan.pickedPlace else { return }
                    coordinator.pushViewController(
                        .placeDetail(placeId: picked.id, showsArrivalAction: true)
                    )
                }
            )

        case .matching(let radiusKm):
            MatchingView(
                viewModel: factory.matching(radiusKm),
                onBack: { coordinator.popViewController() },
                onMatched: { match in
                    coordinator.pushViewController(
                        .matchResult(match: match, radiusKm: radiusKm)
                    )
                }
            )

        case .matchResult(let match, let radiusKm):
            MatchResultView(
                viewModel: factory.matchResult(match, radiusKm),
                onClose: { coordinator.popToRootViewController() },
                onConfirmed: { coordinator.popToRootViewController() }
            )

        case .placeSearch:
            PlaceSearchView(
                viewModel: factory.placeSearch(),
                onBack: { coordinator.popViewController() },
                onDone: { coordinator.popViewController() }
            )

        case .placeDetail(let placeId, let showsArrivalAction):
            PlaceDetailView(
                viewModel: factory.placeDetail(placeId),
                onVerifyArrival: showsArrivalAction
                    ? { coordinator.pushViewController(.arrivalVerification(place: $0)) }
                    : nil,
                onBack: { coordinator.popViewController() }
            )

        case .arrivalVerification(let place):
            ArrivalVerificationView(
                viewModel: factory.arrivalVerification(place),
                onBack: { coordinator.popViewController() },
                onWriteReview: { coordinator.pushViewController(.review(place: place)) },
                onDone: { coordinator.popToRootViewController() }
            )

        case .review(let place):
            ReviewView(
                viewModel: factory.review(place),
                onBack: { coordinator.popViewController() },
                onSubmitted: { coordinator.popToRootViewController() }
            )

        case .passportDetail(let userId, let section):
            PassportDetailView(
                viewModel: factory.passport(userId),
                section: section,
                onBack: { coordinator.popViewController() }
            )

        case .regionDetail(let regionId):
            RegionDetailView(
                viewModel: factory.regionDetail(regionId),
                onBack: { coordinator.popViewController() }
            )

        case .rankerDetail(let userId, let rank):
            RankerDetailView(
                viewModel: factory.rankerDetail(userId),
                rank: rank,
                onBack: { coordinator.popViewController() }
            )

        case .terms:
            LegalDocumentView(document: .terms, onClose: { close() })

        case .privacy:
            LegalDocumentView(document: .privacy, onClose: { close() })

        case .profile:
            ProfileView(
                viewModel: factory.profile(),
                onEdit: { coordinator.pushViewController(.profileEdit(nickname: $0)) },
                onBack: { coordinator.popViewController() }
            )

        case .profileEdit(let nickname):
            ProfileEditView(
                viewModel: factory.profileEdit(nickname),
                onSaved: { coordinator.popViewController() },
                onBack: { coordinator.popViewController() }
            )

        // 아직 화면이 없는 Route는 자리표시자로 둔다 — 화면이 생기는 대로 이 case를 교체한다.
        case .ranking, .settings:
            placeholder
        }
    }

    /// 로그인 화면에서는 시트로, 설정에서는 푸시로 열린다 — 어느 쪽으로 떠 있든 닫는다.
    private func close() {
        if coordinator.sheet != nil || coordinator.fullScreenCover != nil {
            coordinator.dismiss()
        } else {
            coordinator.popViewController()
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
