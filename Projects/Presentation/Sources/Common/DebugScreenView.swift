//
//  DebugScreenView.swift
//  Presentation
//
//  ⚠️ 임시 확인용. 서버·소셜 로그인·목적지 반경 안 GPS가 모두 있어야 닿는 화면을
//  눈으로만 확인하기 위해, 가짜 응답으로 화면 하나만 띄운다.
//  실행 시 환경변수 DEBUG_SCREEN=arrival | review 로 고른다.
//  실제 흐름으로 확인할 수 있게 되면 이 파일과 AnywhereApp의 분기를 통째로 지운다.
//

#if DEBUG
import Foundation
import SwiftUI
import Domain

public struct DebugScreenView: View {
    public enum Screen: String {
        case arrival
        case review
    }

    private let screen: Screen

    /// 환경변수에 알아볼 수 있는 값이 없으면 nil — 호출부는 평소대로 RootView를 띄운다.
    public init?(rawValue: String?) {
        guard let rawValue, let screen = Screen(rawValue: rawValue) else { return nil }
        self.screen = screen
    }

    public var body: some View {
        switch screen {
        case .arrival:
            ArrivalVerificationView(viewModel: .debugStub)
        case .review:
            ReviewView(viewModel: .debugStub)
        }
    }
}

// MARK: - 가짜 응답

private let debugPlace = PlaceRef(id: "debug-place", name: "왕곡마을 옛집")

private struct StubLocationRepository: LocationRepository {
    func authorizationStatus() async -> LocationAuthorization { .authorized }
    func requestAuthorization() async -> LocationAuthorization { .authorized }
    func currentCoordinate() async throws(LocationError) -> Coordinate {
        Coordinate(latitude: 38.3, longitude: 128.4)
    }
}

private struct StubMissionRepository: MissionRepository {
    func checkIn(placeId: String, at coordinate: Coordinate) async throws(CheckInError) -> CheckInResult {
        // 로딩 상태도 눈으로 볼 수 있게 일부러 늦춘다.
        try? await Task.sleep(for: .seconds(3))
        return CheckInResult(
            message: "체크인 완료",
            stamp: StampResult(
                id: "debug-stamp",
                placeName: debugPlace.name,
                regionName: "강원특별자치도 고성군",
                isDepopulated: true,
                bonusMultiplier: 2,
                stampsEarned: 2,
                checkedInAt: Date(),
                totalStamps: 13,
                visitorNumber: 470,
                regionLevel: 3,
                regionLeveledUp: true
            ),
            newBadges: [
                EarnedBadge(id: "debug-badge", key: "night-star", name: "한밤의 별지기", icon: "sparkles")
            ]
        )
    }
}

private struct StubReviewRepository: ReviewRepository {
    func createReview(placeId: String, content: String) async throws(ReviewError) -> Review {
        Review(id: "debug-review", content: content, createdAt: Date(), placeId: placeId, placeName: debugPlace.name)
    }
    func fetchReviews(placeId: String, limit: Int?) async throws(NetworkError) -> [PlaceReview] { [] }
}

private extension ArrivalVerificationViewModel {
    static var debugStub: ArrivalVerificationViewModel {
        ArrivalVerificationViewModel(
            place: debugPlace,
            checkInUseCase: CheckInUseCase(
                locationRepository: StubLocationRepository(),
                missionRepository: StubMissionRepository()
            )
        )
    }
}

private extension ReviewViewModel {
    static var debugStub: ReviewViewModel {
        ReviewViewModel(
            place: debugPlace,
            createReviewUseCase: CreateReviewUseCase(reviewRepository: StubReviewRepository())
        )
    }
}
#endif
