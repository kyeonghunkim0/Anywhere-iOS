//
//  BlockedUsersViewModel.swift
//  Presentation
//

import Foundation
import Observation
import Domain
import UIComponents

@MainActor
@Observable
public final class BlockedUsersViewModel {
    public private(set) var blockedUsers: [BlockedUser] = []
    public private(set) var isLoading = false
    /// 해제 중인 유저 id. 행마다 개별로 버튼을 잠근다.
    public private(set) var unblockingUserID: String?
    public var errorMessage: String?

    private var hasLoaded = false

    private let fetchBlockedUsersUseCase: FetchBlockedUsersUseCase
    private let unblockUserUseCase: UnblockUserUseCase

    public init(fetchBlockedUsersUseCase: FetchBlockedUsersUseCase, unblockUserUseCase: UnblockUserUseCase) {
        self.fetchBlockedUsersUseCase = fetchBlockedUsersUseCase
        self.unblockUserUseCase = unblockUserUseCase
    }

    public func load() async {
        guard !hasLoaded, !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        do throws(NetworkError) {
            blockedUsers = try await fetchBlockedUsersUseCase.execute()
            hasLoaded = true
        } catch {
            errorMessage = L10n.loginNetworkError
        }
    }

    public func unblock(userId: String) async {
        guard unblockingUserID == nil else { return }
        unblockingUserID = userId
        defer { unblockingUserID = nil }

        do throws(UserError) {
            try await unblockUserUseCase.execute(userId: userId)
            blockedUsers.removeAll { $0.id == userId }
        } catch .rejected(let message) {
            errorMessage = message
        } catch {
            // sessionExpired/network/alreadyBlocked(해제 요청에는 나오지 않음) 전부 일반 안내로 처리한다.
            errorMessage = L10n.loginNetworkError
        }
    }
}
