//
//  RegionDetailViewModel.swift
//  Presentation
//

import Foundation
import Observation
import Domain
import UIComponents

@MainActor
@Observable
public final class RegionDetailViewModel {
    public private(set) var region: RegionDetail?
    public private(set) var isLoading = false
    public var errorMessage: String?

    private var hasLoaded = false

    private let regionId: String
    private let fetchRegionDetailUseCase: FetchRegionDetailUseCase

    public init(regionId: String, fetchRegionDetailUseCase: FetchRegionDetailUseCase) {
        self.regionId = regionId
        self.fetchRegionDetailUseCase = fetchRegionDetailUseCase
    }

    public func load() async {
        guard !hasLoaded, !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        do throws(NetworkError) {
            region = try await fetchRegionDetailUseCase.execute(regionId: regionId)
            hasLoaded = true
        } catch {
            errorMessage = L10n.loginNetworkError
        }
    }

    public func retry() async {
        errorMessage = nil
        await load()
    }
}

public extension RegionDetail {
    /// 최고 레벨이면 서버가 target을 null로 준다 — 그때는 게이지를 가득 채운다.
    var progress: Double {
        guard let target, target > 0 else { return 100 }
        return min(max(Double(current) / Double(target) * 100, 0), 100)
    }
}

public extension RegionLevelRow {
    var icon: DSIcon { achieved ? .check : .lock }
}
