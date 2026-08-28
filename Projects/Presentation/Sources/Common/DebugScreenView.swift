//
//  DebugScreenView.swift
//  Presentation
//
//  ⚠️ 임시 확인용. 서버·소셜 로그인·목적지 반경 안 GPS가 모두 있어야 닿는 화면을
//  눈으로만 확인하기 위해, 가짜 응답으로 화면 하나만 띄운다.
//  실행 시 환경변수 DEBUG_SCREEN=arrival | review | passport 로 고른다.
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
        case passport
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
        case .passport:
            PassportView(viewModel: .debugStub)
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

private struct StubPassportRepository: PassportRepository {
    func fetchPassport(userId: String) async throws(NetworkError) -> Passport {
        let visited: [(String, String, Int, Int)] = [
            ("충청남도", "부여군", 86, 6), ("경상북도", "영양군", 41, 20),
            ("경상남도", "남해군", 218, 34), ("전라남도", "구례군", 132, 47),
            ("전북특별자치도", "임실군", 57, 61), ("충청북도", "단양군", 304, 75),
            ("경상북도", "안동시", 12, 88), ("강원특별자치도", "고성군", 470, 102),
            ("전북특별자치도", "군산시", 91, 119),
        ]
        let unvisited: [(String, String)] = [
            ("강원특별자치도", "양양군"), ("경상북도", "경주시"), ("전라남도", "보성군"),
            ("충청남도", "청양군"), ("경상남도", "합천군"), ("전라남도", "곡성군"),
            ("강원특별자치도", "정선군"), ("충청북도", "괴산군"), ("경상북도", "청송군"),
            ("전북특별자치도", "장수군"), ("경상남도", "산청군"), ("충청남도", "서천군"),
        ]
        let regions =
            visited.enumerated().map { index, item in
                PassportRegion(
                    regionId: "debug-visited-\(index)",
                    sidoName: item.0,
                    sigunguName: item.1,
                    isDepopulated: true,
                    isVisited: true,
                    visitCount: 1,
                    lastVisitedAt: Date().addingTimeInterval(-Double(item.3) * 86_400),
                    level: 3,
                    visitorNumber: item.2
                )
            }
            + unvisited.enumerated().map { index, item in
                PassportRegion(
                    regionId: "debug-unvisited-\(index)",
                    sidoName: item.0,
                    sigunguName: item.1,
                    isDepopulated: false,
                    isVisited: false,
                    visitCount: 0,
                    lastVisitedAt: nil,
                    level: 1,
                    visitorNumber: nil
                )
            }

        return Passport(
            userId: userId,
            nickname: "로컬탐험가",
            totalStamps: 13,
            totalRegions: 228,
            visitedRegions: visited.count,
            completionRate: Double(visited.count) / 228 * 100,
            regions: regions
        )
    }
}

private struct StubBadgeRepository: BadgeRepository {
    func fetchMyBadges() async throws(NetworkError) -> [Badge] {
        [
            debugBadge(id: "b1", name: "첫 도장", icon: "star", status: .earned),
            debugBadge(id: "b2", name: "로컬 베이스볼", icon: "baseball", status: .available),
            debugBadge(id: "b3", name: "강태공의 계절", icon: "fish", status: .expired),
        ]
    }

    func fetchSeasonalBadges() async throws(NetworkError) -> [Badge] { [] }

    private func debugBadge(id: String, name: String, icon: String, status: BadgeStatus) -> Badge {
        Badge(
            id: id, key: id, name: name, description: "",
            icon: icon, type: .hidden, status: status,
            earnedAt: status == .earned ? Date() : nil,
            daysRemaining: nil, isLocationHidden: false,
            coordinate: nil, radiusM: nil, regionId: nil, placeId: nil
        )
    }
}

private extension PassportViewModel {
    static var debugStub: PassportViewModel {
        PassportViewModel(
            userId: "debug-user",
            fetchPassportUseCase: FetchPassportUseCase(passportRepository: StubPassportRepository()),
            fetchMyBadgesUseCase: FetchMyBadgesUseCase(badgeRepository: StubBadgeRepository())
        )
    }
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
