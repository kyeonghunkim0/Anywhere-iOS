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
    public private(set) var isBlocking = false
    public private(set) var isBlocked = false
    public var errorMessage: String?

    private var hasLoaded = false

    private let userId: String
    private let fetchRankerDetailUseCase: FetchRankerDetailUseCase
    private let blockUserUseCase: BlockUserUseCase

    public init(
        userId: String,
        fetchRankerDetailUseCase: FetchRankerDetailUseCase,
        blockUserUseCase: BlockUserUseCase
    ) {
        self.userId = userId
        self.fetchRankerDetailUseCase = fetchRankerDetailUseCase
        self.blockUserUseCase = blockUserUseCase
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

    /// 이미 차단한 사용자를 다시 차단하면 서버가 409를 주는데, 화면 입장에서는
    /// 원하던 결과(차단됨)와 같아서 실패로 보여주지 않는다.
    public func blockUser() async {
        guard !isBlocking, !isBlocked else { return }
        isBlocking = true
        defer { isBlocking = false }

        do throws(UserError) {
            try await blockUserUseCase.execute(userId: userId)
            isBlocked = true
        } catch .alreadyBlocked {
            isBlocked = true
        } catch .rejected(let message) {
            errorMessage = message
        } catch {
            errorMessage = L10n.loginNetworkError
        }
    }
}
