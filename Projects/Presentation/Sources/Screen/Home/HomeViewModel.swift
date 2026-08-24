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
    public private(set) var currentTrip: CurrentTrip?
    public private(set) var seasonalBadges: [Badge] = []
    public private(set) var growthRegions: [GrowthRegion] = []

    private let fetchCurrentTripUseCase: FetchCurrentTripUseCase
    private let fetchSeasonalBadgesUseCase: FetchSeasonalBadgesUseCase
    private let fetchGrowthRegionsUseCase: FetchGrowthRegionsUseCase
    private let cancelMatchUseCase: CancelMatchUseCase

    public init(
        user: User,
        fetchCurrentTripUseCase: FetchCurrentTripUseCase,
        fetchSeasonalBadgesUseCase: FetchSeasonalBadgesUseCase,
        fetchGrowthRegionsUseCase: FetchGrowthRegionsUseCase,
        cancelMatchUseCase: CancelMatchUseCase
    ) {
        self.nicknameInitial = String(user.nickname.prefix(1))
        self.fetchCurrentTripUseCase = fetchCurrentTripUseCase
        self.fetchSeasonalBadgesUseCase = fetchSeasonalBadgesUseCase
        self.fetchGrowthRegionsUseCase = fetchGrowthRegionsUseCase
        self.cancelMatchUseCase = cancelMatchUseCase
    }

    /// 세 섹션을 동시에 불러온다. 한 섹션이 실패해도 다른 섹션은 보여준다 —
    /// 대시보드 성격상 부분 실패로 화면 전체를 막을 이유가 없다.
    public func load() async {
        isLoading = true

        async let trip = Self.loadTrip(fetchCurrentTripUseCase)
        async let badges = Self.loadSeasonalBadges(fetchSeasonalBadgesUseCase)
        async let regions = Self.loadGrowthRegions(fetchGrowthRegionsUseCase)

        currentTrip = await trip
        seasonalBadges = await badges
        growthRegions = await regions
        isLoading = false
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
        }
    }
}
