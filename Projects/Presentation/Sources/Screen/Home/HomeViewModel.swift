//
//  HomeViewModel.swift
//  Presentation
//

import Foundation
import Domain
import UIComponents

@MainActor
@Observable
public final class HomeViewModel {
    public let nicknameInitial: String
    public private(set) var isLoading = false
    public var errorMessage: String?
    /// 위치 권한이 거부돼 여정을 시작할 수 없는 상태. 설정으로 안내한다.
    public var locationPermissionDenied = false
    public private(set) var currentTrip: CurrentTrip?
    public private(set) var seasonalBadges: [Badge] = []
    public private(set) var growthRegions: [GrowthRegion] = []

    private let fetchCurrentTripUseCase: FetchCurrentTripUseCase
    private let fetchSeasonalBadgesUseCase: FetchSeasonalBadgesUseCase
    private let fetchGrowthRegionsUseCase: FetchGrowthRegionsUseCase
    private let cancelMatchUseCase: CancelMatchUseCase
    private let requestLocationPermissionUseCase: RequestLocationPermissionUseCase

    public init(
        user: User,
        fetchCurrentTripUseCase: FetchCurrentTripUseCase,
        fetchSeasonalBadgesUseCase: FetchSeasonalBadgesUseCase,
        fetchGrowthRegionsUseCase: FetchGrowthRegionsUseCase,
        cancelMatchUseCase: CancelMatchUseCase,
        requestLocationPermissionUseCase: RequestLocationPermissionUseCase
    ) {
        self.nicknameInitial = String(user.nickname.prefix(1))
        self.fetchCurrentTripUseCase = fetchCurrentTripUseCase
        self.fetchSeasonalBadgesUseCase = fetchSeasonalBadgesUseCase
        self.fetchGrowthRegionsUseCase = fetchGrowthRegionsUseCase
        self.cancelMatchUseCase = cancelMatchUseCase
        self.requestLocationPermissionUseCase = requestLocationPermissionUseCase
    }

    /// 여정을 시작해도 되는지 판정한다. 위치 권한은 여기서 확보한다 —
    /// 매칭 화면에 들어간 뒤에 물으면 다트가 날아가는 도중에 다이얼로그가 뜬다.
    /// 거부 상태면 안내 문구를 채우고 false를 돌려준다.
    public func prepareTrip() async -> Bool {
        switch await requestLocationPermissionUseCase.execute() {
        case .authorized:
            return true
        case .denied, .restricted:
            locationPermissionDenied = true
            return false
        case .notDetermined:
            // 다이얼로그를 닫지 않고 화면을 벗어난 경우. 조용히 멈춘다.
            return false
        }
    }

    private var hasLoaded = false

    /// 화면 진입용. .task는 push/pop으로 홈이 다시 나타날 때마다 재실행되므로,
    /// 이미 채워진 화면을 위해 같은 세 번의 요청을 다시 보내지 않는다.
    public func load() async {
        guard !hasLoaded else { return }
        await reload()
    }

    /// 세 섹션을 동시에 불러온다. 한 섹션이 실패해도 다른 섹션은 보여준다 —
    /// 대시보드 성격상 부분 실패로 화면 전체를 막을 이유가 없다.
    public func reload() async {
        isLoading = true

        async let trip = Self.loadTrip(fetchCurrentTripUseCase)
        async let badges = Self.loadSeasonalBadges(fetchSeasonalBadgesUseCase)
        async let regions = Self.loadGrowthRegions(fetchGrowthRegionsUseCase)

        currentTrip = await trip
        seasonalBadges = await badges
        growthRegions = await regions
        isLoading = false
        hasLoaded = true
    }

    public func cancelTrip() {
        guard let currentTrip else { return }
        Task {
            do throws(MatchError) {
                try await cancelMatchUseCase.execute(matchId: currentTrip.matchId)
                self.currentTrip = nil
            } catch {
                errorMessage = Self.message(for: error)
            }
        }
    }

    private static func loadTrip(_ useCase: FetchCurrentTripUseCase) async -> CurrentTrip? {
        do throws(MatchError) {
            return try await useCase.execute()
        } catch {
            return nil
        }
    }

    private static func loadSeasonalBadges(_ useCase: FetchSeasonalBadgesUseCase) async -> [Badge] {
        do throws(NetworkError) {
            return try await useCase.execute()
        } catch {
            return []
        }
    }

    private static func loadGrowthRegions(_ useCase: FetchGrowthRegionsUseCase) async -> [GrowthRegion] {
        do throws(NetworkError) {
            return try await useCase.execute(limit: nil)
        } catch {
            return []
        }
    }

    private static func message(for error: MatchError) -> String {
        switch error {
        case .dailyLimitExceeded(let message), .notFound(let message), .rejected(let message):
            message
        case .network:
            L10n.loginNetworkError
        case .location(.authorizationDenied):
            L10n.locationPermissionDenied
        case .location(.unableToLocate):
            L10n.locationUnableToLocate
        }
    }
}
