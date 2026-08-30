//
//  RankerDetailViewModel.swift
//  Presentation
//

import Foundation
import Observation
import Domain
import UIComponents

@MainActor
@Observable
public final class RankerDetailViewModel {
    public private(set) var ranker: RankerDetail?
    public private(set) var isLoading = false
    public var errorMessage: String?

    private var hasLoaded = false

    private let userId: String
    private let fetchRankerDetailUseCase: FetchRankerDetailUseCase

    public init(userId: String, fetchRankerDetailUseCase: FetchRankerDetailUseCase) {
        self.userId = userId
        self.fetchRankerDetailUseCase = fetchRankerDetailUseCase
    }

    public func load() async {
        guard !hasLoaded, !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        do throws(NetworkError) {
            ranker = try await fetchRankerDetailUseCase.execute(userId: userId)
            hasLoaded = true
        } catch {
            errorMessage = L10n.loginNetworkError
        }
    }

    public func retry() async {
        errorMessage = nil
        await load()
    }

    /// 막대 높이는 그 달에 가장 많이 찍은 주를 기준으로 잡는다.
    public var busiestWeek: Int {
        ranker?.weeks.map(\.count).max() ?? 0
    }
}
