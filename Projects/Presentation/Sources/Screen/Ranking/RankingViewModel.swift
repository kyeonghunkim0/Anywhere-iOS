//
//  RankingViewModel.swift
//  Presentation
//
//  두 세그먼트가 서로 다른 API를 쓴다. 한쪽이 실패해도 다른 쪽은 보여준다 —
//  랭킹은 부분만 보여도 쓸모가 있다.
//

import Foundation
import Observation
import Domain
import UIComponents

@MainActor
@Observable
public final class RankingViewModel {
    public private(set) var growthRegions: [GrowthRegion] = []
    public private(set) var rankers: [UserRankItem] = []
    public private(set) var myRank: MyRank?
    public private(set) var isLoading = false

    private var hasLoaded = false

    private let fetchGrowthRegionsUseCase: FetchGrowthRegionsUseCase
    private let fetchUserRankingUseCase: FetchUserRankingUseCase
    private let fetchMyRankUseCase: FetchMyRankUseCase

    public init(
        fetchGrowthRegionsUseCase: FetchGrowthRegionsUseCase,
        fetchUserRankingUseCase: FetchUserRankingUseCase,
        fetchMyRankUseCase: FetchMyRankUseCase
    ) {
        self.fetchGrowthRegionsUseCase = fetchGrowthRegionsUseCase
        self.fetchUserRankingUseCase = fetchUserRankingUseCase
        self.fetchMyRankUseCase = fetchMyRankUseCase
    }

    public func load() async {
        guard !hasLoaded, !isLoading else { return }
        isLoading = true

        async let regions = Self.load(growth: fetchGrowthRegionsUseCase)
        async let users = Self.load(users: fetchUserRankingUseCase)
        async let mine = Self.load(me: fetchMyRankUseCase)

        growthRegions = await regions
        rankers = await users
        myRank = await mine

        isLoading = false
        hasLoaded = true
    }

    private static func load(growth useCase: FetchGrowthRegionsUseCase) async -> [GrowthRegion] {
        do throws(NetworkError) {
            return try await useCase.execute(limit: nil)
        } catch {
            return []
        }
    }

    private static func load(users useCase: FetchUserRankingUseCase) async -> [UserRankItem] {
        do throws(NetworkError) {
            return try await useCase.execute()
        } catch {
            return []
        }
    }

    private static func load(me useCase: FetchMyRankUseCase) async -> MyRank? {
        do throws(NetworkError) {
            return try await useCase.execute()
        } catch {
            return nil
        }
    }
}
